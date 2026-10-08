# 附录: 可能有用的信息 (含 AI 补充内容)

> 主线导航: [README](../README.md) · 上一篇 [常见坑与速查](./06-pitfalls.md) · 下一篇 — · 最后核对 2026-10

本附录收集额外的可能有用的信息, 其中包含 AI 补充内容. 后者一律用引用块 (`>`) 明确标出 AI 的贡献和作者核验情况, 请自行判断是否采用.

## Linux 参考资料

这里列举一些作者推荐的 Linux 参考资料:

- [Debian 官方安装手册 (trixie, amd64)](https://www.debian.org/releases/stable/installmanual): 有中英等语言的 HTML 与 PDF 版本, 例如[中文 PDF](https://www.debian.org/releases/stable/amd64/install.zh-cn.pdf). 装好系统之后也可以不时翻开看看, 是很好的学习资料
- *How Linux works: what every superuser should know*, Brian Ward: 介绍原理, 非常扎实, 不太好读. 各章节相对独立, 读不动了可以先跳到下一章
- *Linux pocket guide*, Daniel J. Barrett: 收录了很多常用的 bash 命令, 按用途分类, 实用小字典
- [ArchWiki](https://wiki.archlinux.org): 最权威, 最全面, 且最新的 Linux 参考资料, 没有之一. 有中文支持

## 向 Debian 发送安装报告

先用 `which reportbug` 命令确认 reportbug 已安装; 如果没有就用 apt 手动安装.

第一次使用前需先配置. 命令行执行 `reportbug --configure`, 使用默认的 novice 模式, 然后回答问题: 确认你有网络连接, 告知它你的名字和邮箱 (真实邮箱, 不然收不到回信且报告容易进 spam), 接着它会问你有没有 "mail transport agent" (MTA), 回答 `N` 没有, 最后会问 SMTP 和 网络代理, 两个问题都留空直接回车即可. 这样 reportbug 会自行将 SMTP 设为默认值 `reportbug.debian.org`, 即通过 Debian 官方的 SMTP 服务器发送你的报告.

配置好之后运行 `reportbug installation-reports`, 按提示回答问题, 它会自动帮你生成末尾附带安装日志里 `lsb-release`, `hardware-summary`, `firmware-summary` 三个文件的模板化报告并用默认文本编辑器打开, 再按提示勾选 Checklist 选项并填写你的 Comments/Problems, 保存并退出编辑, 然后确认提交就可以了. Debian 收到报告会自动回复到你的邮箱.

## 常用验证命令

> **以下命令由 AI (DeepSeek) 总结, 作者已逐条确认有效.**

- `apt list --installed | grep <包名>`, `dpkg -l <包名>`: 确认某个包是否装上, 前者还可以显示是手动装还是自动装上的
- `findmnt`, `lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS`: 查看挂载与分区情况
- `journalctl -b -p err`, `systemctl --user status`: 排查开机和会话级的报错
- `fc-list | grep -i <关键字>`: 确认字体是否已经被系统识别
- `timedatectl show`: 查看时区, 硬件时钟 (LocalRTC) 与 NTP 同步状态
- `which keyd`, `dpkg -L keyd | grep bin`: 确认 keyd 的可执行文件名 (见正文里被改名成 `keyd.rvaiya` 的情况)
- `sudo keyd.rvaiya monitor`: 观察当前按键映射是否符合预期
- `ghostty +show-config`: 打印 ghostty 实际生效的配置, 可用来确认 `~/.config/ghostty/config.ghostty` 有没有被读到
- `amixer scontrols`: 列出 ALSA 的控件名

## 系统时钟显示本地时间

> **这一主题由 AI (DeepSeek) 强烈建议补充, 但作者完全没遇到这方面的问题; 推测是旧版本常见问题, 但是最新版本 Debian 安装程序能自动解决, 无需人工介入.**

Windows 默认把主板上的硬件时钟 (RTC) 当作本地时间, 而 Linux 默认把它当作 UTC, 这可能会造成两个系统显示的时间差几个小时. Debian 安装程序会尝试根据磁盘上已有的系统自动判断 (官方手册的说法是: 同时装了 Windows 的机器一般应当把时钟设为本地时间), 因此这一步通常不需要手动干预 —— 本机 `timedatectl` 显示 `LocalRTC=yes`, 而我只做过 `dpkg-reconfigure tzdata` 改时区, 没有手动设置过硬件时钟.

如果确实遇到了这个问题, 可执行 `timedatectl set-local-rtc 1 --adjust-system-clock` 将系统时钟改为本地时间.

## 其他补充话题

> **以下内容由 AI (DeepSeek) 补充, 作者没有实操或查验过, 仅供参考.**
>
> **硬件差异.** 本文的经验来自一台 Intel 核显的笔记本: 显卡驱动开箱即用, 视频硬解由 `intel-media-va-driver` 之类的包提供 (Xfce 任务里已经带了). 如果你用的是 NVIDIA 独立显卡, 通常需要额外安装 non-free 驱动 (`nvidia-driver`, 可能还要处理 DKMS 与 nouveau 的冲突), 建议先读 [Debian Wiki: NvidiaGraphicsDrivers](https://wiki.debian.org/NvidiaGraphicsDrivers) 再动手.
>
> **apt 源与非自由固件.** Debian 12 之后的官方安装镜像自带必要的非自由固件, 安装器会自动启用 `non-free-firmware` 组件, 所以 Wi-Fi 这类硬件通常开箱可用. 需要更多软件时 (某些显卡或无线网卡驱动), 可以先看看 `/etc/apt/sources.list` 里启用了哪些组件, 再按需加上 `contrib`, `non-free`, `non-free-firmware`.
>
> **Debian Pure Blends.** 从 trixie 开始, 安装器的软件选择界面底部多了一项 "Choose a Debian Blend for installation", 可以一次性安装面向某个领域打包好的软件集合 (例如 Debian Science, Debian Edu). 官方安装手册 6.3.6.2 有说明.
>
> **系统更新与备份.** 日常更新用 `sudo apt update && sudo apt upgrade` 即可, 内核和底层库升级后建议重启. 备份策略因人而异: 家目录可以用 `rsync`, `restic`, `borg` 之类的工具定期同步到外部磁盘; 系统本身的重装成本并不高 (本文档存在的意义之一就是让重装变快). 想给 `/home` 做快照的话 LVM 快照是一个选项, 但快照不等于备份, 仍然建议保留一份离线或异地的副本.
