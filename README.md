# 配置饥荒联机版（DST）的专用服务器（Linux 版)

> 参考的文档
> 
> [V 社的 SteamCMD 文档](https://developer.valvesoftware.com/wiki/SteamCMD:zh-cn)
> 
> http://blog.ttionya.com/article-1233.html
> 
> http://blog.ttionya.com/article-1235.html
> 
> [Klei 论坛的教程](https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/)

> 这里服务器的配置（cluster.ini 等）是我个人的服务器，保存在 [Scripts](https://github.com/WhitePlumage/DST_Dedicated_Server_Configration/tree/master/Scripts) 里，根据需要更改。
> 
> 务必一次成功，最后跑不起来就 `userdel -fr steamuser` 再 `reboot` 一遍。
> 
> 搞懂了每条命令具体干什么之后可以参照[只有命令的脚本](https://github.com/WhitePlumage/DST_Dedicated_Server_Configration/blob/master/Scripts/%E8%A7%A3%E5%86%B3%E5%A5%BD%E4%BE%9D%E8%B5%96%E4%B9%8B%E5%90%8E%E7%9A%84%E5%91%BD%E4%BB%A4.sh) (不能当真的脚本用的)，拷到文本编辑器里复制命令更加方便。
> 
> 顺带一提，不管是 `ls` 还是 `tree` 在后面加 `-a` 就可以看见隐藏文件（夹）了

配置过程总的来说，就是在 Linux 上安装 SteamCMD，通过 SteamCMD 安装饥荒专用服务器，并写好（放入）配置文件。文件的结构可以参考本地存档。

这里的操作都基于 Debian 及其发行版 (Ubuntu)。

## 处理依赖库

首先处理依赖库以保证安装的顺利。如果你碰到了什么问题，多半是运行库的锅。注意 Steam 需要的所有库**都是 *i386*** 而不是 *amd64* 版的。

按照 [Klei 推荐的教程](https://forums.kleientertainment.com/forums/topic/64441-dedicated-server-quick-setup-guide-linux/)，需要的库有libstdc++6，libgcc1，libcurl4-gnutls-dev

```
# For a 64-bit machine:
sudo apt-get install libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386
 
# For a 32-bit machine:
sudo apt-get install libstdc++6 libgcc1 libcurl4-gnutls-dev
```
但是一般 apt-get 都会提示找不到包。。可以把 `libgcc1:i386` 换成 `lib32gcc1`、`libstdc++6:i386` 换成 `lib32stdc++6` 试试。最后成功与否是运行[这里的命令](./README.md#%E5%86%99%E4%B8%80%E4%B8%AA%E5%90%AF%E5%8A%A8%E8%84%9A%E6%9C%AC)根据报错[处理](http://blog.ttionya.com/article-1233.html)，无报错就成功了。

然后 **curl 是万恶之源**，不要一开始就 `agt-get install curl`，这些命令一个个试。。总会成功的。。

```
dpkg --add-architecture i386
apt-get update
apt-get install libcurl3-gnutls:i386
apt-get install libcurl4-gnutls-dev:i386    # libcurl4 依赖 libcurl3
apt-get install libcurl4-gnutls:i386
```

## 安装 SteamCMD

> [用户操作参考](https://www.runoob.com/linux/linux-user-manage.html)
> 
> sudo 权限参考：
> https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04
> https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos
> 
> **必须用 visudo** (实际上可能启动的是 nano 而不是 vi)

首先以 root 登录。添加一个用户 steamuser，并授予 sudo 权限

```
useradd -m steamuser && usermod -aG sudo steamuser
passwd steamuser
```

还是以 root 身份进行下列操作
1. 进入 steamuser 的主目录，新建一个 Steam 目录用来解压 SteamCMD 的安装包（SteamCMD 安装完会生成一个 Steam 文件夹，所以不如干脆使用 Steam 解压安装包）
2. 下载 SteamCMD 安装包并解压
3. 切换到 steamuser（注意**涉及到运行脚本均以 steamuser 身份运行**）
4. 运行 steamcmd 脚本 + 以匿名账户登录 SteamCMD + 设定安装目录为 /home/steamuser/**dst** + 安装饥荒专用服务器并校验文件（只需要在第一次下载时校验）+ 退出

```
mkdir /home/steamuser/Steam && cd /home/steamuser/Steam

curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
# curl 的依赖是饥荒服务器依赖的一部分，如果不想用 curl 可以用 wget
# wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && tar -zxvf steamcmd_linux.tar.gz && rm steamcmd_linux.tar.gz

su - steamuser
cd ~/Steam

sudo ./steamcmd.sh +login anonymous +force_install_dir /home/steamuser/dst +app_update 343050 validate +quit
```

安装完成后 /home/steamuser/ 下就有一个 dst 目录了，这是 SteamCMD 安装饥荒专用服务器的目录，对应本地的饥荒（DST）安装文件夹默认在 Windows 的 `X:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together` 中。

## 写一个启动脚本

先检查依赖是否**完全**处理好了

```
cd /home/steamuser/dst/bin
ldd dontstarve_dedicated_server_nullrenderer
./dontstarve_dedicated_server_nullrenderer
```

> 如果没有报错说明处理好了，因为启动脚本需要依赖 **`dontstarve_dedicated_server_nullrenderer`**，如果有其他报错，参考[这里](http://blog.ttionya.com/article-1233.html)，或搜索该库文件属于哪个包（e.g. [curl-gnutls.so.4 属于哪个包？](https://stackoverflow.com/questions/37012612/how-to-create-lib-curl-gnutls-so-4#comment67924043_39318677)）

写入启动脚本，这里**不管洞穴**只写主世界，保存为 start.sh（如果保存不了加 sudo）

```
sudo echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > start.sh
sudo sh start.sh
```

脚本会开始运行，待出现 Your Server Will Not Start 字样后，按 Ctrl+C 终止脚本进程。此时运行了一遍没有配置文件的服务器，在 /home/steamuser/ 下可以找到 .klei 目录。主要目录结构和本地存档（一般在 Windows 的 `文档\Klei` 下）大致相同，如下所示（tree -d 命令）。如果运行了洞穴的启动脚本还会有括号里的 Cave 目录。

```
.klei
 ├── Agreements
 │   └── DoNotStarveTogether
 └── DoNotStarveTogether
     ├── MyDediServer
     │   ├── Master
     │   │   ├── backup
     │   │   └── save
     │   └── (Cave)
     └── Cluster_1 …
```

然后退出 steamuser，再删除多余的 Cluster 目录

```
exit
rm -rf /home/steamuser/.klei/DoNotStarveTogether/Cluster_*
```

## 配置文件
需要的配置文件有
- cluster.ini (服务器存档配置，定义服务器名字、密码、pvp 等，可以在本地存档里找到）
- cluster_token.txt (自己的 token，下文讲如何获取）
- server.ini (服务器配置，一般不改)
- worldgenoverride.lua (世界配置，定义时间、季节、生物等，可以在本地存档里找到)
- dedicated_server_mods_setup.lua (需要下载哪些 mod，id 可以在 modoverrides.lua 里找)
- modoverrides.lua (mod 的配置，可以在本地存档的 Master 里找到)
[详细配置参考](http://blog.ttionya.com/article-1235.html)

```
/home/steamuser/.klei/DoNotStarveTogether/MyDediServer
├── cluster.ini
├── cluster_token.txt
├── (adminlist.txt)
├── (blocklist.txt)
├── (whitelist.txt)
│
└── **Master**
    ├── modoverrides.lua
    ├── server.ini
    ├── worldgenoverride.lua
    ├── 其他文件
    └── 其他文件夹

/home/steamuser/dst/mods
└── dedicated_server_mods_setup.lua
```

### 获取 server_token
![Step1](./image/Main.png)

![Step2](./image/Webpage1.png)

![Step3](./image/Webpage2.png)

![Step4](./image/Webpage3.png)

将得到的 token_key 复制到文本编辑器备用

### 放入文件

```
cd /home/steamuser/.klei/DoNotStarveTogether/MyDediServer
wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/cluster.ini
echo [保存的 token_key] > cluster_token.txt

cd Master
wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/worldgenoverride.lua
wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/modoverrides.lua

cd /home/steamuser/dst/mods
rm dedicated_server_mods_setup.lua*
wget https://raw.githubusercontent.com/WhitePlumage/DST_Dedicated_Server_Configration/master/Scripts/dedicated_server_mods_setup.lua
```
放完之后可以 `cd /home/steamuser/.klei/DoNotStarveTogether/MyDediServer && tree` 和 `cd /home/steamuser/dst/mods && ls` 确认一下

### 再运行一遍启动脚本
保证在**steamuser**下运行

这里我们用到 screen 命令会在 [screen](./README.md#screen) 部分有详细解释。

```
cd ~/dst/bin
screen -S dst1 sudo sh start.sh
```

在以 screen 运行了脚本后按 Ctrl+A 之后按一次 d，就可以退出 steamuser 了（不要用 exit，会退出窗口进程，直接输入 `su` 再输入 root 密码）

## 重启服务器

当出现通信问题，或需要更新 mod 时，都需要重启服务器。（一些 mod 需要服务器和客户端的版本相同，如果服务器端不更新将无法进入游戏）首先解释一下要用到的 screen 用法。

### screen

有时候我们远程运行一个任务，必须等待它执行完毕，在此期间不能关掉窗口或者断开连接，否则这个任务就会被杀掉，一切半途而废了。screen 是一个让用户可以以窗口的形式后台运行脚本的程序。通过 screen 我们可以断开连接而保持进程的运行。详细原理和更多用法可以参考：[IBM Developer](https://www.ibm.com/developerworks/cn/linux/l-cn-screen/)。screen 以 session（会话）和 window（窗口）运行 shell 进程，注意不同用户的会话也不同。例如 `screen sh start.sh` 是在 screen 中新建一个运行 start.sh 的窗口。 

screen 的会话有 3 种状态：连接状态 (Attached)、**断开状态 (Detached)**、停止状态 (Dead)。这里的 Detached 并不是进程运行终止了，而是和控制台断开，进入后台运行，当我们需要时我们可以连接上它并继续执行操作。我们使 start.sh 所启动的进程在 screen 中运行并 detach，即可灵活的管理饥荒服务器进程。

使用 screen 的方式有：

1. 直接在命令行键入 `screen` 命令。
   Screen 将创建一个执行 shell 的全屏**窗口**。你可以执行任意 shell 程序，就像在 ssh 窗口中那样。在该窗口中键入 exit 退出该窗口，如果这是该 screen 会话的唯一窗口，该 screen 会话退出，提示 **`[screen is terminating]`**，否则 screen 自动切换到前一个窗口。

2. 
   ```
   screen -S dst1 sudo sh start.sh
   ```
   这里 screen 运行一个名为 dst1 的会话，运行的内容是 `sudo sh start.sh`。


screen 后接的参数一般有

|              命令                    |                          说明                                |
| ------------------------------------ | ------------------------------------------------------------ |
| -c file                              | 使用配置文件 file，而不使用默认的 $HOME/.screenrc            |
| -d \| -D [pid.tty.host]              | 不开启新的 screen **会话**，而是断开（Detach）其他正在运行的 screen 会话 |
| -h num                               | 指定历史回滚缓冲区大小为 num 行                              |
| -list \| **-ls**                     | **列出现有 screen 会话，格式为 pid.tty.host**                |
| -d -m                                | 启动一个**开始就处于断开模式（Detached）的会话**             |
| **-r** sessionowner / [pid.tty.host] | **重新连接一个断开的会话**。多用户模式下连接到其他用户 screen 会话需要指定 sessionowner，需要 setuid-root 权限 |
| -S sessionname                       | **创建 screen 会话时为会话指定一个名字**                     |
| -v                                   | 显示 screen 版本信息                                         |
| -wipe [match]                        | 同 - list，但删掉那些无法连接的会话                          |

默认情况下，在 **screen 窗口中**，screen 接收按下 Ctrl + A (`^A`) 之后的命令，例如按下 Ctrl + A（此处不会有任何反应）后输入 `?`，会显示这里的所有可用命令。

这里可能用到的命令有：

- `^A ?`    查看帮助信息
- `^A d`    将当前窗口断开
- `^A c`    新建一个窗口
- `^A p/n`    上一个/下一个窗口
- `^A \`    退出当前窗口，也可以直接按 `^C`

### 重启服务器

在启动服务器的时候，我们就已经将 screen 窗口命名为 dst1 的话，进入该窗口 - 停止该窗口 (Ctrl + C)，然后重新运行脚本。如果没有命名为已知名字的窗口，用 `screen -ls` 查看窗口 pid，然后 `screen -r [pid]` 即可。

```
# su - steamuser
$ screen -r dst1
$ ^C
[screen is terminating]
$ cd dst/bin
screen -S dst1 sudo sh start.sh
```

运行后可以查看日志，或按 `Ctrl+A, d` detach 这个窗口。

方便起见，我们还可以写一个脚本 restart.sh 来完成上述过程：[restart.sh](https://github.com/WhitePlumage/DST_Dedicated_Server_Configration/blob/master/Scripts/restart.sh)（修改自[这里](https://steamcommunity.com/sharedfiles/filedetails/?id=590565473)）













