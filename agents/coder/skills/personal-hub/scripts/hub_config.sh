#!/bin/bash
# hub_config.sh — Hub 配置工具（个人版，无 registry）
#
# 用法:
#   bash hub_config.sh env              # 输出环境变量
#   bash hub_config.sh detect [path]    # 检测当前项目信息
set -uo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "$0")" && pwd)"
HUB_ROOT="$(dirname "$SCRIPT_DIR")"

export HUB_ROOT

_CMD="${1:-}"

case "$_CMD" in
    env)
        echo "HUB_ROOT=${HUB_ROOT}"
        echo "SCRIPTS_DIR=${SCRIPT_DIR}"
        ;;

    detect)
        REPO_PATH="${2:-$(pwd)}"
        bash "${SCRIPT_DIR}/detect_repo.sh" "$REPO_PATH"
        ;;

    pull|services|service|local_path)
        # 兼容原版命令，个人版不需要 registry
        echo "NOTE: 个人版不使用 registry。项目信息从当前目录自动检测。"
        ;;

    "")
        ;;

    *)
        echo "Usage: hub_config.sh [env|detect [path]]" >&2
        exit 1
        ;;
esac
