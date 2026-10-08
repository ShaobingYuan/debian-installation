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
| [00 为什么选择 Debian](./docs/00-why-debian.md) | 选择这个发行版的理由, 以及一点作者私货 (纯观点, 含暴论, 可跳过) |
| [01 Linux 快速入门](./docs/01-linux-primer.md) | 层级结构, 开机过程, 文件系统, 权限管理, 终端与 shell |
| [02 安装系统本体](./docs/02-install.md) | 安装前准备, 虚拟机演练, 磁盘分区, 安装选项 |
| [03 新系统基础配置](./docs/03-base-setup.md) | 桌面设置, 系统级软件 (ibus-rime, keyd, ghostty), 用户级软件 (yazi, LazyVim) |
| [04 常用操作及相关配置](./docs/04-common-tasks.md) | 挂载 U 盘, ssh, 交换空间, GRUB 主题, 登录界面, 蓝牙, 音量, 关机超时 |
| [05 其他用户级应用](./docs/05-optional-apps.md) | uv, nvm, TeX Live + zathura, ollama, 微信 |
| [06 常见坑与速查](./docs/06-pitfalls.md) | 正文里所有坑的汇总表, 出问题先查这里 |
| [07 附录](./docs/07-appendix.md) | Linux 参考资料, 发送安装报告, 以及 AI 补充内容 |

另外提供一份把所有章节拼在一起的单文件版 [all-in-one.md](./all-in-one.md), 方便离线阅读或者整份喂给 AI; 它由 [tools/build-all-in-one.sh](./tools/build-all-in-one.sh) 自动生成, 请勿直接编辑. 文中出现的 bash 脚本另外整理在 [scripts/](./scripts/) 目录下, 其中 [.bashrc](./scripts/.bashrc) 文件需追加 (注意不是覆盖) 到 `~/.bashrc` 文件末尾, 其余脚本可以直接复制到 `~/.local/bin/`.

## 关于内容可信度

- 正文都是作者本人在真机上跑过的流程; 来源于 AI 补充的内容只存在于[附录](./docs/07-appendix.md)后半段, 且均用引用块 (`>`) 特别标出来源为 AI 并声明作者核实情况
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
