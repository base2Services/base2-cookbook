Param(
  [string]$RuntimeCookbook,
  [string]$OverrideRunList,
  [string]$ChefOverride = "C:\chef\override.json",
  [string]$NetworkInterfaceId,
  [string[]]$VolumeIds
)

function Get-EC2InstanceTag {
  Param(
    [string][Parameter(Mandatory=$True)]$Tag,
    [string][Parameter(Mandatory=$True)]$InstanceID,
    [string][Parameter(Mandatory=$True)]$Region
  )

  $instanceId = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
  $instance = Get-EC2Instance -Region $Region -Filter @{Name = "instance-id"; Values = $instanceId} | select -ExpandProperty instances
  $t = $instance.Tags | Where-Object {$_.Key -eq $Tag}
  return $t.Value
}

function Invoke-Chef {
  Param(
    [string][Parameter(Mandatory=$True)]$Environment,
    [string][Parameter(Mandatory=$True)]$EnvironmentType,
    [string][Parameter(Mandatory=$True)]$RunList
  )

  $chef_args = "--local-mode -o $RunList"
  if (Test-Path $ChefOverride) {
    $chef_args = "$chef_args -j $ChefOverride"
  }

  if (Test-Path "C:\chef\environments\$EnvironmentType.json") {
    $chef_args = "$chef_args -E $EnvironmentType"
  }

  if (Test-Path "C:\chef\environments\$Environment.json") {
    $chef_args = "$chef_args -E $Environment"
  }

  Write-Output "running chef-client $chef_args"
  cmd.exe /c "C:\opscode\chef\bin\chef-client $chef_args"
}

function ConvertFrom-Base64toMemoryStream{
    param(
        [parameter(Mandatory)]
        [string]$Base64Input
    )
    [byte[]]$bytearray = [System.Convert]::FromBase64String($Base64Input)
    $stream = New-Object System.IO.MemoryStream($bytearray,0,$bytearray.Length)
    return $stream
}
function ConvertFrom-StreamToString{
    param(
        [parameter(Mandatory)]
        [System.IO.MemoryStream]$inputStream
    )
    $reader = New-Object System.IO.StreamReader($inputStream);
    $inputStream.Position = 0;
    return $reader.ReadToEnd()
}

function Get-Secrets{
  param(
    [string][Parameter(Mandatory=$True)]$KeyPrefix
  )

  $Secrets = Get-S3Object $secretsstore -Region $Region -KeyPrefix $KeyPrefix/
  $SecretsKey = (Get-S3Object $secretsstore -Region $Region -KeyPrefix $KeyPrefix/ -MaxKey 1).Key.split('/')[1]

  if ($Secrets) {
    Write-Output "Getting $KeyPrefix secrets"
    $obj = (ConvertFrom-Json '{}')
    foreach ($secret in $Secrets) {
      $array=$secret.Key.split('/')
      $tmpObj = $obj
      $s3GetFile = Read-S3Object -Region $Region -BucketName $secretsstore -Key $secret.Key -File temp.enc
      $DecryptedOutputStream = Invoke-KMSDecrypt -CiphertextBlob $(ConvertFrom-Base64toMemoryStream -Base64Input $(Get-Content temp.enc))
      $s3ObjectValue = ConvertFrom-StreamToString -inputStream $DecryptedOutputStream.Plaintext
      $folder = $array[($array.length -2)]

      # Start at index 1, skip selected element
      for ($i=1; $i -lt $array.length; $i++) {
        $newElement = $array[$i];
        if($i -eq ($array.length -1)){
          Write-Output "Saving secret: $folder $newElement"
          $tmpObj |  Add-Member -Type "NoteProperty"  -Name $newElement -Value ($s3ObjectValue) -ErrorAction SilentlyContinue
        }else {
          $tmpObj |  Add-Member -Type "NoteProperty"  -Name $newElement -Value (ConvertFrom-Json '{}') -ErrorAction SilentlyContinue
          $tmpObj = $tmpObj.$newElement
        }
      }
    }
    $overrideobject | Add-Member -type NoteProperty -name $SecretsKey -value $obj.$SecretsKey -Force
  } else {
    Write-Output "No $KeyPrefix secrets found"
  }
}

if (Test-Path $ChefOverride) {
	$overrideobject = Get-Content -Raw -Path $ChefOverride | ConvertFrom-Json
} else {
	$overrideobject = @{}
}

# Get Instance Details
$az = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/placement/availability-zone
$Region = $az.Substring(0,$az.Length-1)
$instanceId = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
$name = Get-EC2InstanceTag -Tag Name -InstanceID $instanceId -Region $Region
$environment = Get-EC2InstanceTag -Tag Environment -InstanceID $instanceId -Region $Region
$environmenttype = Get-EC2InstanceTag -Tag EnvironmentType -InstanceID $instanceId -Region $Region
$role = Get-EC2InstanceTag -Tag Role -InstanceID $instanceId -Region $Region
$SecretsStore = Get-EC2InstanceTag -Tag SecretsStore -InstanceID $instanceId -Region $Region

$base2override = @{}
$base2override["role"] = $role
$base2override["region"] = $Region
$base2override["az"] = $az
$base2override["environment"] = @{}
$base2override["environment"]["name"] = $environment
$base2override["environment"]["type"] = $environmenttype
$base2override["ec2"] = @{}
$base2override["ec2"]["instance-id"] = $instanceId
$base2override["ec2"]["name"] = $name

Write-Output "Bootstrap process called..."
Write-Output "ChefOverride: $ChefOverride"
Write-Output "RuntimeCookbook: $RuntimeCookbook"
Write-Output "Role: $role"
Write-Output "Region: $Region"

if ($SecretsStore) {
  Write-Output "Secrets Store: $SecretsStore"
  $EnvSecrets = Get-S3Object $secretsstore -Region $Region -KeyPrefix $environment/
  if ($EnvSecrets) {
    Write-Output "Environment specific secrets found"
    Get-Secrets -KeyPrefix $environment
  } else {
    Write-Output "No Environment specific secrets found"
    Get-Secrets -KeyPrefix default
  }
}

$overrideobject | Add-Member -type NoteProperty -name base2 -value $base2override -Force
$overrideobject | ConvertTo-Json -Depth 100 | Out-File -encoding ASCII $ChefOverride

if($RuntimeCookbook) {
  $run_list = "recipe['$RuntimeCookbook::$role']"
} else {
  $run_list = "recipe['$role']"
}

if($OverrideRunList) {
  $run_list = $OverrideRunList
}

#Attach Network Interface
if($NetworkInterfaceId) {
  Write-Output "Attaching Network Interface $NetworkInterfaceId"
  Add-EC2NetworkInterface -Region $Region -NetworkInterfaceId $NetworkInterfaceId -InstanceId $instanceId -DeviceIndex 1 -Force
}

#Attach EBS Volume
if($VolumeIds) {
  ForEach ( $volumeId in $VolumeIds ) {
    $volume = $volumeId.Split(":")
    Write-Output "Attaching EBS Volume $volume"
    Add-EC2Volume -Region $Region -InstanceId $instanceId  -VolumeId $volume[0] -Device $volume[1] -Force
  }
}

#Run Chef
if($environment -and $role) {
  Write-Output "Invoking chef for $environment environment, $run_list role"
	Invoke-Chef -Environment $environment -EnvironmentType $environmenttype -RunList $run_list
} else {
	Write-Output "Failed to bootstrap $instanceId is missing Environment, Role or Name Tags"
	Exit 1
}

