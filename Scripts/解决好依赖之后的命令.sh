useradd -m steamuser && usermod -aG sudo steamuser

passwd steamuser

mkdir /home/steamuser/Steam && cd /home/steamuser/Steam

curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

su - steamuser

cd ~/Steam

sudo ./steamcmd.sh +login anonymous +force_install_dir /home/steamuser/dst +app_update 343050 validate +quit

cd /home/steamuser/dst/bin

sudo echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > start.sh

sudo sh start.sh

(^C)

exit

rm -rf /home/steamuser/.klei/DoNotStarveTogether/Cluster_*

cd /home/steamuser/.klei/DoNotStarveTogether/MyDediServer

wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicate_Server_Configration/master/Scripts/cluster.ini

echo [保存的 token_key] > cluster_token.txt

cd Master

wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/worldgenoverride.lua

wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/modoverrides.lua

cd /home/steamuser/dst/mods

rm dedicated_server_mods_setup.lua*

wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/dedicated_server_mods_setup.lua

cd /home/steamuser/.klei/DoNotStarveTogether/MyDediServer && tree

cd /home/steamuser/dst/mods && ls

su - steamuser

cd ~/dst/bin

screen sudo sh start.sh
