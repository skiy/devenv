#!/usr/bin/env bash

##
# 合并扩展库到脚本
##

# 定义变量
start="# SH_START"
end="# SH_END"

replacement="_include.sh"
target_file=""

[ $# -eq 0 ] || target_file="${1}"

echo "target_file $target_file"

# 检查替换文件是否存在
if [ ! -f "$replacement" ]; then
  echo "Error: $replacement not found!"
  exit 1
fi

# 检查目标文件是否存在
if [ ! -f "$target_file" ]; then
  echo "Error: $target_file not found!"
  exit 1
fi

# 先删除其之间的内容
OS_TYPE=$(uname | tr '[:upper:]' '[:lower:]')
if [[ "$OS_TYPE" = "linux" ]]; then
  sed -i -e "/$start/,/$end/{ /$start/{p; d}; /$end/p; d }" "$target_file"
else
  sed -i "" -e "/$start/,/$end/{ /$start/{p; d}; /$end/p; d }" "$target_file"
fi

if [ $# -ge 2 ]; then
  printf "delete %s #START to #END\n" "$target_file"
  exit
fi

# 获取替换区域的开始行号和结束行号
start_line=$(grep -n "$start" "$target_file" | cut -d ':' -f 1)
end_line=$(grep -n "$end" "$target_file" | cut -d ':' -f 1)

# 检查是否找到了开始和结束标记
if [ -z "$start_line" ] || [ -z "$end_line" ]; then
  echo "Error: $start or $end not found in $target_file!"
  exit 1
fi

# 计算替换区域的行数
num_lines=$((end_line - start_line))

# 创建一个临时文件
tmp_file=$(mktemp)

# 将目标文件中的替换区域之前的部分写入临时文件
head -n "$((start_line))" "$target_file" >"$tmp_file"

# 将替换文件的内容写入临时文件
cat <(tail -n "+$((start_line + 1))" "$target_file" | head -n "$((num_lines - 1))") <(tail -n +2 "$replacement") >>"$tmp_file"

# 将目标文件中的替换区域之后的部分写入临时文件
tail -n "+$((end_line))" "$target_file" >>"$tmp_file"

# 将临时文件重命名为目标文件
mv "$tmp_file" "$target_file"

echo "Merged $replacement to $target_file"
