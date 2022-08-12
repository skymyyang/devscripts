# 查询
.\handle_dns.ps1 "SEARCH" "A" "dns_ceshia.ceshi" "aixbx.com"
.\handle_dns.ps1 "SEARCH" "AAAA" "dns_ceshiaaaa.ceshi" "aixbx.com"
.\handle_dns.ps1 "SEARCH" "CNAME" "dns_ceshicname.ceshi" "aixbx.com"
.\handle_dns.ps1 "SEARCH" "TXT" "dns_ceshitxt.ceshi" "aixbx.com"


-------------------------------------------------------------------------
# 新增
.\handle_dns.ps1 "ADD" "A" "dns_ceshia.ceshi" "aixbx.com" "192.168.50.101"
.\handle_dns.ps1 "ADD" "AAAA" "dns_ceshiaaaa.ceshi" "aixbx.com" "1030::C9B4:FF12:48AA:1A2B"
.\handle_dns.ps1 "ADD" "CNAME" "dns_ceshicname.ceshi" "aixbx.com" "camp.xxxx.com.w.kunluncan.com"
.\handle_dns.ps1 "ADD" "TXT" "dns_ceshitxt.ceshi" "aixbx.com" "202201170000001b7ql3yo44oh2pkzk3k8zuwlkk9o62mfs9wnk3drju8ou1v68f"


-------------------------------------------------------------------------
# 更新
.\handle_dns.ps1 "UPDATE" "A" "dns_ceshia.ceshi" "aixbx.com" "192.168.50.102"
.\handle_dns.ps1 "UPDATE" "AAAA" "dns_ceshiaaaa.ceshi" "aixbx.com" "1030::C9B4:FF12:48AA:1A3C"
.\handle_dns.ps1 "UPDATE" "CNAME" "dns_ceshicname.ceshi" "aixbx.com" "camp.xxxx.com.w.kunluncan.com.xx"
.\handle_dns.ps1 "UPDATE" "TXT" "dns_ceshitxt.ceshi" "aixbx.com" "202201170000001b7ql3yo44oh2pkzk3k8zuwlkk9o62mfs9wnk3drju8ou1v76b"


-------------------------------------------------------------------------
# 删除
.\handle_dns.ps1 "DEL" "A" "dns_ceshia.ceshi" "aixbx.com" "192.168.50.102"
.\handle_dns.ps1 "DEL" "AAAA" "dns_ceshiaaaa.ceshi" "aixbx.com" "1030::C9B4:FF12:48AA:1A3C"
.\handle_dns.ps1 "DEL" "CNAME" "dns_ceshicname.ceshi" "aixbx.com" "camp.xxxx.com.w.kunluncan.com.xx"
.\handle_dns.ps1 "DEL" "TXT" "dns_ceshitxt.ceshi" "aixbx.com" "202201170000001b7ql3yo44oh2pkzk3k8zuwlkk9o62mfs9wnk3drju8ou1v76b"