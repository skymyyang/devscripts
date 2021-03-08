
function add_txt_type()
{

        param($myargs)
        $Aname = $myargs[0]
        $TXT = $myargs[1]
        $DnsServer = $myargs[2]
        $ARecord = Get-WmiObject -Namespace root\MicrosoftDNS -class MicrosoftDNS_TXTType | ? {$_.OwnerName -eq $Aname}
        if ($ARecord -eq $null){
        echo "The text record does not exist!"
        echo $myargs[0]
        $dns = [WMIClass]"ROOT\MicrosoftDNS:MicrosoftDNS_TXTType"
        $OwnerName=$myargs[0]
        $dns.CreateInstanceFromPropertyData($DnsServer, "aixbx.cn", $OwnerName, 1, 3600, $TXT)
        echo "Record added successfully!"

        }
        else {
        echo "Record already exists!"    
        }
        
}

add_txt_type $args