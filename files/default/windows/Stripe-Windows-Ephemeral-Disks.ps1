#################################################
#  Detect the Ephemeral drives and stripe them
#################################################

$DriveLetterToAssign = 'Z'                           # Be sure to choose a drive letter that will not already be assigned

#################################################
#  Given a device (e.g. xvda), strip off "xvd" and convert the remainder to the appripriate SCSI ID
#################################################
function GetSCSI {
	Param([string]$device)

	$deviceSuffix = $device.substring(3)      # remove xvd prefix

  if ($deviceSuffix.length -eq 1) {
		$scsi = (([int][char] $deviceSuffix[0]) - 97)
	}
	else {
		$scsi = (([int][char] $deviceSuffix[0]) - 96) *  26 +  (([int][char] $deviceSuffix[1]) - 97)
	}

	return $scsi
}

#################################################
#  Main
#################################################

# From metadata read the device list and grab only the ephermals

$alldrives = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/block-device-mapping/).Content
$ephemerals = $alldrives.Split(10) | where-object {$_ -like 'ephemeral*'}

# Build a list of scsi ID's for the ephemerals

$scsiarray = @()
foreach ($ephemeral in $ephemerals) {
	$device = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/block-device-mapping/$ephemeral).Content
	$scsi = GetSCSI $device
	$scsiarray = $scsiarray + $scsi
}

# Convert the scsi ID's to OS drive numbers and set them up with diskpart

$diskarray = @()
foreach ($scsiid in $scsiarray) {
    $disk =  Get-WmiObject -Class Win32_DiskDrive | where-object {$_.SCSITargetId -eq $scsiid}
    $physicaldisk = Get-PhysicalDisk | where-object {$_.SerialNumber -eq $disk.SerialNumber}
    if ($physicaldisk -ne $null)
    {
        $diskarray += $physicaldisk
    }
}

echo $diskarray

# Build the stripe from the diskarray
if ($diskarray.count -gt 0)
{
	echo -FriendlyName "LUN-EPHEM" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks $diskarray
	New-VirtualDisk -FriendlyName "EphemDatastore" -StoragePoolFriendlyName "LUN-EPHEM" -UseMaximumSize -ResiliencySettingName Simple
	$disknumber = (Get-VirtualDisk -FriendlyName "EphemDatastore" | Get-Disk).Number
	Set-Disk -Number $disknumber -IsOffline $False
	Initialize-Disk -Number $disknumber
	New-Partition -DiskNumber $disknumber -UseMaximumSize -DriveLetter $DriveLetterToAssign
	Format-Volume -DriveLetter $DriveLetterToAssign -FileSystem NTFS -NewFileSystemLabel 'Data1' -Confirm:$false
}
