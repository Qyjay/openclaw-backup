# MiniMax 开源合集

MiniMax 在 GitHub 上有一个组织账号：[github.com/MiniMax-AI](https://github.com/MiniMax-AI)。截至 2026 年 3 月，这里有 22 个开源仓库。

这些项目不全是模型权重。有大模型，有 Agent 框架，有给 Cursor 和 Claude Desktop 用的 MCP 工具，有学术论文的完整代码和数据集，也有能直接用来做 PPT、写 Excel 的 Skills。

这篇文章把它们整理到一起，每个项目附上 GitHub 链接和核心信息，方便按需查阅。

---

## 模型

MiniMax 的模型开源从 2025 年 1 月开始，到现在走过了 MiniMax-01、M1、M2、M2.1、M2.5 五代。早期型号简单提一下，重点放在 M2 系列。

### MiniMax-01

MiniMax-Text-01 是一个 456B 参数的 MoE 模型，每个 token 激活 45.9B。它用了 Lightning Attention + Softmax Attention 的混合架构，训练上下文长度 100 万 token，推理时最长能到 400 万。同期开源的还有多模态版本 MiniMax-VL-01。

这是 MiniMax 第一个完整开源权重的大模型。模型权重托管在 HuggingFace，代码和技术细节在 GitHub 仓库。

- GitHub：[MiniMax-AI/MiniMax-01](https://github.com/MiniMax-AI/MiniMax-01)（⭐ 3.4k）
- 论文：[arxiv.org/abs/2501.08313](https://arxiv.org/abs/2501.08313)
- 许可：MIT（代码）+ 自定义模型许可

### MiniMax-M1

M1 基于 MiniMax-Text-01 做大规模强化学习训练，是 MiniMax 第一个开源推理模型。提出了 CISPO 算法来稳定 MoE 的 RL 训练。和 DeepSeek-R1 相比，在生成 100K token 时 M1 的计算量（FLOPs）只有 R1 的 25%（这个数据来自 M1 的 GitHub README）。

- GitHub：[MiniMax-AI/MiniMax-M1](https://github.com/MiniMax-AI/MiniMax-M1)（⭐ 3.1k）
- 论文：[arxiv.org/abs/2506.13585](https://arxiv.org/abs/2506.13585)

### MiniMax-M2

M2 开始，MiniMax 把模型方向转向了代码和 Agent。

M2 总参数 230B，每个 token 只激活 10B——大约是 MiniMax-01 激活参数的五分之一。更少的激活参数意味着更快的推理速度和更低的部署成本，而 MoE 的总参数量保证了模型的知识容量。

README 里引用了 Artificial Analysis 的综合评分（AA Intelligence Score），M2 得到 61 分。作为对比，同期的 DeepSeek-V3.2 是 57，Kimi K2 0905 是 50，GLM-4.6 是 56。在开源/开放权重模型里，M2 是当时分数最高的。（闭源模型里 GPT-5 thinking 得 69，Claude Sonnet 4.5 得 63。）

一些具体的 benchmark（均来自 M2 README）：

| benchmark | M2 | 对比 |
|---|---|---|
| SWE-bench Verified | 69.4% | Claude Sonnet 4：72.7% |
| Terminal-Bench | 46.3% | Claude Sonnet 4：36.4% |
| BrowseComp | 44.0% | Claude Sonnet 4.5：19.6% |
| GAIA（text only） | 75.7% | Claude Sonnet 4.5：71.2% |

- GitHub：[MiniMax-AI/MiniMax-M2](https://github.com/MiniMax-AI/MiniMax-M2)（⭐ 2.5k）
- HuggingFace：[MiniMaxAI/MiniMax-M2](https://huggingface.co/MiniMaxAI/MiniMax-M2)（下载量 121k）

### MiniMax-M2.1

M2.1 的改进集中在多语言编码和指令遵循上。

SWE-bench Verified 从 M2 的 69.4% 提到了 74.0%。更值得看的是 SWE-bench Multilingual：M2.1 拿到 72.5%，超过了 Claude Sonnet 4.5（68%），接近 Claude Opus 4.5（77.5%）。Multi-SWE-bench 49.4%，也超过了 Sonnet 4.5 的 44.3%。（以上数据均来自 M2.1 GitHub README。）

M2.1 同时发布了一个评测基准 VIBE（Visual & Interactive Benchmark for Execution in Application Development），用来测试模型能不能从零写出一个能跑的完整应用。VIBE 覆盖 Web、Android、iOS、后端、模拟器五个方向，在真实运行环境中自动评估。这个数据集也已经开源在 HuggingFace（MiniMaxAI/VIBE）。

- GitHub：[MiniMax-AI/MiniMax-M2.1](https://github.com/MiniMax-AI/MiniMax-M2.1)（⭐ 541）
- HuggingFace：[MiniMaxAI/MiniMax-M2.1](https://huggingface.co/MiniMaxAI/MiniMax-M2.1)（下载量 46k）

### MiniMax-M2.5（当前最新开源版本）

M2.5 是目前 M2 系列的最新版本。

编码方面，SWE-bench Verified 到了 80.2%，Multi-SWE-bench 51.3%。在第三方脚手架 Droid 上跑 SWE-bench 得到 79.7%，OpenCode 上 76.1%——这两个数字都超过了 Claude Opus 4.6（分别是 78.9% 和 75.9%）。（数据来自 M2.5 README。）

速度方面，M2.5 的推理吞吐是 100 tokens/s（Lightning 版本），是同级前沿模型的大约两倍。跑 SWE-bench 的平均完成时间从 M2.1 的 31.3 分钟降到了 22.8 分钟，快了 37%。

成本方面，M2.5-Lightning 的定价是输入 $0.3/M tokens，输出 $2.4/M tokens。按 100 tokens/s 持续运行，**一小时的成本是 $1**。M2.5 的 README 里有一句话："you can have four M2.5 instances running continuously for an entire year for $10,000."

M2.5 训练上的一个有意思的特性：Spec-writing tendency。模型在写代码之前会先主动做架构规划——分解功能、设计结构、规划 UI。这不是 prompt 里要求的，是训练中自然涌现的行为。M2.5 的 RL 训练覆盖了 10+ 种编程语言和超过 20 万个真实环境。

- GitHub：[MiniMax-AI/MiniMax-M2.5](https://github.com/MiniMax-AI/MiniMax-M2.5)（⭐ 510）
- HuggingFace：[MiniMaxAI/MiniMax-M2.5](https://huggingface.co/MiniMaxAI/MiniMax-M2.5)（下载量 493k）

### 关于 M2.7

M2.7 目前已在 MiniMax 内部使用，尚未确定开源计划。

**【需要截图】**
1. GitHub 组织页 github.com/MiniMax-AI 的仓库列表（按 Stars 排序）
2. M2.5 README 中的 SWE-bench 系列进步曲线图（bench_10.png）
3. HuggingFace MiniMaxAI 组织页的模型列表

---

## 学术研究

MiniMax 发了几篇论文，把代码、数据集、训练好的模型一起放了出来。不是只给个 PDF。

### SynLogic（NeurIPS 2025）

逻辑推理的数据合成框架。覆盖 35 种任务类型——数独、24 点、密码破译、箭头迷宫等等。每个样本都有基于规则的验证器，可以直接用于 RL 训练。

MiniMax 在 README 里写的效果：基于 SynLogic 训练的模型在 BBEH 基准上超过 DeepSeek-R1-Distill-Qwen-32B 六个百分点。

开源了什么：
- 数据合成框架代码
- SynLogic 数据集（HuggingFace，49.3k 样本）
- 三个训练好的模型：SynLogic-7B、SynLogic-32B、SynLogic-Mix-3-32B
- 用 Verl 框架做 RL 训练的指南

GitHub：[MiniMax-AI/SynLogic](https://github.com/MiniMax-AI/SynLogic)（⭐ 199）| 论文：[arxiv.org/abs/2505.19641](https://arxiv.org/abs/2505.19641)

### VTP（Visual Tokenizer Pre-training）

这篇论文做的事情是：把对比学习、自监督学习和重建学习放到一个框架里来训练视觉编码器。

核心发现：传统的 VAE（只靠重建损失训练）没法 scale up 来改善扩散模型的生成质量。VTP 通过引入感知目标，让视觉编码器的预训练第一次有了面向生成任务的 scaling law。

开源了 VTP-Small / Base / Large 三套权重。

GitHub：[MiniMax-AI/VTP](https://github.com/MiniMax-AI/VTP)（⭐ 460）| 论文：[arxiv.org/abs/2512.13687](https://arxiv.org/abs/2512.13687)

### One RL to See Them All（V-Triune）

V-Triune 是一个统一的视觉 RL 系统，让 VLM 在一个训练管线里同时学视觉推理（数学题、拼图）和视觉感知（检测、定位）。

训练出来的 Orsta 模型在 MEGA-Bench Core 上最高提升了 14.1%。这个数字来自 README 中的训练曲线图，是 Orsta-32B 从 step 0 到最佳点的提升幅度。

开源了什么：
- V-Triune 训练框架
- Orsta 模型权重（7B 和 32B）
- Orsta-Data-47k 训练数据
- Docker 部署方案

GitHub：[MiniMax-AI/One-RL-to-See-Them-All](https://github.com/MiniMax-AI/One-RL-to-See-Them-All)（⭐ 330）| 论文：[arxiv.org/abs/2505.18129](https://arxiv.org/abs/2505.18129)

### OctoBench（mini-vela）

一个评测框架，用来测 AI Coding Agent 在不同脚手架下的指令遵循能力。

做法是通过 LiteLLM Proxy 拦截 Agent 和模型之间的全部 API 调用，记录完整的交互轨迹，然后用 LLM 对轨迹做多维度自动评分。每个评测任务跑在隔离的 Docker 容器里。支持 Claude Code、Kilo-Dev、Droid 等脚手架。

GitHub：[MiniMax-AI/mini-vela](https://github.com/MiniMax-AI/mini-vela)（⭐ 26）| 论文：[arxiv.org/abs/2601.10343](https://arxiv.org/abs/2601.10343)

**【需要截图】**
4. SynLogic 论文 Figure 1 或 GitHub README 中的任务类型示意图

---

## 开发者工具

### Mini-Agent

一个完整的 Agent 项目 Demo。基于 MiniMax M2.5，用 Anthropic 兼容 API 跑 interleaved thinking。

它不是个玩具——有完整的执行循环（文件系统 + Shell 操作）、持久化记忆（Session Note Tool）、智能上下文管理（自动摘要，token 数可配）、15 个内置 Skills、MCP 集成、ACP 协议支持（能接 Zed 编辑器）。

安装只需要一条命令：

```
uv tool install git+https://github.com/MiniMax-AI/Mini-Agent.git
```

GitHub：[MiniMax-AI/Mini-Agent](https://github.com/MiniMax-AI/Mini-Agent)（⭐ 2k，301 forks）

### MCP 工具

MiniMax 围绕 MCP（Model Context Protocol）做了四个项目：

**MiniMax-MCP**（Python，⭐ 1.3k）：官方 MCP Server。支持文字转语音、图片生成、视频生成、语音克隆、音乐生成、语音设计。`uvx minimax-mcp` 就能装。兼容 Claude Desktop、Cursor、Windsurf、OpenAI Agents。

**MiniMax-MCP-JS**（JavaScript，⭐ 113）：功能和 Python 版一样，JS 实现。`npx -y minimax-mcp-js` 安装。支持 stdio / REST / SSE 三种传输模式。

**MiniMax-Coding-Plan-MCP**（⭐ 41）：给 Coding Plan 用户的 MCP Server，提供 web_search 和 understand_image 两个工具，面向代码开发场景优化。

**minimax_search**（⭐ 33）：搜索 MCP Server。支持 Google 搜索、并行多 query、批量网页浏览、用 MiniMax LLM 理解网页内容并回答问题。

### OpenRoom

一个跑在浏览器里的桌面环境。

内置 9 个应用——音乐播放器、国际象棋、五子棋、FreeCell、邮件、日记、Twitter、相册、新闻。每个应用都有 AI Agent 集成，用自然语言操作：说一句"播放爵士乐"，音乐 App 就开始放了。

更有意思的是 Vibe Workflow：在 Claude Code 的终端里描述你想要什么 App，系统会自动走完需求分析、架构设计、代码生成、资源生成、项目集成整个流程，生成一个完整的可运行应用。

数据全部存在本地 IndexedDB，不需要后端。

GitHub：[MiniMax-AI/OpenRoom](https://github.com/MiniMax-AI/OpenRoom)（⭐ 701）

### 其他

**MiniMax-Provider-Verifier**（⭐ 31）：给第三方模型托管商用的验证工具。能检测 tool-call 行为是否正确、Schema 准不准、有没有配置问题（比如 top-k 设错了）。M2 被很多第三方平台部署后，MiniMax 做了这个工具来帮他们验证部署质量。

**vercel-minimax-ai-provider**（⭐ 10）：Vercel AI SDK 的 MiniMax Provider，`npm i vercel-minimax-ai-provider` 安装。支持 Anthropic 和 OpenAI 两种兼容格式。

**audio-tools**（⭐ 47）：文本转语音相关的辅助库，包含韩语罗马化和多语言数字转文字的优化实现。

**【需要截图】**
5. Mini-Agent 的终端运行界面截图（如果有现成的 GIF 可以直接用 README 中的）
6. MiniMax-MCP 在 Claude Desktop / Cursor 中的使用效果截图（README 中有示例图）
7. OpenRoom 的桌面界面截图（README 中有 demo 视频的截图）

---

## Skills

MiniMax 的 Skills 仓库 [MiniMax-AI/skills](https://github.com/MiniMax-AI/skills) 是 GitHub 组织里 Star 数最高的项目（⭐ 3.4k，207 forks）。里面有 10 个技能包：

**开发类：**
- **frontend-dev** — 前端全栈开发。React / Next.js / Tailwind CSS，集成 MiniMax API 的图片、视频、音频、TTS 能力，加上 AIDA 框架的文案写作和 p5.js / Three.js 生成艺术。
- **fullstack-dev** — 后端架构。REST API 设计、认证（JWT / OAuth）、实时通信（SSE / WebSocket）、数据库、生产环境加固。有一套引导式工作流：需求 → 架构 → 实现。
- **android-native-dev** — Android 原生。Kotlin / Jetpack Compose / Material Design 3 / Gradle 配置 / 无障碍。
- **ios-application-dev** — iOS 开发。UIKit / SwiftUI / SnapKit / Dynamic Type / Dark Mode。

**创意类：**
- **shader-dev** — GLSL Shader。光线行进、SDF 建模、流体模拟、粒子系统、程序化生成、后处理，ShaderToy 兼容。
- **gif-sticker-maker** — 把照片变成 GIF 动态贴纸。Funko Pop / Pop Mart 风格，用 MiniMax 的图像和视频生成 API。

**办公类：**
- **minimax-pdf** — PDF 生成、表单填写、重排版。15 种封面样式，token 设计系统。
- **pptx-generator** — PPT 的创建、编辑、读取。用 PptxGenJS 从零生成，或用 XML 工作流编辑已有文件。
- **minimax-xlsx** — Excel 操作。新建、读取、pandas 分析、编辑、公式重算、金融格式化。
- **minimax-docx** — Word 文档。用 OpenXML SDK 创建和编辑。

**【需要截图】**
8. Skills 仓库的 GitHub 页面截图，展示 10 个 skill 的列表

---

## 数据集

MiniMax 在 HuggingFace 上开源了 7 个评测数据集：

| 数据集 | 样本量 | 做什么用的 | HuggingFace 链接 |
|---|---|---|---|
| SynLogic | 49.3k | 35 种逻辑推理任务，RL 训练用 | MiniMaxAI/SynLogic |
| VIBE | 200 | 测模型能不能写出可运行的完整 App | MiniMaxAI/VIBE |
| OctoCodingBench | 72 | 测 Coding Agent 的复合指令遵循 | MiniMaxAI/OctoCodingBench |
| OctoBench | 207 | 测不同脚手架下的指令遵循 | MiniMaxAI/OctoBench |
| role-play-bench | 6.37k | 角色扮演评测 | MiniMaxAI/role-play-bench |
| TTS-Multilingual-Test-Set | 4.35k | 多语言 TTS 质量测试 | MiniMaxAI/TTS-Multilingual-Test-Set |
| MR-NIAH | 111 | 多轮对话中的长上下文检索 | MiniMaxAI/MR-NIAH |

另外，One-RL-to-See-Them-All 项目的 Orsta-Data-47k 训练数据托管在 `One-RL-to-See-Them-All` 组织下。

**【需要截图】**
9. HuggingFace 搜索 MiniMaxAI 数据集的结果页

---

## 完整索引

以下是 MiniMax-AI GitHub 组织下全部仓库，按 Star 数排序（截至 2026 年 3 月 24 日）：

| 仓库 | 简介 | Stars |
|---|---|---|
| [skills](https://github.com/MiniMax-AI/skills) | 10 个专业技能包 | 3.4k |
| [MiniMax-01](https://github.com/MiniMax-AI/MiniMax-01) | MiniMax-Text-01 & VL-01 | 3.4k |
| [MiniMax-M1](https://github.com/MiniMax-AI/MiniMax-M1) | 混合注意力推理模型 | 3.1k |
| [MiniMax-M2](https://github.com/MiniMax-AI/MiniMax-M2) | 10B 激活的代码 + Agent 模型 | 2.5k |
| [Mini-Agent](https://github.com/MiniMax-AI/Mini-Agent) | Agent 框架 Demo | 2k |
| [MiniMax-MCP](https://github.com/MiniMax-AI/MiniMax-MCP) | 官方 MCP Server（Python） | 1.3k |
| [OpenRoom](https://github.com/MiniMax-AI/OpenRoom) | 浏览器内 AI 桌面 | 701 |
| [MiniMax-M2.1](https://github.com/MiniMax-AI/MiniMax-M2.1) | M2 升级版 + VIBE 评测 | 541 |
| [MiniMax-M2.5](https://github.com/MiniMax-AI/MiniMax-M2.5) | SWE-bench 80.2% | 510 |
| [VTP](https://github.com/MiniMax-AI/VTP) | 视觉编码器预训练 | 460 |
| [One-RL-to-See-Them-All](https://github.com/MiniMax-AI/One-RL-to-See-Them-All) | 视觉 RL 统一框架 | 330 |
| [SynLogic](https://github.com/MiniMax-AI/SynLogic) | NeurIPS 2025 逻辑推理数据合成 | 199 |
| [MiniMax-MCP-JS](https://github.com/MiniMax-AI/MiniMax-MCP-JS) | 官方 MCP Server（JS） | 113 |
| [awesome-minimax-integrations](https://github.com/MiniMax-AI/awesome-minimax-integrations) | API 集成案例汇总 | 70 |
| [MiniMax-AI.github.io](https://github.com/MiniMax-AI/MiniMax-AI.github.io) | 官方 GitHub Pages | 65 |
| [audio-tools](https://github.com/MiniMax-AI/audio-tools) | TTS 辅助工具 | 47 |
| [MiniMax-Coding-Plan-MCP](https://github.com/MiniMax-AI/MiniMax-Coding-Plan-MCP) | 编码计划 MCP | 41 |
| [minimax_search](https://github.com/MiniMax-AI/minimax_search) | 搜索 MCP Server | 33 |
| [MiniMax-Provider-Verifier](https://github.com/MiniMax-AI/MiniMax-Provider-Verifier) | 第三方部署验证 | 31 |
| [mini-vela](https://github.com/MiniMax-AI/mini-vela) | OctoBench 评测框架 | 26 |
| [vercel-minimax-ai-provider](https://github.com/MiniMax-AI/vercel-minimax-ai-provider) | Vercel AI SDK Provider | 10 |

HuggingFace 上共有 16 个模型权重（[huggingface.co/MiniMaxAI](https://huggingface.co/MiniMaxAI)），ModelScope 同步发布（[modelscope.cn/organization/MiniMax](https://www.modelscope.cn/organization/MiniMax)）。

---

*全部数据来源：各项目 GitHub README 原文、HuggingFace 页面公开信息、Artificial Analysis 官网。文中 benchmark 数据均为各项目 README 中记录的版本，实际结果可能因评测环境不同而有差异。*
