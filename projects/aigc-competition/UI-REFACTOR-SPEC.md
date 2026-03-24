# UI 重构规范 — Doodle 手绘风格

## 设计目标
将所有 emoji 图标、方块占位、简陋 UI 替换为统一的 Doodle 手绘风格。
目标：像 Headspace/Forest 那样的现代 App，但带有独特的手绘质感。

---

## 1. 设计 Token（已有，需严格遵循）

```scss
// 主色
$primary: #E8855A;         // 暖杏橙
$primary-light: #F2B49B;   // 淡珊瑚粉
$primary-bg: #FDF8F3;      // 奶油白背景

// 文字
$text-title: #2C1F14;      // 深暖棕
$text-body: #4A3628;       // 暖棕
$text-secondary: #8A7668;  // 中灰
$text-hint: #AE9D92;       // 浅灰

// 模块色（每个功能入口有自己的颜色）
$color-diary: #E8855A;     // 暖杏橙
$color-study: #6BA87B;     // 森林绿
$color-social: #6B8EB4;    // 天空蓝
$color-growth: #C8A86B;    // 琥珀金
$color-fortune: #D4728A;   // 玫瑰粉
$color-novel: #9B72C8;     // 薰衣紫
$color-ai: #5AACE8;        // 科技蓝
$color-todo: #C87290;      // 樱花粉

// 圆角
$radius-sm: 8px;
$radius-md: 14px;
$radius-lg: 20px;
$radius-card: 16px;

// 间距（8pt 网格）
$space-xs: 4px;
$space-sm: 8px;
$space-md: 16px;
$space-lg: 24px;
$space-xl: 32px;
```

## 2. Doodle 手绘风格规范

### 2.1 SVG 手绘滤镜
每个 SVG 图标应用微小的位移滤镜模拟手绘抖动：
```html
<svg>
  <defs>
    <filter id="hand-drawn">
      <feTurbulence type="turbulence" baseFrequency="0.04" numOctaves="4" seed="1"/>
      <feDisplacementMap in="SourceGraphic" scale="1.2" xChannelSelector="R" yChannelSelector="G"/>
    </filter>
  </defs>
</svg>
```

### 2.2 图标参数
- stroke-width: 2-2.2px
- stroke-linecap: round
- stroke-linejoin: round
- fill: none（线性图标）
- 应用 filter: url(#hand-drawn)
- viewBox: 0 0 24 24

### 2.3 不规则圆角（手绘盒子）
图标容器和卡片使用不规则圆角，每个角不同：
```scss
.doodle-box {
  border-radius: 14px 18px 12px 20px; // 每个角不同
}
// 变体（随机组合，但固定在同一元素上）
.doodle-box-v2 { border-radius: 16px 12px 18px 14px; }
.doodle-box-v3 { border-radius: 12px 16px 14px 18px; }
.doodle-box-v4 { border-radius: 18px 14px 16px 12px; }
```

### 2.4 手绘边框
```scss
.hand-border {
  border: 1.5px solid rgba($primary, 0.3);
  // 不规则圆角 + 微妙阴影
  box-shadow: 2px 3px 0 rgba($primary, 0.08);
}
```

### 2.5 纸张纹理背景
在卡片和页面背景上叠加微妙的纸张纹理：
```scss
.paper-texture {
  background-image: url("data:image/svg+xml,..."); // 细微噪点
  background-size: 200px 200px;
  opacity: 0.03;
}
```

## 3. 图标系统

### 3.1 创建 DoodleIcon.vue 组件

```vue
<!-- src/components/DoodleIcon.vue -->
<template>
  <view class="doodle-icon" :style="{ width: size + 'px', height: size + 'px' }">
    <!-- 内联 SVG，根据 name 渲染不同路径 -->
  </view>
</template>
```

### 3.2 需要的图标清单（替换所有 emoji）

| 图标名 | 替换 | 用于页面 | 颜色 |
|--------|------|---------|------|
| home | - | TabBar | $primary |
| book | 📔 | 日记、TabBar | $color-diary |
| search | 🔍 | 发现、TabBar | $text-secondary |
| pen | ✏️ | 写日记、TabBar | $primary |
| chat | 💬 | 消息、TabBar、AI对话 | $color-ai |
| user | 👤 | 我的、TabBar | $text-secondary |
| heart | ❤️ | 心情、成长 | $color-fortune |
| star | ⭐🌟 | 运势、等级 | $color-growth |
| tomato | 🍅 | 番茄钟 | $color-diary |
| camera | 📷 | 拍照记录 | $color-study |
| robot | 🤖 | AI 对话/伙伴 | $color-ai |
| trophy | 🏆 | 成就 | $color-growth |
| target | 🎯 | 目标/里程碑 | $color-diary |
| lock | 🔒 | 未解锁成就 | $text-hint |
| palette | 🎨 | 漫画/创作 | $color-fortune |
| crystal | 🔮 | 运势 | $color-fortune |
| music | 🎵 | BGM | $color-novel |
| fire | 🔥 | 连续天数 | $color-diary |
| check | ✓✅ | 待办完成 | $color-study |
| cross | ✕ | 删除/关闭 | $text-hint |
| plus | + | 添加 | $primary |
| loading | ⏳ | 加载中 | $primary |
| sparkle | ✨💫 | AI 生成完成 | $color-growth |
| share | - | 分享 | $color-social |
| calendar | 📅🗓 | 情绪日历 | $color-diary |
| run | 🏃 | 运动搭子 | $color-study |
| handshake | 🤝 | 搭子/社交 | $color-social |
| bookopen | 📚 | 学习 | $color-study |
| medal | 💎 | 稀有成就 | $color-novel |
| chart | 📊 | 数据/统计 | $color-growth |
| settings | - | 设置 | $text-secondary |
| moon | 🌙 | 晚安 | $color-novel |
| sun | ☀️ | 早上好 | $color-growth |
| phone | 📱 | 设备 | $text-secondary |
| flower | 🌸 | 装饰 | $color-fortune |
| puzzle | 🧩 | 更多功能 | $color-social |
| wand | 🪄 | AI 魔法 | $color-novel |
| novel | 📖 | 自传小说 | $color-novel |
| grid | - | 漫画面板 | $color-diary |
| send | - | 发送消息 | $primary |
| back | - | 返回 | $text-title |

## 4. 动画系统

### 4.1 页面过渡
```scss
// 页面进入：从底部滑入 + 淡入
.page-enter {
  animation: slideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1);
}
@keyframes slideUp {
  from { transform: translateY(24px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
```

### 4.2 列表项 Stagger 动画
```scss
// 列表项依次渐入
.stagger-item {
  opacity: 0;
  transform: translateY(12px);
  animation: fadeInUp 0.4s ease forwards;
}
.stagger-item:nth-child(1) { animation-delay: 0.05s; }
.stagger-item:nth-child(2) { animation-delay: 0.10s; }
// ... 以此类推
```

### 4.3 按钮点击反馈
```scss
.press-feedback {
  transition: transform 0.15s ease, box-shadow 0.15s ease;
  &:active {
    transform: scale(0.95);
    box-shadow: none;
  }
}
```

### 4.4 骨架屏 Shimmer
```scss
.skeleton {
  background: linear-gradient(90deg, #F0E8E0 25%, #F8F0E8 50%, #F0E8E0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

### 4.5 卡片悬浮效果
```scss
.card-hover {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(44,31,20,0.1);
  }
}
```

### 4.6 数字滚动动画（等级、统计数据）
用 CSS counter 或 JS requestAnimationFrame 实现数字从 0 滚动到目标值。

### 4.7 手绘描线动画
SVG path 用 stroke-dasharray + stroke-dashoffset 做描线动画：
```scss
.draw-in {
  stroke-dasharray: 100;
  stroke-dashoffset: 100;
  animation: drawLine 0.8s ease forwards;
}
@keyframes drawLine {
  to { stroke-dashoffset: 0; }
}
```

## 5. 功能入口图标盒子

发现页的功能入口网格，每个用不同颜色的手绘盒子：
```vue
<view class="func-icon-box" :style="{
  background: item.bgColor,
  border: '1.5px solid ' + item.borderColor,
  borderRadius: item.radiusVariant
}">
  <DoodleIcon :name="item.icon" :color="item.color" :size="24" />
</view>
```

每个功能的配色映射：
| 功能 | 背景色 | 边框色 | 图标色 | 圆角变体 |
|------|--------|--------|--------|---------|
| 番茄钟 | #FFF8F0 | #F2B49B | #E8855A | v1 |
| 找搭子 | #F0F8FF | #B4CCE8 | #6B8EB4 | v2 |
| 拍照记录 | #F0FFF5 | #9BC8A8 | #6BA87B | v3 |
| 运势 | #FFF5F8 | #E8A0B4 | #D4728A | v4 |
| 成长轨迹 | #FFF8EE | #E8C49B | #C8A86B | v1 |
| 自传小说 | #F8F0FF | #C4A8E8 | #9B72C8 | v2 |
| 漫画 | #EEFFF5 | #9BC8A8 | #5CA06E | v3 |
| 待办 | #FFF0F5 | #E8B4C4 | #C87290 | v4 |
| 成就系统 | #FFF8EE | #E8C49B | #C8A86B | v1 |
| AI简历 | #F0F8FF | #B4CCE8 | #5AACE8 | v2 |
| 日记BGM | #F8F0FF | #C4A8E8 | #9B72C8 | v3 |
| 分享卡片 | #FFF5F8 | #E8A0B4 | #D4728A | v4 |

## 6. 卡片设计

### 日记卡片
```scss
.diary-card {
  background: white;
  border-radius: 14px 18px 12px 20px;  // 手绘不规则
  padding: 16px;
  box-shadow: 2px 3px 0 rgba(232,133,90,0.08);
  border: 1px solid rgba(232,133,90,0.1);
  transition: transform 0.3s ease;
  
  &:active {
    transform: scale(0.98);
  }
}
```

### AI 洞察卡
```scss
.ai-insight-card {
  background: linear-gradient(135deg, #FFF8F0, #FFF0E6);
  border: 1.5px dashed rgba(232,133,90,0.3);  // 虚线边框，手绘感
  border-radius: 16px 12px 18px 14px;
}
```

## 7. TabBar 升级
- 使用 Doodle SVG 图标替换现有图标
- 中间「写」按钮：凸起圆形 + 手绘风格边框 + 微妙的脉冲动画
- 选中状态：图标变色 + 下方小圆点指示器（手绘圆点，不完美的圆）

## 8. 注意事项
- 当前为 H5 开发模式，内联 SVG 可用
- 所有 emoji 必须全部替换，不留任何一个
- 保持 Mock 数据不变，只改 UI/样式
- 不要修改路由和页面结构
- 不要修改业务逻辑
- 新增的组件和样式文件放在 `src/components/` 和 `src/common/`
