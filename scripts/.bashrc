# SPDX-License-Identifier: MIT
# 追加到 ~/.bashrc 末尾 (或 source 本文件)

# 将 ~/.local/bin 纳入环境变量 PATH
export PATH="$HOME/.local/bin:$PATH"

# 设置 neovim 为默认文本编辑器
export EDITOR='nvim'
export VISUAL='nvim'

# 重命名的 yazi 官方 shell 集成, 用于移动工作目录
yz() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
  command rm -f -- "$tmp"
}

#   mntd <分区名>   挂载 /dev/<分区名>, 并在家目录创建 mnt 软链接指向 /media/$USER/
#   umntd <分区名>  卸载 /dev/<分区名>, 必要时清理 mnt 软链接
#   pfd <磁盘名>    给可移动磁盘断电以便安全拔出
# 例如: mntd sda1 / umntd sda1 / pfd sda
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
