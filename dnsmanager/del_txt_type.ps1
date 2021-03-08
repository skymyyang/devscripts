
function del_txt_type()
{

        param($myargs)
        $Aname = $myargs[0]
        $ARecord = Get-WmiObject -Namespace root\MicrosoftDNS -class MicrosoftDNS_TXTType | ? {$_.OwnerName -eq $Aname}
        if ($ARecord -eq $null){
        echo "The text record does not exist!"
        }
        else {
        echo "Start deleting text record"
        $ARecord.delete()  
        }
        
}

del_txt_type $args