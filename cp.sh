#!/bin/bash
Json_path="/etc/shadowsocks-libev"
echo "---------------------------------------------------"
echo "|  This is manage shadowsocks-libev port program   |"
echo "---------------------------------------------------"

func_create(){
    echo "---------------------------------------------------"
    echo "Json file list"
    res=$(ls $Json_path)
    echo $res
    echo "---------------------------------------------------"
    echo "Now create a new port."
    read -p "Enter a new port:" Port
    read -p "Enter passwd for the port:" Passwd
    read -p "Limit the port transfer? Enter 1 or 0:" Limit
    echo "---------------------------------------------------"
    echo "It is that right?"
    read -p "Enter the answer in Y/N: " ANSWER
jsonfile_name=$Json_path"/config_"$Port".json"
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    #write a json file for port
    echo "{" > $jsonfile_name
    echo "    \"server\":\"0.0.0.0\"," >> $jsonfile_name
    echo "    \"server_port\":\"$Port\"," >> $jsonfile_name
    echo "    \"password\":\"$Passwd\"," >> $jsonfile_name
    echo "    \"timeout\":300," >> $jsonfile_name
    echo "    \"method\":\"aes-256-gcm\"," >> $jsonfile_name
    echo "    \"fast_open\":true," >> $jsonfile_name
    echo "    \"nameserver\":\"8.8.8.8\"," >> $jsonfile_name
    echo "    \"mode\":\"tcp_and_udp\"" >> $jsonfile_name
    echo "}" >> $jsonfile_name
    case "$Limit" in
     [0])
      sudo systemctl restart sslibev
      ;;
     [1])
      iptables -A OUTPUT -p tcp --sport $Port -m quota --quota 257698037760 -j ACCEPT
      iptables -A OUTPUT -p udp --sport $Port -m quota --quota 257698037760 -j ACCEPT
      iptables -A OUTPUT -p tcp --sport $Port -j DROP
      iptables -A OUTPUT -p udp --sport $Port -j DROP
      sudo systemctl restart sslibev
      ;;
     esac
     ;;
  [nN] | [nN][oO])
    exit
    ;;
esac
}

func_update(){
read -p "Enter the port you want to update:" update_port
cd $Json_path
res=`find -type f -name "*.json"|xargs grep "$update_port" -l 2 2>/dev/null`
[ -z "$res" ] && echo "Can not find the port" && exit
res1=${res%%:*}
res2=${res1#*/}
theportfilepath=$Json_path"/"$res2
echo "Found it."
read -p "Enter what port you want to change:" change_port
sed -i "s/${update_port}/${change_port}/g" ${theportfilepath}
sudo systemctl restart sslibev
echo "Changed."
}

func_changepasswd(){
read -p "Enter the port you want to update:" update_port
cd $Json_path
res3=`find -type f -name "*.json"|xargs grep "$update_port" -l 2 2>/dev/null`
[ -z "$res3" ] && echo "Can not find the port" && exit
res4=${res3%%:*}
res5=${res4#*/}
theportfilepath1=$Json_path"/"$res5
echo "Found it."
read -p "Enter old passwd:" old_passwd
if [ `grep -c "$old_passwd" $theportfilepath1` -eq '1' ]; then
    echo "Old passwd is right."
else
    echo "Old passwd is wrong."
    exit
fi
read -p "Enter new passwd:" change_passwd
sed -i "s/${old_passwd}/${change_passwd}/g" ${theportfilepath1}
sudo systemctl restart sslibev
echo "Changed."
}

func_findport(){
read -p "Enter the port you want to find:" update_port
cd $Json_path
find_res=`find -type f -name "*.json"|xargs grep "$update_port" -l 2 2>/dev/null`
[ -z "$find_res" ] && echo "Can not find the port" && exit
find_res1=${find_res%%:*}
find_res2=${find_res1#*/}
#echo $find_res1
#echo $find_res
find_theportfilepath=$Json_path"/"$find_res2
echo "Found it."
echo $find_theportfilepath
}

func_delete(){
read -p "Enter the port you want to delete:" delete_port
cd $Json_path
delete_res=`find -type f -name "*.json"|xargs grep "$delete_port" -l 2 2>/dev/null`
[ -z "$delete_res" ] && echo "Can not find the port" && exit
delete_res1=${delete_res%%:*}
delete_res2=${delete_res1#*/}
delete_theportfilepath=$Json_path"/"$delete_res2
echo "Found it."
rm -rf $delete_theportfilepath
rm -rf ${delete_theportfilepath%.*}.log
iptables -D OUTPUT -p tcp --sport $delete_port -m quota --quota 257698037760 -j ACCEPT
iptables -D OUTPUT -p udp --sport $delete_port -m quota --quota 257698037760 -j ACCEPT
iptables -D OUTPUT -p tcp --sport $delete_port -j DROP
iptables -D OUTPUT -p udp --sport $delete_port -j DROP
sleep 3s
sudo systemctl restart sslibev
echo "Deleted success."
}

func_limitport(){
read -p "Enter the port you want to limit:" limit_port
cd $Json_path
limit_res=`find -type f -name "*.json"|xargs grep "$limit_port" -l 2 2>/dev/null`
[ -z "$limit_res" ] && echo "Can not find the port" && exit
iptables -A OUTPUT -p tcp --sport $limit_port -m quota --quota 257698037760 -j ACCEPT
iptables -A OUTPUT -p udp --sport $limit_port -m quota --quota 257698037760 -j ACCEPT
iptables -A OUTPUT -p tcp --sport $limit_port -j DROP
iptables -A OUTPUT -p udp --sport $limit_port -j DROP
sudo systemctl restart sslibev
echo "limit the port ${limit_port} successed."
}

func_unlimitport(){
read -p "Enter the port you want to unlimit:" unlimit_port
cd $Json_path
unlimit_res=`find -type f -name "*.json"|xargs grep "$unlimit_port" -l 2 2>/dev/null`
[ -z "$unlimit_res" ] && echo "Can not find the port" && exit
iptables -D OUTPUT -p tcp --sport $unlimit_port -m quota --quota 257698037760 -j ACCEPT
iptables -D OUTPUT -p udp --sport $unlimit_port -m quota --quota 257698037760 -j ACCEPT
iptables -D OUTPUT -p tcp --sport $unlimit_port -j DROP
iptables -D OUTPUT -p udp --sport $unlimit_port -j DROP
sudo systemctl restart sslibev
echo "unlimit the port ${unlimit_port} successed."
}


func_init(){
echo "1.Create a new port"
echo "2.Change a port"
echo "3.Change a port passwd"
echo "4.Find a port"
echo "5.Delete a port"
echo "6.Limit a port transfer"
echo "7.Unlimit a port transfer"
read -p "Enter your choose: " ANSWER1
case "$ANSWER1" in
  [1])
    func_create;
    ;;
  [2])
    func_update;
    ;;
  [3])
    func_changepasswd;
    ;;
  [4])
    func_findport;
    ;;
  [5])
    func_delete;
    ;;
  [6])
    func_limitport;
    ;;
  [7])
    func_unlimitport;
    ;;
esac
}

# program init
func_init;
