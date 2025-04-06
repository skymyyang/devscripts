# -*- coding: utf-8 -*-

import json
import os
import argparse
import yaml

try:
    import requests
except ImportError:
    import urllib2


class PlatformLogsAnalysis(object):
    def __init__(self):
        self.script = list()
        self.scriptDict = dict()

        self.hash_password = "1595ba243877f93a57a975473b8e267c59e2da32297aee334d895af099089348" # 集成平台密码

        self.logs = '/opt/ruijie/ruizhi/logs/install/Platform.Active.log' # 默认日志文件路径
        self.install_path = '/opt/ruijie/ruizhi/'
        self.default_ip = '127.0.0.1'
        self.default_port = 8082
        self.components_path = '/opt/ruijie/ruizhi/components'

    def platform_port(self):
        with open(os.path.join(self.install_path, 'application.yml'), 'r') as conf:
            config = yaml.safe_load(conf)
        port = config.get('server', {}).get('port')
        if not port:
            print("platform port value get failed, set default port")
            port = self.default_port
        return port

    def init_list(self):
        parser = argparse.ArgumentParser(description="Read a logs file and print its contents.")
        parser.add_argument('--logs', type=str, default=self.logs, help='Path to the logs file to read')
        args = parser.parse_args()
        filepath = args.logs
        absolute_path_os = os.path.abspath(filepath)

        if not os.path.isfile(absolute_path_os):
            print(f"Error: The file '{filepath}' does not exist.")
            return

        with open(absolute_path_os, 'r') as file:
            for line in file:
                if "waiting execute component is:" in line:
                    cmd_str = line.split("waiting execute component is:")[1]
                    cmd_list = cmd_str.split(",")
                    if cmd_list[0] in self.script:
                        self.script.remove(cmd_list[0])
                        del self.scriptDict[cmd_list[0]]
                    self.script.append(cmd_list[0])
                    self.scriptDict[cmd_list[0]] = cmd_list

    def get_token(self):
        platform_port = self.platform_port()
        platform_login_url = f'http://{self.default_ip}:{platform_port}/user/login'
        headers = {
            "Content-Type": "application/json",
        }
        data = {
            "account": "sysadmin",
            "password": self.hash_password
        }

        try:
            response = requests.post(platform_login_url, data=json.dumps(data), headers=headers)
            if response.status_code == 201 or response.status_code == 200:  # 根据API文档确认成功状态码
                created_data = response.json()
                try:
                    return created_data["result"]["token"], platform_port
                except KeyError:
                    return "", platform_port
            else:
                print("请求失败，状态码：{}".format(response.status_code))
                return False
        except Exception as e:
            data_json = json.dumps(data)
            req = urllib2.Request(platform_login_url, data_json.encode('utf-8'), headers=headers)
            response = urllib2.urlopen(req)
            if response.code == 200 or response.code == 201:
                created_data = json.loads(response.read())
                try:
                    return created_data["result"]["token"], platform_port
                except KeyError:
                    return "", platform_port
            else:
                print("请求失败，状态码：{}".format(response.code))
                return False

    def change_param(self, data):
        token, platform_port = self.get_token()
        if not token or token == "":
            print("请求 token 失败或登录失败, 请验证登录密码.")
            return False

        security_uri = f'http://{self.default_ip}:{platform_port}/platform/v1/api/security/content/explain'
        header = {
            'Content-Type': 'application/json',
            'RIIL_USER_TOKEN': token,
        }
        try:
            response = requests.post(security_uri, data=data, headers=header)
            if response.status_code == 201 or response.status_code == 200:  # 根据API文档确认成功状态码
                created_data = response.json()
                return created_data["result"]
            else:
                print("请求失败，状态码：{}".format(response.status_code))
                return False
        except Exception:
            req = urllib2.Request(url=security_uri, data=data, headers=header)
            response = urllib2.urlopen(req)
            if response.code == 200 or response.code == 201:
                created_data = json.loads(response.read())
                return created_data["result"]
            else:
                print("请求失败，状态码：{}".format(response.code))
                return False

    def write(self, file_path, text, param):
        file_name = file_path.split('/')[-1]
        name = file_name.split('.')[0] + ".sh"
        file = open(name, 'w')
        file.write(text)
        file.close()
        os.chmod(name, 0o777)
        name = "param_" + file_name.split('.')[0] + ".json"
        file = open(name, 'w')
        file.write(param)
        file.close()
        os.chmod(name, 0o777)

    def create_script(self, element):
        name = element[0]
        type = element[1].split(":")[1]
        param = element[2].split(":")[1].replace("\n", "")
        param = self.change_param(param)
        if not param:
            return False
        if "bash" in type:
            text = f"#!/bin/bash\nbash -x {name} '{param}'"
            self.write(name, text, param)
        elif "ansible-playbook" in type:
            text = f"#!/bin/bash\nansible-playbook {name} -e '{param}'  -v"
            self.write(name, text, param)

    def search(self, scr_num):
        strList = list()
        for sc in self.script:
            if scr_num in sc:
                strList.append(sc)
        if len(strList) == 1:
            self.create_script(self.scriptDict[strList[0]])
        elif len(strList) == 0:
            print("未找到指定的内容")
        else:
            self.print_list()

    def print_list(self):
        self.init_list()
        script = self.script
        i = len(self.components_path)
        sorted_data = sorted(script, key=lambda x: x.split('/')[-1])
        for index, ele in enumerate(sorted_data):
            parts = ele[i:].split('/')
            last_part = parts[-1]
            remaining_parts = '/'.join(parts[:-1])
            print(index, last_part, remaining_parts)
        num = input("输入编号或者名称: ")
        try:
            print("选择的是：" + sorted_data[int(num)])
            self.create_script(self.scriptDict[sorted_data[int(num)]])
        except ValueError:
            self.search(num)


if __name__ == '__main__':
    analyPlatform = PlatformLogsAnalysis()
    analyPlatform.print_list()
