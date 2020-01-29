# This script creates an inventory of PCs on your network

# Get list of PCs to inventory from text file
$computer = Get-Content c:\powershell\computers.txt

# Get inventory info: OS info, Processor, Device serial number, HD, RAM, IP Address
$Output = Foreach($C in $computer){
    $System = Get-WmiObject Win32_ComputerSystem -ComputerName $C -ErrorAction SilentlyContinue | Select-Object -Property Name,Model
    $BIOS = Get-WmiObject Win32_BIOS -ComputerName $C -ErrorAction SilentlyContinue | Select-Object -Property SerialNumber
	$OS = Get-WmiObject Win32_OperatingSystem -ComputerName $C -ErrorAction SilentlyContinue | Select-Object  -Property Caption, OSArchitecture, BuildNumber
	$Processor = Get-WmiObject Win32_Processor -ComputerName $C -ErrorAction SilentlyContinue | Select-Object -Property Name, NumberOfCores, NumberOfLogicalProcessors
	$HardDrive = Get-WmiObject Win32_LogicalDisk -ComputerName $C -ErrorAction SilentlyContinue -Filter "DeviceID = 'C:'" | Select-Object -Property DeviceID, VolumeName, @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},@{L="Capacity";E={"{0:N2}" -f ($_.Size/1GB)}}
	$PhysicalRAM = [Math]::Round((Get-WmiObject -Class win32_computersystem -ComputerName $C).TotalPhysicalMemory/1Gb)
	$IPAddress = ([System.Net.Dns]::GetHostByName($C).AddressList[0]).IpAddressToString
	[PSCustomObject]@{
		ComputerName = $C
		Name = $System.Name
		Model = $System.Model
        SerialNumber = $BIOS.SerialNumber
		OS = $OS.Caption
		OSArchitecture = $OS.OSArchitecture
		BuildNumber = $OS.BuildNumber
		ProcessorName = $Processor.Name
		NumberOfCores = $Processor.NumberOfCores
		NumberOfLogicalProcessors = $Processor.NumberOfLogicalProcessors
		DeviceID = $HardDrive.DeviceID
		VolumeName = $HardDrive.VolumeName
		FreeSpaceGB = $HardDrive.FreeSpaceGB
		HDCapacity = $HardDrive.Capacity
		InstalledMemory = $PhysicalRAM
		IPAddress = $IPAddress
		
	}
}
$Output

# Outputs formatted file as a csv
$Output |Export-Csv -Path c:\powershell\Result.csv -NoTypeInformation
