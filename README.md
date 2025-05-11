## shell 编码规范建议
1. bash是唯一允许用于可执行文件的shell脚本语言；即文件必须以`#!/bin/bash` 开头。
2. STDOUT 和 STDERR
    1. 所有的错误消息都应该发送到STDERR

```plain
建议使用一个函数来打印错误消息和其他状态信息。
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

if ! do_something; then
  err "Unable to do_something"
  exit 1
fi
```

3. 每个文件开头都要是注释；都要以其内容的描述开始
    1. 每个文件都必须要有一个顶级注释；其中包含对其内容的简要概述。

```plain
#!/bin/bash
#
# Perform hot backups of Oracle databases.
```

4. 函数注释

```plain
任何不明显且不简短的函数必须进行注释。无论长度或复杂程度如何，库中的任何函数都必须进行注释。
通过阅读注释（以及提供的自助帮助，如果有的话），其他人应该能够学习如何使用您的程序或使用您库中的函数，而无需阅读代码。
所有函数注释都应描述预期的 API 行为，包括：
函数的描述。
全局变量：使用和修改的全局变量列表。
参数：接受的参数。
输出：输出到 STDOUT 或 STDERR。
返回值：除了最后一条运行命令的默认退出状态之外的返回值。
示例：
#######################################
# Cleanup files from the backup directory.
# Globals:
#   BACKUP_DIR
#   ORACLE_SID
# Arguments:
#   None
#######################################
function cleanup() {
  …
}

#######################################
# Get configuration directory.
# Globals:
#   SOMEDIR
# Arguments:
#   None
# Outputs:
#   Writes location to stdout
#######################################
function get_dir() {
  echo "${SOMEDIR}"
}

#######################################
# Delete a file in a sophisticated manner.
# Arguments:
#   File to delete, a path.
# Returns:
#   0 if thing was deleted, non-zero on error.
#######################################
function del_thing() {
  rm "$1"
}
实现注释
在代码中注释那些棘手、不明显、有趣或重要的部分。

这遵循了谷歌通常的编码注释实践。不要对每个地方都进行注释。如果有一个复杂的算法或者你正在做一些非常规的事情，请添加一个简短的注释。

待办事项注释
使用待办事项注释来标记临时性的代码、短期解决方案或者达到足够好但不完美的代码。

这符合 C++ Guide 中的约定。

待办事项注释应包括全大写的 TODO 字符串，后面跟着问题所涉及的最佳上下文知识人员的姓名、电子邮件地址或其他标识符。主要的目的是拥有一个一致的待办事项，可以通过搜索来找到如何在请求时获取更多详细信息。待办事项并不意味着该人将修复问题。因此，当创建一个待办事项时，几乎总是使用你自己的姓名。

# TODO(mrmonkey): Handle the unlikely edge cases (bug ####)

```

## shell脚本注意事项
```plain
使用 bash。使用 zsh 或 fish 或其他任何 shell，会让其他人很难理解 / 协作。在所有 shell 中，bash 在可移植性和开发体验之间取得了良好的平衡。

只需将第一行设置为 #!/usr/bin/env bash，即使您不为脚本文件赋予可执行权限也可以。

为您的文件使用 .sh（或 .bash）扩展名。不使用扩展名的脚本可能很有创意，但除非您的情况明确依赖于它，否则您可能只是想做一些聪明的事情。聪明的东西很难理解。

在脚本的开头使用 set -o errexit;这样，当一个命令失败时，bash 会退出而不是继续执行脚本的其余部分

最好使用 set -o nounset。您可能有一个很好的理由不这样做，但是我个人认为最好始终设置它。这将使脚本在访问未设置的变量时失败。防止由于变量名拼写错误而造成可怕的意外后果。
当您需要访问可能已设置或未设置的变量时，请使用${VARNAME-} 而不是$VARNAME​ 这样就没问题了。

使用 set -o pipefail。同样，您可能有很好的理由不这样做，但我建议始终设置它.


这将确保即使管道中的一个命令失败，管道命令也将被视为失败。

使用 set -o xtrace，并检查 $TRACE 环境变量。
用于复制粘贴：if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi。
这有助于大大提高脚本的调试能力。
可以通过运行 TRACE=1 ./script.sh 而不是 ./script.sh 来启用调试模式。
在 if / while 语句中使用 [[ ]] 条件，而不是 [ ] 或 test。

[[ ]] 是 bash 内置的关键字，比 [ ] 或 test 更强大。
其中一个例外是在 [[ ]] 条件的左边。但即使在那里，我也建议加上引号。
当您需要不带引号的行为时，使用 bash 数组可能会更好。
在函数中使用局部变量。
始终使用双引号引用变量访问。

接受多种方式的用户请求帮助并做出相应回应。
检查第一个参数是否为 -h 或 --help 或 help 或只有 h 或甚至 -help，在所有这些情况下，打印帮助文本并退出。
请为了您未来的自己而这样做。
在打印错误消息时，请将其重定向到 stderr

通常情况下，这是合适的。
使用 cd "$(dirname "$0")"​，这在大多数情况下都有效。
使用 shellcheck工具检查脚本并注意其警告。



```

```plain
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./script.sh arg-one arg-two

This is an awesome bash script to make your life better.

'
    exit
fi

cd "$(dirname "$0")"

main() {
    echo do awesome stuff
}

main "$@"
```

![](https://cdn.nlark.com/yuque/0/2025/png/2673015/1737098096489-711dc2df-b2cc-40ff-9826-37adbfa53bdf.png)

## shell脚本调试
1. **<font style="color:rgb(6, 6, 7);">使用set -x 进行调试</font>**

```plain
set -x
# 脚本内容

在脚本开始处添加set -x，这将打印出执行的每条命令及其参数，帮助你了解脚本的执行流程。
```

2. **<font style="color:rgb(6, 6, 7);">使用echo打印变量值</font>**

```plain
echo "Current value of variable: $my_var"

在脚本的关键位置使用echo来打印变量的值，这可以帮助你检查变量在不同阶段的状态。
```

3. **<font style="color:rgb(6, 6, 7);">使用trap捕获错误</font>**

```plain
trap 'echo "An error occurred at line $LINENO"' ERR

使用trap命令来捕获脚本执行过程中的错误，并执行一些清理工作或打印错误信息。
```

4. **<font style="color:rgb(6, 6, 7);">使用</font>**`**-n **`**<font style="color:rgb(6, 6, 7);">或</font>**`**-v**`**<font style="color:rgb(6, 6, 7);">选项运行脚本，检查语法</font>**

```plain
使用bash -n script.sh不执行命令，只检查脚本的语法。

使用bash -v script.sh可以打印出被执行的每条命令，用于检查脚本内容。
```

5. **<font style="color:rgb(6, 6, 7);">使用</font>**`**debug**`**<font style="color:rgb(6, 6, 7);">和</font>**`**return**`**<font style="color:rgb(6, 6, 7);">调试函数</font>**

```plain

function my_func {
  # 函数代码
  return
}
```

+ <font style="color:rgb(6, 6, 7);">如果脚本中使用了函数，可以在函数调用后立即使用</font>`return`<font style="color:rgb(6, 6, 7);">语句，然后逐步调试每个函数。</font>
6. **<font style="color:rgb(6, 6, 7);">使用</font>**`**exit**`**<font style="color:rgb(6, 6, 7);">退出脚本</font>**

```plain

if [ some_condition ]; then
  echo "Condition met, exiting."
  exit 1
fi
```

+ <font style="color:rgb(6, 6, 7);">在调试时，可以在关键位置使用</font>`exit`<font style="color:rgb(6, 6, 7);">来退出脚本，这样你可以逐步检查脚本的逻辑。</font>
7. **<font style="color:rgb(6, 6, 7);">使用</font>**`**[[ ]]**`**<font style="color:rgb(6, 6, 7);">进行条件测试</font>**

```plain

if [[ -f "$file" ]]; then
  echo "File exists."
fi
```

+ <font style="color:rgb(6, 6, 7);">使用</font>`[[ ]]`<font style="color:rgb(6, 6, 7);">进行条件测试，它支持模式匹配和更复杂的条件表达式，并且更易于调试。</font>
8. **<font style="color:rgb(6, 6, 7);">使用</font>**`**getopts**`**<font style="color:rgb(6, 6, 7);">处理命令行参数</font>**

```plain

while getopts "a:b:" opt; do
  case $opt in
    a) echo "Option a with value $OPTARG" ;;
    b) echo "Option b with value $OPTARG" ;;
    *) echo "Invalid option: -$OPTARG" >&2 ;;
  esac
done
```

+ <font style="color:rgb(6, 6, 7);">使用</font>`getopts`<font style="color:rgb(6, 6, 7);">来解析命令行参数，这不仅可以简化参数处理，还可以通过打印错误信息来帮助调试。</font>
9. **<font style="color:rgb(6, 6, 7);">使用日志文件记录调试信息</font>**

```plain
exec >  (tee -a debug.log) 2>&1

将调试信息写入日志文件，这样你可以在脚本执行后回顾调试过程。
```



