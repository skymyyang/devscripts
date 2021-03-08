## Kubernetes 需求

由于内网使用kubernetes服务, 通过cert-manager自动化申请SSL证书, 由于我们内网使用的是Windows Acitve Directory 作为DNS服务器, Kbuernetes主机的DNS服务器指向为内网DNS服务器, cert-manager通过DNS-01协议进行证书验证, 调用aliyun 的DNS web-hook实现自动化添加acme认证解析, 但是无法同步到内网DNS服务器上, 导致DNS解析验证失败.


此脚本通过Python与powershell结合, 使用相关指令, 获取到阿里云DNS服务器的TXT解析之后, 然后同步至本地DNS服务器, 需要结合Windows 计划任务进行使用. 可设置为每5-10分钟验证一次. 当下次cert-manager申请证书时,自动将解析添加到内网的Windows Acitve Directory DNS服务器当中. 验证成功后, 自动更新证书. 

## 安装包依赖

```
pip install dnspython
```

## 使用

将ps1的文件,存放在c盘 scritps目录下,  其他目录, 请自行修改源码.