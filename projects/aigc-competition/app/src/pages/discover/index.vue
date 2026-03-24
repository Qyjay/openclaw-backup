<template>
  <view class="page">

    <!-- CustomNavBar -->
    <CustomNavBar title="发现" left-icon="avatar" />

    <!-- 内容滚动区 -->
    <scroll-view class="page-scroll" scroll-y>

      <!-- 运势横幅 -->
      <view class="fortune-banner" @click="go('/pages/fortune/index')">
        <view class="fortune-banner-bg" />
        <view class="fortune-banner-content">
          <view class="fortune-banner-left">
            <text class="fortune-title">🔮 今日运势</text>
            <view class="fortune-stars-row">
              <text class="fortune-label">学业</text>
              <text class="fortune-stars">
                <text v-for="i in 5" :key="i" :class="i <= 4 ? 'star-on' : 'star-off'">★</text>
              </text>
              <text class="fortune-label" style="margin-left: 20rpx">社交</text>
              <text class="fortune-stars">
                <text v-for="i in 5" :key="i" :class="i <= 5 ? 'star-on' : 'star-off'">★</text>
              </text>
            </view>
            <text class="fortune-desc">"今天适合去图书馆"  </text>
            <view class="fortune-cta">
              <text>查看</text>
              <text style="margin-left: 4rpx">→</text>
            </view>
          </view>
          <view class="fortune-orb">
            <text class="fortune-orb-emoji">🔮</text>
          </view>
        </view>
      </view>

      <!-- AI 创作工具 -->
      <SectionTitle title="AI 创作工具" />
      <view class="feature-grid">
        <view
          v-for="item in aiTools"
          :key="item.key"
          class="feature-item"
          @click="handleClick(item.key, item.toast)"
        >
          <text class="feature-emoji">{{ item.emoji }}</text>
          <text class="feature-name">{{ item.name }}</text>
        </view>
      </view>

      <!-- 学习工具 -->
      <SectionTitle title="学习工具" />
      <view class="feature-grid">
        <view
          v-for="item in studyTools"
          :key="item.key"
          class="feature-item"
          @click="handleClick(item.key, item.toast)"
        >
          <text class="feature-emoji">{{ item.emoji }}</text>
          <text class="feature-name">{{ item.name }}</text>
        </view>
      </view>

      <!-- 社交与成长 -->
      <SectionTitle title="社交与成长" />
      <view class="feature-grid">
        <view
          v-for="item in socialGrowth"
          :key="item.key"
          class="feature-item"
          @click="handleClick(item.key, item.toast)"
        >
          <text class="feature-emoji">{{ item.emoji }}</text>
          <text class="feature-name">{{ item.name }}</text>
        </view>
      </view>

      <!-- 更多 -->
      <SectionTitle title="更多" />
      <view class="feature-grid">
        <view
          v-for="item in moreItems"
          :key="item.key"
          class="feature-item"
          @click="handleClick(item.key, item.toast)"
        >
          <text class="feature-emoji">{{ item.emoji }}</text>
          <text class="feature-name">{{ item.name }}</text>
        </view>
      </view>

      <view class="bottom-spacer" />
    </scroll-view>

    <!-- TabBar -->
    <TabBar />
  </view>
</template>

<script setup lang="ts">
import CustomNavBar from '@/components/CustomNavBar.vue'
import TabBar from '@/components/TabBar.vue'

// 内部组件：段落标题
const SectionTitle = {
  props: { title: String },
  template: `<view class="section-title-wrap"><text class="section-title">{{ title }}</text></view>`,
}

// ── 数据 ──
const aiTools = [
  { key: 'comic',       emoji: '🎬', name: '漫画生成', toast: '' },
  { key: 'share-card',  emoji: '📤', name: '分享卡片', toast: '' },
  { key: 'style-engine',emoji: '✍️', name: '文风引擎', toast: '' },
]

const studyTools = [
  { key: 'pomodoro',    emoji: '🍅', name: '番茄钟',   toast: '' },
  { key: 'todo',        emoji: '📋', name: '待办清单', toast: '' },
  { key: 'classnote',   emoji: '📸', name: '课堂笔记', toast: '复赛上线' },
]

const socialGrowth = [
  { key: 'match',        emoji: '👥', name: '找搭子',   toast: '' },
  { key: 'growth',       emoji: '🌱', name: '成长轨迹', toast: '' },
  { key: 'achievements',emoji: '🏆', name: '成就系统', toast: '' },
]

const moreItems = [
  { key: 'novel',   emoji: '📖', name: '自传小说', toast: '' },
  { key: 'audio',   emoji: '🎙️', name: '有声日记', toast: '开发中' },
  { key: 'bgm',     emoji: '🎵', name: '日记BGM',  toast: '开发中' },
]

// ── 路由 ──
const routes: Record<string, string> = {
  comic:        '/pages/diary/comic',
  'share-card': '/pages/diary/share-card',
  'style-engine': '/pages/diary/style-engine',
  pomodoro:     '/pages/study/pomodoro',
  todo:         '/pages/study/todo',
  match:        '/pages/social/match',
  growth:       '/pages/growth/index',
  achievements: '/pages/growth/achievements',
  novel:        '/pages/novel/index',
}

function handleClick(key: string, toast?: string) {
  if (toast) {
    uni.showToast({ title: toast, icon: 'none' })
    return
  }
  const path = routes[key]
  if (path) {
    uni.navigateTo({ url: path })
  }
}

function go(url: string) {
  uni.navigateTo({ url })
}
</script>

<style lang="scss" scoped>
.page {
  position: absolute;
  inset: 0;
  height: 100% !important;
  min-height: 0 !important;
  background: #FDF8F3;
  overflow: hidden;
}

.page-scroll {
  position: absolute;
  top: 44px;
  left: 0;
  right: 0;
  bottom: 60px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding: 0 16rpx 0;
}

/* ── 运势横幅 ── */
.fortune-banner {
  border-radius: 24rpx;
  background: linear-gradient(135deg, #FDF0E8 0%, #F7CDB5 100%);
  margin: 16rpx 0 24rpx;
  padding: 28rpx 24rpx;
  position: relative;
  overflow: hidden;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: transform 0.15s;
  &:active { transform: scale(0.98); }
}

.fortune-banner-bg {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 80% 50%, rgba(232, 133, 90, 0.12) 0%, transparent 60%);
  pointer-events: none;
}

.fortune-banner-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  z-index: 1;
}

.fortune-banner-left { flex: 1; }

.fortune-title {
  font-size: 34rpx;
  font-weight: 700;
  color: #2C1F14;
  display: block;
  margin-bottom: 8rpx;
}

.fortune-stars-row {
  display: flex;
  align-items: center;
  margin-bottom: 8rpx;
}

.fortune-label {
  font-size: 24rpx;
  color: #4A3628;
  margin-right: 6rpx;
}

.fortune-stars {
  font-size: 22rpx;
  letter-spacing: 1rpx;
}

.star-on { color: #E8855A; }
.star-off { color: #D4C4B8; }

.fortune-desc {
  font-size: 24rpx;
  color: #4A3628;
  display: block;
  margin-bottom: 10rpx;
  opacity: 0.8;
}

.fortune-cta {
  display: inline-flex;
  align-items: center;
  font-size: 24rpx;
  color: #E8855A;
  font-weight: 600;
}

.fortune-orb {
  width: 96rpx;
  height: 96rpx;
  border-radius: 50%;
  background: rgba(232, 133, 90, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  margin-left: 16rpx;
}

.fortune-orb-emoji {
  font-size: 48rpx;
}

/* ── 段落标题 ── */
.section-title-wrap {
  padding: 24rpx 8rpx 12rpx;
}

.section-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #2C1F14;
}

/* ── 功能网格 ── */
.feature-grid {
  display: flex;
  gap: 16rpx;
  margin-bottom: 8rpx;
}

.feature-item {
  flex: 1;
  height: 180rpx;
  background: #FFFFFF;
  border-radius: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8rpx;
  cursor: pointer;
  transition: transform 0.15s;
  &:active { transform: scale(0.96); }
}

.feature-emoji {
  font-size: 48rpx;
  line-height: 1;
}

.feature-name {
  font-size: 26rpx;
  color: #4A3628;
  text-align: center;
}

.bottom-spacer {
  height: 40rpx;
}
</style>
