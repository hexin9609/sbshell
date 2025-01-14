#!/bin/bash

# 定义颜色
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

# 手动输入的配置文件
MANUAL_FILE="/etc/sing-box/manual.conf"
DEFAULTS_FILE="/etc/sing-box/defaults.conf"

# 获取当前模式
MODE=$(grep -oP '(?<=^MODE=).*' /etc/sing-box/mode.conf)

# 提示用户输入参数的函数
prompt_user_input() {
    while true; do
        read -rp "请输入 Sub Store 链接（不填使用默认值）: " USER_INPUT
        if [ -z "$USER_INPUT" ]; then
            SUB_STORE=$(grep Sub_Store "$DEFAULTS_FILE" 2>/dev/null | cut -d'=' -f2-)
            if [ -z "$SUB_STORE" ]; then
                echo -e "${RED}未设置默认 Sub Store 链接，请在菜单中设置！${NC}"
                continue
            fi
            echo -e "${CYAN}使用默认 Sub Store 链接: $SUB_STORE${NC}"
        else
            SUB_STORE="$USER_INPUT"
        fi
        break
    done
}

while true; do
    prompt_user_input

    # 显示用户输入的配置信息
    echo -e "${CYAN}你输入的配置信息如下:${NC}"
    echo "Sub Store 链接: $SUB_STORE"

    read -rp "确认输入的配置信息？(y/n): " confirm_choice
    if [[ "$confirm_choice" =~ ^[Yy]$ ]]; then
        # 更新手动输入的配置文件
        echo "Sub_Store=$SUB_STORE" > "$MANUAL_FILE"
        echo "手动输入的配置已更新"

        # 构建完整的配置文件URL
        FULL_URL="${SUB_STORE}"
        echo "生成完整订阅链接: $FULL_URL"

        # 调试：打印出完整 URL，检查是否有错误
        echo "调试：完整链接为 $FULL_URL"

        while true; do
            # 下载并验证配置文件
            if curl -L --connect-timeout 10 --max-time 30 "$FULL_URL" -o /etc/sing-box/config.json; then
                echo "配置文件下载完成，并验证成功！"
                if ! sing-box check -c /etc/sing-box/config.json; then
                    echo "配置文件验证失败"
                    exit 1
                fi
                break
            else
                echo "配置文件下载失败"
                read -rp "下载失败，是否重试？(y/n): " retry_choice
                if [[ "$retry_choice" =~ ^[Nn]$ ]]; then
                    exit 1
                fi
            fi
        done

        break
    else
        echo -e "${RED}请重新输入配置信息。${NC}"
    fi
done
