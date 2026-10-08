# 常用操作及相关配置

> 主线导航: [README](../README.md) · 上一篇 [新系统基础配置](./03-base-setup.md) · 下一篇 [其他用户级应用 (可选)](./05-optional-apps.md) · 最后核对 2026-10

本章介绍一些日常会用到的实用操作及相关配置技巧.

## 手动挂载文件系统

有时我们需要插拔 U 盘或者查看 Windows 系统下的文件 (如果还装了其他操作系统也同理). 这就需要手动挂载和卸载额外的文件系统.

Linux 下最基础的挂载和卸载命令是 `mount` 和 `umount`. 由于挂载和卸载文件系统是高危操作, 需要 root 权限, 这两个命令都需要 `sudo` 提权. 对于日常插拔 U 盘这类简单操作而言, 更推荐使用 `udisksctl`; 它针对日常使用的需求做了更进一步的封装, 并通过 `Polkit` 工具简化了提权操作, 无需 `sudo`, 甚至很多时候不需要输入密码. 更进一步地, 你可以将以下代码追加到 `~/.bashrc` (也许需要针对你的设备修改代码中的某些路径, 推荐请教 AI):

```bash
# ~/.bashrc
# 添加到末尾
mntd() {
  [ "$#" -eq 1 ] || return 2
  local part="/dev/$1"
  udisksctl mount -b "$part" || return
  if [ ! -e "$HOME/mnt" ]; then
    ln -sfn "/media/$USER/" "$HOME/mnt"
  fi
}
_mntd_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(lsblk -rn -o NAME -Q 'TYPE=="part" && ! MOUNTPOINTS')" -- "$cur"))
}
complete -F _mntd_complete mntd
umntd() {
  [ "$#" -eq 1 ] || return 2
  local part="/dev/$1"
  if [[ "$(pwd -P)" == "/media/$USER/"* ]]; then
    cd "$HOME"
  fi
  udisksctl unmount -b "$part" || return
  if [ -L "$HOME/mnt" ] &&
    [ "$(readlink "$HOME/mnt")" = "/media/$USER/" ] &&
    [ -z "$(ls -A "$HOME/mnt" 2>/dev/null)" ]; then
    if [[ "$PWD" = "$HOME/mnt" ]]; then
      cd "$HOME"
    fi
    unlink "$HOME/mnt"
  fi
}
_umntd_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(lsblk -rn -o NAME -Q 'TYPE=="part" && MOUNTPOINTS && MOUNTPOINTS!="/boot/efi"')" -- "$cur"))
}
complete -F _umntd_complete umntd
pfd() {
  [ "$#" -eq 1 ] || return 2
  local disk="/dev/$1"
  udisksctl power-off -b "$disk"
}
_pfd_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$(lsblk -rn -o NAME -Q 'TYPE=="disk" && RM==1')" -- "$cur"))
}
complete -F _pfd_complete pfd
```

这样一来, 就可以通过命令 `mntd <磁盘分区名>` 和 `umntd <磁盘分区名>` 来挂载和卸载相应的磁盘分区, 并将挂载好的目录软链接至家目录下方便访问. 在拔出 U 盘前, 先 `umntd <磁盘分区名>` 卸载其名下的磁盘分区再运行 `pfd <移动磁盘名>` 给 U 盘断电, 即可安全拔出.

如果不喜欢用命令行, 可尝试使用图形化磁盘管理工具, 比如 GNOME 桌面环境默认的 gnome-disk-utility.

## ssh 连接远程

可通过 `ssh-keygen -t ed25519` 生成 ssh 密钥对, 默认存放在 `~/.ssh` 目录. 生成密钥后的可选步骤是 `ssh-keygen -p` 给私钥修改口令, 选中刚生成的密钥文件先输入旧口令 (刚生成的明文密钥无口令, 即口令为空) 再两次输入新口令. 需要连接不止一个远程的情况下, 推荐针对每个远程生成一对专用密钥而不是共用同一对. 至于如何把公钥部署到远程服务器, 各家要求可能不完全相同 (常见做法是 `ssh-copy-id`, 或者把公钥内容追加到远程的 `~/.ssh/authorized_keys`), 这里不做展开, 请以服务器方提供的说明为准. ssh 配置文件在 `~/.ssh/config`, 常用选项如下:

```ini
# ~/.ssh/config
Host <远程别名>
    Hostname <远程域名>
    User <远程用户名>
    IdentityFile ~/.ssh/<私钥文件名>
# 启用 ControlMaster
    ControlMaster auto
    ControlPath ~/.ssh/control:%h:%p:%r
    ControlPersist 10m
```

设置好之后, 命令行 `ssh <远程别名>` 即会使用选定的密钥以指定的用户名连接位于给定域名的远程服务器. ControlMaster 的作用是 ssh 连接成功时自动在 `ControlPath` 处生成一个 socket 文件后台维系和远程的 ssh 连接, 并且该 socket 文件在所有与该远程的活跃会话都结束后仍继续存在 `ControlPersist` (这里设置为 10 分钟) 的时间, 随后被自动删除. 在该 socket 文件存在期间, 任何 ssh 到该远程的新会话都无需重新验证身份, 可以直接复用已有的连接.

针对在远程集群上修改代码和传递数据的需求, 推荐使用 sshfs 工具. 它可以把远程服务器上的文件夹挂载到本地目录上, 让你像处理本地文件一样处理远程文件. 可以考虑在 `~/.bashrc` 中设置类似如下的别名命令:

```bash
# ~/.bashrc
# 添加到末尾
alias ssf='mkdir ~/ssh-remote && sshfs <远程用户名>@<远程别名>:<远程目录名> ~/ssh-remote && cd ~/ssh-remote'
alias ussf='cd ~ && fusermount3 -u ~/ssh-remote && rmdir ~/ssh-remote'
```

这样就可以通过命令行 `ssf` 创建目录 `~/ssh-remote` 并将远程目录挂载到该目录, 并通过命令行 `ussf` 卸载远程挂载并删除该目录.

## 启用 `/swapfile` 交换空间

交换空间也可以叫做虚拟内存, 就是划分出一部分硬盘空间暂存不活跃的内存数据, 从而确保宝贵的真内存空间都用在刀刃上, 提升响应速度; 还有一个功能是休眠 (hibernate, 把内存数据写进交换空间后断电), 下次开机可以直接恢复上一次的会话 (注意别和挂起/睡眠 suspend 混淆, 后者只把数据留在内存里, 不需要交换空间). 不过, 按照本文档提供的轻量配置, 内存占用其实非常小, 正常使用一般连 4G 都用不到, 现代电脑标配的 16G 内存都显得很空旷; 而且冷开机速度也很快 (秒级), 导致休眠功能也显得很鸡肋. 因此, 不设置交换空间其实也基本不影响使用.

如需启用交换空间, 可依序在命令行执行:

```bash
sudo fallocate -l 16G /swapfile # 创建大小为16G (可按需调整大小, 注意确保根分区空间充足) 的 /swapfile 文件
sudo chmod 600 /swapfile        # 设置为仅 root 可读写以确保安全
sudo mkswap /swapfile           # 文件系统类型设为 swap
sudo swapon /swapfile           # 启用 /swapfile 作为交换空间
```

这样启动的交换空间只在本次登录会话生效, 重启需再次 `sudo swapon /swapfile` 才能再次启用交换空间. 如果需要开机默认启用交换空间, 需在 `/etc/fstab` 末尾追加一行设置

```ini
# /etc/fstab
# 添加到末尾
/swapfile none swap defaults 0 0
```

这种设置非常灵活, 我们可以随时启用 (`swapon`) 或关闭 (`swapoff`) 交换空间, 以及把旧的 `/swapfile` 删掉再创建一个新的以修改交换空间大小 (当然, 不能删除正在使用的交换空间文件, 需要先 `swapoff`). 如需额外设置, 比如使用交换空间的积极程度, 可以在 `/etc/sysctl.d/99-swappiness.conf` 文件中修改 `vm.swappiness` 参数 (默认为 60, 越大越积极使用交换空间).

## GRUB 主题美化

默认的 GRUB 引导菜单比较丑. 推荐访问 [gnome-look.org](https://www.gnome-look.org) 网站, 找到 `GRUB Themes` 一栏, 从中选取自己喜欢的主题 (人气最高的经典选择是 Vimix), 按网页右侧栏提示下载和启用即可. 大致分三步: 先把下载好的主题压缩包解压并移动到 `/boot/grub/themes/`, 然后修改 `/etc/default/grub` 配置文件, 最后命令行 `sudo update-grub` 读取配置文件更新设置. 这三步都需要 `sudo` 提权.

## 登录界面设置

Xfce 桌面自带的登录管理器是 LightDM, 登录界面由 lightdm-gtk-greeter 管理. 可通过配置文件 `/etc/lightdm/lightdm.conf` 的 greeter-hide-users 参数改变默认不提供用户名的行为, 以及通过配置文件 `/etc/lightdm/lightdm-gtk-greeter.conf` 的 background 和 user-background 选项自定义登录界面背景图片. 这里有一个坑是权限问题: 系统用户 `lightdm` 可能会因为权限不足读取不了一些路径的文件导致设置无效. 比如说, 可以尝试运行 `ls -ld ~` 检查家目录权限; 如果是 700, 则 `lightdm` (也包括其他系统用户) 读取不了家目录中的任何内容. 推荐 `chmod 711 ~` 添加家目录执行权限从而允许其他用户进入.

## 蓝牙

可以通过系统默认自带的 bluetoothctl 命令行工具连接蓝牙设备. 如果想要图形化界面管理蓝牙, 可以尝试安装 blueman.

以 bluetoothctl 为例. 命令行 `bluetoothctl` 并回车后进入交互界面, 通过 `scan on` 发现新设备, 找到想要连接的设备后 `scan off` 关闭扫描, 复制该设备 MAC 地址, `pair <MAC 地址>` 即可与该设备配对, 然后应该就可以自动连接. 通过 `devices` 命令可查看所有已配对设备信息. 如果配对了没有自动连接, 可能需要先 `trust <MAC 地址>` 信任该设备 (很多设备不需要信任, 只要配对也可以直接连). 如需手动连接, 可使用命令 `connect <MAC 地址>`.

## 音量调节

Linux 的音量调节功能比较精细和复杂; 说实话, 我个人认为这里的设计确实不好用. 系统默认自带两套工具: ALSA 层面的 amixer (命令行工具) 和 alsamixer (终端图形化界面), 以及 PulseAudio 层面的 pactl (命令行工具) 和 pavucontrol (真图形化界面). ALSA 相对简单和底层, 可以直接控制声卡行为; PulseAudio 更复杂和高级, 接近用户端, 比如它可以通过调控应用发给声卡的信号大小 (称为信宿输入 sink input) 而不是声卡本身的增益 (称为信宿音量 sink volume) 来控制音量, 这是 ALSA 做不到的.

需要调节音量时, 更推荐通过 PulseAudio 调控信宿输入而不是信宿音量, 保持信宿音量在 100% 以获得最佳音质和信噪比. 我在 `~/.local/bin/` 下创建了如下两个 bash 脚本用于控制音量, 然后通过 `设置 > 键盘 > 应用程序快捷键` 将其关联到想要的快捷键上. 这两个脚本都预设当前只有一个活跃音频流; 多于一个应用播放音频的情况下会只调节其中的一个音频流. 可按需改进.

```bash
#!/bin/bash
# ~/.local/bin/vol-down
exec &>/dev/null
idx=$(pactl list short sink-inputs | head -1 | awk '{print $1}')
[ -z "$idx" ] || pactl set-sink-input-volume "$idx" -5%
```

```bash
#!/bin/bash
# ~/.local/bin/vol-up
exec &>/dev/null
idx=$(pactl list short sink-inputs | head -1 | awk '{print $1}')
[ -z "$idx" ] || pactl set-sink-input-volume "$idx" +5%
```

静音则更简单. 如果声卡有名为 `Master` 的控件, 用 `amixer -q set Master toggle` 就行 (可先用 `amixer scontrols` 确认控件名: 有些机器上它叫 Speaker 或 PCM, 那时此 amixer 命令要做相应修改). 更省心的做法是继续走 PulseAudio, 这样不受声卡控件命名的影响:

```bash
#!/bin/bash
# ~/.local/bin/mute
exec &>/dev/null
pactl set-sink-mute @DEFAULT_SINK@ toggle
```

## 关机超时问题

Debian 系统的开关机都非常快. 不过, 存在一个偶发的可能影响使用体验的关机超时问题: 有时关机时会报错 "A stop job is running for User Manager for UID 1000", 然后卡在这里倒计时 90 秒再完成关机. 这是由于用户的某个后台进程拒绝响应关机时 systemd 给出的中止信号 (SIGTERM), systemd 在此时会默认等这个进程 90 秒, 如果它还不自行中止才会强行杀死这个进程以完成关机. 放着不管也没事, 但是如果不想等这么久, 最简单的办法是修改配置文件 `/etc/systemd/user.conf`, 将变量 DefaultTimeoutStopSec 从默认的 90s 改成 10s 或者其他想要的时间, 然后下次重启生效或者 `sudo systemctl daemon-reload` 立即生效.
