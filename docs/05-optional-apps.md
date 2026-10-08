# 其他用户级应用 (可选)

> 主线导航: [README](../README.md) · 上一篇 [常用操作及相关配置](./04-common-tasks.md) · 下一篇 [常见坑与速查](./06-pitfalls.md) · 最后核对 2026-10

本章介绍一些我自己在用的用户级应用的部署和使用方法. 应用本身是针对特定用途的, 不一定适用于所有人, 但是这里涉及到的后台应用启动方法和 AppImage 压缩包解压方法是通用的.

## uv 和 nvm

uv 是最新一代的 Python 包管理器, 用 rust 语言编写, 轻量且快. 安装只需一行命令 `curl -LsSf https://astral.sh/uv/install.sh | sh`, 无需提权 (后续的所有 uv 相关操作也都无需提权), 默认安装在家目录里. 前面提过, 这种 `curl ... | sh` 的安装方式都建议先把脚本下载下来读一遍再执行. 装好之后 `uv python install` 即可安装最新版本 Python (不做这一步的话会使用系统自带的 Python, 版本较旧). 运行 `uv venv` 会在当前目录中创建一个 `.venv` 子目录作为 Python 虚拟环境; 通过 `uv run <脚本名>.py` 运行脚本或者 `uv pip install <包名>` 安装包, uv 会自动从当前目录开始逐级向父目录查找 `.venv` 文件夹用作执行该命令的虚拟环境. 一般推荐每个项目文件夹创建一个专用的 `.venv` 虚拟环境或者虚拟环境软链接以省去 uv 向上查找的时间 (虽然也很快). 更多高级用法参见 [uv 官网](https://docs.astral.sh/uv/).

nvm 用于管理 Node.js. 类比一下的话, nvm 相当于 uv, Node.js 相当于 Python, npm 相当于 pip. 官方仓库和文档在 [nvm-sh/nvm](https://github.com/nvm-sh/nvm), 从 README 的 `Installing and Updating` 一节可以取到最新的安装命令 (也是一行 `curl` 命令, 但是包含版本号, 所以会随版本更新). 装好之后 `nvm install --lts` 即可安装最新稳定版 Node.js 和 npm. 更多高级功能请善用搜索.

顺带一提, 要给 LazyVim 添加 Python 语言支持, 只需在 LazyVim 内执行 `:LazyExtras` 并激活 lang.python 选项, 随后退出 nvim 重新进入就会开始安装相关插件和依赖; 重新进入 nvim 这一步推荐使用命令 `uv run nvim` 而不是简单地 `nvim`, 因为 lsp 服务器需要 Python 相关的依赖才能安装. 如果觉得默认的 Pyright 语法检查过于严格, 可以换用 pylsp, 方法是在配置文件 `~/.config/nvim/lua/config/options.lua` 里添加一行

```lua
-- ~/.config/nvim/lua/config/options.lua
-- 添加到末尾
vim.g.lazyvim_python_lsp = "pylsp"
```

依旧是 `uv run nvim` 安装 pylsp 即可.

## texlive + zathura

texlive 可以直接用 apt 安装, 但版本旧且占用系统目录, 不推荐. 手动安装需从 [tug.org/texlive/acquire-netinstall](https://www.tug.org/texlive/acquire-netinstall.html) 下载安装器压缩包 `install-tl-unx.tar.gz`, `tar xvf install-tl-unx.tar.gz` 解压, 然后 `cd install-tl-*/` 进入安装器目录. 接下来, `./install-tl` 运行安装器, 输入 `D` 进入目录设置, 将变量 TEXDIR 设定为 `~/.local/texlive/2026` (不污染系统目录, 之后所有相关操作也无需 sudo 提权), 保存后按 `R` 返回, 输入 `S` 选择安装 scheme, 最后输入 `I` 开始安装. 装好之后按提示把相应路径纳入环境变量 PATH, MANPATH 和 INFOPATH. 如果选用的安装 scheme 不是默认的 full (安装所有包, 非常占空间, 大多数包其实用不上), 可以通过 `tlmgr` 工具补充需要的包, 这一步推荐去问 AI 具体补哪些 collection 及核心包.

zathura 只需 `sudo apt install zathura` 即可安装. 这是一个非常轻量的 PDF 阅读器, 非常适合辅助编写 LaTeX. 其缺陷是基本没有编辑和读取批注相关的功能, 只提供最单纯的阅读功能. 如需批注功能, 推荐安装 evince (GNOME 默认 PDF 阅读器) 或者 okular (KDE 默认 PDF 阅读器, Linux 下最重但也功能最全). Xfce 自带的 atril 对批注的支持有限但又不如 zathura 轻量, 建议 `sudo apt purge atril && sudo apt autoremove --purge` 卸载. zathura 的配置文件位于 `~/.config/zathura/zathurarc`, 可参考我的配置:

```text
# ~/.config/zathura/zathurarc
set window-height 3000 # 默认最大化窗口
set window-width 3000 # 默认最大化窗口
set adjust-open width # 默认适合宽度
set selection-clipboard clipboard # 鼠标选取复制到剪贴板
map e exec "evince $FILE" # e 键用 evince 打开当前文件
map E feedkeys "eq" # E 键用 evince 打开当前文件并关闭当前 zathura 界面
map f exec "thunar $FILE" # f 键在 thunar 文件管理器中打开当前文件
```

要给 LazyVim 添加 LaTeX 语言支持, 还是通过 `:LazyExtras` 命令, 找到并激活 lang.tex 选项, 重启 nvim 安装依赖, 再重启即可使用. 推荐添加配置文件 `~/.config/nvim/lua/plugins/vimtex.lua`, 内容如下:

```lua
-- ~/.config/nvim/lua/plugins/vimtex.lua
return {
  {
    "lervag/vimtex",
    lazy = false, -- 让 VimTeX 在打开 tex 文件时立即加载，确保一切功能正常
    init = function()
      -- 1. 设置 PDF 查看器为 Zathura
      vim.g.vimtex_view_method = "zathura"

      -- 2. 设置编译器为 latexmk
      vim.g.vimtex_compiler_method = "latexmk"

      -- 3. 配置 latexmk 的详细参数
      vim.g.vimtex_compiler_latexmk = {
        -- 传递给 latexmk 的额外选项
        options = {
          "-pdf", -- 默认生成PDF
          "-interaction=nonstopmode", -- 遇到错误不停止，继续编译
          "-synctex=1", -- 启用正向和反向搜索
          "-shell-escape", -- 允许执行 shell 命令（某些宏包需要）
          "-file-line-error", -- 在错误信息中显示文件名和行号
          "-auxdir=.build", -- 指定编译输出目录（相对于 tex 文件所在目录）
        },
      }

      -- 4. 配置 latexmk 的编译引擎
      -- vim.g.vimtex_compiler_latexmk_engines = {
      --   ["_"] = "-xelatex",
      -- }
    end,
  },
}
```

这样就可以用了. 到项目目录里用 nvim 打开 tex 文档, 键入 `\ll` 开始编译, `\lv` 预览 PDF 并且高亮光标对应的位置. 默认采用 texlab 作为 lsp server 检查 LaTeX 语法, 它存在一个已知的小 bug 是解析项目时容易陷入死循环, 会导致 `lsp timeout` 警告并拖慢保存操作, 因为保存时会自动运行 texlab 检查. 解决方法非常简单, 只需在 LaTeX 项目根目录里添加一个空的 `.latexmkrc` 文件即可. 这个文件也可以写入一些仅针对本项目 tex 文档生效的编译设置, 比如改用 xelatex 编译引擎 (也可以通过在 tex 文档开头添加 shebang 魔法注释设置).

以下是一些更精细的设置. 在配置文件 `~/.config/nvim/lua/config/options.lua` 里添加一行 `vim.g.maplocalleader = ";"` 可以将 vimtex 相关快捷键从 `\` 开头改为 `;` 开头, 更容易按 (前面说的 `\ll` 编译和 `\lv` 预览就相应变成 `;ll` 和 `;lv`). 此外, 还可以再在配置文件 `~/.config/nvim/lua/config/autocmds.lua` 末尾添加:

```lua
-- ~/.config/nvim/lua/config/autocmds.lua
-- 添加到末尾
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    -- 双击鼠标左键或键入 ;v 触发前向搜索（等价于 \lv）
    vim.keymap.set("n", "<2-LeftMouse>", "<Plug>(vimtex-view)", { buffer = true, desc = "VimTeX 前向搜索" })
    vim.keymap.set("n", ";v", "<Plug>(vimtex-view)", { buffer = true, desc = "VimTeX 前向搜索" })
    -- 启用拼写检查
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end,
})
```

## ollama

ollama 是一个小模型本地部署工具. 官网提供脚本安装命令 `curl -fsSL https://ollama.com/install.sh | sh`, 默认装进系统目录并设为开机自启的守护进程. 我选择手动安装. 从 [ollama/ollama/releases](https://github.com/ollama/ollama/releases) 找到合适架构的最新版 ollama 压缩包, 对于普通个人电脑就是 `ollama-linux-amd64.tar.zst`, wget 下载到 `~/.local/` 目录 (注意, 这次不放在 `~/.local/opt/` 里, 因为有更好的方式), 在 `~/.local` 目录直接 `tar xvf ollama-linux-amd64.tar.zst`, 解压产物就刚好自动进入 `~/.local/bin/` 和 `~/.local/lib/` 目录. 这样就算安装好了, 然后删除压缩包或者将其移动到 `~/.local/opt/` 下存起来都行.

命令行 `ollama serve` 即可启动 ollama 服务, 此时 ollama 会向当前终端窗口持续输出大量日志信息 (如果看不懂, 可以复制下来发给 AI 问能读出哪些信息), 且不打算把命令提示符还给你, 因此你不能在当前命令行再输入任何命令, 直到你按下 `Ctrl + c` 关闭 ollama 服务. 这时正确的做法是 (ghostty 下) `Ctrl + Shift + t` 新开一个终端标签页, `ollama pull <模型名称>` 下载想要的模型, 然后 `ollama run <模型名称>` 即可开始对话 (可用的模型列表见 [ollama.com/search](https://ollama.com/search), 例如 qwen3.5:9b). 对话的同时, ollama serve 所在的页面会持续输出相关日志信息, 比如 token 生成速度. 想结束对话就输入 `/bye` 并回车, 想中止 ollama 服务就在 ollama serve 页面 `Ctrl + c` 即可.

以上为基础用法. 我在 `~/.local/bin/` 目录下创建了一个名为 llmsrv 的 bash 脚本 (创建好之后需要 `chmod u+x ~/.local/bin/llmsrv` 添加执行权限), 内容如下:

```bash
#!/usr/bin/bash
# ~/.local/bin/llmsrv
export OLLAMA_IGPU_ENABLE=1            # 启用集成显卡 (ollama 默认会跳过集显, 只用 CPU 推理)
export OLLAMA_FLASH_ATTENTION=1        # 启用 flash attention 加速注意力计算
nohup ollama serve &>/tmp/ollama.log & # 后台启动 ollama 服务并且将输出重定向至 /tmp/ollama.log 日志文件

exit 0                                 # 显式退出脚本
```

这样只需命令行 `llmsrv` 即可后台启动 ollama 服务, 无需新开命令行, 可直接在当前终端窗口继续 ollama pull 或 ollama run 模型, 直到关机或者通过 `pkill ollama` 命令关闭 ollama 服务. 需要查看日志就去找 `/tmp/ollama.log` 文件. 顺带一提, `/tmp` 目录关机自动清空, 在包括 debian13 在内的很多主流发行版中会默认挂载在内存上. 脚本启动 ollama serve 前设置了一些环境变量, 我实际试验过的不止这两条, 但是没做深入测试, 这里只给出两条感觉最有用的: `OLLAMA_IGPU_ENABLE=1` 启用后 CPU 占用明显下降 (ollama 默认不使用集成显卡), 但由于笔记本集成显卡没有独立显存, 内存占用不变; `OLLAMA_FLASH_ATTENTION=1` 是官方提供的加速选项. 两个选项都用上, 在我的电脑上对 9b 模型的生成速度大约有 5% 量级的提升, 但也有可能只是模型推理速度本身的波动造成的错觉, 总之加速效果很有限. GPU 加速还是要在更大的模型和独立显卡上才比较明显.

## wechat

微信是我目前安装的唯一一个非自由软件. 微信安装包可以从 [linux.weixin.qq.com/](https://linux.weixin.qq.com/) 下载. 这里推荐使用 AppImage 格式的包, 文件名应该是 `WeChatLinux_x86_64.AppImage`. 将它移动到 `~/.local/opt/` 目录下并 `cd ~/.local/opt/`. 接下来, `chmod u+x WeChatLinux_x86_64.AppImage` 给文件添加执行权限, 然后 `./WeChatLinux_x86_64.AppImage --appimage-extract` 将其解压. 顺带一提, AppImage 格式的文件赋予执行权限后其实可以不解压直接运行, 这种运行方式需要 FUSE, Debian 12 之后默认不再预装 libfuse2 (因为更新到了 fuse3), 大多数比较旧的 AppImage (微信似乎不在此列, 因为 Linux 版出的很晚) 需要先 `sudo apt install libfuse2t64` 才能以这种方式运行; 这里介绍的解压后运行的方式则完全不需要 FUSE. 解压产物是一个名为 squashfs-root 的目录, 将其下的 AppRun 可执行脚本软链接至 `~/.local/bin/wechat` 即可 (软链接之前推荐先把 squashfs-root 目录名改一下, 以防下次安装新的 AppImage 软件时解压目录重名).

以上是通用的 AppImage 软件安装方法. 针对微信, 由于其 AppRun 脚本依赖关系和 squashfs-root 文件结构非常简单, 还可以再优化一下. 解压之后先不改目录名和软链接 AppRun, 而是 `cp -r squashfs-root/opt/wechat/ .`, 这样就得到了 `~/.local/opt/wechat/` 目录. 此时可以 `rm -rf squashfs-root` 删掉解压产物 squashfs-root 目录, 随即 `ln -s ~/.local/opt/wechat/wechat ~/.local/bin/` 将 wechat 目录下的 wechat 可执行文件软链接到 `~/.local/bin` 下, 安装就完成了.

微信的性质和 ollama serve 一样, 是要持续运行的, 因此命令行直接 `wechat` 虽然确实可以运行, 但是会一直占用一个命令行窗口. 因此, 推荐在 `~/.local/bin` 下创建一个名为 vx 的脚本并 `chmod u+x ~/.local/bin/vx` 赋予执行权限, 内容如下:

```bash
#!/usr/bin/bash
# ~/.local/bin/vx
nohup ~/.local/opt/wechat/wechat &>/dev/null &

exit 0
```

这样命令行 `vx` 即可后台启动微信.
