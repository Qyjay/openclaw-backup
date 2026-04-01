# 【六稿】4月，我们把1月的7位获奖者回访整理了出来——他们说了什么

---

## 开头

1 月底，我们办了一场 Coding Plan 订阅抽奖活动，送出去了 7 台 Mac mini。

奖品寄出之后，我们和几位获奖者分别聊了聊——问他们平时怎么用 MiniMax，对当时最新的 M2.5 感受如何，有没有什么建议。

4 月初，我们决定把这 6 份回访整理出来。之所以现在才发，是因为想先说一句：当时大家提的那些建议，有些已经落地了，有些正在做。所以与其说这是一篇「回访」，不如说这是一次「进度汇报」。

---

## 用户故事

---

### 钱奎省 · 南京

🏷️ 全能选手 ·「代码编辑丝滑到不像在跟 AI 对话」

钱奎省用 OpenClaw 做新闻聚合、行情分析——但最常用的，还是代码编辑。

**他的原话：**

> 「主要是给 OpenClaw 使用，做一些新闻总结、市场行情统计分析、代码编辑的任务。整体使用下来各个场景都很流畅，代码编辑方面更加『丝滑』。使用上比较流畅，速度快，长上下文适应场景更广泛。」

他也留了一句建议：「建议增强生成质量。」

**我们听进去了。** M2.7 在 SWE-Pro 得分 56.22%，追平 GPT-5.3-Codex；在更贴近真实工程场景的 SWE Multilingual（76.5）和 Multi SWE Bench（52.7）中优势更明显。代码生成的准确率和可读性都有明显提升，「聪明一点」这件事，正在做到。

---

### 卓皓 · 福州

🏷️ 重构专家 ·「Bug 诊断逻辑清晰，幻觉明显减少」

卓皓用 CodingPlan 做代码重构和性能优化。

**他的原话：**

> 「平常使用 CodingPlan 做代码重构与优化，对旧有代码进行性能优化，提升可读性。整体使用下来各个场景表现丝滑。尤其复杂 Bug 诊断，比如输入一段报错信息后，它在定位问题根源并提供一键修复建议时响应很快，逻辑清晰。对 M2.5，我感觉逻辑深度提升很多，明显感觉到在处理长逻辑链条时的稳定性更强，不像之前的版本容易在后期产生幻觉。」

**这是当时被提到最多的感受：幻觉在减少。** M2.7 把这个方向继续推进了。在 40 个复杂 skills（超过 2000 Token）上仍能保持 97% 的 skills 遵循率，长程交互的稳定性进一步提升。不只是诊断 Bug，M2.7 面对实际生产环境告警时，能关联监控指标做因果推理，主动连接数据库验证根因——多次将线上故障恢复时间缩短到三分钟以内。

---

### 罗崇勋 · 珠海

🏷️ 横评玩家 ·「便宜大碗，国内开发者的真香选择」

罗崇勋是一个「对比型用户」。他在 OpenClaw 里同时跑好几个大模型做横向比较。

**他的原话：**

> 「我在 OpenClaw 里用几个不同的大模型做对比。OpenAI 的 Codex GPT 5.2 和 MiniMax 2.1 在日常处理上感觉差别不大。相较来说 MiniMax 对国内网络环境更友好，性价也高，属实便宜大碗。因为 OpenClaw 作者推荐 MiniMax 的，感觉很惊艳，响应速度和逻辑能力都很不错，第一次使用 CodingPlan 这种订阅方式，很划算。」

他同时也说了一句大实话：

> 「编程能力方面和 Claude Opus 4.6 比感觉还是有差距，我试过在 OpenCode 用相同的提示词做测试，Claude 无论是速度还是效果都是比较好的，希望能越来越强。MiniMax Agent 是个很好的产品，但是用起来速度还是比较慢，希望在版本迭代能越来越好。」

**这个差距，我们认真对待了。** M2.7 在 OpenClaw 的 MM-Claw 评测中已接近 Sonnet 4.6 的水平，在 Terminal Bench 2（复杂工程系统深层理解）中得分 57.0%。Agent 执行能力的提升是这一代的核心迭代方向，方向是对的，但差距还客观存在，我们会继续推。

---

### 孙振宇 · 杭州

🏷️ Agent 探索者 ·「用 M2.5 驱动自动任务」

**他的原话：**

> 「用 OpenClaw 的项目场景，对 Agent 的能力做一些测试。」

目前还在探索阶段，但他对 M2.5 的多步任务理解能力已经看到了潜力。

**探索还在继续。** M2.7 是第一个深度参与自身迭代的模型，能够自行构建 Agent Harness，驱动自身强化学习。如果你现在还在做类似的测试，我们很期待听到升级后的感受。

---

### 沈喜荣 · 上海

🏷️ 多模态玩家 ·「一站式搞定代码+音乐+配音」

沈喜荣是这 6 个人里使用场景最杂的一个。

**他的原话：**

> 「我经常用 MiniMax 来写代码、生成音乐、做语音配音，还支持基于 OpenClaw 的大模型 Coding Plan 方面的应用，一站式搞定各种创作和开发需求。在性能方面，在国内网络环境下依然响应极速，准确率超高；尤其升级到 2.5 版本后，模型准确度又提升了一大截，用起来更流畅、更可靠。而且它支持精准的上下文处理，还能让多个 agents 并行协作，处理复杂任务的效率比我想象的高。」

**多模态是真实需求，我们认同。** Coding Plan 升级为 Token Plan 时，把多模态作为了核心增量：Hailuo 视频模型、Speech 语音模型、Music 音乐模型、Image 图像生成模型，全部通过同一个 Token Plan Key 调用，不占用编程模型用量。如果你现在还在生成音乐和配音，可以试试把这些能力串起来用。

---

### Nils BEGOU · 法国格勒诺布尔

🏷️ 海外开发者 ·「敢让 AI 自主跑几个小时」

Nils 是这次回访里唯一一位海外用户。他做 Rust 开发。

**他的原话：**

> 「I do a lot of Rust development, and MiniMax has no real competitor in this domain when it comes to price-to-performance ratio on Rust programming. Most open-source models of this size are far from what MiniMax M2.1 offers for Rust coding tasks.」
>
> 「Plan execution and long-duration tasks are where CodingPlan truly shines. MiniMax stays faithful to the plan without getting stuck, and if something doesn't work, it actively searches for alternative solutions without compromising quality. It's one of the few models where I feel confident leaving it to work autonomously for several hours.」
>
> 「I'm particularly happy with the inference speed and the tool usage capabilities. The overall experience has been outstanding.」

他留了两个期待：

> 「I would love to see the minimax-her model integrated into CodingPlan – this could easily bring you more customers in the coding plan space. Additionally, if the next base model could be a bit larger and/or have multimodality integrated, that would be fantastic!」

**多模态已经来了。** Token Plan 支持调用 Hailuo 视频模型、Speech 语音模型、Music 音乐模型和 Image 图像生成模型。同时，M2.7 的模型权重也将在近期开源。感谢 Nils 从法国发来的这份认可。

---

## 他们眼里的 MiniMax

把这 6 份反馈放在一起，好消息是：速度快、长上下文流畅、国内网络无需特殊配置、性价比高——这几点被多个用户同时提到，不是偶然。

同时也有两条直接的建议：代码生成质量还能再提升，Agent 执行速度与顶尖模型还有差距。

这两条，M2.7 都在回应。但差距还客观存在，我们会继续推。

---

## 说在最后

1 月底寄出 Mac mini 的时候，我们没想到能收到这么多真实的反馈。有好评，也有不客气的建议——后者对我们来说，往往更珍贵。

感谢这 6 位愿意抽出时间接受回访的朋友。第七位还在联系中。如果你也在用 MiniMax，欢迎随时告诉我们你的感受——每一句反馈，都可能在下一个版本里变成现实。

👉 **立即体验 Token Plan：**
https://platform.minimaxi.com/subscribe/coding-plan?code=1c8FaUGpJ8&source=link

---

*（全文完。共 6 位用户故事，约 2,500 字。）*
