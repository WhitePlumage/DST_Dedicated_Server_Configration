#!/bin/sh
# launch of server Overworld

#Path Directory
name_folder="/home/steamuser/dst/bin"

#Command line
start_overworld="sudo sh start.sh"

#Start or Restart the server
screen -dr dst_server1 -X -S quit
cd ${name_folder}
screen -S dst1 ${start_overworld}
