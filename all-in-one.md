<!-- 本文件由 tools/build-all-in-one.sh 自动生成, 请勿直接编辑; 要改内容请改 README.md 或 docs/ 下对应的章节 -->

> 本文件是 [README](./README.md) 与 [docs/](./docs/) 下各章节按阅读顺序拼接而成的单文件版, 便于离线阅读或整份喂给 AI. 指向章节的链接已改写为文件内跳转; 指向 LICENSE, scripts/ 等仓库内其它文件的链接只在仓库中有效.

---

# Debian GNU/Linux 13 (trixie) x86_64 系统安装记录

一份写给 Linux 新手的 Debian 13 安装与配置笔记: 从 Windows 双系统安装, 到 Xfce 桌面, 输入法, 终端, 编辑器, 常用配置和用户级应用. 内容基于 2026 年一次真实的从零搭建过程, 按"最短篇幅, 先跑通再深入"的思路组织.

## 这份文档是什么

当前或许是将个人电脑和日常工作流迁移至 Linux 系统的最佳时机. 历经过去几十年的累积, Linux 生态已经完善到了我个人认为已经足以应对 (至少对于理工科学生来说) 所有日常需要的程度. AI 辅助编程也正在并将持续增进 Linux 开源生态的繁荣. AI 的对话功能同时也大幅降低了 Linux 的学习成本和上手难度. 这些变化逐步让 Linux 真正成为一个普通人的可选项. 你不需要花费任何金钱, 只需要花点时间学习相关的配置即可获取一个占用缩小数倍, 性能增强数倍, 没有后门没有遥测没有垃圾文件, 且完美适配各种 AI Agent 的操作系统.

关于 Linux, 在网上很容易找到详尽的专业文档或者针对一些常见问题的解决方案. 然而它们太庞杂或者零散了, 有一些还存在着过时的问题, 新手可能很容易感到无从下手. AI 能在相当大的程度上减小搜索的难度, 但是相对小众和细节的问题 AI 也很难给出准确的回答, 毕竟训练集里没有这种数据, 联网也查不到. 相比之下, 本文档并不追求事无巨细或专业严谨, 只是从非 CS 专业学生和 Linux 新手的视角总结记录 2026 年个人从零开始搭建日用 Linux 工作环境的第一手经验和最小化知识, 目标是以最短的篇幅让毫无相关背景的读者能搭建起真正可用的系统并获得足以将自己的疑惑组织成有效问题的知识; 完成从 0 到 1 这一步之后, 通过日常使用新系统和向 AI 提问, 从 1 到 100 的进步就不再有原则性的困难, 只是时间问题了. 不过作者水平有限, 文中难免有错漏, 发现请指出.

## 环境

- 硬件: 惠普 HP Pavilion Plus Laptop 16-ab0xxx (2024 年夏购入), Intel i7-13700H, Iris Xe 集成显卡, 16G 内存
- 系统: Debian GNU/Linux 13.6 (trixie) x86_64, 内核 6.12, locale 为 zh_CN.UTF-8
- 桌面: Xfce 4.20 (X11), 自带 LightDM, PulseAudio, Thunar 等工具
- 基础软件: ibus-rime (白霜拼音), keyd, ghostty, yazi, neovim (LazyVim)
- 可选软件: uv, nvm, TeX Live 2026 + zathura, ollama, 微信
- 分区: LVM 卷组内的 `debian-root` (60G 根分区) 与 `debian-home` (90G 家分区), 根分区中包含 16G 的 `/swapfile` 用作交换空间
- 最后核对: 2026-10 (每篇开头另有一条"最后核对"标记)

## 阅读顺序

主线是按顺序读; 只想装系统的读者可以直接从 02 开始, 遇到不明白的概念再回头查 01.

| 章节 | 内容 |
| --- | --- |
| [00 为什么选择 Debian](#为什么选择-debian) | 选择这个发行版的理由, 以及一点作者私货 (纯观点, 含暴论, 可跳过) |
| [01 Linux 快速入门](#linux-快速入门) | 层级结构, 开机过程, 文件系统, 权限管理, 终端与 shell |
| [02 安装系统本体](#安装系统本体) | 安装前准备, 虚拟机演练, 磁盘分区, 安装选项 |
| [03 新系统基础配置](#新系统基础配置) | 桌面设置, 系统级软件 (ibus-rime, keyd, ghostty), 用户级软件 (yazi, LazyVim) |
| [04 常用操作及相关配置](#常用操作及相关配置) | 挂载 U 盘, ssh, 交换空间, GRUB 主题, 登录界面, 蓝牙, 音量, 关机超时 |
| [05 其他用户级应用](#其他用户级应用-可选) | uv, nvm, TeX Live + zathura, ollama, 微信 |
| [06 常见坑与速查](#常见坑与速查) | 正文里所有坑的汇总表, 出问题先查这里 |
| [07 附录](#附录-可能有用的信息-含-ai-补充内容) | Linux 参考资料, 发送安装报告, 以及 AI 补充内容 |

另外提供一份把所有章节拼在一起的单文件版 all-in-one.md (即本文件), 方便离线阅读或者整份喂给 AI; 它由 [tools/build-all-in-one.sh](./tools/build-all-in-one.sh) 自动生成, 请勿直接编辑. 文中出现的 bash 脚本另外整理在 [scripts/](./scripts/) 目录下, 其中 [.bashrc](./scripts/.bashrc) 文件需追加 (注意不是覆盖) 到 `~/.bashrc` 文件末尾, 其余脚本可以直接复制到 `~/.local/bin/`.

## 关于内容可信度

- 正文都是作者本人在真机上跑过的流程; 来源于 AI 补充的内容只存在于[附录](#附录-可能有用的信息-含-ai-补充内容)后半段, 且均用引用块 (`>`) 特别标出来源为 AI 并声明作者核实情况
- 软件版本会不断变化 (例如文中的 Debian 13.6 与 TeX Live 2026), 实际操作时请以官方文档为准.

## 许可

- 文档 (本文件以及 `docs/` 下的 Markdown): [CC BY-SA 4.0](./LICENSE)
- 脚本 (`scripts/` 与 `tools/` 目录): [MIT](./scripts/LICENSE)
- 版权: © 2026 Shaobing Yuan (文档与脚本)

文档中演示的部分表述, 配置或脚本改编自第三方项目或他人的配置, 其版权与许可仍归原作者. 文中尽量注明来源, 目前明确给出的包括:

- 关于计算机开机启动流程的说明简化自 Brian Ward 的著作 *How Linux works: what every superuser should know* 中的原始表述
- rime 配置补丁的部分写法改编自 rime 官方 wiki (MIT) 和白霜拼音 (GPL-3.0)
- yazi 的 shell 集成来自 yazi 官方文档 (MIT)

如发现遗漏或标注不当, 欢迎指出.

## 纠错与贡献

文中难免有错漏, 欢迎提 Issue 或 PR 指出. 如果某一步在你的机器上表现不同, 也欢迎补充, 说明机器型号, 系统版本和具体现象会很有帮助.

## 致谢

感谢 Debian 和所有自由软件的贡献者, 感谢自由的 (按照最严苛的自由软件标准则是头部大模型中最接近自由的) DeepSeek AI, 也感谢读到这里的人.

---

# 为什么选择 Debian

本篇是观点与背景说明, 不涉及任何具体操作, 只想尽快把系统装起来的读者可以直接跳到下一篇.

Linux 内核加上预装的一系列必要的软件包依赖 (其中最重要的一部分是 GNU 工具) 就可以组成一个开箱即用的 GNU/Linux 操作系统, 称为一个 GNU/Linux 发行版. 这些预装软件包的选取有相当程度的自由性, 因此可选的 Linux 发行版非常多, 它们可以展现出非常不同的特性以适应完全不同的需要. 其中, Debian 是最重要的主流发行版之一, 是众多基于它进一步打包封装的下游发行版 (例如 Ubuntu) 的基石.

我认为 Debian 的优势可以概括为: 自由 (开源), 稳定 (不易崩溃), 轻量 (纯净无冗余), 高效 (响应快, 性能强). 我所选取的软件配置 (xfce4 桌面, rime 输入法, ghostty 终端, 等等) 也都遵循同样的偏好以最大化这种优势. 以下逐条说明:

1. 自由: 简单的理解基本上约等于开源, 但是自由的要求比单纯开源要更加严格, 其内涵也更为深刻. Debian 是一个完全由自由软件构成的操作系统. 因此, 它在最大程度上为用户所掌控, 值得信赖.
2. 稳定: Debian 是最稳定的 Linux 发行版, 应该也可以说是最稳定的操作系统, 没有之一; 除非你以 root 权限故意执行一些破坏性操作, 它几乎不会崩溃.
3. 轻量: 刚才提到它是众多下游发行版的基座, 也就意味着它只包含必要的预装软件包, 基本没有多余的东西, 非常干净而且节省空间.
4. 高效: 砍掉了多余的功能之后, 所有的计算资源都被最大程度地用在刀刃上, 使用体验自然会非常丝滑.

这些优势也就意味着 Debian 同时舍弃了一些特性. Debian 最为人诟病的点在于 apt 包管理器提供的软件包因追求稳定性而版本过旧的问题. 这并不意味着你不能用最新的软件, 仅仅是你需要手动从压缩包安装它们而不能通过包管理器 `sudo apt install <软件包名>` 一行命令安装. 然而, 我并不认为这是一个缺点, 因为依赖包管理器安装所有软件本就是一个不好的习惯, 而 Debian 的这种设计会帮助你养成区分系统级工具和用户级应用的好习惯. 系统级工具提供比较单纯和底层的功能, 用户级应用调用和集成这些底层工具实现比较高级和复杂的功能. 系统级工具基本不会有太大的更新, 用户级应用则可能频繁迭代. 这两者界限没有那么分明, 很多软件可能归到两边都可以; 不过, 如果 apt 安装的版本相对于你的需求而言过旧了, 那应该就只能算作用户级应用. 对于这类应用, 即使可以通过包管理器安装也不推荐这样做, 因为包管理器会将它装进系统目录里, 导致你很难在不借助包管理器的前提下追踪和管理它们. 一旦软件在升级或者运行的过程中出了什么包管理器自己解决不了的问题, 你几乎束手无策, 连完整卸载它都难以做到, 因为它分散在众多系统目录里了. 相比之下, 手动解压缩包将其安装在用户家目录下就能确保你对该软件的完全掌控, 出了问题只要把软件的安装目录整个删除就能将软件本体完全卸载干净, 连提权都不需要.

总而言之, Debian 是一个简单纯粹的发行版. 它的边界感很强, 很多其他操作系统默认的用户层面操作它不会越权替你决定或执行, 但是分内的事它会做到极致可靠. 比如值得一提的是, 相比于用户空间层面上的保守, Debian 实际上在硬件适配性层面做了相当多用户友好的妥协, 包括安装程序自动打包必要的非自由固件 (一般认为算作硬件的一部分而不是操作系统的一部分), 以及通过 shim 签名绕开主板的 secure boot 问题, 因此你基本不用折腾硬件相关的配置 (除非你的硬件非常特殊). 如果你图省事, 或许确实会觉得它用起来没那么方便; 但是如果你想要一个绝对可靠和可控的系统, 那么 Debian 是无可替代的. 对于 Linux 新手来说, 它的上手难度也因为上述原因可能比一些其他发行版略难, 但如果你的目的是深入理解和掌控 Linux, 那么我相信它是最适合的入门之选. 毕竟, 从长远的角度来看, 绕远路才是最短的捷径.

## 技术之外: 何谓自由 (选读)

> [!WARNING]
> 以下内容主观性很强, 是作者对于 Debian 哲学的个人理解, 不感兴趣或不认同可以无视. 如果愿意读下去, 也推荐先完成装机再回过头来看这一小节, 感触或许会更深刻.

AI 时代, 越来越多的人开始担忧自己被 AI 取代, 甚至可能对于一些人来说这种担忧已经成为现实了. 但是, 稍微细想就会发现这非常荒谬: AI 再强也只是工具, 新的工具取代人的提法能成立, 不就意味着人在那之前被有意或无意地当成工具了吗? 这并非是 AI 新引入的问题, 而是一直存在着的不合理事实; AI 只不过把所有人都习以为常熟视无睹的不合理放大到了荒诞的程度, 让人即便不情愿也不得不面对它罢了 -- 这个问题再也不能用 "人能思考" 这种借口搪塞过去了.

那么, 人和工具的区别是什么, 人又是如何被异化成工具的? 我认为是自由; 自由的丧失导致人沦为工具人. 人不论是因为何种理由, 强制性的手段或者非强制的规训, 威逼或者利诱, 不得不做一些事的时候, 就在不同程度上丧失了自身的自由. 在最极端的情况下, 人所有的自由都被剥夺, 每分每秒要做的事都被固定下来, 那么这个人就和具身智能机器人完全没有区别了, 他的感受和想法都不再有任何意义.

自由这个词是标准术语, 但是常被用作庸俗化的理解, 因此还需要更进一步的解释. 自由不是 "想做什么就做什么" 的自由, "想不做什么就不必做什么" 的提法也不准确, 关于机械决定论和自由意志存在性的讨论更是毫不相关. 这里关注的是社会化对人的影响: 一个没有任何社会关系的自然人是完全自由的, 但是他能做到的事是很有限的; 人需要社会化, 和他人分工合作, 这样能让每个人都得到好处, 但分工也就意味着每个人都让渡了自身的一部分自由. 社会化的过程, 也就是人用自身的自由换取便利的过程. 如果还是不好理解的话, 或许可以尝试把 "自由" 这个词替换为 "主体性".

社会化协作是必要的, 但并不是每一笔用自由换取便利的社会化交易都是合理的: 很多时候人由于贪图眼前的便利同时权利意识淡薄, 自觉或不自觉地让渡了太多不必要让渡的自由, 之后才逐渐或者突然意识到有哪里不对劲. 还是用技术相关的场景为例, 人们只看到图形化界面的便利而放任非自由操作系统 Windows 垄断, 于是不得不持续为它付费, 还要忍受它糟糕的性能, 反复爆满的 C 盘, 时不时的蓝屏崩溃和不知道传了什么数据的遥测; 人们只看到非自由 AI agent 眼下更强的智能而去使用它们, 于是在支付高昂溢价的同时模型时不时被降智, 私有数据被盗用, 个人账号被封禁, 无价的绝版书籍被恶意销毁; 等等.

技术进步带来的便利是好事, 但是能带来便利的并非只有技术进步, 还可以是放权给外包; 后者可就绝对不是什么好事了. 如果有人宣称你只需要把某项社会分工放心交给他, 不需要也不能过问或质疑他执行的全部或某些具体细节, 这其中一定有鬼, 不论他摆出怎样的 "好心为你提供方便" "保护知识产权, 保护创新" "存在专业壁垒, 给你你也看不懂" 之类冠冕堂皇的说辞. 如果你对于将思考外包给 AI 这件事抱有本能的警惕性和危机感, 那么就应当也不难理解, 其他的外包行为同样在不同程度地取代你这个人, 或多或少地将你从独立的个体转化为社会机器的螺丝钉. 不论技术如何进步, 权限管理都是不能省去的 "麻烦", 因为权限一旦给出去, 你就不再具备反制的能力; 在没有任何实质性保障 (例如开源) 的情况下, 只凭对对方道德水平的无理由信任而放权一定会造成失权, 只不过失权的恶果很多时候不会立即显现罢了.

在没有对比的情况下, 人们很难准确地意识到自己已经被剥夺了多少自由, 即便意识到了问题, 可能也没的选; 但至少仅就软件技术这方面而言, 我们是拥有足够大的自由软件生态的, 在相当多的时候我们有的选. Debian 的选择是最大程度地尊重和保护用户的自由, 为此有意不去提供某些便利. 很多用户可能对此感到莫名其妙, 认为 Debian 是保守或者教条主义; 但在我看来却恰恰相反, 这反而是最激进和进步的做法. 这个魔幻的时代终会证明 Debian 及所有自由软件支持者们坚守的意义.

---

# Linux 快速入门

本章尝试从实用角度给出日常使用所需的关于 Linux 的最小化理解. 不保证概念上绝对严谨, 只是最简化的表述.

## 操作系统层级结构

计算机可以说是人类最复杂的造物, 或许没有之一. 尽管如此, 和它的交互却并不困难, 因为其底层的复杂性被操作系统层层封装, 最终抽象成简单易用的接口. 为了便于理解, 我们可以将操作系统的层级结构与网络的层级结构类比, 如下表所示:

| 操作系统层级 | 网络层级 |
| ---- | ---- |
| 用户空间 | 应用层 |
| 内核核心 | 传输层 |
| 文件系统 | 网络层 |
| 驱动程序 | 数据链路层 |
| 硬件 | 物理层 |

这个类比并不完全严谨, 实际上有些层级不是那么一一对应, 但是这对于初学者来说是个足够好的近似模型了. 除了内核核心 (kernel core) 外, 文件系统 (filesystem) 和驱动程序 (driver) 通常也被认为是操作系统内核 (kernel) 的一部分, 不过它们相对独立和模块化, 可以在内核运行中随时插入/移除. 日常使用中主要是在和用户空间打交道, 有时需要手动挂载或修改文件系统, 其他部分基本不用管; 这就像是在上网的过程中主要是在和应用层 (例如 http, ssh 等) 打交道, 偶尔需要手动调整网络层设置 (ip 相关), 传输层的 tcp 协议以及底层硬件的物理实现可以不关心.

## 计算机开机启动全过程

> 本小节的内容简化自 Brian Ward 的著作 *How Linux works: what every superuser should know* 一书中的第五章 *How the Linux Kernel Boots* 开头的表述.

计算机的开机启动 (boot) 过程基本上分为如下几步:

1. 通电后, CPU 加载烧录在其硬件中的固件 UEFI (在过去是 BIOS), 在硬盘的 ESP 分区找到 boot loader (对于 Linux 系统是 GRUB2), 启动它并移交控制权
2. boot loader 在硬盘上的特定位置 (对于 Linux 系统是在 `/boot` 目录下) 找到内核并将其加载进内存, 控制权移交至内核
3. 内核启动各类硬件设备并加载相应驱动程序, 随后挂载文件系统
4. 准备就绪后, 启动用户空间的第一个进程 init (在包括 Debian 在内的多数主流现代发行版中是 systemd), 后续由它来管理用户空间的所有进程
5. init 启动所有需开机自启动的服务后展示登录界面, 开机启动完成

## 文件系统

狭义上的文件系统是一种磁盘管理方式. 没有文件系统的情况下, 只能向磁盘的某个地址写入或读取数据, 这对于日常使用的需要而言显然太抽象了. 文件系统允许你创建文件, 接下来你只需要记住文件名, 通过文件名找到文件并向它写入或读取内容, 文件系统会根据你的文件名找到相应的地址写入或者读取数据. 目录是一种特殊的文件类型, 其内容指向其他文件. 通过目录可以构建起目录树, 将所有文件分类整理成易于查找和管理的样式.

在 Linux 中, 文件系统的概念不仅局限于磁盘. 所有硬件设备, 内存, 甚至进程等各种对象都被抽象为特殊的文件系统 (devtmpfs, tmpfs, proc,...) 挂载在特殊目录下 (`/dev/`, `/run/`, `/proc/`, `/sys/`,...), 形式上和磁盘上的普通文件系统挂在同一个虚拟目录树的根节点 `/` 下.

将某个文件系统关联到目录树上某个位置的行为称为 "挂载" (mount), 挂载到目录树上的位置称为 "挂载点" (mount point). 挂载后你对该目录的读写行为就会被映射到对应的文件系统上. 安装时设定好的磁盘分区 (当然后续也可以修改) 开机会自动挂载; 有时也需要手动挂载和卸载一些额外的磁盘分区, 比如说 U 盘. 可用 `findmnt` 命令查看当前完整挂载情况, 或用 `lsblk` 命令查看磁盘挂载情况.

文件名以 `.` 开头的文件是隐藏文件, 在各种文件管理器中都默认不显示, 可以用相应的快捷键解除隐藏. 具体的快捷键因文件管理器而异, 比如 thunar 是 `Ctrl + h`, yazi 是 `.`, 等等.

## 权限管理

Linux 下, root 用户拥有最高权限, 没有任何限制. 没有限制也就意味着, 一旦在执行高危操作时出错, 很容易对系统造成严重的破坏. 因此, 一般推荐以普通用户登录完成日常工作, 只在必要时通过 sudo 命令临时提权为 root, 以最少化 root 权限操作.

除了 root 用户外, 其他用户的权限都是有限的, 这种有限的权限能在很大程度上确保系统和私有数据的安全. 这里的用户不一定是真实用户, 很多后台运行的服务也会创建相应的系统用户账户登录进 Linux 来运行, 所以你只创建了一个用户账户并不意味着系统上只有你一个用户.

文件权限包括读 (r), 写 (w), 以及执行 (x) 权限. 如果用 1 代表有该项权限, 0 代表没有该项权限, 那么 rwx 就可以取值从 0 到 7 的任意一个数, 比如只读就是 r-- = 100 = 4, 可读写就是 rw- = 110 = 6.

一个文件会区分三类用户: 它的属主, 它所属的组的成员, 和其他人. 这三类用户会享有递减的权限. 文件的全部权限信息可由一个三位 8 进制数表示, 常见的包括 700 (属主有全部权限, 其他人禁止访问), 711, 755, 600, 644 等. 用户组可以提供比较精细的权限控制, 用的其实并不多, 所以刚才给出的例子中后两位都是相同的, 也就是只区分属主和非属主.

可通过 `ls -la` 命令查看当前目录下所有文件的权限信息. 该命令的第一列是 10 位字符, 其中第 1 位给出文件类型, 后 9 位给出文件对三类用户的 rwx 权限. 普通用户的权限一般是家目录 `~` (`/home/<用户名>/`) 内可读写, 系统目录 (`/home/` 之外) 大部分文件和目录只读.

## 终端模拟器和 shell 命令行

计算机诞生早期没有图形化界面, 屏幕也只能显示 ASCII 字符, 人与计算机的交互通过 tty 终端 (硬件) 和 shell 交互式工具 (软件) 实现. 现在虽然有了图形化界面, 但是命令行的作用仍无可替代. 在图形化界面中可以通过终端模拟器来使用命令行. 顾名思义, 终端模拟器软件模拟的是过去的终端硬件, 其内部仍然是 shell 负责解读用户的指令并执行. shell 有很多种, Linux 的默认 shell 一般是 bash shell.

传统的终端模拟器也只能显示字符. 不过, 更现代的终端模拟器集成了图形协议和真彩色, 显示图片也没有问题. 我选用的是 ghostty.

shell 运行的命令本质上都是可执行文件. 当你在命令提示符后输入命令 (对于比较长的命令, 输入时可尝试用 `Tab` 键自动补全命令的剩余部分) 并回车, 以 `ls` 为例, shell 会去特定的目录中找名为 `ls` 的可执行文件, 找到就执行, 找不到就报错. 可用 `which` 命令找出命令对应的可执行文件在目录树中的位置, 如 `which ls` 可能输出 `/usr/bin/ls`. shell 找命令的目录通过冒号分隔记录在环境变量 `PATH` 中, 可通过命令 `echo $PATH` 查看. 对于不熟悉的命令, 可以尝试 `<命令名> -h` 或 `<命令名> --help` 快速查看可选项, 或者 `man <命令名>` 查看官方说明文档. 上网查或者问 AI 也是不错的办法.

想要临时执行 `PATH` 外的可执行文件, 需直接输入文件路径, 绝对路径或相对路径均可; 如果想运行的文件在当前工作目录, 应输入 `./<文件名>` 以避免歧义. 想要将它添加为普通命令, 可以把它复制或移动到 `PATH` 包含的某个目录里, 或者将它所在的目录添加进环境变量 `PATH` 里. 推荐尽量少修改环境变量以便管理和维护.

此外, 如果想运行的文件还没有执行权限, 可通过 `chmod u+x <文件路径>` 命令修改文件权限, 添加执行权限 x.

---

# 安装系统本体

本章给出在 Windows 设备上通过 U 盘安装 Debian 作为第二系统的必要流程. 略过了一些相对明确的操作细节, 请善用搜索或 AI.

## 安装前准备

### 虚拟机和 Live

正式安装前, 务必先在虚拟机上完整运行至少一遍 Debian 安装程序, 确认安装过程中的全部操作都没有问题, 安装好的系统也和预期表现一致. 如有问题, 就删掉当前虚拟机重开一个再安装, 直至成功安装且无任何疑问. 虚拟机生成和管理推荐使用 Oracle VirtualBox.

虚拟机模拟安装成功完成后, 推荐在正式安装之前再尝试运行 Debian Live 以确认硬件兼容性和 U 盘烧录操作没有问题. 虚拟机和 Live 这两步基本可以排除正式安装可能遇到的所有问题.

如果有时间, 推荐把官方安装手册 (获取链接: [debian.org/releases/stable/installmanual](https://www.debian.org/releases/stable/installmanual)) 也从头到尾读一遍.

### 获取安装程序镜像和制作启动 U 盘

安装程序镜像 (以及 Live 和官方安装手册) 下载链接可从官网 [debian.org/distrib/](https://www.debian.org/distrib/) 获取. 选用物理上距离你较近的镜像源可能可以加速下载, 但内容都是一样的. 推荐使用 iso 格式的 netinst 小型安装镜像 (小型的意思是安装过程需网络); 安装介质分类推荐选 cd 而非 bd 或 dvd (默认的 cd 版可以从 U 盘启动, bd 和 dvd 版我没试过不清楚); CPU 架构按需选取, 现代个人电脑一般是选 amd64 (适用于 64 位 amd 或 intel, 即 x86_64). 我当时使用的安装镜像是 debian-13.6.0-amd64-netinst.iso (写作本文档时 Debian 的最新稳定版版本号已更新至 13.7.0).

下载完成后建议顺手校验一下镜像 (其实不校验一般也没问题, 但有条件的话还是推荐校验一下). 基本的校验操作需要在从镜像站点文件夹里下载 iso 镜像文件的同时把该文件夹里的 `SHA256SUMS` 或 `SHA512SUMS` 也一并下载下来, 然后验证 iso 文件生成的相同长度的哈希值和 `SHA256SUMS` 或 `SHA512SUMS` 给出的一致. Windows 上生成和比对哈希值的方法请去问 AI, 此处不赘述; 对于 Linux 系统 (以 256 位为例) 只需命令行 `sha256sum -c SHA256SUMS --ignore-missing` (只校验本地已有的文件), 看到 OK 即可; 想更严格一些还可以用 gpg 验证 `SHA256SUMS.sign`, 不过这可能对新手来说有门槛, 此处不展开.

VirtualBox 可以直接从 iso 文件启动虚拟机上的系统安装. 正式安装和运行 Live 则需要先将 iso 镜像烧录到 U 盘. 烧录不是简单的复制文件, 会破坏 U 盘上存储的所有数据, 所以请确保所用的 U 盘上的数据已备份或者没有用了; 但是烧录不会对硬件本身造成任何破坏, U 盘仍可烧录新内容或者重新格式化作为普通存储 U 盘使用. 我使用的烧录软件是 Rufus, 也可以用别的, 操作都大同小异.

### 修改 Windows 设置

正式安装前, 还需要调整 Windows 系统磁盘和文件系统相关的设置以确保两个操作系统能在同一块磁盘上正确运行. 主要是以下三步:

1. 解除 BitLocker: 这是 Windows 的磁盘加密功能, 推荐先保存密码再解除加密, 否则可能访问不了自己的磁盘. 可以从 `设置` 中找到 `设备加密`, 或者从 `控制面板` 找 `系统和安全 > BitLocker 驱动器加密` 来关掉它. 解密磁盘的过程可能要花几十分钟, 期间不要向磁盘写入数据, 建议等待时去干点别的.
2. 为新系统准备磁盘分区: 通过 Windows `磁盘管理` 的 `压缩卷` 功能给新系统腾出空闲的磁盘空间. 推荐至少给到 30G (系统本身占用不到 10G, 再加用户自用的部分和留出备用的部分); 我目前正常使用, 占用约 60G, 其中一小半是 16G 的交换空间和 10G 多的 ollama 本地小模型 (均非必需).
3. 关闭 Windows 快速启动 (和休眠): Windows 快速启动基于休眠技术, 会在关机时把内存中的 Windows 内核放进硬盘以避免下一次冷启动. 在双系统下, 如果两个系统修改了同一块磁盘分区中的文件, 快速启动会导致文件系统和 Windows 内核的记忆不一致, 可能造成文件系统损坏. 可通过 `控制面板` 或命令行关闭此功能. 推荐把休眠功能也一并关闭, 确保快速启动运行不了.

### 引导安装程序

将烧录好的 U 盘插在电脑上, 从 `设置` 里找到 `恢复 > 高级启动`, 通过 `高级启动` 重启电脑会显示 UEFI 启动选项界面, 选择从 U 盘启动, 即可启动 U 盘上烧录的安装程序或者 Live 系统.

Live 系统本身也自带一个安装器, 不过可能和 netinst.iso 提供的有区别, 我没有试过从 Live 直接安装.

## 使用安装程序

默认使用图形安装程序. 虚拟机模拟安装和真机实装都适用.

### 基础选项

第一个选项应该是选择语言和地区. 语言和地区最好设置成相符的样式, 比如简体中文-中国, 否则语言方面可能会出一些奇怪的问题. 选简体中文有一个副作用: 安装程序会自动加上中文本地化任务 (见下文"安装选项"), 而且家目录下的默认目录会变成中文名 (桌面, 下载, 文档, ...). 就我的使用体验来说这不算问题: 日常导航基本都在 yazi 里完成, 中文目录名既不影响 `cd`, 又能一眼区分系统自带目录和我自己建的工作区目录; 如果确实想要英文目录名, 装好系统后改 `~/.config/user-dirs.dirs` 即可. 时区默认会跟随选择的地区, 但是装好系统后可以通过 `dpkg-reconfigure tzdata` 一行命令修改. 接下来的键盘选择用默认选项就好.

然后是网络设置. 如果不是虚拟机直接桥接宿主网络或者通过网线联网, 应该会需要先连 Wi-Fi. 安装器的 Wi-Fi 连接选项似乎只有最简单的 Wi-Fi 名 (SSID) 和密码, 没有高级设置, 因此可能连不了 eduroam 这种需要验证身份的 Wi-Fi 网络. 我是用手机热点完成安装后再在新系统内连接 eduroam. 如果先在 Live 系统连好 Wi-Fi, 再直接通过 Live 自带的安装器安装, 应该可以直接继承 Live 的 Wi-Fi 连接; 我没实际尝试过. 获得网络连接后, Debian 会尝试通过 DHCP 自动配置 IP. 安装器会询问你想设置的主机名和域名, 可以随意设置, 别有空格或特殊符号; 主机名推荐写一个简单好记的 (我的主机名是 debian13), 域名推荐留空 (按回车直接跳过此项). 装完也都可以改.

接下来是添加用户. 默认要设置一个 root 用户用于系统管理和一个普通用户用于日常工作. Debian 默认不会把第一个普通用户加进 sudo 组, 装好系统后需要手动 `su -` 登录 root 再 `usermod -aG sudo <用户名>` 最后 `reboot` 重启生效. 然而, 如果你在这里设置 root 用户时故意把密码留空 (直接回车即可), root 账户会被禁用, 同时你创建的第一个普通用户账户会自动获得 sudo 权限 (官方安装手册 [6.3.2.1](https://www.debian.org/releases/stable/amd64/ch06s03.zh-cn.html#user-setup-root) 确认了这一点). 这样不仅省去了手动设置 sudo 的麻烦, 禁用 root 并以 sudo 作为唯一提权方式本身也更安全; 我就是这样做的.

### 磁盘分区

> [!WARNING]
> 本小节涉及分区表的写入, 操作失误会造成数据丢失且无法撤销. 请务必先在虚拟机里把整套流程演练至烂熟于心, 并在每一步操作前反复确认自己选中的是正确的磁盘和分区.

磁盘分区是最重要, 也最困难和最危险的一步. 虽然安装程序会提供自动分区的选项, 但是自动分区的效果可能会比较傻瓜, 还是推荐手动分区. 请注意, 磁盘上的改动是不随断电消失的; 不像其他很多操作可以通过重启强行重置, 硬盘改坏了是不可逆的. 因此, 务必在虚拟机上模拟你最终想要的分区方案并确认无误, 实际安装时确保操作完全和虚拟机练习时一致. 如果有条件, 可以备份硬盘以防万一, 但是即便有备份也最好不要让它派上用场.

历史上 `/boot` 和 `/swap` 也需要单独分区, 但是现代 Linux 系统一般推荐只分两个区, 根分区 (挂载到 `/`) 和家分区 (挂载到 `/home`). 这样根分区存放系统数据, 家分区存放用户数据, 包括用户级应用, 用户个人配置, 以及工作区. 如果要更精细一些的话其实工作区也可以单独分区, 和配置分开存放; 我没这么做. 分区时推荐使用 LVM (逻辑卷管理): 它最大的好处是把卷组里的空闲空间随时重新分配给任意逻辑卷, 扩容时不必挪动相邻分区; 不启用 LVM 的话眼下设置分区这一步会稍容易一点点, 但是日后想调整各分区的空间大小会麻烦很多 (ext4 支持在线扩容, 但缩小分区始终是高危操作). 此外, 也可以选择加密或者不加密. 本文推荐的两分区方案没有单独的 `/boot` 分区 (`/boot` 落在根分区里), 因此不要直接加密根分区, 否则系统无法引导; 如果想加密根分区和用户数据, 必须分出一个独立且不加密的 `/boot` 分区, 但那属于另一套分区方案, 本文没有实操过, 需要的话请参考官方安装手册. 作为新手可以先不加密.

接下来是具体操作. 在磁盘分区这一步, 先找到之前从 Windows 磁盘管理压缩卷得到的空闲分区 (可通过空间大小判断), 务必反复确认, 千万不要找错了, 不然格式化了有用的磁盘分区后果会非常严重. 选中该空闲分区, 将其设置用作 `LVM 物理卷` 并保存设置, 然后进入 `配置逻辑卷管理器` 选项, 此时安装器会提示 "配置 LVM 需要先把当前分区表写入磁盘, 且此改动不可撤销"; 提示就是字面意思, 在这里选择确认之前发现分区选错了还来得及反悔, 之后就不行了. 确认进入 `配置逻辑卷管理器` 后, 创建一个卷组并选用刚设置好的物理卷, 然后再在该卷组中创建 debian-home 和 debian-root 两个逻辑卷 (命名为别的也都可以, 你自己能区分开就行), 大小按需分配, 空间充裕的话 debian-home 和 debian-root 先各给 50G 和 30G, 不充裕就先至少各给 10G, 不够了再扩. 这一步不需要把卷组的空间都分完, 完全可以保留空闲空间日后灵活扩容给需要的分区. 这一步做好之后退出逻辑卷管理器, 会发现出现了和之前用作物理卷的分区并列的两个逻辑卷 debian-home 和 debian-root. 分别设置这两个逻辑卷用作 `ext4` 文件系统, 并将挂载点设为 debian-home 挂载到 `/home` 和 debian-root 挂载到 `/`, 最后选 `完成分区操作并将修改写入磁盘`. 和刚才 `配置逻辑卷管理器` 会将物理卷分配真正写入磁盘一样, 这一步会将逻辑卷分配方案真正写入磁盘; 此后除非从备份恢复硬盘, 没有任何恢复硬盘原有数据的方法. 再强调一遍, 执行这两步写入操作之前, 务必再最后复核一遍确认所有分区选项无误.

所有没提到的选项都保持默认即可. 这些默认选项当中有一个会给每个分区留出 5% 作为保留块, 仅 root 可使用, 作为磁盘分区被不慎撑爆时的保命措施; 同时, ext4 文件系统元数据也会占用一部分空间, 因此你实际可使用的空间小于你所分配的空间, 这是正常现象. 1024 进制和 1000 进制的单位区别 (GB, MB 和 GiB, MiB) 也可能造成你的空间分配情况和预想的略有不同; 如果介意的话设置时可以多留意一下单位.

### 安装选项

完成分区会自动开始安装系统本体, 放轻松等着进度条跑完就行, 接下来都很简单.

装好系统本体之后会安装一些额外的预装软件. 默认启用网络镜像, 在有网络连接的情况下保持即可. 然后会提示你选择镜像源, 可以手动选也可以保持默认, 选物理上比较近的源一般速度会比较快. 然后会出现一些安装选项, 我只勾选了 `XFCE` 和 `标准系统工具` 两项. 后者是必要的, 前者可以替换为你想要的其他桌面环境 (可以通过虚拟机或者 Live 预览不同桌面的效果, 选用自己喜欢的; 装好系统也可以再更换桌面). 默认会勾选 `Debian 桌面系统` (名字有误导性, 并不是桌面系统的必要依赖, 只是附带的记事本之类的桌面小工具全家桶, 可以不选), `GNOME` (默认桌面环境, 重于 Xfce 轻于 KDE, 风格类似 Mac 桌面), `SSH server` (台式机可以有, 笔记本没必要, 提供便携设备通过 ssh 远程登录本机的功能) 和 `标准系统工具`. 选好确认然后耐心等待安装完成即可. 另外, 前面语言选择简体中文会让安装程序自动加上中文本地化任务 (task-chinese-s), 中文字体这类软件包就是由此而来, 不需要手动安装.

最后一步是安装 boot loader, 也就是 GRUB. 这一步应该不需要做任何干预, 安装程序会自动找到已有的 ESP 分区装好 GRUB.

安装完成后按提示重启系统就行了.

## 问题排查

安装过程的日志会保存在新系统的 `/var/log/installer/` 目录下 (里面有 `partman`, `hardware-summary`, `syslog`, `Xorg.0.log` 等), 可用于排查安装时的问题. 无论安装有没有问题, 都推荐在完成安装后抽空通过 `reportbug installation-reports` 命令向 Debian 提交安装报告; 该命令生成的安装报告会自动带上一部分安装日志, 有助于 Debian 的维护和开发. 更多详情请参见附录[向 Debian 发送安装报告](#向-debian-发送安装报告)一节.

第一次启动新系统万一遇到任何问题, 请别慌, 先去阅读官方文档 [8.6](https://www.debian.org/releases/stable/amd64/ch08s06.zh-cn.html) 节, 尝试通过救援模式修复系统. 如果救援失败, 尝试能否启动 Windows 系统或者 U 盘上的 live 系统, 然后从头开始重装 Debian. 如果这些都没能解决问题 (我认为可能性微乎其微), 请咨询专家.

---

# 新系统基础配置

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

---

# 常用操作及相关配置

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

---

# 其他用户级应用 (可选)

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

---

# 常见坑与速查

正文里的坑分散在各章, 这里集中成表, 方便遇到问题时先查一眼. 每一行都给了对应章节的链接, 细节请回到正文看.

首先是关于系统本身的坑:

| 现象 | 优先排查原因及相应处理 | 详见 |
| --- | --- | --- |
| 安装器连不上 eduroam 这类需要身份验证的 Wi-Fi | 安装器只支持最简单的 Wi-Fi 名 + 密码; 可以用手机热点装完系统, 再在新系统里连 eduroam | [基础选项](#基础选项) |
| Windows 与 Debian 双系统兼容问题 | BitLocker, 快速启动, 时间设置 | [修改 Windows 设置](#修改-windows-设置) [系统时钟显示本地时间](#系统时钟显示本地时间) |
| 想禁用 root, 并让第一个普通用户直接有 sudo | 设置 root 密码时留空 (直接回车) | [基础选项](#基础选项) |
| 想把中文目录名改回英文 | 编辑 `~/.config/user-dirs.dirs` | [基础选项](#基础选项) |
| 使用 U 盘或访问 Windows 分区 | 通过 udisksctl 工具挂载和卸载文件系统, 可进一步封装成 bash 函数 | [手动挂载文件系统](#手动挂载文件系统) |
| 自定义的登录界面背景图不生效 | 家目录权限是 700, `lightdm` 读不到里面的文件, `chmod 711 ~` | [登录界面设置](#登录界面设置) |
| 蓝牙设备配对后没有自动连接 | 可能需要先 `trust <MAC 地址>` 信任该设备 | [蓝牙](#蓝牙) |
| 关机时卡在 "A stop job is running for User Manager for UID 1000" 倒计时 90 秒 | 某个用户进程不响应 SIGTERM; 改小 `/etc/systemd/user.conf` 的 `DefaultTimeoutStopSec` | [关机超时问题](#关机超时问题) |
| 持续运行的程序占用终端 | 用脚本后台启动并重定向输出 | [ollama](#ollama)  [wechat](#wechat) |
| 试图不解压直接运行 AppImage 时报错 | Debian 12 之后默认没有 libfuse2, 比较旧的 AppImage 运行需要装 `libfuse2t64`; 更推荐用 `--appimage-extract` 解压后运行 | [wechat](#wechat) |

接下来是针对特定应用的坑:

| 现象 | 优先排查原因及相应处理 | 详见 |
| --- | --- | --- |
| `Alt + Capslock + <某些键>` keyd 键盘映射失灵 | keyd 的 `Alt` 修饰键边界 bug, 存在硬件依赖; 可改用 oneshot 或尝试 `alt = layer(altgr)` | [keyd](#keyd) |
| `which keyd` 找不到 keyd 可执行文件 | Debian 打包时把可执行文件改名为 `keyd.rvaiya` | [keyd](#keyd) |
| 输入法配置改坏了 | 把 `~/.config/ibus/rime/` 整个删掉, 左键状态栏图标选 "重新部署" 即可复原 | [ibus-rime + rime-frost (白霜拼音)](#ibus-rime--rime-frost-白霜拼音) |
| yazi, LazyVim 里的图标显示成方框 | 没装 Nerd Font, 或装了但没刷新字体缓存 (`fc-cache -fv`) | [yazi + nerd fonts](#yazi--nerd-fonts) |
| neovim 报 `clipboard: error: Error: target STRING not available` | neovim 与 xclip 的已知兼容问题, 改装 `xsel` | [neovim + LazyVim](#neovim--lazyvim) |
| LazyVim 文件管理器里明明存在的文件看不到 | 默认隐藏被 git 忽略的文件, 用快捷键解除隐藏 | [neovim + LazyVim](#neovim--lazyvim) |
| 开启编译后保存 tex 时卡顿, 提示 `lsp timeout` | texlab 解析项目时死循环, 在项目根目录放一个空的 `.latexmkrc` | [texlive + zathura](#texlive--zathura) |

---

# 附录: 可能有用的信息 (含 AI 补充内容)

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

---
