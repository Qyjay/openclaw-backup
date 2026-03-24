# MiniMax 开源合集

从 2025 年 1 月开源第一个模型到今天，我们在 GitHub 上发布了 22 个开源项目，在 HuggingFace 上发布了 16 个模型权重和 7 个评测数据集。

我们做开源有一个朴素的出发点：让开发者不仅能获取模型能力，还能真正用它构建产品。模型权重只是起点。开发者还需要 Agent 框架来跑通执行链路，需要 MCP 工具来接入编辑器和工作流，需要专业的 Skills 来处理 PDF、PPT、Excel，需要学术论文的完整代码和数据来复现和改进。所以我们的开源是一整套体系，从模型到工具链到研究。

【配图建议：GitHub 组织页 github.com/MiniMax-AI 截图，按 Stars 排序，展示仓库列表全貌】

---

## 01 模型：从 MiniMax-01 到 M2.7

我们的模型开源从 2025 年 1 月开始。

**MiniMax-01** 是第一个开源权重的模型。MiniMax-Text-01 总参数 456B，每个 token 激活 45.9B，采用 Lightning Attention 与 Softmax Attention 的混合架构。训练上下文 100 万 token，推理时最长支持 400 万——这在当时是开源模型中最长的。同期发布的 MiniMax-VL-01 是对应的多模态版本。

在 MiniMax-01 的基础上，**MiniMax-M1** 通过大规模强化学习训练，成为我们第一个开源推理模型。M1 提出了 CISPO 算法来稳定 MoE 架构的 RL 训练。在生成 100K token 时，M1 的计算量只有 DeepSeek-R1 的 25%。

**M2 系列**是一个转折点。从 M2 开始，我们把方向明确转向代码和 Agent。

MiniMax-M2 总参数 230B，每个 token 只激活 10B——大约是 MiniMax-01 激活参数的五分之一。更少的激活参数意味着更快的推理和更低的部署成本，MoE 的总参数量保证知识容量。M2 在 Artificial Analysis 综合评分（AA Intelligence Score）中得到 61 分，在当时的开源模型中排名第一。在 SWE-bench Verified 上得分 69.4%。

之后的 108 天里，我们连续发布了 M2.1 和 M2.5，保持了 M2 系列行业最快的迭代速度。

M2.1 将 SWE-bench Verified 提到了 74.0%，SWE Multilingual 拿到 72.5%（同期 Claude Sonnet 4.5：68%）。我们同时发布了 VIBE 基准——一个测试模型能否从零构建可运行应用的评测集，覆盖 Web、Android、iOS、后端和模拟器五个方向。

M2.5 把 SWE-bench Verified 推到了 80.2%。在第三方脚手架 Droid 和 OpenCode 上，M2.5 的表现超过了 Claude Opus 4.6。推理吞吐达到 100 tokens/s，以这个速度连续工作一小时只需要 1 美金。在 MiniMax 内部，M2.5 生成的代码已占新提交代码的 80%。训练过程中出现了一个有意思的涌现行为：模型会在写代码前主动做架构规划——分解功能、设计结构、规划 UI——我们称之为原生 Spec 行为。

M2.7 是我们最新的模型，也是第一个深度参与自身迭代的模型。M2.7 能够自行构建复杂的 Agent Harness，驱动自己的强化学习，并基于结果优化训练过程和 Harness 本身。在内部测试中，我们让 M2.7 自主优化一个开发脚手架的表现，它全程自主运行了超过 100 轮"分析失败 → 修改代码 → 评测 → 对比"的迭代循环，最终在内部评测集上效果提升了 30%。在 SWE-Pro 上得分 56.22%，在 VIBE-Pro 上得分 55.6%，在 Terminal Bench 2 上得分 57.0%，均接近 Claude Opus 4.6 的水平。在专业办公领域，M2.7 在 GDPval-AA 中 ELO 得分 1500。M2.7 已在 MiniMax Agent 和开放平台全量上线。

从 MiniMax-01 到 M2.5 的全部模型权重已在 HuggingFace 开源，支持本地部署。ModelScope 同步发布。

【配图建议：M2.5 GitHub README 中的 SWE-bench 进步曲线图（bench_10.png），展示 M2→M2.1→M2.5 的迭代节奏】

---

## 02 工具：让开发者用起来

模型权重开源是第一步。但我们很快意识到，开发者不只需要一个模型文件——他们需要能直接用它来构建产品的工具。

**Mini-Agent** 是一个完整的 Agent 框架示例项目。基于 MiniMax M2.5，通过 Anthropic 兼容 API 支持 interleaved thinking。它不是一个最小 Demo——具备完整的 Agent 执行循环（文件系统 + Shell 操作）、持久化记忆（Session Note Tool）、智能上下文管理（自动摘要，token 上限可配）、15 个内置 Skills、MCP 工具集成，以及 ACP 协议支持（可接入 Zed 编辑器）。安装只需要一条命令：`uv tool install git+https://github.com/MiniMax-AI/Mini-Agent.git`。

围绕 **MCP**（Model Context Protocol），我们构建了四个项目：

- **MiniMax-MCP**（Python，⭐1.3k）：官方 MCP Server。支持文字转语音、图片生成、视频生成、语音克隆、音乐生成和语音设计。兼容 Claude Desktop、Cursor、Windsurf、OpenAI Agents，`uvx minimax-mcp` 即可安装。
- **MiniMax-MCP-JS**（JavaScript，⭐113）：功能相同的 JS 实现，支持 stdio / REST / SSE 三种传输模式。
- **MiniMax-Coding-Plan-MCP**（⭐41）：面向代码开发场景的 MCP Server，提供搜索和图像理解工具。
- **minimax_search**（⭐33）：搜索 MCP Server，支持并行多查询和网页内容理解。

**Skills** 是我们开源的专业技能包集合（⭐3.4k），覆盖四个方向、十个领域：

- 开发：前端全栈（React / Next.js / Tailwind CSS + MiniMax API 集成）、后端架构（REST / Auth / 数据库 / 生产环境加固）、Android 原生（Kotlin / Jetpack Compose）、iOS 原生（UIKit / SwiftUI）
- 创意：GLSL Shader（光线行进 / 流体模拟 / 程序化生成）、GIF 动态贴纸制作（Funko Pop / Pop Mart 风格）
- 办公：PDF 生成与排版（15 种封面样式）、PPT 创建与编辑、Excel 分析与建模、Word 文档

这些 Skills 既可以在 Mini-Agent 中直接使用，也可以集成到 MiniMax Agent 平台上构建专家（Expert）。截至 M2.5 发布时，用户已在 MiniMax Agent 上构建了 1 万多个专家。

**OpenRoom** 是一个跑在浏览器里的 AI 交互空间。它有一个完整的桌面环境——窗口可以拖动、缩放、并排显示，内置 9 个应用（音乐播放器、国际象棋、五子棋、FreeCell、邮件、日记、Twitter、相册、新闻），每个应用都接入了 AI Agent，用自然语言操作。说一句"播放爵士乐"，音乐应用就开始放了。数据全部存储在本地 IndexedDB，没有后端。更有意思的是 Vibe Workflow：在 Claude Code 的终端里描述你想要什么应用，系统自动走完需求分析 → 架构设计 → 代码生成 → 资源生成 → 项目集成的全流程，生成一个可以直接在桌面上运行的完整应用。正如我们之前所说——"这个里面的代码大部分也是 AI 写的。"

此外，我们还开源了 **vercel-minimax-ai-provider**（Vercel AI SDK 集成）和 **audio-tools**（多语言 TTS 辅助工具）。

**MiniMax-Provider-Verifier** 是一个我们认为有必要做、但行业里很少有人做的项目。M2 系列开源后被大量第三方部署商接入——OpenRouter、SiliconFlow、Fireworks、Novita、Atlas Cloud 等等。但开源模型一旦交给别人部署，质量就不完全在自己手里了：推理框架的差异、量化精度的选择、解码参数（比如 top-k）的配置，都可能导致用户拿到的模型行为和官方部署不一致。最常见的问题包括：工具调用该触发的没触发、Schema 格式不对、小语种场景下语言跟随失败、甚至模型只输出推理链而不给最终答案。Provider-Verifier 就是用来系统性地检测这些问题的。它设计了六个维度的评测指标——查询成功率、工具调用触发一致性、Schema 准确率、响应完整性、语言跟随率——并提供了自动化脚本，跑 10 轮取均值，和官方部署做对比。目前已覆盖 M2、M2.1、M2.5 三代模型在十多家部署商上的测试结果，全部公开在 README 里。对开发者来说，选第三方 API 之前跑一遍这个工具，就能知道哪家的部署质量靠谱。

【配图建议：1. Mini-Agent 的终端运行演示 GIF（README 中有现成素材）  2. MiniMax-MCP 在 Cursor 中使用的效果截图（README 中有）  3. OpenRoom 的桌面界面截图（README 中有 demo 视频截帧）】

---

## 03 研究：代码、数据、模型，一个都不少

我们的学术论文不只发 PDF。每一篇论文，我们都把代码框架、数据集和训练好的模型一起开源，确保可复现。

**SynLogic**（NeurIPS 2025）是一个逻辑推理的数据合成框架。覆盖 35 种任务类型——数独、24 点、密码破译、箭头迷宫等。每个样本都有基于规则的验证器，可以直接用于 RL 训练。在 BBEH 基准上，基于 SynLogic 训练的模型超过 DeepSeek-R1-Distill-Qwen-32B 六个百分点。开源了完整的数据合成框架、SynLogic 数据集（HuggingFace，49.3k 样本）、三个训练好的模型（7B / 32B / Mix-3-32B），以及基于 Verl 框架做 RL 训练的指南。

**VTP**（Visual Tokenizer Pre-training，[arXiv:2512.13687](https://arxiv.org/abs/2512.13687)）是我们视频团队发布的视觉编码器预训练研究。这篇工作瞄准了一个行业里公认但一直没有被系统解决的问题：现有视觉 tokenizer（比如 VAE）的重建损失和生成质量之间存在矛盾——像素级重建越好，生成效果不一定越好。传统 VAE 把大量算力砸在重建预训练上，生成性能在 1/10 的算力就饱和了，继续堆算力几乎没有回报。我们把这个现象定义为"预训练 scaling 问题"。

VTP 的思路是：好的隐空间不该只记住像素，而要理解语义。我们设计了一个统一预训练框架，在 ViT Auto-Encoder 上同时优化三类目标——图文对比学习（CLIP 路线）、自监督学习（自蒸馏 + 掩码图像建模，DINOv2 路线）和传统重建损失。三类损失联合训练，让编码器在压缩视觉信号时既保留底层细节，又捕获高层语义。

核心发现：**理解能力是生成能力的关键驱动力**。我们观察到隐空间的语义理解质量和生成性能之间有强正相关——感知目标越好，生成效果越好。这意味着视觉 tokenizer 的预训练第一次有了面向生成任务的 scaling law：不改变下游 DiT 的训练配置和算力，只增加 VTP 预训练的投入，生成质量就持续提升。把预训练算力放大 10 倍，FID 改善 65.8%，而传统 autoencoder 在 1/10 算力就停滞了。

最终模型在 ImageNet 上同时做到：重建 rFID 0.36、零样本分类准确率 78.2%、线性探测准确率 85.7%，超过了 VILA-U 和 UniTok 等统一 tokenizer。配合 DiT 做生成，VTP 在仅 80 个 epoch、不使用 guidance 技巧的条件下就达到 2.03 gFID，超过了 VA-VAE 和 RAE 等方法，收敛速度是蒸馏方法的 4.1 倍。最终在 ImageNet 256×256 生成任务上达到 1.11 gFID。开源了 Small / Base / Large 三套权重和完整训练代码。

**V-Triune**（One RL to See Them All）是一个统一的视觉 RL 系统，在一个训练管线里同时训练视觉推理（数学题、拼图）和视觉感知（检测、定位）。训练出来的 Orsta 模型在 MEGA-Bench Core 上最高提升了 14.1%。开源了训练框架、模型权重（7B / 32B）、Orsta-Data-47k 训练数据和 Docker 部署方案。

**OctoBench**（mini-vela）是一个 AI Coding Agent 评测框架，通过 LiteLLM Proxy 拦截 Agent 与模型之间的全部 API 调用，记录完整交互轨迹，用 LLM 做多维度自动评分，支持 Claude Code、Kilo-Dev 等脚手架。

**MiniMax-Speech**（[arXiv:2505.07916](https://arxiv.org/abs/2505.07916)）是我们语音团队发布的 TTS 技术报告。之前的语音克隆模型大多需要"一段参考音频 + 这段音频的文字转录"才能工作，本质上是 one-shot 学习。MiniMax-Speech 做到了真正的 zero-shot——只需要一段参考音频，不需要任何转录文本。这背后的核心是一个可学习的 Speaker Encoder：它和自回归 Transformer 联合训练，而不是用预训练的说话人验证模型做特征提取。联合训练让编码器学到的表征天然适配 TTS 任务，音色保持和发音清晰度都比固定编码器更好。在音频质量上，MiniMax-Speech 提出了 Flow-VAE——把 VAE 和 Flow Matching 结合，用 VAE 编码器提取连续语音特征替代传统 mel-spectrogram 作为建模目标，突破了频谱图的信息瓶颈。由于 Speaker Encoder 是可学习的，它能在训练数据覆盖的所有语言上联合优化，模型因此支持 32 种语言的合成。在 Seed-TTS-eval 测试集上，零样本克隆的 WER 低于 ground truth 音频，Speaker Similarity 与 ground truth 持平；在 Artificial Arena 公开 TTS 排行榜上，MiniMax-Speech（产品名 Speech-02-HD）拿到了第一名，ELO 评分超过 OpenAI 和 ElevenLabs。因为 Speaker Encoder 的表征足够鲁棒和解耦，模型不改基座就能扩展：用 LoRA 控制任意情绪、用文本描述直接生成音色（Text-to-Voice）、用少量数据微调做专业级语音克隆（Professional Voice Cloning）。论文公开了完整的技术方案，配套的 [TTS-Multilingual-Test-Set](https://huggingface.co/datasets/MiniMaxAI/TTS-Multilingual-Test-Set)（24 种语言评测集）已在 HuggingFace 开源。

在 HuggingFace 上，我们还开源了 7 个评测数据集：SynLogic（逻辑推理）、VIBE（应用开发）、OctoBench / OctoCodingBench（Agent 评测）、role-play-bench（角色扮演）、TTS-Multilingual-Test-Set（多语言语音）、MR-NIAH（长上下文检索）。

【配图建议：SynLogic 论文 Figure 1 或 README 中的任务类型示意图】

---

## 完整索引

截至 2026 年 3 月，MiniMax-AI GitHub 组织下全部开源项目（按 Star 数排序）：

| 项目 | 简介 | Stars |
|------|------|-------|
| [skills](https://github.com/MiniMax-AI/skills) | 10 个专业 Skills | 3.4k |
| [MiniMax-01](https://github.com/MiniMax-AI/MiniMax-01) | Text-01 & VL-01 大模型 | 3.4k |
| [MiniMax-M1](https://github.com/MiniMax-AI/MiniMax-M1) | 混合注意力推理模型 | 3.1k |
| [MiniMax-M2](https://github.com/MiniMax-AI/MiniMax-M2) | 代码 + Agent 模型 | 2.5k |
| [Mini-Agent](https://github.com/MiniMax-AI/Mini-Agent) | Agent 框架 Demo | 2k |
| [MiniMax-MCP](https://github.com/MiniMax-AI/MiniMax-MCP) | 官方 MCP Server（Python）| 1.3k |
| [OpenRoom](https://github.com/MiniMax-AI/OpenRoom) | 浏览器内 AI 桌面 | 701 |
| [MiniMax-M2.1](https://github.com/MiniMax-AI/MiniMax-M2.1) | M2 升级 + VIBE 评测 | 541 |
| [MiniMax-M2.5](https://github.com/MiniMax-AI/MiniMax-M2.5) | SWE-bench 80.2% | 510 |
| [VTP](https://github.com/MiniMax-AI/VTP) | 视觉编码器预训练 | 460 |
| [One-RL-to-See-Them-All](https://github.com/MiniMax-AI/One-RL-to-See-Them-All) | 视觉 RL 框架 | 330 |
| [SynLogic](https://github.com/MiniMax-AI/SynLogic) | NeurIPS 2025 逻辑推理 | 199 |
| [MiniMax-MCP-JS](https://github.com/MiniMax-AI/MiniMax-MCP-JS) | MCP Server（JS）| 113 |
| [awesome-minimax-integrations](https://github.com/MiniMax-AI/awesome-minimax-integrations) | API 集成案例 | 70 |
| [MiniMax-AI.github.io](https://github.com/MiniMax-AI/MiniMax-AI.github.io) | 官方 GitHub Pages | 65 |
| [audio-tools](https://github.com/MiniMax-AI/audio-tools) | TTS 辅助工具 | 47 |
| [MiniMax-Coding-Plan-MCP](https://github.com/MiniMax-AI/MiniMax-Coding-Plan-MCP) | 编码计划 MCP | 41 |
| [minimax_search](https://github.com/MiniMax-AI/minimax_search) | 搜索 MCP | 33 |
| [MiniMax-Provider-Verifier](https://github.com/MiniMax-AI/MiniMax-Provider-Verifier) | 第三方部署验证 | 31 |
| [mini-vela](https://github.com/MiniMax-AI/mini-vela) | OctoBench 评测框架 | 26 |
| [vercel-minimax-ai-provider](https://github.com/MiniMax-AI/vercel-minimax-ai-provider) | Vercel AI SDK | 10 |

模型权重：[huggingface.co/MiniMaxAI](https://huggingface.co/MiniMaxAI)
评测数据集：[huggingface.co/MiniMaxAI](https://huggingface.co/MiniMaxAI)（Datasets 标签页）
ModelScope 同步：[modelscope.cn/organization/MiniMax](https://www.modelscope.cn/organization/MiniMax)

---

## 写在最后

回看过去 14 个月的开源之路，我们越来越坚信：模型能力的进步，只有转化为开发者手中可用的工具，才真正有意义。

开源是"双向奔赴"的道路。M2 系列模型的快速迭代，离不开社区开发者在各种脚手架和真实场景中的使用与反馈。我们从中学到的东西，又反过来推动了下一代模型的训练。这个循环，比我们单方面的努力走得更快。

接下来，我们会继续保持这个节奏。模型会更强，工具会更完善，研究会继续全量开放。如果你在用我们的任何一个开源项目，欢迎在 GitHub 上提 Issue 和 PR——这些反馈对我们非常重要。也欢迎大家加入我们的交流社群，和我们一起学习、一起进步。

除了 GitHub 上的代码和工具，我们在 HuggingFace 上也同步发布了从 MiniMax-01 到 M2.5 的全部模型权重，以及 SynLogic、VIBE、TTS-Multilingual-Test-Set 等评测数据集，方便研究者直接下载使用和复现。ModelScope 同步更新。

---

MiniMax Agent：agent.minimaxi.com
API 服务：platform.minimaxi.com
Coding Plan 订阅：platform.minimaxi.com/subscribe/coding-plan
GitHub：github.com/MiniMax-AI

Intelligence with Everyone.
