


import dns.resolver
import subprocess

class Txt_value():
    def __init__(self):
        pass
    def get_txt_value(self,dns_wan_server, txt_name):
        my_resolver=dns.resolver.Resolver()
        my_resolver.nameservers=[dns_wan_server]
        try:
            answer = my_resolver.query(txt_name, "TXT")
            for rdata in answer:
                for txt_string in rdata.strings:
                    txt_string_value = str(txt_string, encoding='utf-8')
                    
            return txt_string_value
        except Exception as e:
            print(e)
            return ""

    def put_txt_value(self, txt_name, txt_string_value, dns_lan_server="localhost"):
        try:
            args = [r"powershell.exe", r"c:\scripts\add_txt_type.ps1", txt_name, txt_string_value, dns_lan_server]
            p = subprocess.Popen(args, stdout=subprocess.PIPE)
            dt = p.stdout.read()
            return dt
        except Exception as e:
            print(e)
            return ""

    def del_txt_value(self, txt_name, dns_lan_server="localhost"):
        try:
            args = [r"powershell.exe", r"c:\scripts\del_txt_type.ps1", txt_name, dns_lan_server]
            p = subprocess.Popen(args, stdout=subprocess.PIPE)
            dt = p.stdout.read()
            return dt
        except Exception as e:
            print(e)
            return ""


if __name__ == "__main__":
    t = Txt_value()
    txt_string_value = t.get_txt_value("223.5.5.5", "_acme-challenge.drone.it.aixbx.cn")
    txt_string_value2 = t.get_txt_value("192.168.50.207", "_acme-challenge.drone.it.aixbx.cn")
    if txt_string_value != "" and txt_string_value != txt_string_value2:
        t.del_txt_value("_acme-challenge.drone.it.aixbx.cn")
        t.put_txt_value("_acme-challenge.drone.it.aixbx.cn", txt_string_value)
    else:
        pass



