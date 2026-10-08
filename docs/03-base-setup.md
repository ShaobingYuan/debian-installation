# 新系统基础配置

> 主线导航: [README](../README.md) · 上一篇 [安装系统本体](./02-install.md) · 下一篇 [常用操作及相关配置](./04-common-tasks.md) · 最后核对 2026-10

本章介绍预装软件之外的 Debian 通用基础配置, 在装好系统第一次启动后即可无缝衔接开始配置.

## 图形界面设置 - 外观, 显示, 桌面

此处以 Xfce4 桌面环境为例; GNOME, KDE 及其他桌面环境的操作会有所不同.

登录后可以先用快捷键 `Alt + F1` 打开菜单, 找到 `设置` 一栏. `设置 > 外观 > 样式` 可以选用 Adwaita-dark 深色主题, 我觉得比默认配色好看. `设置 > 显示` 可以调整显示设定, 比如整体放大 1.5 倍之类的; 如果你需要用外接显示器, 可以通过 `设置 > 显示 > 高级 > 配置` 分别保存笔记本屏幕和外接显示器各自的显示配置文件, 这样今后设备就会根据接入显示器的情况自动启用已设定的配置. `设置 > 桌面` 可更换桌面背景图片; 目录 `/usr/share/wallpapers/` 下有一些默认壁纸, 当然也可以用自己的图片, 指定路径即可.

## 系统级安装

可用 `Ctrl + Alt + t` 快捷键打开终端. 输入 `sudo apt install <软件包名>` 并回车即可安装相应的软件包. 推荐先装 git, build-essential, cmake, 这些是代码和编译相关的工具. 然后可能需要补充一些字体. 中文字体 (`fonts-noto-cjk`) 会随着简体中文的语言选择自动装上 (见上一章), 不用额外操心; 我另外手动装了 `fonts-noto` 和 `fonts-noto-color-emoji` 来补全某些特殊字符和 emoji 的显示, 不装的话也只是一些字符显示乱码, 不影响使用. 要注意的是, 手动添加的字体文件 (比如下面 [yazi + nerd fonts](#yazi--nerd-fonts) 一节复制到 `~/.local/share/fonts/` 的 .ttf) 需要运行 `fc-cache -fv` 刷新字体缓存才会生效, 可以用 `fc-list | grep -i <关键字>` 检查系统是否已经识别到该字体. 可以装一个 fastfetch 快速查看系统当前信息. 可以再装一个 vim 文本编辑器, 装好直接在命令行输入 `vimtutor` 命令并回车学习其用法; 不想装 vim 只用默认的 nano 编辑器也行. 用 `which` 命令检查是否已安装 wget, curl, unzip, tar, 如果有缺的也同样用 apt 安装即可.

最后要装的是 ibus-rime 输入法, keyd 键盘映射, 以及 ghostty 终端模拟器.

### ibus-rime + rime-frost (白霜拼音)

通过 `sudo apt install ibus-rime` 一行命令安装. 在 `设置 > IBus 首选项` 中启用 rime 输入法. 切换至该输入法后应该可以在右上角状态栏看到 rime 图标.

ibus-rime 的配置文件夹在 `~/.config/ibus/rime/` 当中. 不用担心把它改坏; 你可以随时把这个目录整个删除, 左键状态栏里的 rime 图标选择重新部署, 即可重新生成默认的配置文件夹. 默认使用明月拼音输入法, 推荐换用[白霜拼音](https://github.com/gaboolic/rime-frost), 只需命令行执行 `cd ~/.config/ibus && rm -rf rime && git clone --depth 1 https://github.com/gaboolic/rime-frost rime` 将配置文件夹整个替换为白霜拼音仓库, 再左键状态栏里的 rime 图标选择重新部署即可.

这时输入法已经可以用了. 不过还可以加一些配置文件补丁来进一步定制其行为, 让它更符合你的使用习惯. 在配置文件夹 `~/.config/ibus/rime/` 中新建文件 `<方案名>.custom.yaml` (对于白霜拼音就是 `rime_frost.custom.yaml`), 内容如下:

```yaml
# ~/.config/ibus/rime/<方案名>.custom.yaml

patch:
  # 这一部分改编自 rime 官方 wiki https://github.com/rime/home/wiki/CustomizationGuide
  switches:                   # 注意縮進
    - name: ascii_mode
      reset: 1                # reset 1 的作用是當從其他輸入方案切換到本方案時，
      states: [ 中文, 西文 ]  # 重設爲指定的狀態，而不保留在前一個方案中設定的狀態。
    - name: simplification
      reset: 1                # 增加這一行：默認啓用「繁→簡」轉換。
      states: [ 漢字, 汉字 ]
  # 以下配置魔改自白霜拼音 (GPL-3.0) https://github.com/gaboolic/rime-frost/blob/master/default.yaml
  ascii_composer/switch_key:
    Shift_L: noop # 左侧Shift取消切换中英文功能
  key_binder/bindings:
    # Esc 或 Shift_L：强制切到英文模式 (开启 ascii_mode)
    - { when: always, accept: Escape, set_option: ascii_mode }
    - { when: always, accept: Shift_L, set_option: ascii_mode }
    # Shift_R：强制切到中文模式 (关闭 ascii_mode)
    - { when: always, accept: Shift_R, unset_option: ascii_mode }
    # 翻页 , .
    - { when: paging, accept: comma, send: Page_Up }
    - { when: has_menu, accept: period, send: Page_Down }

```

这是我自用的配置文件的一部分, 仅供参考, 可以随意删改或者追加新内容. 这部分配置中我个人原创的是通过 `Esc` 或左侧 `Shift` 强制切换英文输入, 右侧 Shift 强制切换中文输入. 这样做的好处是中英文输入非常明确, 完全不依赖于你按 `Shift` 之前的状态; 以及在 vim/neovim 中, 连按两次 `Esc` 能确保从任意状态退回英文输入+普通模式, 左 `Shift` 键入冒号进入命令模式时也会自动强制切到英文输入, 方便输入命令. 要注意的是, 这里的左右 `Shift` 键不区分点按和长按, 按到就触发, 比如 `Shift` 键入大写字母也会触发中英文切换.

### keyd

依旧 `sudo apt install keyd` 一行命令安装 keyd, 然后 `sudo systemctl enable --now keyd` 启用 keyd 并设置开机自启. 接下来运行 `which keyd` 检查一下能不能找到 `keyd`; 如果前面的安装和启动命令都没报错, 但是这里没有输出的话, 很可能是因为 keyd 的可执行文件被重命名了. 在我这里, 该可执行文件被重命名为 `keyd.rvaiya`.

接下来修改键位映射. 和 ibus-rime 的设置不同, 这里的修改需要 root 权限. 输入命令 `sudo vim /etc/keyd/default.conf` (用 nano 的话就把命令中的 vim 替换为 nano), 按需参考以下映射方案写入文档并保存退出:

```ini
# /etc/keyd/default.conf

[ids]
# 应用于所有键盘
*

[main]
# capslock 键点按为 esc, 长按作为修饰键激活接下来定义的 fkeys 图层
# keyd 默认会将右侧 shift 和 control 映射成左侧的以便管理. rightshift = rightshift 显式保持右侧 shift 不变, 配合输入法切换中文
# 右侧 alt 保持原有功能的同时追加粘滞键机制, 含 alt 的组合键可以按住它触发, 也可以先按下它再抬起然后再按剩余的键触发
capslock = overload(fkeys, esc)
rightshift = rightshift
rightalt = overload(altgr, oneshot(altgr))

[fkeys]
# 按住 capslock 激活此图层, 在此期间按下的数字键和-=被映射为 f1 到 f12 功能键, hjkl 被映射为方向键
1 = f1
2 = f2
3 = f3
4 = f4
5 = f5
6 = f6
7 = f7
8 = f8
9 = f9
0 = f10
minus = f11
equal = f12

h = left
j = down
k = up
l = right
```

修改好并保存之后 `sudo keyd.rvaiya reload` 重启 keyd 即可生效. 可以运行 `sudo keyd.rvaiya monitor` 观察当前键盘映射是否符合预期; 按 `Ctrl + c` 退出 monitor.

keyd 存在一个已知的 `Alt` 修饰键边界条件 bug, 在同时按下 `Alt` 和 `Capslock` 时, 某些键可能不再能被捕获. 此 bug 存在硬件依赖性, 在我的笔记本上表现为按下 `Alt + Capslock` 后数字键 `1` 不再被捕获, 因此不能通过 `Alt + Capslock + 1` 触发 `Alt + F1` 快捷键; 但是同样的键位用外接的机械键盘就没问题. 社区中则有人报告 `Alt + Capslock` 按下后 `a` 键不被捕获. 如果你要用的快捷键恰好有受这个 bug 影响的, 可以尝试在 `[main]` 字段添加 `alt = layer(altgr)` 将左 `Alt` 键映射为右侧的 (右侧 `Alt` 键行为比左侧更稳定), 或者改用 oneshot 粘滞键机制 (oneshot 粘滞键比 layer 修饰键更稳定).

### ghostty

ghostty 比较新, Debian 官方尚未收录, 因此不能直接通过 apt 安装. 这里把它当作系统级应用来装 (而不是像后文的 yazi, neovim 那样放进家目录), 理由是终端模拟器需要和桌面环境集成: 比如要被 Xfce 的终端选项, 文件管理器的 "在终端中打开" 之类的功能识别到, 装在系统目录里最稳妥; 它虽然还没进 Debian 官方仓库, 但已经是被广泛使用的自由软件, 打包来源可以信任. 最简单的做法是通过一行命令 `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"` 执行脚本安装社区编译版 —— 这个脚本做的事其实就是判断架构, 下载对应的 .deb 再交给 apt-get 安装, 和手动安装的流程完全相同, 只是将其自动化了. 顺带提醒: 后文还会出现若干 `curl ... | sh` 形式的安装命令 (uv, nvm, ollama 等), 在 Linux 上执行任何这类脚本之前都建议先把脚本下载下来读一遍. 也可以手动从 [mkasberg/ghostty-ubuntu/releases](https://github.com/mkasberg/ghostty-ubuntu/releases) 下载适用的 .deb 文件通过 dpkg 或 apt 安装 (`sudo apt install <软件包名>.deb` 底层也是调用 `sudo dpkg -i <软件包名>.deb`), 效果和脚本一样, 注意选和 Debian 版本对应的构建 (文件名里会带发行版代号). 再有就是从源码构建, 或者从 [pkgforge-dev/ghostty-appimage](https://github.com/pkgforge-dev/ghostty-appimage) 仓库下载 AppImage 解压并移动到合适的位置.

装好之后无需任何配置就已经很好用了. 如需修改, 配置文件在 `~/.config/ghostty/config.ghostty`. 我的配置文件如下:

```ini
# ~/.config/ghostty/config.ghostty

# 默认最大化窗口
maximize = true
# 消除内边距
window-padding-x = 0
window-padding-y = 0
window-padding-color = extend
# 新窗口和新标签页的起始工作目录都固定为家目录
working-directory = ~
window-inherit-working-directory = false
tab-inherit-working-directory = false
```

## 用户级安装

接下来安装 yazi 文件导航和 LazyVim 文本编辑器. 存在其他安装方式, 比如像刚刚 ghostty 那样的安装脚本, 或者通过 homebrew 之类的第三方包管理器, 当然也可以从源码编译构建; 不过这里主要介绍从压缩包手动安装的方法.

一般推荐把用户级应用的可执行文件或软链接放在 `~/.local/bin/` 下 (软链接相当于快捷方式). 为此, 首先运行 `echo $PATH` 检查这一目录是否在默认搜索路径当中. 如果不在, 需先编辑 `~/.bashrc`, 在末尾添加

```bash
# ~/.bashrc
# 添加到末尾
export PATH="$HOME/.local/bin:$PATH"
```

然后 `source ~/.bashrc` 或者重启终端即可生效. 此外, 推荐新建一个 `~/.local/opt/` 目录专门用来存放手动下载的软件; 运行命令 `mkdir ~/.local/opt` 即可.

### yazi + nerd fonts

访问 [sxyazi/yazi/releases](https://github.com/sxyazi/yazi/releases), 找到绿色 `latest` 标记的最新稳定版, 在 `Assets` 一栏中找到适合的 .zip 压缩包 (对于最常见的 x86_64 架构, 可以选 `yazi-x86_64-unknown-linux-gnu.zip` 或 `yazi-x86_64-unknown-linux-musl.zip`), 右键选择复制链接, 进入终端执行命令 `cd ~/.local/opt && wget <复制的压缩包下载链接>`. 下载完成之后, `ls` 应该能看到下载好的 .zip 压缩包, 运行 `unzip <压缩包名>.zip`, 然后 `cd <压缩包名>` 进入解压后的同名目录 (比如说 `yazi-x86_64-unknown-linux-gnu/`), 随后 `ls` 就能找到一个名为 `yazi` 的二进制可执行文件. 接下来把该可执行文件复制或软链接到 `~/.local/bin/` 里, 即可在命令行中直接执行 `yazi` 命令. 可通过 `ln -s ../opt/yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin` 建立相对路径软链接, 或者 `ln -s "$PWD/yazi" ~/.local/bin/` (在解压出来的目录里执行) 建立绝对路径软链接, 或者干脆 `cp yazi ~/.local/bin/` 直接复制 (我自己用的就是复制). 软链接是更通用的做法, 能确保提供完整功能, 但是这里只复制可执行文件也可以, 因为 yazi 程序比较简单, 可执行文件没有额外的运行时依赖; 文件夹中的其他部分提供包括插件管理等高级功能在内的 cli 工具 ya 和自动补全设定, 只用 yazi 基础功能的话可以不需要.

可访问 [yazi 官网](https://yazi-rs.github.io/docs/quick-start) 来学习其基本使用方法. 现在运行 `yazi`, 文件图标大概会显示乱码, 这是没有安装相应字体的缘故. 可以从 [nerdfonts.com/font-downloads](https://www.nerdfonts.com/font-downloads) 选择喜欢的字体下载 (推荐选用版本号大于等于 3.0 的, LazyVim 也要用), 也是 .zip 压缩包, 还是用同样的 `unzip` 命令解压, 然后把解压得到的文件夹里的所有 ttf 文件全都复制到 `~/.local/share/fonts/` 目录下 (不妨试试通过 yazi 完成这次复制粘贴), 再运行 `fc-cache -fv` 刷新字体缓存. 之后新开一个终端运行 `yazi`, 确认图标是否已经正常显示.

可以在 `~/.bashrc` 最后再添加以下代码然后 `source ~/.bashrc` 或者重启终端, 这样就可以在命令行执行 `yz` 启动 yazi, 并且在 `q` 退出 yazi 时自动将工作目录切换到 yazi 导航到的目录. 有了 `yz` 就很少再会用 `ls` 和 `cd` 等命令了. `yz` 函数本身是官网提供的 shell 集成, [官网](https://yazi-rs.github.io/docs/quick-start#shell-wrapper)上这个函数被命名为 `y`, 我觉得太抽象了所以改了函数名.

```bash
# ~/.bashrc
# 添加到末尾
yz() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
  command rm -f -- "$tmp"
}
```

yazi 无需配置, 开箱就很好用了. 如果要修改配置, 配置文件位于 `~/.config/yazi/yazi.toml`. 我采用的额外设定只有将 zathura 设为 pdf 文件的默认打开方式, 配置文件如下:

```toml
# ~/.config/yazi/yazi.toml
[opener]
zathura = [
    { run = 'zathura %s', orphan = true },
]

[open]
prepend_rules = [
    { mime = "application/pdf", use = "zathura" },
]
```

### neovim + LazyVim

neovim 是一个社区重构升级的现代版 vim, 而 LazyVim 是一个打包了众多插件开箱即用的 neovim 发行版. 在此前系统安装的 vim 不必删除, 因为功能定位不太相同: 系统级工具 vim 可以通过 sudo 提权用于修改系统配置文件, 用户级应用 neovim 则用于日常工作. 如果你习惯于用 vscode 编辑代码的话, 也可以不装 neovim; 二者能提供的功能是相似的, neovim 上手难度略高一些, 但是学会之后比 vscode 上限更高, 而且它非常轻, 占用远小于 vscode 且感受不到延迟或卡顿.

首先下载 neovim. 从官网 [neovim.io/doc/install/](https://neovim.io/doc/install/) 中的 `Install from download` 一栏可以找到下载链接, 选用合适的架构下载到 `~/.local/opt/` 即可 (对于最常见的 x86_64, 下载链接就是 [Linux x86_64](https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz)). 下载好之后找到对应的 .tar.gz 压缩包, 通过 `tar -xvf <压缩包名>.tar.gz` 命令解压缩, 再通过 `ln -s` 命令或者 `yz` 把解压得到的文件夹里的可执行文件软链接到 `~/.local/bin/` 里, neovim 就安装完成了. 整个安装过程所执行的命令可能类似于:

```bash
cd ~/.local/opt/                                                         # 移动到 ~/.local/opt/ 目录
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz # 下载压缩包
tar -xvf nvim-linux-x86_64.tar.gz                                                       # 解压压缩包
ln -s ../opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/                  # 软链接到 ~/.local/bin/ 目录
```

接下来命令行执行 `nvim` 即可启动 neovim. 如果还不熟悉 vim, 可以输入 `:Tutor` 回车进入教程.

安装 LazyVim 的方法和刚才安装白霜拼音一样, 将 neovim 的配置文件夹整个替换为相应的 github 仓库 [LazyVim/starter](https://github.com/LazyVim/starter) 即可. 核心安装命令是 `git clone https://github.com/LazyVim/starter ~/.config/nvim`, 更多细节可参考官网安装指导 [lazyvim.org/installation](https://www.lazyvim.org/installation). 装好之后运行 `nvim`, 会发现它开始自动下载所需的插件 (默认下载到 `~/.local/share/nvim/`), 下载好之后输入 `:q` 回车退出, 再重新启动 `nvim` 就可以用了.

接下来, 推荐在 `~/.bashrc` 文件里添加以下内容然后 `source ~/.bashrc` 或者重启终端, 这样就可以将 neovim 设置为默认文本编辑器. 比如, 用 yazi 导航到想要的文件或目录后, 回车即可用 neovim 打开该文件或目录.

```bash
# ~/.bashrc
# 添加到末尾
export EDITOR='nvim'
export VISUAL='nvim'
```

LazyVim 中, 你可以正常使用鼠标, 但是所有操作都可以只通过键盘实现. 请善用搜索或 AI 找出你所需的操作对应的快捷键, 熟悉之后用起来就会非常爽, 像打游戏一样. 相当一部分快捷键以 `<leader>` 键 (默认为空格键) 以及 `g` 键开头, 这些多于一个按键的组合键会有下一步按键的功能提示. 误触了不想要的快捷键时, 绝大多数情况下都可以通过 `Esc` 键清空状态退回普通模式 (加上之前设定的输入法切换英文, 最保险的做法是连按两次 `Esc`); 我所了解的唯一例外是 `q` 键开启的宏录制状态需要通过 `q` 键关闭 (不喜欢这个功能可以通过修改配置文件 `~/.config/nvim/lua/config/keymaps.lua` 重新设定 neovim `q` 键功能). 此外值得一提的是, LazyVim 的文件管理器默认不止隐藏 `.` 开头的隐藏文件, 还隐藏被 git 忽略的文件; 因此发现文件管理器栏某些文件看不到或者明明创建了但没显示不要慌, 大概率只是被隐藏了, 用快捷键解除隐藏状态试试.

一个比较有用的命令是 `:checkhealth`, 在 LazyVim 正常模式下完整输入这条命令并回车即可查看当前可用的功能和可以补充的系统工具依赖. 比如说, 需要共享系统剪贴板的话, 可以 `sudo apt install xsel` 安装 xsel 工具 (这里推荐安装 xsel 而不是 xclip, 因为 neovim 与 xclip 存在一个已知的兼容性 bug, 有时会报错 `clipboard: error: Error: target STRING not available`).
