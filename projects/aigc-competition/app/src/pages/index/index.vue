<template>
  <view class="page">
    <!-- ==================== 顶部自定义导航 ==================== -->
    <view class="navbar">
      <view class="navbar-inner">
        <view class="navbar-avatar">
          <text class="avatar-emoji">🎓</text>
        </view>
        <view class="navbar-logo">
          <text class="logo-text">AI 生活伙伴</text>
        </view>
        <view class="navbar-actions">
          <text class="navbar-bell">🔔</text>
        </view>
      </view>
    </view>

    <!-- ==================== 滚动内容区 ==================== -->
    <scroll-view class="scroll-content" scroll-y>
      <!-- 顶部占位（导航栏高度） -->
      <view style="height: 88px;" />

      <!-- ─── 1. 问候 Banner ─── -->
      <view class="section-greeting">
        <view class="greeting-banner">
          <view class="banner-circle banner-circle--1" />
          <view class="banner-circle banner-circle--2" />
          <view class="greeting-content">
            <view class="greeting-top">
              <text class="greeting-main">{{ greetingText }}，{{ userName }} {{ greetingEmoji }}</text>
            </view>
            <text class="greeting-sub">今天是你记录的第 <text class="greeting-days font-mono">{{ recordDays }}</text> 天 🎉</text>
            <view class="greeting-meta">
              <view class="meta-item">
                <text class="meta-icon">🌤️</text>
                <text class="meta-text">{{ weather }}</text>
              </view>
              <view class="meta-divider" />
              <view class="meta-item">
                <text class="meta-icon">{{ todayEmotion.emoji }}</text>
                <text class="meta-text">今日 {{ todayEmotion.label }}</text>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- ─── 2. 情绪选择卡 ─── -->
      <view class="section section--padded">
        <view class="section-header">
          <text class="section-title">今日心情</text>
          <text class="section-link">记录情绪 →</text>
        </view>
        <view class="emotion-card">
          <view class="emotion-picker">
            <view
              v-for="em in emotions"
              :key="em.key"
              class="emotion-item"
              :class="{ 'emotion-item--selected': selectedEmotion === em.key }"
              @click="selectEmotion(em.key)"
            >
              <view
                class="emotion-emoji-wrap"
                :class="selectedEmotion === em.key ? 'emotion-bg--' + em.key : ''"
              >
                <text class="emotion-emoji">{{ em.emoji }}</text>
              </view>
              <text
                class="emotion-label"
                :class="{ 'emotion-label--active': selectedEmotion === em.key }"
              >{{ em.label }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- ─── 3. 快捷操作区 ─── -->
      <view class="section section--padded">
        <view class="section-header">
          <text class="section-title">快捷操作</text>
        </view>
        <view class="quick-actions">
          <view
            v-for="action in quickActions"
            :key="action.key"
            class="quick-action-item"
            @click="handleAction(action)"
          >
            <view class="quick-action-icon-wrap" :style="{ background: action.bgColor }">
              <text class="quick-action-icon">{{ action.icon }}</text>
            </view>
            <text class="quick-action-label">{{ action.label }}</text>
          </view>
        </view>
      </view>

      <!-- ─── 4. 今日日记预览 ─── -->
      <view class="section section--padded">
        <view class="section-header">
          <text class="section-title">今日日记</text>
          <text class="section-link">查看全部 →</text>
        </view>
        <view class="diary-list">
          <view
            v-for="diary in diaryList"
            :key="diary.id"
            class="diary-card"
            @click="openDiary(diary)"
          >
            <view class="diary-card-inner">
              <view class="diary-card-header">
                <view class="diary-meta">
                  <text class="diary-time">{{ diary.time }}</text>
                  <view class="diary-tag">{{ diary.tag }}</view>
                </view>
                <text class="diary-emotion">{{ diary.emotion }}</text>
              </view>
              <text class="diary-title">{{ diary.title }}</text>
              <text class="diary-content">{{ diary.content }}</text>
              <view v-if="diary.image" class="diary-image-wrap">
                <view class="diary-image-placeholder">
                  <text class="diary-image-icon">{{ diary.imageIcon }}</text>
                  <text class="diary-image-desc">{{ diary.imageDesc }}</text>
                </view>
              </view>
            </view>
          </view>
        </view>
      </view>

      <!-- ─── 5. AI 洞察卡 ─── -->
      <view class="section section--padded">
        <view class="ai-insight-card">
          <view class="ai-insight-header">
            <view class="ai-badge">
              <text class="ai-badge-text">✨ AI 洞察</text>
            </view>
            <text class="ai-insight-date">基于最近 47 篇日记</text>
          </view>
          <text class="ai-insight-content">{{ aiInsight }}</text>
          <view class="ai-insight-footer">
            <view class="ai-dot-loading">
              <view class="dot dot1" />
              <view class="dot dot2" />
              <view class="dot dot3" />
            </view>
            <text class="ai-insight-more">查看完整分析 →</text>
          </view>
        </view>
      </view>

      <!-- ─── 6. 运势入口卡 ─── -->
      <view class="section section--padded">
        <view class="fortune-card" @click="goFortune">
          <view class="fortune-card-left">
            <text class="fortune-title">今日运势</text>
            <text class="fortune-sub">AI 结合你的近期状态生成</text>
            <view class="fortune-stars">
              <text v-for="i in 5" :key="i" class="star" :class="{ 'star--filled': i <= 4 }">
                {{ i <= 4 ? '★' : '☆' }}
              </text>
            </view>
          </view>
          <view class="fortune-card-right">
            <text class="fortune-emoji">🔮</text>
          </view>
        </view>
      </view>

      <!-- 底部留白 -->
      <view class="bottom-spacer" />
    </scroll-view>

    <!-- ==================== 底部 TabBar ==================== -->
    <view class="tabbar">
      <view
        v-for="(tab, index) in tabList"
        :key="index"
        class="tabbar-item"
        :class="{ 'tabbar-item--active': activeTab === index, 'tabbar-item--home': index === 2 }"
        @click="switchTab(index)"
      >
        <view v-if="index === 2" class="tabbar-home-btn">
          <text class="tabbar-home-icon">🏠</text>
        </view>
        <template v-else>
          <text class="tabbar-icon">{{ tab.icon }}</text>
          <text class="tabbar-label" :class="{ 'tabbar-label--active': activeTab === index }">
            {{ tab.label }}
          </text>
        </template>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// ── 用户数据 ──
const userName = ref('Kylin')
const recordDays = ref(47)
const weather = ref('北京 · 18°C 晴')
const activeTab = ref(2)

const currentHour = new Date().getHours()
const greetingText = computed(() => {
  if (currentHour < 6) return '夜深了'
  if (currentHour < 12) return '早上好'
  if (currentHour < 14) return '中午好'
  if (currentHour < 18) return '下午好'
  if (currentHour < 22) return '晚上好'
  return '夜深了'
})
const greetingEmoji = computed(() => {
  if (currentHour < 6) return '🌙'
  if (currentHour < 12) return '☀️'
  if (currentHour < 18) return '⛅'
  return '🌆'
})

// ── 情绪数据 ──
const todayEmotion = ref({ emoji: '😊', label: '开心' })
const selectedEmotion = ref('happy')

const emotions = [
  { key: 'happy', emoji: '😊', label: '开心' },
  { key: 'calm', emoji: '😌', label: '平静' },
  { key: 'sad', emoji: '😔', label: '难过' },
  { key: 'angry', emoji: '😤', label: '烦躁' },
  { key: 'tired', emoji: '😴', label: '疲惫' },
]

function selectEmotion(key: string) {
  selectedEmotion.value = key
  const em = emotions.find(e => e.key === key)
  if (em) todayEmotion.value = { emoji: em.emoji, label: em.label }
}

// ── 快捷操作 ──
const quickActions = [
  { key: 'photo', icon: '📸', label: '拍照记录', bgColor: 'rgba(232, 133, 90, 0.12)' },
  { key: 'pomodoro', icon: '🍅', label: '番茄钟', bgColor: 'rgba(212, 149, 106, 0.12)' },
  { key: 'fortune', icon: '🔮', label: '今日运势', bgColor: 'rgba(200, 168, 130, 0.12)' },
  { key: 'social', icon: '👥', label: '找搭子', bgColor: 'rgba(230, 184, 112, 0.12)' },
]

function handleAction(action: any) {
  uni.showToast({ title: action.label, icon: 'none' })
}

// ── 日记列表 Mock 数据 ──
const diaryList = ref([
  {
    id: 1,
    time: '12:30',
    tag: '美食',
    emotion: '😋',
    title: '午饭日记',
    content: '今天食堂出了新菜，番茄牛腩真的太香了！配上白米饭，吃了两碗都不够。下次还要来，感觉幸福感满满的一天就从一顿好饭开始。',
    image: true,
    imageIcon: '🍱',
    imageDesc: '午饭实拍',
  },
  {
    id: 2,
    time: '10:00',
    tag: '学习',
    emotion: '📝',
    title: '课堂笔记 · 算法课',
    content: '今天讲了红黑树的插入和删除，脑子有点绕。课后回去把代码手写了一遍，感觉思路清晰多了。动态规划部分下周要重点复习。',
    image: false,
    imageIcon: '',
    imageDesc: '',
  },
])

function openDiary(diary: any) {
  uni.showToast({ title: `打开: ${diary.title}`, icon: 'none' })
}

// ── AI 洞察 ──
const aiInsight = ref('你已经连续 3 天情绪不错 😊，最近关于"美食"的日记写了 8 篇，是个会享受生活的人。学习方面，你在算法课上的专注度比上周提升了 15%，继续保持！')

// ── 运势 ──
function goFortune() {
  uni.showToast({ title: '运势功能即将开放', icon: 'none' })
}

// ── TabBar ──
const tabList = [
  { icon: '📔', label: '日记', path: '/pages/diary/index' },
  { icon: '📚', label: '学习', path: '/pages/study/index' },
  { icon: '🏠', label: '首页', path: '/pages/index/index' },
  { icon: '👥', label: '社交', path: '/pages/social/index' },
  { icon: '👤', label: '我的', path: '/pages/profile/index' },
]

function switchTab(index: number) {
  if (index === 2) return
  activeTab.value = index
  uni.switchTab({ url: tabList[index].path })
}
</script>

<style lang="scss">
.page {
  min-height: 100vh;
  background: #FDF8F3;
  position: relative;
}

/* ── 导航栏 ── */
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(253, 248, 243, 0.94);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  box-shadow: 0 1px 0 rgba(26, 26, 46, 0.06);
}

.navbar-inner {
  height: 88px;
  display: flex;
  align-items: center;
  padding: 0 16px;
}

.navbar-avatar {
  width: 32px;
  height: 32px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.avatar-emoji {
  font-size: 18px;
  line-height: 1;
}

.navbar-logo {
  flex: 1;
  text-align: center;
}

.logo-text {
  font-size: 17px;
  font-weight: 600;
  color: #2C1F14;
}

.navbar-actions {
  width: 32px;
  display: flex;
  justify-content: flex-end;
}

.navbar-bell {
  font-size: 20px;
}

/* ── 滚动区 ── */
.scroll-content {
  height: 100vh;
}

/* ── 通用 Section ── */
.section {
  margin-bottom: 16px;
}

.section--padded {
  padding: 0 16px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #2C1F14;
}

.section-link {
  font-size: 13px;
  color: #E8855A;
  font-weight: 500;
}

/* ── 1. 问候 Banner ── */
.section-greeting {
  padding: 0 16px;
  margin-bottom: 16px;
}

.greeting-banner {
  border-radius: 20px;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 60%, #F7CDB5 100%);
  padding: 24px 20px;
  position: relative;
  overflow: hidden;
}

.banner-circle {
  position: absolute;
  border-radius: 9999px;
  background: rgba(255, 255, 255, 0.12);
}

.banner-circle--1 {
  width: 120px;
  height: 120px;
  top: -40px;
  right: -30px;
}

.banner-circle--2 {
  width: 80px;
  height: 80px;
  bottom: -20px;
  left: -15px;
}

.greeting-content {
  position: relative;
  z-index: 1;
}

.greeting-top {
  margin-bottom: 6px;
}

.greeting-main {
  font-size: 24px;
  font-weight: 700;
  color: #FFFFFF;
  line-height: 1.3;
  text-shadow: 0 1px 4px rgba(0, 0, 0, 0.10);
  display: block;
}

.greeting-sub {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.88);
  line-height: 1.5;
  display: block;
}

.greeting-days {
  font-weight: 700;
  color: #FFF;
  font-family: "DIN Alternate", monospace;
}

.greeting-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 12px;
  background: rgba(255, 255, 255, 0.18);
  border-radius: 20px;
  padding: 6px 12px;
  width: fit-content;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 4px;
}

.meta-icon {
  font-size: 14px;
}

.meta-text {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.95);
  font-weight: 500;
}

.meta-divider {
  width: 1px;
  height: 14px;
  background: rgba(255, 255, 255, 0.40);
}

/* ── 2. 情绪卡片 ── */
.emotion-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 1px 6px rgba(26, 26, 46, 0.06);
}

.emotion-picker {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.emotion-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  cursor: pointer;
}

.emotion-emoji-wrap {
  width: 52px;
  height: 52px;
  border-radius: 9999px;
  background: #F5EDE4;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s, box-shadow 0.2s;
}

.emotion-item--selected .emotion-emoji-wrap {
  transform: scale(1.18);
  box-shadow: 0 3px 10px rgba(232, 133, 90, 0.30);
}

.emotion-bg--happy  { background: rgba(240, 194, 110, 0.25) !important; }
.emotion-bg--calm   { background: rgba(91, 164, 207, 0.25) !important; }
.emotion-bg--sad    { background: rgba(100, 181, 246, 0.20) !important; }
.emotion-bg--angry  { background: rgba(217, 92, 74, 0.20) !important; }
.emotion-bg--tired  { background: rgba(168, 168, 162, 0.25) !important; }

.emotion-emoji {
  font-size: 28px;
  line-height: 1;
}

.emotion-label {
  font-size: 11px;
  color: #AE9D92;
  font-weight: 500;
  transition: color 0.2s;
}

.emotion-label--active {
  color: #4A3628;
  font-weight: 600;
}

/* ── 3. 快捷操作 ── */
.quick-actions {
  display: flex;
  justify-content: space-between;
  gap: 8px;
}

.quick-action-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.quick-action-item:active .quick-action-icon-wrap {
  transform: scale(0.92);
}

.quick-action-icon-wrap {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s;
}

.quick-action-icon {
  font-size: 28px;
  line-height: 1;
}

.quick-action-label {
  font-size: 12px;
  color: #4A3628;
  font-weight: 500;
  text-align: center;
}

/* ── 4. 日记列表 ── */
.diary-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.diary-card {
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 1px 6px rgba(26, 26, 46, 0.06);
  overflow: hidden;
  border-left: 4px solid #E8855A;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
}

.diary-card:active {
  transform: scale(0.985);
  box-shadow: 0 4px 12px rgba(232, 133, 90, 0.12);
}

.diary-card-inner {
  padding: 14px 14px 14px 12px;
}

.diary-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}

.diary-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.diary-time {
  font-size: 12px;
  color: #AE9D92;
  font-family: "DIN Alternate", monospace;
}

.diary-tag {
  font-size: 11px;
  color: #E8855A;
  background: rgba(232, 133, 90, 0.10);
  padding: 2px 8px;
  border-radius: 9999px;
  font-weight: 500;
}

.diary-emotion {
  font-size: 22px;
}

.diary-title {
  font-size: 16px;
  font-weight: 600;
  color: #2C1F14;
  display: block;
  margin-bottom: 5px;
}

.diary-content {
  font-size: 14px;
  color: #857268;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.diary-image-wrap {
  margin-top: 10px;
}

.diary-image-placeholder {
  width: 100%;
  height: 100px;
  background: linear-gradient(135deg, #FDF0E8, #F7CDB5);
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.diary-image-icon {
  font-size: 32px;
}

.diary-image-desc {
  font-size: 12px;
  color: #AE9D92;
}

/* ── 5. AI 洞察卡 ── */
.ai-insight-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 1px 6px rgba(26, 26, 46, 0.06);
  background: linear-gradient(135deg, rgba(232,133,90,0.04) 0%, rgba(242,180,155,0.07) 100%);
  border: 1px solid rgba(232, 133, 90, 0.15);
}

.ai-insight-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.ai-badge {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 9999px;
  padding: 3px 10px;
}

.ai-badge-text {
  font-size: 12px;
  color: #FFFFFF;
  font-weight: 600;
}

.ai-insight-date {
  font-size: 12px;
  color: #AE9D92;
}

.ai-insight-content {
  font-size: 14px;
  color: #4A3628;
  line-height: 1.75;
  display: block;
  margin-bottom: 12px;
}

.ai-insight-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.ai-dot-loading {
  display: flex;
  gap: 4px;
  align-items: center;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 9999px;
  background: #E8855A;
  animation: dot-bounce 1.4s ease infinite;
}

.dot1 { animation-delay: 0s; }
.dot2 { animation-delay: 0.2s; }
.dot3 { animation-delay: 0.4s; }

@keyframes dot-bounce {
  0%, 80%, 100% { transform: scale(0.6); opacity: 0.4; }
  40% { transform: scale(1.0); opacity: 1.0; }
}

.ai-insight-more {
  font-size: 13px;
  color: #E8855A;
  font-weight: 500;
}

/* ── 6. 运势卡 ── */
.fortune-card {
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 60%, #F7CDB5 100%);
  border-radius: 16px;
  padding: 20px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  box-shadow: 0 4px 16px rgba(232, 133, 90, 0.28);
  transition: transform 0.15s;
}

.fortune-card:active {
  transform: scale(0.97);
}

.fortune-card-left {
  flex: 1;
}

.fortune-title {
  font-size: 20px;
  font-weight: 700;
  color: #FFFFFF;
  display: block;
  margin-bottom: 4px;
}

.fortune-sub {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.82);
  display: block;
  margin-bottom: 10px;
}

.fortune-stars {
  display: flex;
  gap: 2px;
}

.star {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.50);
}

.star--filled {
  color: #FFFFFF;
}

.fortune-card-right {
  flex-shrink: 0;
  margin-left: 12px;
}

.fortune-emoji {
  font-size: 48px;
  line-height: 1;
}

/* ── 底部留白 ── */
.bottom-spacer {
  height: 80px;
}

/* ── TabBar ── */
.tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 200;
  height: 60px;
  padding-bottom: env(safe-area-inset-bottom);
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 -1px 6px rgba(26, 26, 46, 0.08);
  display: flex;
  align-items: center;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

.tabbar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  cursor: pointer;
  height: 100%;
}

.tabbar-icon {
  font-size: 22px;
  line-height: 1;
  opacity: 0.45;
  transition: opacity 0.2s, transform 0.2s;
}

.tabbar-item--active .tabbar-icon {
  opacity: 1;
  transform: scale(1.1);
}

.tabbar-label {
  font-size: 11px;
  color: #AE9D92;
  font-weight: 500;
  transition: color 0.2s;
}

.tabbar-label--active {
  color: #E8855A;
}

/* 首页中间凸起 */
.tabbar-item--home {
  padding-bottom: 8px;
}

.tabbar-home-btn {
  width: 52px;
  height: 52px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 4px 12px rgba(232, 133, 90, 0.38);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s, box-shadow 0.15s;
  margin-top: -18px;
}

.tabbar-item--home:active .tabbar-home-btn {
  transform: scale(0.92);
  box-shadow: 0 2px 6px rgba(232, 133, 90, 0.28);
}

.tabbar-home-icon {
  font-size: 24px;
  line-height: 1;
}

.font-mono {
  font-family: "DIN Alternate", "SF Mono", monospace;
  font-variant-numeric: tabular-nums;
}
</style>
