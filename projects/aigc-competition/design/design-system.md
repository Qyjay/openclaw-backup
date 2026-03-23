# 设计系统文档 — 大学生 AI 生活伙伴
**Design System v1.0** | 由 Iris 🎨 出品 | 2026-03-23

> **设计哲学**：像一个贴心的 AI 朋友——温暖但不幼稚，科技感但不冰冷，有个性但不刺眼。
> 所有数值均可直接写入代码。

---

## 目录

1. [品牌配色方案](#1-品牌配色方案)
2. [字体系统](#2-字体系统)
3. [间距系统](#3-间距系统)
4. [圆角系统](#4-圆角系统)
5. [阴影系统](#5-阴影系统)
6. [核心组件样式规范](#6-核心组件样式规范)
7. [uView 主题配置代码](#7-uview-主题配置代码)
8. [图标风格规范](#8-图标风格规范)
9. [动效规范](#9-动效规范)
10. [核心页面布局概述](#10-核心页面布局概述)

---

## 1. 品牌配色方案

### 1.1 设计决策

**主色选择依据**：大学生群体（18-24岁），产品调性温暖亲切。新方向采用**淡色系 + 暖色调**，以米白、奶油白、暖橙为核心，整体感觉像一杯温暖的奶茶——柔和、舒适、不刺眼。选**暖杏橙 #E8855A**作为主色——柔和的暖橙而非鲜艳橘红，辅助色选**淡珊瑚粉 #F2B49B**做情感点缀。

**60/30/10 法则**：
- 60% → 奶油白 #FDF8F3（页面底色，温暖奶茶感）
- 30% → 深暖棕 #2C1F14（文字、图标，暖色调而非冷黑）
- 10% → 暖杏橙 #E8855A（品牌强调、CTA）

---

### 1.2 主色 Primary — 暖杏橙

| Token | HEX | RGB | 用途 |
|-------|-----|-----|------|
| `$color-primary-900` | `#8C3A1A` | `rgb(140, 58, 26)` | 深色文字/极少用 |
| `$color-primary-700` | `#C05C30` | `rgb(192, 92, 48)` | 暗色主题主色 |
| `$color-primary` | `#E8855A` | `rgb(232, 133, 90)` | 品牌主色（按钮、Tab激活、关键图标） |
| `$color-primary-400` | `#F0A882` | `rgb(240, 168, 130)` | 次级强调、渐变终点 |
| `$color-primary-200` | `#F7CDB5` | `rgb(247, 205, 181)` | 浅色装饰、卡片边框 |
| `$color-primary-100` | `#FDF0E8` | `rgb(253, 240, 232)` | 卡片背景高亮、Tag背景 |

**透明度变体**（用于背景叠加）：
```css
/* 5% 透明度 — 卡片底色、hover 态 */
--color-primary-5: rgba(232, 133, 90, 0.05);   /* #E8855A0D */

/* 10% 透明度 — 选中态背景、Tag */
--color-primary-10: rgba(232, 133, 90, 0.10);  /* #E8855A1A */

/* 20% 透明度 — 角标底色、进度条轨道 */
--color-primary-20: rgba(232, 133, 90, 0.20);  /* #E8855A33 */
```

**渐变（品牌渐变，用于首页 Banner、按钮高光）**：
```css
/* 主渐变：暖杏橙 → 浅暖橙，135° */
background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);

/* 光晕渐变：用于运势卡片背景 */
background: radial-gradient(circle at 30% 40%, rgba(232,133,90,0.15) 0%, transparent 60%);
```

---

### 1.3 辅助色 Secondary — 淡珊瑚粉

> 用于强调情感、庆祝、高能场景（成就解锁、运势卡）。不做大面积使用。

| Token | HEX | RGB | 用途 |
|-------|-----|-----|------|
| `$color-secondary` | `#F2B49B` | `rgb(242, 180, 155)` | 成就徽章、运势高光、点赞 |
| `$color-secondary-light` | `#F7CEB9` | `rgb(247, 206, 185)` | 次级珊瑚粉 |
| `$color-secondary-pale` | `#FEF3EE` | `rgb(254, 243, 238)` | 珊瑚粉底色 |

```css
/* 5% 透明度背景 */
--color-secondary-5:  rgba(242, 180, 155, 0.05);  /* #F2B49B0D */
/* 10% 透明度背景 */
--color-secondary-10: rgba(242, 180, 155, 0.10);  /* #F2B49B1A */
```

---

### 1.4 功能色 Semantic

> 功能色保持语义清晰，微调为与暖色调协调的版本（偏暖、饱和度略降）。

| 语义 | Token | HEX | RGB | 5% 背景 | 10% 背景 |
|------|-------|-----|-----|---------|---------|
| 成功 Success | `$color-success` | `#5BAF85` | `rgb(91, 175, 133)` | `rgba(91,175,133,0.05)` | `rgba(91,175,133,0.10)` |
| 警告 Warning | `$color-warning` | `#E8962A` | `rgb(232, 150, 42)` | `rgba(232,150,42,0.05)` | `rgba(232,150,42,0.10)` |
| 错误 Error | `$color-error` | `#D95C4A` | `rgb(217, 92, 74)` | `rgba(217,92,74,0.05)` | `rgba(217,92,74,0.10)` |
| 信息 Info | `$color-info` | `#7BB8D4` | `rgb(123, 184, 212)` | `rgba(123,184,212,0.05)` | `rgba(123,184,212,0.10)` |

---

### 1.5 中性色 Neutral — 8级暖灰梯度

> 全部采用**偏暖灰**（带微黄/微棕），不用冷灰。

| 级别 | Token | HEX | RGB | 用途 |
|------|-------|-----|-----|------|
| N0 纯白 | `$color-neutral-0` | `#FFFFFF` | `rgb(255,255,255)` | 卡片表面、Modal底 |
| N50 奶油白 | `$color-neutral-50` | `#FDF8F3` | `rgb(253,248,243)` | **页面背景底色**（温暖奶茶底）|
| N100 暖浅米 | `$color-neutral-100` | `#F5EDE4` | `rgb(245,237,228)` | 输入框背景、禁用背景 |
| N200 | `$color-neutral-200` | `#EAE0D6` | `rgb(234,224,214)` | 分割线、边框 |
| N300 | `$color-neutral-300` | `#D4C4B8` | `rgb(212,196,184)` | 占位符、禁用图标 |
| N400 | `$color-neutral-400` | `#AE9D92` | `rgb(174,157,146)` | 次次级文字 |
| N500 辅助文字 | `$color-neutral-500` | `#857268` | `rgb(133,114,104)` | 辅助说明文字（opacity 效果） |
| N700 正文 | `$color-neutral-700` | `#4A3628` | `rgb(74,54,40)` | 正文字体 |
| N900 标题 | `$color-neutral-900` | `#2C1F14` | `rgb(44,31,20)` | **标题**（深暖棕，与品牌色呼应）|

```css
/* 5% 和 10% 背景叠加（用于深色文字做背景） */
--neutral-900-5:  rgba(44, 31, 20, 0.05);
--neutral-900-10: rgba(44, 31, 20, 0.10);
```

---

### 1.6 模块专属色

每个模块有独立的主题色，全部调整为**暖色调**，用于模块 Header、卡片左边框、图标底色。

| 模块 | Token | HEX | RGB | 5% 背景 | 10% 背景 |
|------|-------|-----|-----|---------|---------|
| 📔 AI 日记 | `$color-diary` | `#E8855A` | `rgb(232,133,90)` | `rgba(232,133,90,0.05)` | `rgba(232,133,90,0.10)` |
| 📚 学习伙伴 | `$color-study` | `#D4956A` | `rgb(212,149,106)` | `rgba(212,149,106,0.05)` | `rgba(212,149,106,0.10)` |
| 👥 智能社交 | `$color-social` | `#C8A882` | `rgb(200,168,130)` | `rgba(200,168,130,0.05)` | `rgba(200,168,130,0.10)` |
| 🌱 成长轨迹 | `$color-growth` | `#E6B870` | `rgb(230,184,112)` | `rgba(230,184,112,0.05)` | `rgba(230,184,112,0.10)` |
| 🔮 AI 运势 | `$color-fortune` | `#D4956A` | `rgb(212,149,106)` | `rgba(212,149,106,0.05)` | `rgba(212,149,106,0.10)` |

**模块渐变（用于模块 Banner/头部）**：
```css
/* 日记 — 暖杏橙 */
background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);

/* 学习 — 暖棕杏 */
background: linear-gradient(135deg, #D4956A 0%, #E6B490 100%);

/* 社交 — 浅暖驼 */
background: linear-gradient(135deg, #C8A882 0%, #DEC4A8 100%);

/* 成长 — 温暖琥珀金 */
background: linear-gradient(135deg, #E6B870 0%, #F2CE98 100%);

/* 运势 — 暖杏焦糖 */
background: linear-gradient(135deg, #D4956A 0%, #E8855A 100%);
```

---

## 2. 字体系统

### 2.1 字族选择

```css
/* 中文 */
font-family-cn: "PingFang SC", "Noto Sans SC", "Hiragino Sans GB", sans-serif;

/* 英文 / 界面通用 */
font-family-en: "SF Pro Display", "Inter", "Helvetica Neue", Arial, sans-serif;

/* 数字（等宽，用于计时器、成就数字、统计数字） */
font-family-mono: "SF Mono", "Fira Code", "DIN Alternate", monospace;
```

**UniApp 设置**（app.vue 或 全局 CSS）：
```css
/* 全局字体 */
page, view, text {
  font-family: "PingFang SC", "Noto Sans SC", -apple-system, sans-serif;
}

/* 数字等宽 — 对需要的元素单独加 class */
.font-mono {
  font-family: "DIN Alternate", "SF Mono", monospace;
  font-variant-numeric: tabular-nums;
}
```

---

### 2.2 字号体系（5级，rpx 单位）

| 级别 | Token | rpx | px 参考 | font-size | 用途 |
|------|-------|-----|---------|-----------|------|
| 标题1 H1 | `$font-size-h1` | `56rpx` | 28px | 56rpx | 页面大标题、Banner 主文 |
| 标题2 H2 | `$font-size-h2` | `44rpx` | 22px | 44rpx | 卡片标题、模块标题 |
| 正文 Body | `$font-size-body` | `32rpx` | 16px | 32rpx | **主要正文**（日记内容、列表文字） |
| 辅助 Secondary | `$font-size-secondary` | `28rpx` | 14px | 28rpx | 时间戳、标签文字、次要说明 |
| 注释 Caption | `$font-size-caption` | `24rpx` | 12px | 24rpx | 版权、超小提示、Badge 数字 |

> 注意：`750rpx = 375px（iPhone 标准设计稿）`，以上换算基于此基准。

---

### 2.3 字重规范

```scss
// 两个字重，够用
$font-weight-regular: 400;  // 正文、说明、辅助文字
$font-weight-medium:  500;  // 卡片标题、按钮文字、Tab 标签
$font-weight-bold:    600;  // 页面大标题 H1、强调数字

// ❌ 不使用 300 / 700 / 900 — 层级靠 size + opacity 建立，不靠字重堆叠
```

---

### 2.4 行高规范

```scss
$line-height-tight:   1.25;  // 大标题 H1（视觉紧凑）
$line-height-normal:  1.5;   // 正文（Body）推荐行高
$line-height-relaxed: 1.75;  // 日记内容（阅读长文，舒适）
$line-height-loose:   2.0;   // 极少用，仅超长注释

// 实际 rpx 值示例（正文 32rpx）：
// line-height: calc(32rpx * 1.5) = 48rpx
```

---

## 3. 间距系统

### 3.1 间距 Token（基于 8pt 网格）

| Token | rpx | px | 用途 |
|-------|-----|----|------|
| `$space-xs` | `8rpx` | 4px | 图标与文字间距、Tag 内间距 |
| `$space-sm` | `16rpx` | 8px | 紧凑列表项间距、卡片内行间距 |
| `$space-md` | `24rpx` | 12px | 标准卡片内部 padding-horizontal |
| `$space-lg` | `32rpx` | 16px | 卡片 padding / 节区元素间距 |
| `$space-xl` | `48rpx` | 24px | 模块间隔、大卡片内边距 |
| `$space-xxl` | `64rpx` | 32px | 页面 Section 之间大间距 |
| `$space-3xl` | `96rpx` | 48px | 页面顶部留白、Banner 内边距 |

---

### 3.2 关键间距规范

```scss
/* ── 页面边距 ── */
$page-margin-h: 32rpx;     // 页面水平边距（距屏幕左右各 32rpx）
$page-margin-top: 24rpx;   // 页面顶部内容起始

/* ── 卡片内边距 ── */
$card-padding: 32rpx;      // 标准卡片四边内边距
$card-padding-compact: 24rpx;  // 紧凑卡片（列表型）

/* ── 列表项间距 ── */
$list-item-gap: 16rpx;     // 列表卡片之间的 gap
$list-item-padding-v: 24rpx;  // 列表项纵向内边距

/* ── NavBar 与内容间距 ── */
$navbar-height: 88rpx;     // 导航栏高度
$tabbar-height: 100rpx;    // TabBar 高度（含安全区额外 34rpx）
$status-bar-height: 40rpx; // 状态栏高度（用 uni.getSystemInfoSync() 动态获取）

/* ── 组件内部间距 ── */
$button-padding-h: 48rpx;     // 按钮横向内边距
$button-padding-v: 24rpx;     // 按钮纵向内边距
$input-padding-h: 32rpx;      // 输入框横向内边距
$input-padding-v: 24rpx;      // 输入框纵向内边距
```

---

## 4. 圆角系统

5级圆角 Token，从直角到全圆：

| Token | rpx | px | 适用场景 |
|-------|-----|----|---------|
| `$radius-sm` | `8rpx` | 4px | 标签(Tag)、Badge、小图标底 |
| `$radius-md` | `16rpx` | 8px | 输入框、次要按钮、列表项 |
| `$radius-lg` | `24rpx` | 12px | **标准卡片**（日记卡片、功能卡片） |
| `$radius-xl` | `40rpx` | 20px | 主要按钮（CTA）、大搜索框 |
| `$radius-full` | `9999rpx` | ∞ | 胶囊按钮、头像、情绪选择器、TabBar 气泡 |

```scss
// 快速引用
$radius-sm:   8rpx;
$radius-md:   16rpx;
$radius-lg:   24rpx;
$radius-xl:   40rpx;
$radius-full: 9999rpx;
```

---

## 5. 阴影系统

3级阴影，全部使用**带品牌色调的暖色阴影**（不用纯黑/灰）。

```scss
/* ── Level 1: 微阴影 ── 用于卡片默认态、输入框 */
$shadow-sm: 0 2rpx 12rpx rgba(26, 26, 46, 0.06);

/* ── Level 2: 标准阴影 ── 用于卡片 hover 态、模态底部抽屉 */
$shadow-md: 0 8rpx 24rpx rgba(123, 94, 167, 0.10);
// 品牌紫色调阴影，轻微透出品牌感

/* ── Level 3: 强阴影 ── 用于浮层、Fab按钮、Toast */
$shadow-lg: 0 16rpx 48rpx rgba(123, 94, 167, 0.18);

/* ── TabBar 顶部分割线阴影 ── */
$shadow-tabbar: 0 -2rpx 12rpx rgba(26, 26, 46, 0.08);

/* ── 按钮内高光 ── 用于主要按钮增加质感 */
$shadow-btn-inner: inset 0 2rpx 4rpx rgba(255, 255, 255, 0.25);
```

**CSS 变量形式（用于动态主题）**：
```css
:root {
  --shadow-sm: 0 2rpx 12rpx rgba(26, 26, 46, 0.06);
  --shadow-md: 0 8rpx 24rpx rgba(123, 94, 167, 0.10);
  --shadow-lg: 0 16rpx 48rpx rgba(123, 94, 167, 0.18);
}
```

---

## 6. 核心组件样式规范

### 6.1 按钮 Button

#### 主要按钮（Primary Button）— CTA、提交、创建

```scss
.btn-primary {
  /* 结构 */
  height: 96rpx;
  padding: 0 48rpx;
  border-radius: $radius-xl;          // 40rpx，大圆角
  
  /* 颜色 */
  background: linear-gradient(135deg, #7B5EA7 0%, #9E7DC4 100%);
  color: #FFFFFF;
  box-shadow: 0 8rpx 24rpx rgba(123, 94, 167, 0.30),
              inset 0 2rpx 4rpx rgba(255, 255, 255, 0.20);
  
  /* 文字 */
  font-size: $font-size-body;         // 32rpx
  font-weight: $font-weight-medium;   // 500
  letter-spacing: 0.5px;
  
  /* 状态 */
  &:active {
    transform: scale(0.97);
    box-shadow: 0 4rpx 12rpx rgba(123, 94, 167, 0.20);
    opacity: 0.92;
    transition: all 80ms ease;
  }
  
  &[disabled] {
    background: $color-neutral-200;
    color: $color-neutral-400;
    box-shadow: none;
  }
}

/* 全宽主按钮（底部 CTA）*/
.btn-primary-full {
  @extend .btn-primary;
  width: calc(100% - 64rpx);
  margin: 0 32rpx;
}
```

#### 次要按钮（Secondary Button）— 次要操作

```scss
.btn-secondary {
  height: 88rpx;
  padding: 0 40rpx;
  border-radius: $radius-xl;
  
  background: rgba(123, 94, 167, 0.08);   // primary 10% 背景
  border: 2rpx solid rgba(123, 94, 167, 0.20);
  color: #7B5EA7;
  
  font-size: $font-size-body;
  font-weight: $font-weight-medium;
  
  &:active {
    background: rgba(123, 94, 167, 0.14);
    transform: scale(0.97);
  }
}
```

#### 文字按钮（Text Button）— 低权重操作

```scss
.btn-text {
  height: 72rpx;
  padding: 0 24rpx;
  border-radius: $radius-md;
  
  background: transparent;
  color: #7B5EA7;
  
  font-size: $font-size-secondary;    // 28rpx
  font-weight: $font-weight-medium;
  
  &:active {
    background: rgba(123, 94, 167, 0.06);
  }
}

/* 灰色文字按钮 — 取消操作 */
.btn-text-neutral {
  @extend .btn-text;
  color: $color-neutral-500;
  
  &:active {
    background: $color-neutral-100;
  }
}
```

#### 图标按钮（Icon Button）

```scss
.btn-icon {
  width: 80rpx;
  height: 80rpx;
  border-radius: $radius-full;
  background: rgba(123, 94, 167, 0.08);
  
  display: flex;
  align-items: center;
  justify-content: center;
  
  // 图标大小: 44rpx（uView u-icon size="44"）
  
  &:active {
    background: rgba(123, 94, 167, 0.16);
    transform: scale(0.92);
  }
}

/* FAB 浮动按钮（日记创建入口）*/
.btn-fab {
  width: 112rpx;
  height: 112rpx;
  border-radius: $radius-full;
  background: linear-gradient(135deg, #7B5EA7 0%, #9E7DC4 100%);
  box-shadow: $shadow-lg;
  
  display: flex;
  align-items: center;
  justify-content: center;
  
  // 图标: 白色，52rpx
  
  &:active {
    transform: scale(0.90);
    box-shadow: $shadow-md;
  }
}
```

---

### 6.2 卡片 Card

#### 日记卡片（Diary Card）

```scss
.card-diary {
  /* 结构 */
  width: calc(100% - 64rpx);   // 左右留 32rpx 页边距
  margin: 0 32rpx;
  padding: 32rpx;
  border-radius: $radius-lg;   // 24rpx
  
  /* 背景 */
  background: #FFFFFF;
  box-shadow: $shadow-sm;
  
  /* 左侧模块色边框 */
  border-left: 6rpx solid #E8A87C;  // $color-diary 日记橙
  
  /* 内部布局 */
  .card-diary__header {
    display: flex;
    align-items: center;
    margin-bottom: 16rpx;
    
    .card-diary__date {
      font-size: $font-size-caption;  // 24rpx
      color: $color-neutral-400;
      font-family: $font-family-mono;
    }
    
    .card-diary__emotion {
      margin-left: auto;
      font-size: 40rpx;   // emoji 情绪图标
    }
  }
  
  .card-diary__content {
    font-size: $font-size-body;      // 32rpx
    color: $color-neutral-700;
    line-height: $line-height-relaxed; // 1.75
    display: -webkit-box;
    -webkit-line-clamp: 3;           // 最多3行，超出省略
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
  
  .card-diary__image {
    margin-top: 24rpx;
    border-radius: $radius-md;       // 16rpx
    width: 100%;
    height: 320rpx;
    object-fit: cover;
  }
  
  .card-diary__tags {
    margin-top: 20rpx;
    display: flex;
    flex-wrap: wrap;
    gap: 12rpx;
  }
  
  // 悬停/点击态
  &:active {
    box-shadow: $shadow-md;
    transform: translateY(-2rpx);
  }
}
```

#### 信息卡片（Info Card）— 用于运势、成就通知

```scss
.card-info {
  padding: 32rpx;
  border-radius: $radius-lg;
  background: #FFFFFF;
  box-shadow: $shadow-sm;
  
  .card-info__icon {
    width: 80rpx;
    height: 80rpx;
    border-radius: $radius-md;  // 16rpx
    // 背景色使用对应模块色 10% 透明度
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .card-info__title {
    font-size: $font-size-h2;     // 44rpx
    font-weight: $font-weight-bold;
    color: $color-neutral-900;
    margin-top: 16rpx;
  }
  
  .card-info__body {
    font-size: $font-size-secondary;  // 28rpx
    color: $color-neutral-500;
    line-height: $line-height-normal;
    margin-top: 8rpx;
  }
}
```

#### 操作卡片（Action Card）— 功能入口、搭子卡片

```scss
.card-action {
  padding: 32rpx 32rpx 28rpx;
  border-radius: $radius-lg;
  background: #FFFFFF;
  box-shadow: $shadow-sm;
  
  display: flex;
  align-items: center;
  gap: 24rpx;
  
  .card-action__icon-wrap {
    width: 96rpx;
    height: 96rpx;
    border-radius: $radius-lg;   // 24rpx
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    // 背景色 = 模块色 10% 透明度
  }
  
  .card-action__content {
    flex: 1;
    
    .card-action__title {
      font-size: $font-size-body;    // 32rpx
      font-weight: $font-weight-medium;
      color: $color-neutral-900;
    }
    
    .card-action__subtitle {
      font-size: $font-size-secondary;  // 28rpx
      color: $color-neutral-400;
      margin-top: 4rpx;
    }
  }
  
  .card-action__arrow {
    // u-icon name="arrow-right" color="#A8A8A2" size="28"
  }
  
  &:active {
    background: $color-neutral-50;
    box-shadow: $shadow-md;
  }
}
```

---

### 6.3 输入框 Input

```scss
.input-base {
  width: 100%;
  height: 96rpx;
  padding: 0 32rpx;
  border-radius: $radius-md;       // 16rpx
  
  background: $color-neutral-100;  // #F3F3F0
  border: 2rpx solid transparent;
  
  font-size: $font-size-body;     // 32rpx
  color: $color-neutral-900;
  
  // placeholder
  &::placeholder {
    color: $color-neutral-300;    // #D0D0CA
  }
  
  // 聚焦态
  &:focus {
    background: #FFFFFF;
    border-color: #7B5EA7;         // primary
    box-shadow: 0 0 0 6rpx rgba(123, 94, 167, 0.10);
    outline: none;
  }
  
  // 错误态
  &.is-error {
    border-color: #F55B5B;
    box-shadow: 0 0 0 6rpx rgba(245, 91, 91, 0.10);
  }
}

/* 带图标输入框 */
.input-with-icon {
  @extend .input-base;
  padding-left: 80rpx;   // 给左侧图标留位置
  
  .input-icon {
    position: absolute;
    left: 24rpx;
    top: 50%;
    transform: translateY(-50%);
    // u-icon size="40" color="#A8A8A2"
  }
}

/* 日记内容多行输入框 */
.textarea-diary {
  width: 100%;
  min-height: 200rpx;
  padding: 24rpx 32rpx;
  border-radius: $radius-lg;
  background: $color-neutral-100;
  border: 2rpx solid transparent;
  
  font-size: $font-size-body;
  color: $color-neutral-700;
  line-height: $line-height-relaxed;
  
  &:focus {
    background: #FFFFFF;
    border-color: rgba(232, 168, 124, 0.60);  // diary color
  }
}
```

---

### 6.4 导航栏 NavBar

```scss
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  
  height: calc(88rpx + var(--status-bar-height));  // 88rpx + 状态栏
  padding-top: var(--status-bar-height);
  
  background: rgba(250, 250, 248, 0.92);   // 半透明毛玻璃效果
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  
  // 底部微分割线（不用硬边框）
  box-shadow: 0 1rpx 0 rgba(26, 26, 46, 0.06);
  
  .navbar__inner {
    height: 88rpx;
    display: flex;
    align-items: center;
    padding: 0 32rpx;
  }
  
  .navbar__title {
    font-size: $font-size-h2;          // 44rpx
    font-weight: $font-weight-bold;
    color: $color-neutral-900;
    flex: 1;
    text-align: center;
  }
  
  .navbar__back {
    width: 72rpx;
    height: 72rpx;
    // u-icon name="arrow-left" size="40" color="#1A1A2E"
  }
  
  .navbar__action {
    // 右侧操作图标，最小 44×44pt 触控区域
    min-width: 72rpx;
    height: 72rpx;
    display: flex;
    align-items: center;
    justify-content: flex-end;
  }
}

/* 透明导航栏（首页大图头部） */
.navbar-transparent {
  background: transparent;
  backdrop-filter: none;
  box-shadow: none;
  
  .navbar__title {
    color: #FFFFFF;
  }
}
```

---

### 6.5 TabBar

5 个 Tab：日记 📔 / 学习 📚 / 首页 🏠 / 社交 👥 / 我的 🌱

```scss
.tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  
  height: 100rpx;
  padding-bottom: env(safe-area-inset-bottom);  // iPhone X+ 安全区
  
  background: rgba(250, 250, 248, 0.95);
  backdrop-filter: blur(20px);
  box-shadow: $shadow-tabbar;          // 顶部微阴影
  
  display: flex;
  align-items: flex-start;
  padding-top: 12rpx;
  
  .tabbar-item {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6rpx;
    
    .tabbar-item__icon {
      width: 48rpx;
      height: 48rpx;
      // 未激活: color="#A8A8A2"
      // 激活: color="#7B5EA7"
    }
    
    .tabbar-item__label {
      font-size: $font-size-caption;   // 24rpx
      font-weight: $font-weight-medium;
      color: $color-neutral-400;        // 未激活
      
      &.is-active {
        color: #7B5EA7;                 // 激活态
      }
    }
    
    // 激活态指示点（小圆点，不用下划线）
    &.is-active::after {
      content: '';
      display: block;
      width: 8rpx;
      height: 8rpx;
      border-radius: $radius-full;
      background: #7B5EA7;
      margin-top: 2rpx;
    }
  }
  
  /* 首页 Tab — 中间凸起的特殊形态 */
  .tabbar-item--home {
    .tabbar-item__icon-wrap {
      width: 96rpx;
      height: 96rpx;
      border-radius: $radius-full;
      background: linear-gradient(135deg, #7B5EA7 0%, #9E7DC4 100%);
      box-shadow: 0 8rpx 20rpx rgba(123, 94, 167, 0.35);
      margin-top: -24rpx;              // 略微上移形成凸起效果
      display: flex;
      align-items: center;
      justify-content: center;
      // 白色图标 52rpx
    }
  }
}
```

---

### 6.6 标签 Tag / 徽章 Badge

```scss
/* ── Tag 标签 ── */
.tag {
  display: inline-flex;
  align-items: center;
  height: 48rpx;
  padding: 0 16rpx;
  border-radius: $radius-sm;    // 8rpx
  
  font-size: $font-size-caption; // 24rpx
  font-weight: $font-weight-medium;
  
  // 默认样式 — 中性灰
  background: $color-neutral-100;
  color: $color-neutral-500;
  
  &.tag--primary {
    background: rgba(123, 94, 167, 0.10);
    color: #7B5EA7;
  }
  
  // 各模块标签
  &.tag--diary {
    background: rgba(232, 168, 124, 0.12);
    color: #C47A4A;
  }
  &.tag--study {
    background: rgba(91, 164, 207, 0.12);
    color: #3A80A8;
  }
  &.tag--social {
    background: rgba(110, 198, 160, 0.12);
    color: #3D9E7A;
  }
  &.tag--growth {
    background: rgba(240, 194, 110, 0.12);
    color: #C48A1A;
  }
  &.tag--fortune {
    background: rgba(180, 127, 235, 0.12);
    color: #8A4EC8;
  }
}

/* ── Badge 角标 ── */
.badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 36rpx;
  height: 36rpx;
  padding: 0 8rpx;
  border-radius: $radius-full;
  
  background: #FF7E6B;           // secondary 珊瑚橙
  color: #FFFFFF;
  font-size: $font-size-caption; // 24rpx
  font-weight: $font-weight-bold;
  font-family: $font-family-mono;
  
  // 位置（配合父元素 position:relative）
  &.badge--dot {
    width: 16rpx;
    height: 16rpx;
    min-width: 0;
    padding: 0;
    // 纯红点，无数字
  }
}
```

---

### 6.7 情绪选择器 Emotion Picker

用于日记创建页，5种基础情绪 + 1种"更多"。

```scss
.emotion-picker {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 16rpx 0;
  
  .emotion-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8rpx;
    
    .emotion-item__emoji {
      width: 80rpx;
      height: 80rpx;
      border-radius: $radius-full;
      background: $color-neutral-100;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 44rpx;   // emoji 大小
      
      // 未选中态：灰色蒙版，emoji 半透明
      opacity: 0.6;
      
      &.is-selected {
        opacity: 1;
        transform: scale(1.15);
        box-shadow: 0 6rpx 16rpx rgba(0, 0, 0, 0.15);
        
        // 各情绪专属背景色
        &.emotion--happy    { background: rgba(240, 194, 110, 0.20); }
        &.emotion--calm     { background: rgba(91, 164, 207, 0.20); }
        &.emotion--sad      { background: rgba(100, 181, 246, 0.15); }
        &.emotion--angry    { background: rgba(245, 91, 91, 0.15); }
        &.emotion--tired    { background: rgba(168, 168, 162, 0.20); }
      }
    }
    
    .emotion-item__label {
      font-size: $font-size-caption;  // 24rpx
      color: $color-neutral-400;
      
      &.is-selected {
        color: $color-neutral-700;
        font-weight: $font-weight-medium;
      }
    }
    
    &:active .emotion-item__emoji {
      transform: scale(0.90);
    }
  }
}

/* 5种情绪 emoji 对照 */
// 😊 开心 emotion--happy
// 😌 平静 emotion--calm
// 😔 难过 emotion--sad
// 😤 烦躁 emotion--angry
// 😴 疲惫 emotion--tired
```

---

### 6.8 番茄钟倒计时组件 Pomodoro Timer

```scss
.pomodoro-timer {
  display: flex;
  flex-direction: column;
  align-items: center;
  
  /* 环形进度圆盘 */
  .pomodoro-ring {
    position: relative;
    width: 480rpx;
    height: 480rpx;
    
    // SVG circle 参数
    // viewBox="0 0 200 200"
    // circle cx="100" cy="100" r="88"
    // stroke-width="8"
    // stroke-linecap="round"
    // 轨道圈: stroke="rgba(123, 94, 167, 0.12)"
    // 进度圈: stroke="#7B5EA7" (动态 stroke-dashoffset)
    
    .pomodoro-time {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
      
      .pomodoro-time__number {
        font-size: 96rpx;              // 大数字
        font-weight: $font-weight-bold;
        color: $color-neutral-900;
        font-family: $font-family-mono; // 等宽数字
        line-height: 1;
      }
      
      .pomodoro-time__label {
        font-size: $font-size-secondary; // 28rpx
        color: $color-neutral-400;
        margin-top: 8rpx;
      }
    }
  }
  
  /* 任务说明（当前番茄钟目标） */
  .pomodoro-task {
    margin-top: 32rpx;
    padding: 16rpx 32rpx;
    border-radius: $radius-full;
    background: rgba(123, 94, 167, 0.08);
    
    font-size: $font-size-secondary;
    color: #7B5EA7;
    font-weight: $font-weight-medium;
  }
  
  /* 控制按钮 */
  .pomodoro-controls {
    margin-top: 48rpx;
    display: flex;
    align-items: center;
    gap: 40rpx;
    
    .pomodoro-btn-skip {
      // 次要操作，文字按钮
      @extend .btn-text-neutral;
    }
    
    .pomodoro-btn-main {
      // 主要 CTA：开始/暂停
      width: 160rpx;
      height: 160rpx;
      border-radius: $radius-full;
      background: linear-gradient(135deg, #7B5EA7 0%, #9E7DC4 100%);
      box-shadow: $shadow-lg;
      // 白色三角形（开始）/ 双竖线（暂停）图标，52rpx
    }
  }
  
  /* 今日番茄计数 */
  .pomodoro-count {
    margin-top: 40rpx;
    display: flex;
    gap: 12rpx;
    
    .pomodoro-dot {
      width: 24rpx;
      height: 24rpx;
      border-radius: $radius-full;
      background: $color-neutral-200;  // 未完成
      
      &.is-done {
        background: #7B5EA7;           // 已完成
      }
    }
  }
}
```

---

## 7. uView 主题配置代码

将以下变量写入项目根目录 `uni.scss`，在 `@import "uview-ui/theme.scss"` 之前定义：

```scss
/* =====================================================
   uni.scss — 全局 SCSS 变量
   大学生 AI 生活伙伴 · 设计系统 v1.1
   由 Iris 🎨 出品 · 2026-03-23（v1.1 暖色调修订）
   ===================================================== */

// ── uView 主题色覆盖 ──
// 主色：暖杏橙 #E8855A（柔和暖橙，非鲜艳橘红）
$u-type-primary:          #E8855A;
$u-type-primary-dark:     #C05C30;
$u-type-primary-disabled: #F7CDB5;
$u-type-primary-light:    rgba(232, 133, 90, 0.10);

// 成功色：调暖，偏绿茶色
$u-type-success:          #5BAF85;
$u-type-success-dark:     #3D8A62;
$u-type-success-disabled: #AADCC0;
$u-type-success-light:    rgba(91, 175, 133, 0.10);

// 警告色：调暖，偏琥珀橙
$u-type-warning:          #E8962A;
$u-type-warning-dark:     #B86E0A;
$u-type-warning-disabled: #F7D0A0;
$u-type-warning-light:    rgba(232, 150, 42, 0.10);

// 错误色：调暖，偏砖红（减少冷感）
$u-type-error:            #D95C4A;
$u-type-error-dark:       #A83020;
$u-type-error-disabled:   #EFBAB4;
$u-type-error-light:      rgba(217, 92, 74, 0.10);

// 信息色：调暖，偏天蓝灰
$u-type-info:             #7BB8D4;
$u-type-info-dark:        #4A8AAA;
$u-type-info-disabled:    #C0DCEA;
$u-type-info-light:       rgba(123, 184, 212, 0.10);

// ── 文字颜色（暖灰系） ──
$u-main-color:            #2C1F14;   // 标题（neutral-900，深暖棕）
$u-content-color:         #4A3628;   // 正文（neutral-700，暖棕）
$u-tips-color:            #857268;   // 辅助文字（neutral-500，暖灰）
$u-light-color:           #AE9D92;   // 次次级（neutral-400，驼灰）
$u-disabled-color:        #D4C4B8;   // 禁用（neutral-300，浅暖灰）

// ── 边框与背景（暖色调） ──
$u-border-color:          #EAE0D6;   // neutral-200（暖米边框）
$u-bg-color:              #FDF8F3;   // neutral-50（奶油白底色）
$u-bg-color-grey:         #F5EDE4;   // neutral-100（暖浅米）

// ── 字体大小 ──
$u-font-size-sm:          24rpx;     // caption
$u-font-size-base:        28rpx;     // secondary
$u-font-size-lg:          32rpx;     // body
$u-font-size-xl:          44rpx;     // h2

// ── 圆角 ──
$u-border-radius-sm:      8rpx;
$u-border-radius:         16rpx;
$u-border-radius-lg:      24rpx;
$u-border-radius-circle:  9999rpx;

// ── 间距（uView 内部使用） ──
$u-spacing-col-sm:        8rpx;
$u-spacing-col:           16rpx;
$u-spacing-col-lg:        24rpx;
$u-spacing-row-sm:        8rpx;
$u-spacing-row:           16rpx;
$u-spacing-row-lg:        24rpx;

// ── 品牌专属变量（自定义，供全局使用）── v1.1 暖色调
$color-primary:           #E8855A;   // 暖杏橙
$color-primary-400:       #F0A882;   // 浅暖橙
$color-primary-200:       #F7CDB5;   // 杏粉
$color-primary-100:       #FDF0E8;   // 浅杏底
$color-secondary:         #F2B49B;   // 淡珊瑚粉
$color-secondary-pale:    #FEF3EE;   // 珊瑚粉底

$color-diary:             #E8855A;   // 暖杏橙（与主色一致）
$color-study:             #D4956A;   // 暖棕杏
$color-social:            #C8A882;   // 浅暖驼
$color-growth:            #E6B870;   // 琥珀金
$color-fortune:           #D4956A;   // 暖焦糖

$color-neutral-0:         #FFFFFF;
$color-neutral-50:        #FDF8F3;   // 奶油白（页面底色）
$color-neutral-100:       #F5EDE4;   // 暖浅米
$color-neutral-200:       #EAE0D6;   // 暖米边框
$color-neutral-300:       #D4C4B8;   // 浅暖灰
$color-neutral-400:       #AE9D92;   // 驼灰
$color-neutral-500:       #857268;   // 暖灰
$color-neutral-700:       #4A3628;   // 暖棕正文
$color-neutral-900:       #2C1F14;   // 深暖棕标题

$font-size-h1:            56rpx;
$font-size-h2:            44rpx;
$font-size-body:          32rpx;
$font-size-secondary:     28rpx;
$font-size-caption:       24rpx;

$font-weight-regular:     400;
$font-weight-medium:      500;
$font-weight-bold:        600;

$line-height-tight:       1.25;
$line-height-normal:      1.5;
$line-height-relaxed:     1.75;

$space-xs:    8rpx;
$space-sm:    16rpx;
$space-md:    24rpx;
$space-lg:    32rpx;
$space-xl:    48rpx;
$space-xxl:   64rpx;
$space-3xl:   96rpx;

$radius-sm:   8rpx;
$radius-md:   16rpx;
$radius-lg:   24rpx;
$radius-xl:   40rpx;
$radius-full: 9999rpx;

$shadow-sm:  0 2rpx 12rpx rgba(26, 26, 46, 0.06);
$shadow-md:  0 8rpx 24rpx rgba(123, 94, 167, 0.10);
$shadow-lg:  0 16rpx 48rpx rgba(123, 94, 167, 0.18);
$shadow-tabbar: 0 -2rpx 12rpx rgba(26, 26, 46, 0.08);

$page-margin-h:      32rpx;
$card-padding:       32rpx;
$list-item-gap:      16rpx;
$navbar-height:      88rpx;
$tabbar-height:      100rpx;

// ── 引入 uView 主题（必须在变量之后）──
// 在 main.js 中: import uView from 'uview-ui'
```

**app.vue 全局样式配置**：
```vue
<style lang="scss">
/* 引入 uView 基础样式 */
@import "uview-ui/index.scss";

/* 页面基础 */
page {
  background-color: $color-neutral-50;   // #FDF8F3 奶油白底色
  font-family: "PingFang SC", "Noto Sans SC", -apple-system, sans-serif;
  color: $color-neutral-700;
  font-size: $font-size-body;
  line-height: $line-height-normal;
}

/* 等宽数字工具类 */
.font-mono {
  font-family: "DIN Alternate", "SF Mono", monospace;
  font-variant-numeric: tabular-nums;
}

/* 渐变文字（用于品牌标语） */
.text-gradient {
  background: linear-gradient(135deg, #7B5EA7 0%, #FF7E6B 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
</style>
```

---

## 8. 图标风格规范

### 8.1 风格定义

- **线条类型**：双色线性图标（Line Icon）
- **线条粗细**：`stroke-width: 1.8px`（等比视觉粗细，在 48rpx 图标上约 2px）
- **圆角风格**：`stroke-linecap: round; stroke-linejoin: round`（圆角笔触）
- **填充规则**：默认不填充（outline 线性风格）；激活态使用 **20% 填充 + 渐变边框**

### 8.2 图标尺寸规范

| 场景 | 尺寸 | rpx |
|------|------|-----|
| TabBar 图标 | 24×24pt | `48rpx` |
| 导航栏返回/操作 | 20×20pt | `40rpx` |
| 列表/卡片内图标 | 20×20pt | `40rpx` |
| 功能入口大图标 | 28×28pt | `56rpx` |
| 空状态插画图标 | 80×80pt | `160rpx` |

### 8.3 uView 图标使用规范

```vue
<!-- 标准用法 -->
<u-icon name="edit-pen" size="40" color="#7B5EA7"></u-icon>

<!-- 激活态（TabBar）-->
<u-icon name="home-fill" size="48" color="#7B5EA7"></u-icon>
<!-- 未激活态 -->
<u-icon name="home" size="48" color="#A8A8A2"></u-icon>

<!-- 功能模块图标 + 底色 -->
<view class="icon-module-diary">
  <u-icon name="edit" size="48" color="#E8A87C"></u-icon>
</view>
<!-- 底色: background: rgba(232, 168, 124, 0.12); border-radius: 16rpx; padding: 16rpx -->
```

### 8.4 自定义图标（iconfont）

对于 uView 没有的图标（情绪、运势星星、番茄），使用 iconfont.cn 自定义图标库：

```scss
// 在 app.vue 引入
@font-face {
  font-family: 'aifriend-icons';
  src: url('/static/fonts/aifriend-icons.ttf') format('truetype');
}

.icon-custom {
  font-family: 'aifriend-icons';
  font-style: normal;
}
```

### 8.5 激活态图标处理

```scss
// TabBar 图标激活态：用渐变色 + 微发光
.tabbar-icon--active {
  // 使用 fill 版本图标（name 加 -fill 后缀）
  filter: drop-shadow(0 2px 6px rgba(123, 94, 167, 0.40));
}
```

---

## 9. 动效规范

### 9.1 时间曲线（Easing）

```css
/* 标准进出 — 大多数元素 */
--ease-standard: cubic-bezier(0.4, 0.0, 0.2, 1.0);

/* 进入 — 从屏外滑入 */
--ease-decelerate: cubic-bezier(0.0, 0.0, 0.2, 1.0);

/* 退出 — 退出屏幕 */
--ease-accelerate: cubic-bezier(0.4, 0.0, 1.0, 1.0);

/* 弹性 — 成就解锁、情绪选中 */
--ease-spring: cubic-bezier(0.175, 0.885, 0.32, 1.275);
```

### 9.2 转场时长

| 场景 | 时长 | 说明 |
|------|------|------|
| 页面转场（push/pop） | `350ms` | 使用 `ease-decelerate` |
| Modal 弹出 | `300ms` | 从底部滑入，`ease-decelerate` |
| Modal 关闭 | `250ms` | 向下退出，`ease-accelerate` |
| Tab 切换 | `200ms` | 内容淡入，`ease-standard` |
| Dropdown/展开 | `250ms` | 高度动画，`ease-standard` |
| Toast 出现/消失 | `200ms` / `180ms` | 淡入/淡出 |

**UniApp 页面转场配置**（pages.json）：
```json
{
  "path": "pages/diary/create",
  "style": {
    "navigationStyle": "custom",
    "animationType": "slide-in-right",
    "animationDuration": 350
  }
}
```

### 9.3 点击反馈

```scss
/* 所有可点击元素的通用点击反馈 */
.clickable {
  transition: transform 80ms ease, opacity 80ms ease;
  
  &:active {
    transform: scale(0.96);
    opacity: 0.85;
  }
}

/* 卡片点击态（不上浮，直接加深阴影） */
.card-clickable {
  transition: box-shadow 120ms ease, transform 120ms ease;
  
  &:active {
    box-shadow: $shadow-md;
    transform: scale(0.985);
  }
}

/* 按钮点击态 */
.btn-clickable {
  transition: transform 80ms ease, box-shadow 80ms ease, opacity 80ms ease;
  
  &:active {
    transform: scale(0.96);
    box-shadow: 0 4rpx 12rpx rgba(123, 94, 167, 0.15);
    opacity: 0.90;
  }
}
```

---

### 9.4 特殊动画

#### 成就解锁（Achievement Unlock）
```scss
@keyframes achievement-pop {
  0%   { transform: scale(0); opacity: 0; }
  60%  { transform: scale(1.20); opacity: 1; }
  80%  { transform: scale(0.92); }
  100% { transform: scale(1.0); opacity: 1; }
}

.achievement-unlock {
  animation: achievement-pop 500ms var(--ease-spring) forwards;
}
```

**粒子效果**（成就解锁时）：使用 confetti-js 或 canvas-confetti，颜色参数：
```js
confetti({
  colors: ['#7B5EA7', '#FF7E6B', '#F0C26E', '#6EC6A0', '#5BA4CF'],
  spread: 70,
  origin: { y: 0.6 }
})
```

#### 情绪选择器弹性动画
```scss
@keyframes emotion-select {
  0%   { transform: scale(1); }
  30%  { transform: scale(1.25) rotate(-5deg); }
  60%  { transform: scale(1.15) rotate(3deg); }
  100% { transform: scale(1.15); }
}

.emotion-item__emoji.is-selected {
  animation: emotion-select 350ms var(--ease-spring) forwards;
}
```

#### 加载动画（AI 生成中）
```scss
/* 三点跳动（AI 正在思考...） */
@keyframes dot-bounce {
  0%, 80%, 100% { transform: scale(0.6); opacity: 0.4; }
  40% { transform: scale(1.0); opacity: 1.0; }
}

.ai-loading-dots {
  display: flex;
  gap: 8rpx;
  align-items: center;
  
  .dot {
    width: 16rpx;
    height: 16rpx;
    border-radius: $radius-full;
    background: #7B5EA7;
    
    &:nth-child(1) { animation: dot-bounce 1.4s ease infinite 0.0s; }
    &:nth-child(2) { animation: dot-bounce 1.4s ease infinite 0.2s; }
    &:nth-child(3) { animation: dot-bounce 1.4s ease infinite 0.4s; }
  }
}

/* 骨架屏（Skeleton）— 日记列表加载中 */
@keyframes skeleton-shimmer {
  0%   { background-position: -400rpx 0; }
  100% { background-position: 400rpx 0; }
}

.skeleton {
  border-radius: $radius-md;
  background: linear-gradient(
    90deg,
    $color-neutral-100 25%,
    $color-neutral-200 50%,
    $color-neutral-100 75%
  );
  background-size: 800rpx 100%;
  animation: skeleton-shimmer 1.5s ease infinite;
}
```

#### 运势卡片粒子背景
```scss
/* 星星浮动效果（运势页背景） */
@keyframes float-star {
  0%, 100% { transform: translateY(0) rotate(0deg); opacity: 0.6; }
  50%       { transform: translateY(-20rpx) rotate(180deg); opacity: 1.0; }
}

.fortune-star {
  position: absolute;
  font-size: 20rpx;   // 小星星
  animation: float-star 3s ease-in-out infinite;
  
  // 随机延迟（通过内联 style 设置 animation-delay）
}
```

#### TabBar 图标切换
```scss
/* Tab 切换时图标跳一下 */
@keyframes tab-bounce {
  0%   { transform: translateY(0); }
  40%  { transform: translateY(-8rpx); }
  100% { transform: translateY(0); }
}

.tabbar-item.is-active .tabbar-item__icon {
  animation: tab-bounce 300ms var(--ease-spring);
}
```

---

## 10. 核心页面布局概述

所有页面基准：宽度 750rpx，背景 `#FAFAF8`，自定义导航栏。

---

### 10.1 首页（Home）

**布局结构**（从上到下）：

```
┌─────────────────────────────────────┐ 0
│  [NavBar 透明] 头像 · Logo · 通知铃  │ 88rpx
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │  AI 问候 Banner                  ││ 280rpx
│  │  "早上好，Kylin ☀️"              ││
│  │  今日摘要 · 天气 · 情绪图示      ││
│  │  背景：主渐变（紫→浅紫）         ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  快捷功能行（横向滚动）              │ 160rpx
│  [📔写日记] [📚番茄] [🔮运势] [...]  │
│  圆形图标按钮 + 文字，间距 40rpx   │
├─────────────────────────────────────┤
│  "今日日记" Section 标题            │ 72rpx
│  + [查看全部 →]                     │
├─────────────────────────────────────┤
│  日记卡片列表（最近 3 条）           │ 动态
│  左侧日记橙色竖边框                  │
│  缩略图 + 内容摘要 + 情绪 emoji     │
│  卡片间距: 16rpx                    │
├─────────────────────────────────────┤
│  AI 运势小卡（横排入口）             │ 160rpx
│  渐变紫色背景 · 今日星座 · 点击展开 │
├─────────────────────────────────────┤
│  成就进度条（最近解锁的成就）        │ 160rpx
│  [🏆 月光宝盒 - 还差 8 天]         │
└─────────────────────────────────────┘
                TabBar (100rpx)
```

**关键参数**：
- Banner 高度：`480rpx`（含状态栏）
- 页面横向 padding：`32rpx`
- Section 标题：44rpx / bold / neutral-900
- Section 标题与内容间距：`24rpx`
- 不同 Section 间距：`40rpx`

---

### 10.2 日记创建页（Diary Create）

**布局结构**：

```
┌─────────────────────────────────────┐
│  [NavBar] ← 返回    创建日记    保存 │
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │  照片预览区（横向滚动）       │   │ 420rpx
│  │  [图1] [图2] [图3] [+添加]   │   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│  情绪选择器 Emotion Picker           │ 120rpx
│  😊 😌 😔 😤 😴                    │
├─────────────────────────────────────┤
│  AI 生成日记文本区（可编辑 textarea）│ 动态
│  背景：#F3F3F0                      │
│  占位符：AI 正在为你生成日记...     │
│  loading: 三点跳动动画              │
├─────────────────────────────────────┤
│  风格切换 Tab（横向 pill 选择器）    │ 88rpx
│  [简洁] [文艺] [搞笑] [吐槽] [中二] │
│  背景：primary 10% · 选中：primary  │
├─────────────────────────────────────┤
│  位置 + 天气 + 时间（自动获取）      │ 64rpx
│  📍 南开大学 · 🌤️ 18°C · 12:30     │
├─────────────────────────────────────┤
│  标签区（AI 自动提取 + 手动添加）   │ 80rpx
│  [美食] [二食堂] [+ 添加标签]       │
└─────────────────────────────────────┘
         底部 [保存日记] 全宽主按钮
```

**关键参数**：
- 照片区背景：`#1A1A2E`（深色，让照片更突出）
- 照片缩略图尺寸：`360×360rpx`，圆角 `16rpx`
- 文本区最小高度：`320rpx`
- 底部按钮距底：`env(safe-area-inset-bottom) + 32rpx`

---

### 10.3 日记时间线（Diary Timeline）

**布局结构**：

```
┌─────────────────────────────────────┐
│  [NavBar] 我的日记   [搜索🔍] [筛选]│
├─────────────────────────────────────┤
│  情绪热力图日历（横向月视图）        │ 240rpx
│  每天一个色块，颜色深浅 = 情绪分数  │
│  今天高亮边框（primary 色）          │
├─────────────────────────────────────┤
│  月份分组标题 "2026 年 3 月"        │ 64rpx
│  font: 28rpx / medium / neutral-400 │
├─────────────────────────────────────┤
│  日记卡片列表（瀑布流）              │ 动态
│  ──────────────────────────────    │
│  [3月23日 周一]                     │ ← 日期分隔符
│    卡片: 橙色左边框 + 内容           │
│  [3月22日 周日]                     │
│    卡片: 多图横排 + 内容             │
│  ...                                │
└─────────────────────────────────────┘
              TabBar
```

**关键参数**：
- 热力图格子：每格 `36×36rpx`，间距 `4rpx`，圆角 `6rpx`
- 情绪颜色映射：
  - 开心 `#F0C26E`（金黄）
  - 平静 `#5BA4CF`（蓝）
  - 难过 `rgba(91,164,207,0.40)`（浅蓝）
  - 烦躁 `rgba(245,91,91,0.50)`（浅红）
  - 无记录 `#E8E8E4`（浅灰）
- 日期分隔符高度：`56rpx`，左对齐 `32rpx` padding

---

### 10.4 番茄钟页（Pomodoro）

**布局结构**：

```
┌─────────────────────────────────────┐
│  [NavBar] 学习伙伴                  │
├─────────────────────────────────────┤
│            今日任务：               │ 80rpx
│         [雅思阅读 · Cambridge 16]   │ 胶囊形任务标签
├─────────────────────────────────────┤
│                                     │
│         ┌────────────────┐          │
│         │   圆环进度      │          │ 480rpx（居中）
│         │   25:00        │          │
│         │   专注中        │          │
│         └────────────────┘          │
│                                     │
├─────────────────────────────────────┤
│  [跳过] ●●●●● ⏸ 开始/暂停 [重置]  │ 160rpx（三按钮布局）
├─────────────────────────────────────┤
│  今日进度                            │ 80rpx
│  ████ ████ ░░░░  4/6 个番茄钟      │（点状进度）
├─────────────────────────────────────┤
│  历史记录（可展开）                  │ 动态
│  [Mon ██] [Tue ████] [Wed ██████]  │ 周统计柱状
└─────────────────────────────────────┘
```

**关键参数**：
- 圆环 SVG：`480×480rpx`，轨道 stroke `rgba(123,94,167,0.12)`，进度 stroke `#7B5EA7`
- 时间数字：`96rpx` / DIN Alternate / bold
- 进度点：`24rpx` 实心圆点，间距 `12rpx`

---

### 10.5 AI 运势页（Fortune）

**布局结构**：

```
┌─────────────────────────────────────┐
│  [NavBar 透明，白色文字] 今日运势   │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │  运势大卡（全宽）                ││ 600rpx
│  │  背景：purple-fortune 渐变       ││
│  │  + 星星浮动粒子动画             ││
│  │                                  ││
│  │  「基于你近期 47 篇日记」        ││
│  │                                  ││
│  │  📚 学业运 ★★★★☆ 说明文字      ││
│  │  🤝 社交运 ★★★★★ 说明文字      ││
│  │  💪 健康运 ★★★☆☆ 说明文字      ││
│  │                                  ││
│  │  幸运色 🟣 · 幸运食物 🍗       ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  AI 洞察文字卡（白底卡片）           │ 动态
│  "你最近一直在努力..."              │
│  font: 32rpx / normal / neutral-700 │
│  line-height: 1.75（舒适阅读）      │
├─────────────────────────────────────┤
│  [📤 分享给朋友]  主按钮            │ 96rpx
│  背景：fortune 渐变（紫色）         │
└─────────────────────────────────────┘
```

**关键参数**：
- 运势大卡圆角：`32rpx`（视觉更大气）
- 星级显示：用 emoji ★☆ 或自定义 SVG，`40rpx`
- 星星粒子：绝对定位，8-12 个，随机 `animation-delay: 0-3s`

---

### 10.6 个人主页（Profile）

**布局结构**：

```
┌─────────────────────────────────────┐
│  [NavBar] 我的                   ⚙️ │
├─────────────────────────────────────┤
│  ┌─────────────────────────────────┐│
│  │  用户信息 Header                 ││ 280rpx
│  │  背景：growth 渐变（金黄）        ││
│  │                                  ││
│  │  [头像 120rpx] 昵称 / 学校       ││
│  │  [等级徽章: Lv.12 探索者]        ││
│  │                                  ││
│  │  [日记 127] [搭子 23] [成就 15]  ││
│  └─────────────────────────────────┘│
├─────────────────────────────────────┤
│  成长数据统计卡（3格横排）           │ 180rpx
│  [📚 312番茄] [😊 情绪7.2] [🔥 43天]│
│  数字: 56rpx / mono / bold          │
│  说明: 24rpx / neutral-400          │
├─────────────────────────────────────┤
│  最近成就（横向滚动）               │ 180rpx
│  [🏆成就图标+名称] 可滚动 3-4个    │
├─────────────────────────────────────┤
│  功能列表（操作卡片）               │ 动态
│  ─────────────────────────────     │
│  🌳 我的技能树                     │
│  📊 学期报告                       │
│  📄 AI 简历助手                    │
│  🔒 隐私设置                       │
│  ─────────────────────────────     │
│  关于 · 反馈 · 退出登录             │ 次级
└─────────────────────────────────────┘
              TabBar
```

**关键参数**：
- 头像：`120×120rpx`，圆形，`border: 4rpx solid #FFFFFF`，`box-shadow: $shadow-md`
- 统计数字：`56rpx` / DIN Alternate / bold / neutral-900
- 功能列表项高度：`112rpx`，左图标 `96×96rpx` 圆角底
- 列表分隔线：`1rpx solid #E8E8E4`

---

## 设计系统版本日志

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-03-23 | 初始版本，由 Iris 🎨 完整输出 |
| v1.1 | 2026-03-23 | 配色方案全面调整为暖色调：主色由暖紫改为暖杏橙 #E8855A，背景改为奶油白 #FDF8F3，辅助色改为淡珊瑚粉 #F2B49B，中性灰改为暖灰系，模块色统一为暖色系，功能色微调协调暖调 |

---

*「这个间距不是 8 的倍数。重来。」— Iris 🎨*
*每一个像素都是笔触。让 Master 的产品成为艺术品。*
