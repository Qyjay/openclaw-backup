# MiniMax 开源全景：从基础模型到开发者工具链

> 模型权重、学术论文、Agent 框架、MCP 工具、评测基准——MiniMax 的开源版图远比你想象的大。

---

MiniMax 一直在做一件事：把技术能力系统性地交给社区。

截至目前，MiniMax 在 GitHub（github.com/MiniMax-AI）上开源了 **20+ 个项目**，在 HuggingFace 上发布了 **16 个模型权重** 和 **8 个评测数据集**，提供了 **10 个开箱即用的 Skills 技能包**。从基础大模型到开发者工具链，从学术论文到评测基准，MiniMax 的开源不是一个点，而是一个面。

这篇文章，把这些项目一次讲清楚。

**【配图建议 ①】** 制作一张 MiniMax 开源全景信息图，分四大板块：🧠 基础模型 / 📄 学术研究 / 🛠️ 开发者工具 / 📊 评测数据集，标注各板块项目数量和总 Star 数。

---

## 一、模型开源：从 MiniMax-01 到 M2.5

### 起点：MiniMax-01

2025 年 1 月，MiniMax 开源了 MiniMax-Text-01 和 MiniMax-VL-01。

MiniMax-Text-01 是一个 456B 参数的 MoE 大语言模型，每个 token 激活 45.9B 参数。它采用了 Lightning Attention + Softmax Attention 的混合架构，训练上下文长度达到 100 万 token，推理时最高可处理 400 万 token。这一超长上下文能力在当时的开源模型中处于领先位置——在 Ruler 基准测试中，MiniMax-Text-01 在 1M token 长度下仍能保持 0.910 的准确率，优于 Gemini-1.5-Pro（0.850）。

在此基础上，MiniMax-VL-01 增加了视觉能力，在 OCRBench（865）、ChartQA（91.7%）等多模态评测中同样表现出色。

📎 GitHub: github.com/MiniMax-AI/MiniMax-01 ⭐ 3.4k
📎 论文: arxiv.org/abs/2501.08313

### 过渡：MiniMax-M1

MiniMax-M1 是首个开源的大规模混合注意力推理模型，基于 MiniMax-Text-01 通过大规模强化学习训练而来。M1 原生支持 100 万 token 上下文，在等长生成下 FLOPs 仅为 DeepSeek-R1 的 25%，提出了 CISPO 算法用于稳定大规模 RL 训练。在 SWE-bench Verified 上达到 56%，在 LongBench-v2 上达到 61.5。

📎 GitHub: github.com/MiniMax-AI/MiniMax-M1 ⭐ 3.1k

### 主角：M2 系列——三个半月，三次跃迁

M2 系列是 MiniMax 开源的核心主线。从 2025 年 10 月到 2026 年 3 月，MiniMax 连续发布了 M2、M2.1 和 M2.5 三个版本，迭代速度在业内前列。

#### MiniMax-M2

M2 是一个精简而强大的 MoE 模型：**230B 总参数，仅 10B 激活参数**。这意味着它能在远低于同级模型的推理成本下，交付接近前沿水平的性能。

在 Artificial Analysis 的综合评测中，M2 的 Intelligence Score **在全球开源模型中排名第一**。在具体任务上：

- SWE-bench Verified：**69.4%**（超过 DeepSeek-V3.2 的 67.8%）
- Terminal-Bench：**46.3%**（超过 Claude Sonnet 4 的 36.4%）
- BrowseComp：**44.0%**（超过 Claude Sonnet 4.5 的 19.6%）
- GAIA（text only）：**75.7%**（超过 GPT-5 thinking 的 76.4% 仅差 0.7）
- τ²-Bench：**77.2%**

M2 展示了一个重要信号：**10B 激活参数 = 快速的 Agent 循环 + 更优的单位经济性**。

📎 GitHub: github.com/MiniMax-AI/MiniMax-M2 ⭐ 2.5k
📎 HuggingFace: 下载量 121k

#### MiniMax-M2.1

M2.1 是 M2 的全面升级，特别是在多语言编码能力上实现了显著突破。

核心数据：
- SWE-bench Verified：**74.0%**（M2 → M2.1 提升 4.6 个百分点）
- SWE-bench Multilingual：**72.5%**（超过 Claude Sonnet 4.5 的 68%，接近 Opus 4.5 的 77.5%）
- Multi-SWE-bench：**49.4%**（超过 Sonnet 4.5 的 44.3%）
- BrowseComp：**47.4%**
- Toolathlon：**43.5%**（与 Opus 4.5 持平）

M2.1 的发布伴随了一个重要贡献：**VIBE（Visual & Interactive Benchmark for Execution in Application Development）评测基准**。VIBE 覆盖 Web、Simulation、Android、iOS、Backend 五个子集，采用创新的 Agent-as-a-Verifier 范式，在真实运行环境中评估应用的交互逻辑和视觉效果。M2.1 在 VIBE 上取得了 88.6 的综合分数。

📎 GitHub: github.com/MiniMax-AI/MiniMax-M2.1 ⭐ 541
📎 HuggingFace: 下载量 46k

#### MiniMax-M2.5（当前最新开源版本）

M2.5 将性能和效率同时推向新的高度。

编码能力：
- SWE-bench Verified：**80.2%**（M2.1 → M2.5 再提升 6.2 个百分点）
- Multi-SWE-bench：**51.3%**
- SWE-bench Multilingual：逐版本持续提升
- 在 Droid（79.7%）和 OpenCode（76.1%）等第三方脚手架上均超过 Claude Opus 4.6

Agent 能力：
- BrowseComp（with context management）：**76.3%**
- xbench-DeepSearch：**72%**
- FinSearchComp-global：**65.5%**

效率与成本：
- 推理速度 100 TPS，是同级前沿模型的约 2 倍
- SWE-bench 单任务完成时间从 M2.1 的 31.3 分钟降至 **22.8 分钟**（-37%）
- **连续运行 1 小时仅需 $1**（100 TPS），成本仅为 Opus/Gemini 3 Pro/GPT-5 的 1/10 到 1/20

M2.5 的一个重要训练特性值得关注：**Spec-writing tendency**——模型在写任何代码之前，会主动像资深架构师一样分解和规划项目的功能、结构和 UI 设计。这一能力在训练中自然涌现，覆盖 10+ 编程语言和 200,000+ 真实环境。

M2.5 同时发布了 Lightning 版本（100 TPS）和标准版（50 TPS），均已在 HuggingFace 开源权重。

📎 GitHub: github.com/MiniMax-AI/MiniMax-M2.5 ⭐ 510
📎 HuggingFace: 下载量 493k

**【配图建议 ②】** 使用 M2.5 README 中的 SWE-bench 进步曲线图（bench_10.png），展示 M2 系列与 Claude/GPT/Gemini 系列的迭代速度对比。这张图直观且有说服力。

#### 展望

值得一提的是，MiniMax 的模型迭代并未停止。M2.7 已在内部投入使用，进一步拓展了模型能力的边界。关于 M2.7 的更多信息，我们后续会与社区分享。

---

## 二、学术开源：把论文变成可用的代码和数据

MiniMax 的学术开源有一个特点：**不止发论文，代码、数据、训练好的模型全部一起开源**。

### SynLogic —— NeurIPS 2025

**逻辑推理数据合成框架**，解决高质量逻辑推理训练数据匮乏的问题。

SynLogic 覆盖 **35 种逻辑推理任务**（数独、24 点、密码、箭头迷宫等），支持可控难度合成，所有样本均可通过规则验证，天然适配 RL 训练。在 BBEH 基准上，基于 SynLogic 训练的模型超过 DeepSeek-R1-Distill-Qwen-32B **6 个百分点**。

开源内容：
- 完整数据合成框架代码
- SynLogic 数据集（49.3k 样本）
- 训练好的 SynLogic-7B、SynLogic-32B、SynLogic-Mix-3-32B 三个模型
- Verl 框架 RL 训练指南

📎 GitHub: github.com/MiniMax-AI/SynLogic ⭐ 199
📎 论文: arxiv.org/abs/2505.19641

### VTP —— 视觉编码器预训练的新范式

VTP（Visual Tokenizer Pre-training）揭示了一个重要发现：**传统基于重建的 VAE 训练无法有效扩展到扩散生成模型**——更好的像素重建精度并不能带来更高质量的生成。

VTP 提出将对比学习、自监督学习和重建学习统一到一个框架中，首次在视觉编码器预训练中展现了针对生成任务的 scaling law。

开源内容：
- 完整训练代码
- VTP-Small / VTP-Base / VTP-Large 三个预训练权重
- 技术报告

📎 GitHub: github.com/MiniMax-AI/VTP ⭐ 460
📎 论文: arxiv.org/abs/2512.13687

### V-Triune / One-RL-to-See-Them-All

**首次在单一 RL 管线中联合训练视觉推理和视觉感知任务**的统一框架。

V-Triune 由三个组件构成：样本级数据格式化、验证器级奖励计算、数据源级指标监控。基于此训练的 Orsta 模型（7B-32B）在 MEGA-Bench Core 上取得了最高 **+14.1%** 的提升，并创新性地提出了 Dynamic IoU Reward 机制。

开源内容：
- V-Triune 训练框架
- Orsta-7B / Orsta-32B 模型权重
- Orsta-Data-47k 训练数据集
- Docker 容器化部署方案

📎 GitHub: github.com/MiniMax-AI/One-RL-to-See-Them-All ⭐ 330
📎 论文: arxiv.org/abs/2505.18129

### OctoBench (mini-vela)

**脚手架感知的 AI Coding Agent 指令遵循评测框架**。

与传统评测不同，OctoBench 通过 LiteLLM Proxy 拦截完整 API 调用轨迹，基于 Checklist 进行多维度自动化评分。支持 Claude Code、Kilo-Dev、Droid 等多种 Agent 脚手架，每个任务在隔离的 Docker 容器中运行。

📎 GitHub: github.com/MiniMax-AI/mini-vela ⭐ 26
📎 论文: arxiv.org/abs/2601.10343

**【配图建议 ③】** 将四个学术项目制作成卡片式排列：每张卡片包含项目名 + 一句话描述 + 会议/论文标注 + GitHub Star 数。

---

## 三、开发者工具：让 MiniMax 能力触手可及

### Mini-Agent：最佳实践级 Agent 框架

Mini-Agent 是一个最小化但专业的 Agent Demo 项目，展示了基于 MiniMax M2.5 构建 Agent 的完整最佳实践。

核心特性：
- ✅ 完整的 Agent 执行循环（文件系统 + Shell 操作）
- ✅ 持久化记忆（Session Note Tool 跨会话保持上下文）
- ✅ 智能上下文管理（自动摘要，支持无限长任务）
- ✅ 15 个内置 Skills（文档 / 设计 / 测试 / 开发）
- ✅ MCP 工具集成（知识图谱 / 网页搜索）
- ✅ ACP 协议支持（与 Zed 编辑器集成）

一条命令即可启动：`uv tool install git+https://github.com/MiniMax-AI/Mini-Agent.git`

📎 GitHub: github.com/MiniMax-AI/Mini-Agent ⭐ 2k

### MCP 全家桶：四个项目覆盖全场景

MiniMax 围绕 Model Context Protocol（MCP）构建了完整的工具链：

**① MiniMax-MCP（Python）** ⭐ 1.3k
官方 MCP Server 的 Python 实现。支持 8 个工具：文本转语音（TTS）、图像生成、视频生成、语音克隆、音乐生成、语音设计等。兼容 Claude Desktop、Cursor、Windsurf、OpenAI Agents 等主流 MCP 客户端。通过 `uvx minimax-mcp` 一条命令即可安装。

**② MiniMax-MCP-JS（JavaScript）** ⭐ 113
官方 MCP Server 的 JavaScript 实现，功能与 Python 版本一致。通过 Smithery 支持一键安装：`npx -y @smithery/cli install @MiniMax-AI/MiniMax-MCP-JS --client claude`。支持 stdio / REST / SSE 三种传输模式。

**③ MiniMax-Coding-Plan-MCP** ⭐ 41
面向编码计划用户的专用 MCP Server。提供 `web_search` 和 `understand_image` 等针对代码开发流程优化的工具，帮助开发者在 IDE 中直接使用 MiniMax 的搜索和视觉理解能力。

**④ minimax_search** ⭐ 33
搜索专用 MCP Server。支持 Google 搜索引擎 + 并行多查询搜索 + 批量网页浏览 + MiniMax LLM 智能理解网页内容。

### OpenRoom：AI 操作你的每一个 App

OpenRoom 是一个运行在浏览器中的桌面环境，内置 AI Agent 通过自然语言操作所有应用。

内置 9 个应用（音乐播放器、象棋、五子棋、FreeCell、邮件、日记、Twitter、相册、新闻），每个应用都与 AI Agent 完全集成。更有趣的是它的 **Vibe Workflow**——只需用一句话描述需求，就能自动生成一个完整的、与 AI Agent 集成的桌面应用。整个过程自动经历需求分析→架构设计→任务规划→代码生成→资源生成→项目集成六个阶段。

所有数据存储在本地 IndexedDB，无需后端，无需账号。

📎 GitHub: github.com/MiniMax-AI/OpenRoom ⭐ 701

### 其他工具

**MiniMax-Provider-Verifier** ⭐ 31
面向第三方模型托管商的部署验证工具。评估 tool-call 行为正确性、Schema 准确率、系统稳定性（如 top-k 配置错误检测）等维度，为 M2 模型的广泛部署提供质量保障。

**vercel-minimax-ai-provider** ⭐ 10
Vercel AI SDK 的 MiniMax 社区 Provider，支持 Anthropic 和 OpenAI 两种兼容格式。前端开发者可以通过 `npm i vercel-minimax-ai-provider` 快速接入 M2 模型。

**audio-tools** ⭐ 47
文本转音频处理辅助工具集，包含韩语罗马化和多语言数字转文字功能的优化实现。

**【配图建议 ④】** 制作 MCP 工具链架构图：中心是 MiniMax API，向外辐射 4 个 MCP Server，再外层连接各 IDE/Client（Claude Desktop、Cursor、Windsurf、Zed）。另附 OpenRoom 桌面截图（可从 README 的 demo 视频中截取）。

---

## 四、Skills 生态：10 个开箱即用的技能包

MiniMax 在 GitHub 上维护了一个 Skills 仓库（github.com/MiniMax-AI/skills ⭐ 3.4k），提供 10 个可直接使用的专业技能包：

### 全栈开发

| Skill | 功能 |
|-------|------|
| **frontend-dev** | 全栈前端开发：React / Next.js / Tailwind CSS + MiniMax API 多媒体能力（图像 / 视频 / 音频 / TTS）+ AIDA 文案框架 + Three.js/p5.js 生成艺术 |
| **fullstack-dev** | 后端架构与前后端集成：REST API 设计、Auth 流程（JWT / OAuth）、实时通信（SSE / WebSocket）、数据库集成、生产加固 |
| **android-native-dev** | Android 原生开发：Kotlin / Jetpack Compose / Material Design 3 / Gradle 配置 / 无障碍 / 性能优化 |
| **ios-application-dev** | iOS 开发：UIKit / SwiftUI / SnapKit / Dynamic Type / Dark Mode / Apple HIG 规范 |

### 创意工具

| Skill | 功能 |
|-------|------|
| **shader-dev** | GLSL Shader 全技术栈：光线行进、SDF 建模、流体模拟、粒子系统、程序化生成、后处理效果，ShaderToy 兼容 |
| **gif-sticker-maker** | 照片转 GIF 动态贴纸：Funko Pop / Pop Mart 风格，基于 MiniMax 图像和视频生成 API |

### 办公自动化

| Skill | 功能 |
|-------|------|
| **minimax-pdf** | PDF 生成 / 填写 / 重排版：15 种封面样式、Token 设计系统、印刷级输出 |
| **pptx-generator** | PPT 全流程：从零创建（PptxGenJS）、编辑现有 PPTX（XML 工作流）、文本提取 |
| **minimax-xlsx** | Excel 完整操作：新建 / 读取 / 分析（pandas）/ 编辑 / 公式重算 / 金融格式化 |
| **minimax-docx** | Word 文档：OpenXML SDK 创建 / 编辑 / 模板格式化 / XSD 验证 |

这些 Skills 仓库目前拥有 **3.4k Star** 和 **207 个 Fork**，是 MiniMax GitHub 组织中 Star 数最高的项目之一。

**【配图建议 ⑤】** 制作 10 个 Skill 的功能矩阵图：横轴为 Skill 名称，纵轴为能力维度（开发 / 设计 / 文档 / 多媒体），用填充色块表示覆盖关系。

---

## 五、评测数据集：不只用标准，更定义标准

MiniMax 在 HuggingFace 上开源了 8 个评测数据集，涵盖代码、推理、多模态、语音、角色扮演等多个维度：

| 数据集 | 规模 | 用途 | 下载量 |
|--------|------|------|--------|
| **VIBE** | 200 样本 | 可视化交互应用开发评测（Web/Android/iOS/后端） | 375 |
| **OctoBench** | 207 样本 | Agent 脚手架感知的指令遵循评测 | 20 |
| **OctoCodingBench** | 72 样本 | 长周期复杂开发场景的复合指令约束评测 | 417 |
| **SynLogic** | 49.3k 样本 | 35 种逻辑推理任务的 RL 训练数据 | 244 |
| **role-play-bench** | 6.37k 样本 | 角色扮演能力评测 | 322 |
| **TTS-Multilingual-Test-Set** | 4.35k 样本 | 多语言文本转语音质量评测 | 48 |
| **MR-NIAH** | 111 样本 | 多轮大海捞针长上下文评测 | 111 |
| **Orsta-Data-47k** | 47k 样本 | V-Triune 视觉 RL 训练数据 | — |

其中，**VIBE** 和 **OctoCodingBench** 是 MiniMax 为行业定义的新评测标准——前者首次在真实运行环境中评估 AI 生成应用的交互质量，后者填补了 Agent 在复杂开发场景中"能否严格遵循指令"的评测空白。

**【配图建议 ⑥】** 数据集矩阵图或 HuggingFace 数据集页面截图，标注各数据集名称和规模。

---

## 总结

从基础模型权重的完整开放，到学术论文代码和数据的同步开源；从覆盖全场景的 MCP 工具链，到 10 个专业 Skills 技能包；从 VIBE、OctoBench 等评测基准的定义，到 Provider-Verifier 对第三方部署质量的保障——MiniMax 正在构建的，不是一个单点的开源项目，而是一个**完整的开源生态**。

全部项目均可在以下地址访问：

- 🔗 **GitHub**: github.com/MiniMax-AI
- 🤗 **HuggingFace**: huggingface.co/MiniMaxAI
- 🔗 **ModelScope**: modelscope.cn/organization/MiniMax
- 🌐 **开放平台**: platform.minimax.io

Intelligence with Everyone.

**【配图建议 ⑦】** 底部放 GitHub 组织页的截图 + MiniMax 开放平台二维码，引导读者直接访问。

---

*附：GitHub 项目完整索引*

| 项目 | 描述 | Stars |
|------|------|-------|
| MiniMax-01 | MiniMax-Text-01 & VL-01，Lightning Attention 混合架构 | 3.4k |
| MiniMax-M1 | 首个大规模混合注意力推理模型 | 3.1k |
| MiniMax-M2 | 10B 激活的代码 + Agent 模型 | 2.5k |
| MiniMax-M2.1 | 多语言编码 SOTA，提出 VIBE 评测 | 541 |
| MiniMax-M2.5 | SWE-bench 80.2%，$1/小时极致性价比 | 510 |
| skills | 10 个开箱即用的专业技能包 | 3.4k |
| Mini-Agent | 完整 Agent 框架 Demo | 2k |
| MiniMax-MCP | 官方 MCP Server（Python） | 1.3k |
| OpenRoom | 浏览器内 AI 桌面操作系统 | 701 |
| VTP | 视觉编码器预训练新范式 | 460 |
| One-RL-to-See-Them-All | 视觉 RL 统一训练框架 | 330 |
| SynLogic | NeurIPS 2025 逻辑推理数据合成 | 199 |
| MiniMax-MCP-JS | 官方 MCP Server（JavaScript） | 113 |
| MiniMax-AI.github.io | 官方 GitHub Pages | 65 |
| audio-tools | 文本转音频辅助工具 | 47 |
| MiniMax-Coding-Plan-MCP | 编码计划专用 MCP | 41 |
| minimax_search | 搜索 MCP Server | 33 |
| MiniMax-Provider-Verifier | 第三方部署验证工具 | 31 |
| mini-vela (OctoBench) | Agent 指令遵循评测框架 | 26 |
| vllm (fork) | vLLM 推理引擎适配 | 17 |
| vercel-minimax-ai-provider | Vercel AI SDK Provider | 10 |
