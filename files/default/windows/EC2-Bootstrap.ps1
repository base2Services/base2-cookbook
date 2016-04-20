Param(
  [string]$RuntimeCookbook,
  [string]$OverrideRunList,
  [string]$ChefOverride = "C:\chef\override.json"
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

# Get Instance Details
$az = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/placement/availability-zone
$Region = $az.Substring(0,$az.Length-1)
$instanceId = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
$environment = Get-EC2InstanceTag -Tag Environment -InstanceID $instanceId -Region $Region
$environmenttype = Get-EC2InstanceTag -Tag EnvironmentType -InstanceID $instanceId -Region $Region
$role = Get-EC2InstanceTag -Tag Role -InstanceID $instanceId -Region $Region

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

#Run Chef
if($environment -and $role) {
  Write-Output "Invoking chef for $environment environment, $run_list role"
	Invoke-Chef -Environment $environment -EnvironmentType $environmenttype -RunList $run_list
} else {
	Write-Output "Failed to bootstrap $instanceId is missing Environment, Role or Name Tags"
	Exit 1
}
