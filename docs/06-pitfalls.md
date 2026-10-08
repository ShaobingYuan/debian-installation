# 常见坑与速查

> 主线导航: [README](../README.md) · 上一篇 [其他用户级应用 (可选)](./05-optional-apps.md) · 下一篇 [附录: 可能有用的信息 (含 AI 补充内容)](./07-appendix.md) · 最后核对 2026-10

正文里的坑分散在各章, 这里集中成表, 方便遇到问题时先查一眼. 每一行都给了对应章节的链接, 细节请回到正文看.

首先是关于系统本身的坑:

| 现象 | 优先排查原因及相应处理 | 详见 |
| --- | --- | --- |
| 安装器连不上 eduroam 这类需要身份验证的 Wi-Fi | 安装器只支持最简单的 Wi-Fi 名 + 密码; 可以用手机热点装完系统, 再在新系统里连 eduroam | [基础选项](./02-install.md#基础选项) |
| Windows 与 Debian 双系统兼容问题 | BitLocker, 快速启动, 时间设置 | [修改 Windows 设置](./02-install.md#修改-windows-设置) [系统时钟显示本地时间](./07-appendix.md#系统时钟显示本地时间) |
| 想禁用 root, 并让第一个普通用户直接有 sudo | 设置 root 密码时留空 (直接回车) | [基础选项](./02-install.md#基础选项) |
| 想把中文目录名改回英文 | 编辑 `~/.config/user-dirs.dirs` | [基础选项](./02-install.md#基础选项) |
| 使用 U 盘或访问 Windows 分区 | 通过 udisksctl 工具挂载和卸载文件系统, 可进一步封装成 bash 函数 | [手动挂载文件系统](./04-common-tasks.md#手动挂载文件系统) |
| 自定义的登录界面背景图不生效 | 家目录权限是 700, `lightdm` 读不到里面的文件, `chmod 711 ~` | [登录界面设置](./04-common-tasks.md#登录界面设置) |
| 蓝牙设备配对后没有自动连接 | 可能需要先 `trust <MAC 地址>` 信任该设备 | [蓝牙](./04-common-tasks.md#蓝牙) |
| 关机时卡在 "A stop job is running for User Manager for UID 1000" 倒计时 90 秒 | 某个用户进程不响应 SIGTERM; 改小 `/etc/systemd/user.conf` 的 `DefaultTimeoutStopSec` | [关机超时问题](./04-common-tasks.md#关机超时问题) |
| 持续运行的程序占用终端 | 用脚本后台启动并重定向输出 | [ollama](./05-optional-apps.md#ollama)  [wechat](./05-optional-apps.md#wechat) |
| 试图不解压直接运行 AppImage 时报错 | Debian 12 之后默认没有 libfuse2, 比较旧的 AppImage 运行需要装 `libfuse2t64`; 更推荐用 `--appimage-extract` 解压后运行 | [wechat](./05-optional-apps.md#wechat) |

接下来是针对特定应用的坑:

| 现象 | 优先排查原因及相应处理 | 详见 |
| --- | --- | --- |
| `Alt + Capslock + <某些键>` keyd 键盘映射失灵 | keyd 的 `Alt` 修饰键边界 bug, 存在硬件依赖; 可改用 oneshot 或尝试 `alt = layer(altgr)` | [keyd](./03-base-setup.md#keyd) |
| `which keyd` 找不到 keyd 可执行文件 | Debian 打包时把可执行文件改名为 `keyd.rvaiya` | [keyd](./03-base-setup.md#keyd) |
| 输入法配置改坏了 | 把 `~/.config/ibus/rime/` 整个删掉, 左键状态栏图标选 "重新部署" 即可复原 | [ibus-rime + rime-frost (白霜拼音)](./03-base-setup.md#ibus-rime--rime-frost-白霜拼音) |
| yazi, LazyVim 里的图标显示成方框 | 没装 Nerd Font, 或装了但没刷新字体缓存 (`fc-cache -fv`) | [yazi + nerd fonts](./03-base-setup.md#yazi--nerd-fonts) |
| neovim 报 `clipboard: error: Error: target STRING not available` | neovim 与 xclip 的已知兼容问题, 改装 `xsel` | [neovim + LazyVim](./03-base-setup.md#neovim--lazyvim) |
| LazyVim 文件管理器里明明存在的文件看不到 | 默认隐藏被 git 忽略的文件, 用快捷键解除隐藏 | [neovim + LazyVim](./03-base-setup.md#neovim--lazyvim) |
| 开启编译后保存 tex 时卡顿, 提示 `lsp timeout` | texlab 解析项目时死循环, 在项目根目录放一个空的 `.latexmkrc` | [texlive + zathura](./05-optional-apps.md#texlive--zathura) |
