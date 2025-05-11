#!/bin/bash
#示例脚本，脚本通用规范
set -o errexit  # 当命令执行失败时，立即退出脚本
set -o nounset # 当使用未设置的变量时，立即退出脚本
set -o pipefail # 当管道中的任何命令失败时，立即退出脚本

# 获取当前时间 格式为 YYYY-MM-DD HH:MM:SS
get_current_time() {
  date +"%Y-%m-%d %H:%M:%S"
}

# --- helper functions for logs ---
info()
{
    local timestamp=$(get_current_time)
    echo "[$timestamp] [INFO] " "$@"
}
warn()
{
    local timestamp=$(get_current_time)
    echo "[$timestamp] [WARN] " "$@" >&2
}
fatal()
{
    local timestamp=$(get_current_time)
    echo "[$timestamp] [ERROR] " "$@" >&2
    exit 1
}

# --- add quotes to command arguments ---
#
#该函数用于给命令行参数添加单引号，并且处理参数中已有的单引号，避免语法错误。
#具体做法是将参数中的单引号替换为 '\''，然后在参数首尾添加单引号。
## 运行示例
#result=$(quote "hello world" "it's a test")
#echo $result
#'hello world' 'it'\''s a test'
quote() {
    for arg in "$@"; do
        printf '%s\n' "$arg" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/'/"
    done
}

# --- add indentation and trailing slash to quoted args ---
#该函数在 quote 函数的基础上，为每个参数添加缩进和换行符，
# 并且在每行末尾添加反斜杠 \，用于多行命令的参数分割。
# 运行示例
#quote_indent "hello world" "it's a test"
#    'hello world' \
#    'it'\''s a test' \
quote_indent() {
    printf ' \\\n'
    for arg in "$@"; do
        printf '\t%s \\\n' "$(quote "$arg")"
    done
}

# --- escape most punctuation characters, except quotes, forward slash, and space ---
#该函数用于转义大部分标点符号（除引号、斜杠和空格），在这些符号前添加反斜杠 \，避免这些符号在 shell 中被解释为特殊字符。
# 运行示例
#escape "hello[world]!"
#hello\[world\]\!
escape() {
    printf '%s' "$@" | sed -e 's/\([][!#$%&()*;<=>?\_`{|}]\)/\\\1/g;'
}

# --- escape double quotes ---
# 该函数用于转义双引号，在双引号前添加反斜杠 \，避免双引号在 shell 中被解释为特殊字符。
# 运行示例 escape_dq 'hello "world"'
# hello \"world\"
escape_dq() {
    printf '%s' "$@" | sed -e 's/"/\\"/g'
}


# --- set arch and suffix, fatal if architecture not supported ---
setup_verify_arch() {
    if [ -z "$ARCH" ]; then
        ARCH=$(uname -m)
    fi
    case $ARCH in
        amd64)
            ARCH=amd64
            SUFFIX=
            ;;
        x86_64)
            ARCH=amd64
            SUFFIX=
            ;;
        arm64)
            ARCH=arm64
            SUFFIX=-${ARCH}
            ;;
        s390x)
            ARCH=s390x
            SUFFIX=-${ARCH}
            ;;
        aarch64)
            ARCH=arm64
            SUFFIX=-${ARCH}
            ;;
        arm*)
            ARCH=arm
            SUFFIX=-${ARCH}hf
            ;;
        *)
            fatal "Unsupported architecture $ARCH"
    esac
}