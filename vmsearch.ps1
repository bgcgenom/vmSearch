# Connect to all dHCI ESXi hosts for VM host discovery.
# Patrick Benoit
# DOB: 06/27/24
#
# --- Requirements --
# Powershell
# PowerCLI
#
# -- Object List ---
# $Password - host password used to authenticate to hosts
# $securePassword = password decryption for use in connection command
# $HostList - contains all ESXi hosts
# $ESXiHost - temporary object for iterating $HostList
# $hostCount - number of hosts connected to
# $searchVM - VM to search for per user input
# foundVM - object for VM and parent host
#
# --- Future modifications ---
# Need to add event trapping for invalid login or host unavailable
# Need to validate connection before showing count
#

# Define ESXi Hosts
$HostList = @(
    'add'
    'ESXi'
    'host'
    'FQDN'
    'here'
)

# Ask user for root password to hosts. Ensure the password is obfuscated
$Password = Read-Host -Prompt "ESXi Host Password" -AsSecureString
$securePassword = [RUntime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

# Zero host count
$hostCount = 0

# Iterate $HostList and login
    # Need to add event trapping for invalid login or host unavailable
foreach ($ESXiHost in $HostList) {
    write-host "Attempting to connect to:" $ESXiHost
    Connect-VIServer $ESXiHost -User root -Password $securePassword #-ErrorAction SilentlyContinue
    write-host `n
    $hostCount = $hostCount + 1
}

# Display hosts connected with count
    # Need to validate connection before showing count
write-host "Successfuly connected to" $hostCount "hosts."

# Define object for VMs and Hosts
$foundVM = @()

# Loop the search untill exit is typed
do {
    # Ask what VM you are looking for and exit when prompted
    $searchVM = Read-Host "Enter VM name to search for or exit"
    $foundVM = get-vm | select Name,VMHost | where {($_.Name -match "$searchVM")}
    $foundVM
    # Exit search
} while ($searchVM -ne "exit")

# Disconnect from the hosts cleanly
Write-Host "Disconnecting hosts"
Disconnect-VIServer -Server * -Confirm:$false
Write-Host "Goodbye"
