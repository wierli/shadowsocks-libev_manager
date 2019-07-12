# shadowsocks-libev_manager
A bash Script to manager the shadowsocks-libev for multiport
Notice：Default encryption is aes-256-gcm and you can edit the bash file.

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
Setp 5 : Now you can clone the cp.sh file to your server and use it
```
git clone https://github.com/wierli/shadowsocks-libev_manager.git
cd shadowsocks-libev_manager
chmod 777 cp.sh
./cp.sh
```
UserInterface
Enjoy it~
```
---------------------------------------------------
|  This is manage shadowsocks-libev port program   |
---------------------------------------------------
1.Create a new port
2.Change a port
3.Change a port passwd
4.Find a port
5.Delete a port
6.Limit a port transfer
7.Unlimit a port transfer
Enter your choose:
```

Manual Control command
```
sudo systemctl restart sslibev   # Restart sslibev service
sudo systemctl disable sslibev   # Disable sslibev self-startup
sudo rm /etc/systemd/system/sslibev.service   # Remove sslibev self-startup
systemctl status sslibev         # View the running status
ss -lnt   # View TCP port access status
```
