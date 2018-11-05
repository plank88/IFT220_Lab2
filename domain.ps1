# Builds a new DC in a new Forest
# Assumption: new machine uses DHCP
# This is the first part
# Change from DHCP to static IP using the same IP
# Get the name of the network adapter
$nicname = Get-NetAdapter  | select -ExpandProperty "name"

# Get current IP Address, Prefix Length (subnet mask), and gateway
$ipaddress = Get-NetIPAddress -InterfaceAlias $nicname -AddressFamily IPv4 | select -ExpandProperty "IPAddress"
$prefixlength = Get-NetIPAddress -InterfaceAlias $nicname -AddressFamily IPv4 | select -ExpandProperty "PrefixLength"
$gateway = Get-NetIPConfiguration -InterfaceAlias $nicname | select -ExpandProperty "IPv4DefaultGateway" | select -ExpandProperty "NextHop"

# Set the current IP address as static
Remove-NetIPAddress -InterfaceAlias $nicname -AddressFamily IPv4 -Confirm:$false
Remove-NetRoute -InterfaceAlias $nicname -AddressFamily IPv4 -Confirm:$false
New-NetIPAddress -InterfaceAlias $nicname -IPAddress $ipaddress -AddressFamily IPv4 -PrefixLength $prefixlength -DefaultGateway $gateway

# Set the DNS address to ourselves
Set-DnsClientServerAddress -InterfaceAlias $nicname -ServerAddresses $ipaddress

# Make sure the timezone is set correctly
Get-TimeZone | select -ExpandProperty "DisplayName"
Write-Host -ForegroundColor yellow "Is that the correct timezone?"
$Readhost = Read-Host -Prompt ("y | n ")
    Switch ($ReadHost) 
     { 
       Y {Write-Host "Okay, time to move on."}
       N {Write-Host -ForegroundColor yellow "Use the GUI to set the timezone. Press Enter when the timezone is set."; Read-Host}
       Default {Write-Host -ForegroundColor yellow "Use the GUI to set the timezone. Press Enter when the timezone is set."; Read-Host}
     }

# Install the AD Services
Write-Host -ForegroundColor yellow "What's the domain name going to be?  It should be ad.<your ASU email prefix>.lan" 
$domainname = Read-Host -Prompt (" ")
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools | Out-Null
Install-ADDSForest -DomainName $domainname

# the machine will now reboot
