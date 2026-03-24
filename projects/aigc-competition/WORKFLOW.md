# 开发工作流 — AIGC 比赛项目

## 技能库（已安装）

### 核心 Skills
| Skill | 路径 | 用途 |
|-------|------|------|
| **minimax-frontend-dev** | `~/.agents/skills/minimax-frontend-dev/` | MiniMax 媒体 API（图片/视频/音频/TTS）、动效系统、资源管理 |
| **minimax-fullstack-dev** | `~/.agents/skills/minimax-fullstack-dev/` | 后端架构、REST API、JWT 认证、SSE 实时、数据库 |
| **uniapp** | `~/.agents/skills/uniapp/` | UniApp 核心 API（路由/存储/媒体/位置/UI） |
| **uniapp-uview** | `~/.agents/skills/uniapp-uview/` | uView UI 组件库集成 |
| **mobile-app-ui-design** | `~/.agents/skills/mobile-app-ui-design/` | 移动端 UI 设计规范（60/30/10 配色、8pt 网格） |

### MiniMax API 资源生成（来自 frontend-dev skill）

#### 脚本位置
```
~/.minimax-skills/skills/frontend-dev/scripts/
├── minimax_image.py    # 图片生成（同步）
├── minimax_video.py    # 视频生成（异步：创建→轮询→下载）
├── minimax_music.py    # 音乐生成（同步）
└── minimax_tts.py      # 文字转语音（同步）
```

#### 环境变量
```bash
MINIMAX_API_KEY=$MINIMAX_TOKENPLAN_API_KEY
```

#### 图片生成（我们已验证可用的方式）
```bash
# 直接 curl（已验证有效）
curl -s -X POST "https://api.minimax.chat/v1/image_generation" \
  -H "Authorization: Bearer $MINIMAX_TOKENPLAN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "image-01",
    "prompt": "描述",
    "aspect_ratio": "1:1",
    "n": 1,
    "prompt_optimizer": true
  }'
```

#### 参考文档
```
~/.minimax-skills/skills/frontend-dev/references/
├── minimax-cli-reference.md    # CLI 参数速查
├── asset-prompt-guide.md       # 提示词工程规则
├── minimax-tts-guide.md        # TTS 用法和声音列表
├── minimax-music-guide.md      # 音乐生成
├── minimax-video-guide.md      # 视频生成（摄像头命令）
├── minimax-image-guide.md      # 图片生成（比例/批量）
└── minimax-voice-catalog.md    # 全部声音 ID
```

### 后端架构模式（来自 fullstack-dev skill）

#### 推荐架构
- **项目结构**：Feature-first（按功能模块组织，非按层组织）
- **API 风格**：REST + JSON
- **认证**：JWT + Refresh Token
- **实时**：SSE（用于 AI 流式响应）
- **错误处理**：类型化错误层次 + 全局错误处理器

#### 后端技术栈（推荐）
```
Python (FastAPI) 或 Node.js (Express/Hono)
├── 认证层 (JWT)
├── MiniMax API 代理层
├── 用户数据层 (SQLite/PostgreSQL)
├── Agent 记忆层 (向量存储 / JSON)
└── SSE 流式响应
```

#### Scaffolding Checklist（来自 fullstack-dev）
- [ ] 健康检查端点 `/health`
- [ ] 全局错误处理中间件
- [ ] 请求 ID 追踪
- [ ] CORS 配置
- [ ] 环境变量验证
- [ ] 结构化日志
- [ ] 优雅关闭

---

## 开发流程

### Phase 1：前端原型（当前阶段）
```
Iris 出设计规范 → BB 用 UniApp 写页面 → H5 浏览器预览 → Master 审核
```

### Phase 2：后端搭建
```
参考 fullstack-dev skill → FastAPI/Express 搭建 → MiniMax API 对接 → SSE 流式
```

### Phase 3：前后联调
```
前端接 API → 真实数据替换 mock → 端到端测试
```

### Phase 4：真机测试
```
UniApp 云打包 APK → vivo 手机安装 → 团队成员测试
```

---

## Agent 分工

| Agent | 职责 | 使用的 Skill |
|-------|------|-------------|
| 👑 Silvana | 统筹协调、任务分配、代码审查 | 全部 |
| 🔮 BB (Babette Lucy) | 编码实现 | uniapp, uniapp-uview, minimax-fullstack-dev |
| 🎨 Iris | 设计规范、素材生成 | mobile-app-ui-design, minimax-frontend-dev (图片/视频) |

---

*Last updated: 2026-03-23*
