#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# 把 README.md 与 docs/ 下的章节按阅读顺序拼接成 all-in-one.md (生成产物, 请勿直接编辑).
# 用法: tools/build-all-in-one.sh
#
# 说明:
#   - 指向章节的链接会被改写成本文件内部的 #锚点, 因此单文件版也能正常跳转;
#   - 指向仓库内其它文件 (LICENSE, scripts/, tools/) 的链接只在仓库中有效;
#   - 锚点规则与 GitHub 一致 (去掉标点, 空格转连字符, 转小写); 改了章节标题后重新运行本脚本即可.
set -euo pipefail

cd "$(dirname "$0")/.."

out=all-in-one.md
mapfile -t files < <(ls docs/*.md)

# 取某篇的 H1 标题, 生成 GitHub 风格的锚点
h1_anchor() {
  LC_ALL=C.UTF-8 sed -n 's/^# //p' "$1" | head -n 1 |
    tr '[:upper:]' '[:lower:]' |
    LC_ALL=C.UTF-8 sed -e 's/[^[:alnum:] _-]//g' -e 's/ /-/g'
}

declare -A anchor=()
sed_readme=(-e 's|\[all-in-one\.md\](\./all-in-one\.md)|all-in-one.md (即本文件)|g')
for f in "${files[@]}"; do
  base=$(basename "$f")
  anchor[$base]=$(h1_anchor "$f")
  # README 里的 ./docs/xx.md(#片段) 改写成本文件内部的 #锚点
  sed_readme+=(-e "s|](\./docs/${base}#|](#|g")
  sed_readme+=(-e "s|](\./docs/${base})|](#${anchor[$base]})|g")
done

{
  echo "<!-- 本文件由 tools/build-all-in-one.sh 自动生成, 请勿直接编辑; 要改内容请改 README.md 或 docs/ 下对应的章节 -->"
  echo
  echo "> 本文件是 [README](./README.md) 与 [docs/](./docs/) 下各章节按阅读顺序拼接而成的单文件版, 便于离线阅读或整份喂给 AI. 指向章节的链接已改写为文件内跳转; 指向 LICENSE, scripts/ 等仓库内其它文件的链接只在仓库中有效."
  echo
  echo "---"
  echo
  # 开头是 README (背景介绍, 环境, 阅读顺序/目录跳转)
  sed "${sed_readme[@]}" README.md
  echo
  echo "---"
  echo
  for f in "${files[@]}"; do
    # 去掉每篇的导航行; 并把跨篇链接 (./0X-xxx.md#锚点) 改写成本文件内部的 #锚点
    sed -e '/^> 主线导航: /d' -e 's|](\./\([0-9][0-9]-[a-z-]*\.md\)#|](#|g' "$f"
    echo
    echo "---"
    echo
  done
} | awk '
  # Markdown 规范化: 代码块之外连续的多个空行压成一个, 并去掉文件末尾的空行.
  # 结果与 markdownlint 的 MD012/MD047 自动修正一致, 因此在编辑器里保存本文件不会产生改动.
  /^[[:space:]]*```/ { if (pending) { print ""; pending = 0 } ; fence = !fence; print; next }
  fence              { print; next }
  /^[[:space:]]*$/   { pending = 1; next }
  { if (pending) { print ""; pending = 0 } ; print }
' >"$out"

echo "已生成 $out ($(wc -l <"$out") 行, 来自 README.md + ${#files[@]} 个章节)"
