# shadowsocks-libev_manager
A bash Script to manager the shadowsocks-libev for multiport

Step 1 : Create a bash file in path
```
/usr/local/bin/shadowsocks-libev-autostart.sh
```
Copy the content to the file

```
#!/bin/bash

proc=/usr/local/bin/ss-server
config_dir=/etc/shadowsocks-libev
log_dir=/etc/shadowsocks-libev

arg=" -v "

config_files=()
files=$(ls ${config_dir}/config_*.json)

for f in ${files[@]}
do 
   fn=${f##*/}
   nohup $proc -c $f $arg  >> ${log_dir}/${fn%.*}.log 2>&1 &
done
```
Setp 2 : Modify file executable permissions

```
chmod 755 /usr/local/bin/shadowsocks-libev-autostart.sh
```
Setp 3 : Configure systemd self-startup
Create a service file in path
```
/etc/systemd/system/sslibev.service
```
Copy the content to the file
```
[Unit]
Description=Shadowsocks-ssserver
After=network.target

[Service]
Type=forking
TimeoutStartSec=3
ExecStart=/usr/local/bin/shadowsocks-libev-autostart.sh
Restart=always

[Install]
WantedBy=multi-user.target
```
Setp 4 : Register systemd self-startup
```
sudo systemctl enable /etc/systemd/system/sslibev.service
sudo systemctl start sslibev
```
Control command
```
sudo systemctl restart sslibev   # Restart sslibev service
sudo systemctl disable sslibev   # Disable sslibev self-startup
sudo rm /etc/systemd/system/sslibev.service   # Remove sslibev self-startup
systemctl status sslibev         # View the running status
ss -lnt   # View TCP port access status
```
