# MiniMax 开源合集 — 修订大纲 v2

## 标题
**《MiniMax 开源全景：从基础模型到开发者工具链》**
副标题：模型权重、学术论文、Agent 框架、MCP 工具、评测基准——MiniMax 的开源版图远比你想象的大

## 写作风格
- 参考 MiniMax 官方 GitHub README 的语气：专业克制、数据先行、技术自信
- 不吹不黑，用数据和事实说话
- 不用"震撼""颠覆"等过度营销词汇
- 适度使用 emoji 区分段落节奏

## 大纲结构

### 1. 开篇（200字）
- 引入：MiniMax 对开源社区的系统性投入
- 概览：20+ 仓库 / 16 个模型权重 / 8 个数据集 / 10 个 Skills
- 配图建议：MiniMax 开源全景图（自制信息图，分 4 大板块 icon）

### 2. 模型开源：从 MiniMax-01 到 M2.5（800字）
- 2.1 MiniMax-01（一笔带过，100字）：456B 参数、Lightning Attention、4M 上下文
- 2.2 M1（一句话提及）：首个大规模混合注意力推理模型
- 2.3 M2 系列（主体，600字）：
  - M2：10B 激活/230B 总参，开源模型 AA 综合 #1，SWE-bench 69.4%
  - M2.1：SWE-bench 74%，多语言编码接近 Opus，提出 VIBE 评测
  - M2.5：SWE-bench 80.2%，"$1/小时" 极致性价比，37% 加速，提出 RISE 评测
  - 关键对比表：M2 → M2.1 → M2.5 性能跃迁
- 2.4 展望（一句话）：M2.7 已在内部使用
- HuggingFace 数据：16 个模型权重、M2.5 下载量 493k
- 配图建议：M2 系列 SWE-bench 进步曲线（来自 M2.5 README bench_10.png）

### 3. 学术开源：把论文变成可用的代码（600字）
- 3.1 SynLogic（NeurIPS 2025）：35 种逻辑推理任务、RL 训练数据合成
- 3.2 VTP：视觉编码器新范式，发现 VAE 无法 scale 的问题
- 3.3 V-Triune / Orsta：首次视觉推理+感知联合 RL，MEGA-Bench +14.1%
- 3.4 OctoBench (mini-vela)：Agent 指令遵循评测框架
- 强调：不止论文，代码 + 数据 + 训练好的模型全部开源
- 配图建议：论文列表截图 + arXiv 链接卡片

### 4. 开发者工具：让 MiniMax 能力触手可及（800字）
- 4.1 Mini-Agent：完整 Agent 框架 Demo
- 4.2 MCP 全家桶（4 个项目）：Python/JS/Coding-Plan/Search
- 4.3 OpenRoom：浏览器内 AI 桌面操作系统
- 4.4 Provider-Verifier：第三方部署质量验证
- 4.5 Vercel AI SDK Provider
- 配图建议：MCP 工具链架构图 + OpenRoom 桌面截图

### 5. Skills 生态：10 个开箱即用的专业技能包（400字）
- 全栈开发（前端/后端/Android/iOS）
- 创意工具（Shader/GIF 贴纸）
- 办公自动化（PDF/PPT/Excel/Word）
- 配图建议：10 个 Skill 的功能矩阵图

### 6. 评测数据集：为行业定义标准（300字）
- VIBE / OctoBench / OctoCodingBench / SynLogic / role-play-bench / TTS-Multilingual / MR-NIAH
- 配图建议：数据集列表 + 下载量

### 7. 结语（200字）
- "Intelligence with Everyone" 理念
- GitHub 链接 + 社区入口
- 配图建议：GitHub 组织页截图 + QR code
