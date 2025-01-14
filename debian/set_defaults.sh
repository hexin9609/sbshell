#!/bin/bash

DEFAULTS_FILE="/etc/sing-box/defaults.conf"

# 提示用户输入 Sub Store 链接，如果为空则报警
while true; do
    read -rp "请输入 Sub Store 链接: " SUB_STORE
    if [ -z "$SUB_STORE" ]; then
        echo -e "\033[0;31m错误: Sub Store 链接不能为空！\033[0m"
    else
        break
    fi
done

# 更新默认配置文件
cat > $DEFAULTS_FILE <<EOF
Sub_Store=$SUB_STORE
EOF

echo "默认配置已更新"
