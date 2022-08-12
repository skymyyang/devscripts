function search_dns($dns_type, $dns_rr, $dns_domain_name){
	$Result = Get-DnsServerResourceRecord -ZoneName $dns_domain_name -RRType $dns_type -Name $dns_rr -Node
	if($Result){
		if($dns_type -eq "A"){
			return $Result.RecordData.IPv4Address.IPAddressToString
		}elseif($dns_type -eq "AAAA"){
			return $Result.RecordData.IPv6Address.IPAddressToString
		}elseif($dns_type -eq "CNAME"){
			return $Result.RecordData.HostNameAlias
		}elseif($dns_type -eq "TXT"){
			return $Result.RecordData.DescriptiveText
		}else{
			return "False"
		}
	}else{
		return "False"
	}
}

function add_dns($dns_type, $dns_rr, $dns_domain_name, $dns_value){
	$Result = "True"
	if($dns_type -eq "A"){
		$Result = Add-DnsServerResourceRecord -ZoneName $dns_domain_name -A -Name $dns_rr -AllowUpdateAny -IPv4Address $dns_value -TimeToLive 01:00:00 -AgeRecord
	}elseif($dns_type -eq "AAAA"){
		$Result = Add-DnsServerResourceRecord -ZoneName $dns_domain_name -AAAA -Name $dns_rr -AllowUpdateAny -IPv6Address $dns_value -TimeToLive "01:00:00" -AgeRecord
	}elseif($dns_type -eq "CNAME"){
		$Result = Add-DnsServerResourceRecord -ZoneName $dns_domain_name -Cname -Name $dns_rr -AllowUpdateAny -HostNameAlias $dns_value -TimeToLive "01:00:00"
	}elseif($dns_type -eq "TXT"){
		$Result = Add-DnsServerResourceRecord -ZoneName $dns_domain_name -Txt -Name $dns_rr -DescriptiveText $dns_value -TimeToLive "01:00:00"
	}else{
		$Result = "False"
	}
	if($Result -eq $null){
		return "suceess add dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
	}else{
		return "fail add dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
	}
}

function update_dns($dns_type, $dns_rr, $dns_domain_name, $dns_value){

	$OldObj = Get-DnsServerResourceRecord -ZoneName $dns_domain_name -RRType $dns_type -Name $dns_rr 
	$NewObj = $OldObj.Clone()
	if($dns_type -eq "A"){
		$NewObj.RecordData.IPv4Address = $dns_value
		$Result = Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $dns_domain_name -PassThru
		if($Result.RecordData.IPv4Address.IPAddressToString -eq $dns_value){
			return "suceess update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}else{
			return "fail update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}
	}elseif($dns_type -eq "AAAA"){
		$NewObj.RecordData.IPv6Address = $dns_value
		$Result = Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $dns_domain_name -PassThru
		if($Result.RecordData.IPv6Address.IPAddressToString -eq $dns_value){
			return "suceess update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}else{
			return "fail update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}
	}elseif($dns_type -eq "CNAME"){
		$NewObj.RecordData.HostNameAlias = $dns_value
		$Result = Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $dns_domain_name -PassThru
		if($Result.RecordData.HostNameAlias -eq $dns_value){
			return "suceess update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}else{
			return "fail update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}
	}elseif($dns_type -eq "TXT"){
		$NewObj.RecordData.DescriptiveText = $dns_value
		$Result = Set-DnsServerResourceRecord -NewInputObject $NewObj -OldInputObject $OldObj -ZoneName $dns_domain_name -PassThru
		if($Result.RecordData.DescriptiveText -eq $dns_value){
			return "suceess update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}else{
			return "fail update dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}
	}else{
		return "fail update, please check dns_type in list: A, AAAA, CNAME, TXT !"
	}
}

function delete_dns($dns_type, $dns_rr, $dns_domain_name, $dns_value){
	$Result = search_dns $dns_type $dns_rr $dns_domain_name
	if($Result -eq "False"){
		return "dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value is not exsits"
	}else{
		$Result = Remove-DnsServerResourceRecord -ZoneName $dns_domain_name -RRType $dns_type -Name $dns_rr -RecordData $dns_value -Force
		if($Result -eq $null){
			return "suceess delete dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}else{
			return "fail delete dns_type:$dns_type dns_rr:$dns_rr dns_domain_name:$dns_domain_name dns_value:$dns_value"
		}
	}
}

function handle_dns(){
	param($myargs)
	$handle_func = $myargs[0]
	$dns_type = $myargs[1]
	$dns_rr = $myargs[2]
	$dns_domain_name = $myargs[3]
	$dns_value = $myargs[4]
	
	if($handle_func -eq "SEARCH"){
		search_dns $dns_type $dns_rr $dns_domain_name
	}elseif($handle_func -eq "ADD"){
		add_dns $dns_type $dns_rr $dns_domain_name $dns_value
	}elseif($handle_func -eq "UPDATE"){
		update_dns $dns_type $dns_rr $dns_domain_name $dns_value
	}elseif($handle_func -eq "DEL"){
		delete_dns $dns_type $dns_rr $dns_domain_name $dns_value
	}else{
		return "fail handle, please check dns_type in list: A, AAAA, CNAME, TXT !"
	}
}

handle_dns $args