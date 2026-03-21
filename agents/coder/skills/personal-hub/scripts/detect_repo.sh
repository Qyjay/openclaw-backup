#!/bin/bash
# detect_repo.sh — 自动检测仓库信息
#
# 用法:
#   bash detect_repo.sh <repo-path> [service-name]
#
# 输出结构化 YAML，供 agent / hub-init 消费。
# 检测内容: 语言、构建系统、命令、git 信息、CI 配置、API 端点
set -uo pipefail

REPO_PATH="${1:?Usage: detect_repo.sh <repo-path> [service-name]}"
SERVICE_NAME="${2:-}"

if [ ! -d "$REPO_PATH" ]; then
    echo "ERROR: repo path does not exist: $REPO_PATH"
    exit 2
fi

cd "$REPO_PATH"

# ── Git 信息 ────────────────────────────────────────────────
GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$REPO_PATH")
GIT_DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "main")
GIT_HEAD=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

# 如果没给 service name，用仓库目录名
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME=$(basename "$GIT_ROOT")
fi

# ── 语言检测 ─────────────────────────────────────────────────
LANGUAGE=""
BUILD_SYSTEM=""

detect_language() {
    if [ -f "go.mod" ]; then
        LANGUAGE="go"
        BUILD_SYSTEM="go"
    elif [ -f "pyproject.toml" ]; then
        LANGUAGE="python"
        if [ -f "uv.lock" ]; then
            BUILD_SYSTEM="uv"
        elif [ -f "poetry.lock" ]; then
            BUILD_SYSTEM="poetry"
        elif [ -f "Pipfile.lock" ]; then
            BUILD_SYSTEM="pipenv"
        else
            BUILD_SYSTEM="pip"
        fi
    elif [ -f "setup.py" ] || [ -f "setup.cfg" ]; then
        LANGUAGE="python"
        BUILD_SYSTEM="pip"
    elif [ -f "package.json" ]; then
        LANGUAGE="nodejs"
        if [ -f "pnpm-lock.yaml" ]; then
            BUILD_SYSTEM="pnpm"
        elif [ -f "yarn.lock" ]; then
            BUILD_SYSTEM="yarn"
        elif [ -f "bun.lockb" ]; then
            BUILD_SYSTEM="bun"
        else
            BUILD_SYSTEM="npm"
        fi
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        LANGUAGE="java"
        BUILD_SYSTEM="gradle"
    elif [ -f "pom.xml" ]; then
        LANGUAGE="java"
        BUILD_SYSTEM="maven"
    elif [ -f "Cargo.toml" ]; then
        LANGUAGE="rust"
        BUILD_SYSTEM="cargo"
    else
        LANGUAGE="unknown"
        BUILD_SYSTEM="unknown"
    fi
}

detect_language

# ── 命令检测 ─────────────────────────────────────────────────
CHECK_CMD=""
TEST_CMD=""
FORMAT_CMD=""
INSTALL_CMD=""

# 先尝试从 Makefile 提取
detect_from_makefile() {
    if [ ! -f "Makefile" ]; then
        return
    fi

    # check 命令: 优先 check-diff, 其次 check, 其次 lint
    if grep -qE "^check-diff:" Makefile 2>/dev/null; then
        CHECK_CMD="make check-diff"
    elif grep -qE "^check:" Makefile 2>/dev/null; then
        CHECK_CMD="make check"
    elif grep -qE "^lint:" Makefile 2>/dev/null; then
        CHECK_CMD="make lint"
    fi

    # test 命令
    if grep -qE "^test:" Makefile 2>/dev/null; then
        TEST_CMD="make test"
    fi

    # format 命令
    if grep -qE "^format:" Makefile 2>/dev/null; then
        FORMAT_CMD="make format"
    elif grep -qE "^fmt:" Makefile 2>/dev/null; then
        FORMAT_CMD="make fmt"
    fi
}

detect_from_makefile

# 兜底: 按语言设默认值（仅填充空字段）
apply_language_defaults() {
    case "$LANGUAGE" in
        python)
            [ -z "$CHECK_CMD" ] && {
                if [ "$BUILD_SYSTEM" = "uv" ]; then
                    CHECK_CMD="uv run ruff check ."
                else
                    CHECK_CMD="ruff check ."
                fi
            }
            [ -z "$TEST_CMD" ] && {
                if [ "$BUILD_SYSTEM" = "uv" ]; then
                    TEST_CMD="uv run pytest tests/ -v"
                else
                    TEST_CMD="pytest tests/ -v"
                fi
            }
            [ -z "$FORMAT_CMD" ] && {
                if [ "$BUILD_SYSTEM" = "uv" ]; then
                    FORMAT_CMD="uv run ruff format ."
                else
                    FORMAT_CMD="ruff format ."
                fi
            }
            if [ "$BUILD_SYSTEM" = "uv" ]; then
                INSTALL_CMD="uv sync"
            elif [ "$BUILD_SYSTEM" = "poetry" ]; then
                INSTALL_CMD="poetry install"
            elif [ "$BUILD_SYSTEM" = "pipenv" ]; then
                INSTALL_CMD="pipenv install --dev"
            else
                INSTALL_CMD="pip install -e '.[dev]'"
            fi
            ;;
        go)
            [ -z "$CHECK_CMD" ] && {
                if command -v golangci-lint &>/dev/null; then
                    CHECK_CMD="golangci-lint run -v"
                else
                    CHECK_CMD="go vet ./..."
                fi
            }
            [ -z "$TEST_CMD" ] && TEST_CMD="go test ./..."
            [ -z "$FORMAT_CMD" ] && {
                if command -v goimports &>/dev/null; then
                    # 检测 go.mod 中的 module 名用于 -local 参数
                    local_module=$(head -1 go.mod 2>/dev/null | awk '{print $2}' || echo "")
                    if [ -n "$local_module" ]; then
                        # 取域名部分作为 -local 参数
                        local_domain=$(echo "$local_module" | cut -d'/' -f1)
                        FORMAT_CMD="goimports -local ${local_domain} -w ."
                    else
                        FORMAT_CMD="goimports -w ."
                    fi
                else
                    FORMAT_CMD="gofmt -w ."
                fi
            }
            INSTALL_CMD="go mod tidy"
            ;;
        nodejs)
            [ -z "$CHECK_CMD" ] && {
                if [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
                    CHECK_CMD="${BUILD_SYSTEM} run lint"
                fi
            }
            [ -z "$TEST_CMD" ] && TEST_CMD="${BUILD_SYSTEM} test"
            [ -z "$FORMAT_CMD" ] && {
                if [ -f "package.json" ] && grep -q '"format"' package.json 2>/dev/null; then
                    FORMAT_CMD="${BUILD_SYSTEM} run format"
                fi
            }
            INSTALL_CMD="${BUILD_SYSTEM} install"
            ;;
        java)
            if [ "$BUILD_SYSTEM" = "gradle" ]; then
                [ -z "$CHECK_CMD" ] && CHECK_CMD="./gradlew check -x test"
                [ -z "$TEST_CMD" ] && TEST_CMD="./gradlew test"
                [ -z "$FORMAT_CMD" ] && {
                    if [ -f "build.gradle" ] && grep -q "spotless" build.gradle 2>/dev/null; then
                        FORMAT_CMD="./gradlew spotlessApply"
                    elif [ -f "build.gradle.kts" ] && grep -q "spotless" build.gradle.kts 2>/dev/null; then
                        FORMAT_CMD="./gradlew spotlessApply"
                    fi
                }
                INSTALL_CMD="./gradlew build -x test"
            else
                [ -z "$CHECK_CMD" ] && CHECK_CMD="mvn verify -DskipTests"
                [ -z "$TEST_CMD" ] && TEST_CMD="mvn test"
                INSTALL_CMD="mvn install -DskipTests"
            fi
            ;;
        rust)
            [ -z "$CHECK_CMD" ] && CHECK_CMD="cargo clippy -- -D warnings"
            [ -z "$TEST_CMD" ] && TEST_CMD="cargo test"
            [ -z "$FORMAT_CMD" ] && FORMAT_CMD="cargo fmt"
            INSTALL_CMD="cargo build"
            ;;
    esac
}

apply_language_defaults

# ── CI 部署信息 ──────────────────────────────────────────────
CI_APPS=""
CI_LANE_SUPPORT="false"

detect_ci() {
    if [ ! -f ".gitlab-ci.yml" ]; then
        return
    fi

    # 提取 APP_NAME
    local apps
    apps=$(grep -oE 'APP_NAME[: ="]+[a-zA-Z0-9_-]+' .gitlab-ci.yml 2>/dev/null \
        | sed 's/APP_NAME[: ="]*//g' \
        | sort -u \
        | tr '\n' ',' \
        | sed 's/,$//')
    CI_APPS="$apps"

    # 检测泳道支持
    if grep -qE 'test/lane|sync-lane' .gitlab-ci.yml 2>/dev/null; then
        CI_LANE_SUPPORT="true"
    fi
}

detect_ci

# ── API 扫描 ─────────────────────────────────────────────────
APIS=""

detect_apis() {
    local api_list=""

    # Thrift IDL
    local thrift_files
    thrift_files=$(find . -maxdepth 3 -name "*.thrift" -not -path './.git/*' 2>/dev/null | head -5)
    if [ -n "$thrift_files" ]; then
        api_list="${api_list}  - type: thrift\n    files: $(echo "$thrift_files" | tr '\n' ',' | sed 's/,$//')\n"
    fi

    # Protobuf IDL
    local proto_files
    proto_files=$(find . -maxdepth 3 -name "*.proto" -not -path './.git/*' 2>/dev/null | head -5)
    if [ -n "$proto_files" ]; then
        api_list="${api_list}  - type: grpc\n    files: $(echo "$proto_files" | tr '\n' ',' | sed 's/,$//')\n"
    fi

    # OpenAPI/Swagger
    local openapi_files
    openapi_files=$(find . -maxdepth 3 \( -name "openapi.*" -o -name "swagger.*" -o -name "api-spec.*" \) -not -path './.git/*' 2>/dev/null | head -5)
    if [ -n "$openapi_files" ]; then
        api_list="${api_list}  - type: openapi\n    files: $(echo "$openapi_files" | tr '\n' ',' | sed 's/,$//')\n"
    fi

    # HTTP 路由文件 (按语言)
    case "$LANGUAGE" in
        python)
            local route_files
            route_files=$(grep -rlE '@(app|router)\.(get|post|put|delete|patch)' --include="*.py" . 2>/dev/null | head -5)
            if [ -n "$route_files" ]; then
                api_list="${api_list}  - type: http\n    files: $(echo "$route_files" | tr '\n' ',' | sed 's/,$//')\n"
            fi
            ;;
        go)
            local route_files
            route_files=$(grep -rlE '(HandleFunc|Handle|Get|Post|Put|Delete|r\.(GET|POST))' --include="*.go" . 2>/dev/null | grep -v '_test.go' | head -5)
            if [ -n "$route_files" ]; then
                api_list="${api_list}  - type: http\n    files: $(echo "$route_files" | tr '\n' ',' | sed 's/,$//')\n"
            fi
            ;;
        nodejs)
            local route_files
            route_files=$(grep -rlE '(app|router)\.(get|post|put|delete|patch)' --include="*.ts" --include="*.js" . 2>/dev/null | head -5)
            if [ -n "$route_files" ]; then
                api_list="${api_list}  - type: http\n    files: $(echo "$route_files" | tr '\n' ',' | sed 's/,$//')\n"
            fi
            ;;
        java)
            local route_files
            route_files=$(grep -rlE '@(GetMapping|PostMapping|PutMapping|DeleteMapping|RequestMapping)' --include="*.java" . 2>/dev/null | head -5)
            if [ -n "$route_files" ]; then
                api_list="${api_list}  - type: http\n    files: $(echo "$route_files" | tr '\n' ',' | sed 's/,$//')\n"
            fi
            ;;
    esac

    # MCP 服务
    local mcp_files
    mcp_files=$(grep -rlE '(mcp|MCP|McpServer|mcp_server)' --include="*.py" --include="*.ts" --include="*.go" . 2>/dev/null | grep -v '_test' | grep -v 'test_' | head -3)
    if [ -n "$mcp_files" ]; then
        api_list="${api_list}  - type: mcp\n    files: $(echo "$mcp_files" | tr '\n' ',' | sed 's/,$//')\n"
    fi

    APIS="$api_list"
}

detect_apis

# ── 目录结构 ─────────────────────────────────────────────────
DIR_TREE=$(find . -maxdepth 2 -type d \
    | grep -vE '\.git|node_modules|__pycache__|\.venv|vendor|\.mypy_cache|\.ruff_cache|\.pytest_cache|dist|build|\.tox|\.egg' \
    | sort)

# ── 入口文件检测 ─────────────────────────────────────────────
ENTRY_FILES=""

detect_entry_files() {
    case "$LANGUAGE" in
        python)
            ENTRY_FILES=$(find . -maxdepth 4 \( -name "main.py" -o -name "app.py" -o -name "main_server.py" -o -name "manage.py" -o -name "wsgi.py" -o -name "asgi.py" \) -not -path './.git/*' -not -path './.venv/*' 2>/dev/null | sort)
            ;;
        go)
            ENTRY_FILES=$(find . -maxdepth 4 -name "main.go" -not -path './.git/*' -not -path './vendor/*' 2>/dev/null | sort)
            ;;
        nodejs)
            ENTRY_FILES=$(find . -maxdepth 3 \( -name "index.ts" -o -name "index.js" -o -name "app.ts" -o -name "app.js" -o -name "server.ts" -o -name "server.js" \) -not -path './node_modules/*' -not -path './.git/*' 2>/dev/null | sort)
            ;;
        java)
            ENTRY_FILES=$(grep -rlE '@SpringBootApplication|public static void main' --include="*.java" . 2>/dev/null | head -5 | sort)
            ;;
        rust)
            ENTRY_FILES=$(find . -maxdepth 3 -name "main.rs" -not -path './.git/*' 2>/dev/null | sort)
            ;;
    esac
}

detect_entry_files

# ── 框架检测 ─────────────────────────────────────────────────
FRAMEWORK=""

detect_framework() {
    case "$LANGUAGE" in
        python)
            if grep -q "fastapi" pyproject.toml 2>/dev/null || grep -q "fastapi" requirements.txt 2>/dev/null; then
                FRAMEWORK="FastAPI"
            elif grep -q "django" pyproject.toml 2>/dev/null || grep -q "django" requirements.txt 2>/dev/null; then
                FRAMEWORK="Django"
            elif grep -q "flask" pyproject.toml 2>/dev/null || grep -q "flask" requirements.txt 2>/dev/null; then
                FRAMEWORK="Flask"
            fi
            ;;
        go)
            if grep -q "github.com/gin-gonic/gin" go.mod 2>/dev/null; then
                FRAMEWORK="Gin"
            elif grep -q "github.com/cloudwego/kitex" go.mod 2>/dev/null; then
                FRAMEWORK="Kitex"
            elif grep -q "github.com/cloudwego/hertz" go.mod 2>/dev/null; then
                FRAMEWORK="Hertz"
            elif grep -q "github.com/labstack/echo" go.mod 2>/dev/null; then
                FRAMEWORK="Echo"
            elif grep -q "github.com/gorilla/mux" go.mod 2>/dev/null; then
                FRAMEWORK="Gorilla"
            fi
            ;;
        nodejs)
            if grep -q '"express"' package.json 2>/dev/null; then
                FRAMEWORK="Express"
            elif grep -q '"next"' package.json 2>/dev/null; then
                FRAMEWORK="Next.js"
            elif grep -q '"nestjs"' package.json 2>/dev/null || grep -q '"@nestjs/core"' package.json 2>/dev/null; then
                FRAMEWORK="NestJS"
            elif grep -q '"fastify"' package.json 2>/dev/null; then
                FRAMEWORK="Fastify"
            fi
            ;;
        java)
            if grep -qE "spring-boot|org.springframework.boot" build.gradle build.gradle.kts pom.xml 2>/dev/null; then
                FRAMEWORK="Spring Boot"
            fi
            ;;
    esac
}

detect_framework

# ── 输出结构化结果 ───────────────────────────────────────────
echo "=== REPO DETECTION ==="
echo ""
echo "service_name: ${SERVICE_NAME}"
echo "repo: ${GIT_REMOTE}"
echo "local_path: ${GIT_ROOT}"
echo "default_branch: ${GIT_DEFAULT_BRANCH}"
echo "head_commit: ${GIT_HEAD}"
echo ""
echo "language: ${LANGUAGE}"
echo "build_system: ${BUILD_SYSTEM}"
echo "framework: ${FRAMEWORK}"
echo ""
echo "commands:"
echo "  check: \"${CHECK_CMD}\""
echo "  test: \"${TEST_CMD}\""
echo "  format: \"${FORMAT_CMD}\""
echo "  install: \"${INSTALL_CMD}\""
echo ""
echo "ci:"
echo "  apps: \"${CI_APPS}\""
echo "  lane_support: ${CI_LANE_SUPPORT}"
echo ""
echo "entry_files:"
if [ -n "$ENTRY_FILES" ]; then
    echo "$ENTRY_FILES" | while read -r f; do
        echo "  - $f"
    done
else
    echo "  (none detected)"
fi
echo ""
echo "apis:"
if [ -n "$APIS" ]; then
    echo -e "$APIS"
else
    echo "  (none detected)"
fi
echo ""
echo "directory_structure:"
echo "$DIR_TREE" | while read -r d; do
    echo "  $d"
done
echo ""
echo "=== END REPO DETECTION ==="
