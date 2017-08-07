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

if (Test-Path $ChefOverride) {
	$overrideobject = Get-Content -Raw -Path $ChefOverride | ConvertFrom-Json
} else {
	$overrideobject = @{}
}

# Get Instance Details
$az = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/placement/availability-zone
$Region = $az.Substring(0,$az.Length-1)
$instanceId = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
$environment = Get-EC2InstanceTag -Tag Environment -InstanceID $instanceId -Region $Region
$environmenttype = Get-EC2InstanceTag -Tag EnvironmentType -InstanceID $instanceId -Region $Region
$role = Get-EC2InstanceTag -Tag Role -InstanceID $instanceId -Region $Region
$secrets = Get-EC2InstanceTag -Tag SSMParameters -InstanceID $instanceId -Region $Region

$base2override = @{}
$base2override["role"] = $role
$base2override["region"] = $Region
$base2override["az"] = $az
$base2override["environment"] = @{}
$base2override["environment"]["name"] = $environment
$base2override["environment"]["type"] = $environmenttype
$base2override["ec2"] = @{}
$base2override["ec2"]["instance-id"] = $instanceId

$overrideobject | Add-Member -type NoteProperty -name base2 -value $base2override -Force
$overrideobject | ConvertTo-Json | Out-File -encoding ASCII $ChefOverride

if($secrets -eq "true") {
  Write-Output "Executing get_ssm_parameters for environment $environment"
  cmd.exe /c "C:\opscode\chef\embedded\bin\ruby C:\base2\bin\get_ssm_parameters -r $Region -e $environment -o $ChefOverride"
}

if($RuntimeCookbook) {
  $run_list = "recipe['$RuntimeCookbook::$role']"
} else {
  $run_list = "recipe['$role']"
}

if($OverrideRunList) {
  $run_list = $OverrideRunList
}

Write-Output "Bootstrap process called..."
Write-Output "ChefOverride: $ChefOverride"
Write-Output "RuntimeCookbook: $RuntimeCookbook"
Write-Output "Role: $role"
Write-Output "Region: $Region"

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
