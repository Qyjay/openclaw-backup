<template>
  <view class="page page-root">

    <!-- ── 顶栏 ── -->
    <view class="navbar">
      <text class="navbar-title font-handwrite">发现</text>
    </view>

    <!-- ── 内容滚动区 ── -->
    <view class="page-scroll">

      <!-- 运势横幅卡 -->
      <view class="fortune-banner" @click="handleFeature('fortune')">
        <view class="fortune-banner-bg" />
        <view class="fortune-banner-content">
          <view class="fortune-banner-left">
            <text class="fortune-banner-title font-handwrite">🔮 今日运势</text>
            <text class="fortune-banner-sub">AI 结合日记生成 · 点击查看</text>
            <view class="fortune-stars">
              <text v-for="i in 5" :key="i" class="fortune-star" :class="{ 'fortune-star--on': i <= 4 }">★</text>
            </view>
          </view>
          <view class="fortune-banner-right">
            <view class="fortune-orb">
              <image class="fortune-orb-img" src="/static/icons/module-fortune.png" mode="aspectFit" />
            </view>
          </view>
        </view>
        <!-- 手绘装饰星星 -->
        <text class="deco-star deco-star--1">✦</text>
        <text class="deco-star deco-star--2">✦</text>
        <text class="deco-star deco-star--3">✧</text>
      </view>

      <!-- 功能网格 -->
      <view class="section-header">
        <text class="section-title font-handwrite section-title-underline">功能</text>
      </view>

      <view class="feature-grid">
        <view
          v-for="feature in features"
          :key="feature.key"
          class="feature-card"
          :style="{ background: feature.bg }"
          @click="handleFeature(feature.key)"
        >
          <image v-if="feature.iconImg" class="feature-icon-img" :src="feature.iconImg" mode="aspectFit" />
          <text v-else class="feature-icon">{{ feature.icon }}</text>
          <text class="feature-name">{{ feature.name }}</text>
          <text class="feature-sub">{{ feature.sub }}</text>
        </view>
      </view>

      <!-- 手绘分隔线 -->
      <view class="divider-handdrawn" />

      <!-- 最近动态 -->
      <view class="section-header">
        <text class="section-title font-handwrite section-title-underline">最近</text>
      </view>

      <view class="recent-list">
        <view class="recent-item" v-for="item in recentItems" :key="item.id" @click="handleFeature(item.key)">
          <text class="recent-icon">{{ item.icon }}</text>
          <view class="recent-text">
            <text class="recent-name">{{ item.name }}</text>
            <text class="recent-desc">{{ item.desc }}</text>
          </view>
          <text class="recent-arrow">›</text>
        </view>
      </view>

      <view class="bottom-spacer" />
    </view>

    <!-- ── TabBar ── -->
    <view class="tabbar">
      <view
        v-for="(tab, index) in tabList"
        :key="index"
        class="tabbar-item"
        :class="{
          'tabbar-item--active': index === 1,
          'tabbar-item--write': index === 2
        }"
        @click="switchTab(index)"
      >
        <view v-if="index === 2" class="tabbar-write-btn">
          <text class="tabbar-write-icon">✏️</text>
        </view>
        <template v-else>
          <text class="tabbar-icon-emoji" :class="{ 'tabbar-icon-emoji--active': index === 1 }">{{ tab.emoji }}</text>
          <text class="tabbar-label" :class="{ 'tabbar-label--active': index === 1 }">{{ tab.text }}</text>
        </template>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
const features = [
  { key: 'pomodoro',  icon: '🍅', iconImg: '/static/icons/module-study.png',   name: '番茄钟',   sub: '今日 4/6',    bg: 'rgba(232, 133, 90, 0.08)' },
  { key: 'match',     icon: '👥', iconImg: '/static/icons/module-social.png',  name: '找搭子',   sub: '3 个匹配',    bg: 'rgba(200, 168, 130, 0.10)' },
  { key: 'photo',     icon: '📸', iconImg: '/static/icons/module-diary.png',   name: '拍照记录',  sub: '快速日记',    bg: 'rgba(242, 180, 155, 0.10)' },
  { key: 'growth',    icon: '🌱', iconImg: '/static/icons/module-growth.png',  name: '成长轨迹',  sub: 'Lv.12',       bg: 'rgba(230, 184, 112, 0.10)' },
  { key: 'fortune',   icon: '🔮', iconImg: '/static/icons/module-fortune.png', name: '今日运势',  sub: '查看运势',    bg: 'rgba(212, 149, 106, 0.10)' },
  { key: 'resume',    icon: '📄', name: 'AI 简历',   sub: '一键生成',    bg: 'rgba(91, 175, 133, 0.10)' },
]

const recentItems = [
  { id: 1, key: 'pomodoro', icon: '🍅', name: '番茄钟完成',     desc: '今天完成了 4 个番茄，专注 100 分钟' },
  { id: 2, key: 'growth',   icon: '🌱', name: '成长值 +25',      desc: '写了今天的午饭日记，继续保持！' },
  { id: 3, key: 'match',    icon: '👥', name: '新搭子匹配',      desc: '发现 3 位有相同学习习惯的同学' },
]

function handleFeature(key: string) {
  uni.showToast({ title: `功能「${key}」即将开放`, icon: 'none' })
}

const tabList = [
  { emoji: '📔', text: '日记' },
  { emoji: '🧭', text: '发现' },
  { emoji: '✏️', text: '写' },
  { emoji: '💬', text: '消息' },
  { emoji: '👤', text: '我的' },
]

function switchTab(index: number) {
  if (index === 1) return
  if (index === 2) { uni.navigateTo({ url: '/pages/write/index' }); return }
  const paths = ['/pages/index/index', '/pages/discover/index', '/pages/write/index', '/pages/messages/index', '/pages/profile/index']
  uni.switchTab({ url: paths[index] })
}
</script>

<style lang="scss">
@import '@/common/styles/handdrawn.scss';

.page {
  position: absolute;
  inset: 0;
  height: 100% !important;
  min-height: 0 !important;
  max-height: 100% !important;
  background: #FDF8F3;
  overflow: hidden;
}

.navbar {
  position: absolute;
  top: 0; left: 0; right: 0;
  z-index: 100;
  height: 44px;
  display: flex;
  align-items: center;
  padding: 0 16px;
  background: rgba(253, 248, 243, 0.95);
  backdrop-filter: blur(12px);
  box-shadow: 0 1px 0 rgba(44, 31, 20, 0.06);
}

.navbar-title {
  font-size: 18px;
  font-weight: 700;
  color: #2C1F14;
}

.page-scroll {
  position: absolute;
  top: 44px; left: 0; right: 0; bottom: 60px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding: 14px 16px 0;
}

/* ── 运势横幅 ── */
.fortune-banner {
  border-radius: 18px;
  background: linear-gradient(135deg, #D4956A 0%, #E8855A 60%, #F0A882 100%);
  padding: 20px 16px;
  display: flex;
  align-items: stretch;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  margin-bottom: 20px;
  box-shadow: 0 6px 20px rgba(232, 133, 90, 0.30);
  transition: transform 0.15s;
  &:active { transform: scale(0.98); }
}

.fortune-banner-bg {
  position: absolute;
  inset: 0;
  background: radial-gradient(circle at 80% 30%, rgba(255,255,255,0.15) 0%, transparent 50%);
  pointer-events: none;
}

.fortune-banner-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  position: relative;
  z-index: 1;
}

.fortune-banner-left { flex: 1; }

.fortune-banner-title {
  font-size: 20px;
  font-weight: 700;
  color: #FFFFFF;
  display: block;
  margin-bottom: 4px;
}

.fortune-banner-sub {
  font-size: 12px;
  color: rgba(255,255,255,0.82);
  display: block;
  margin-bottom: 8px;
}

.fortune-stars { display: flex; gap: 2px; }
.fortune-star { font-size: 14px; color: rgba(255,255,255,0.45); }
.fortune-star--on { color: #FFFFFF; }

.fortune-banner-right { flex-shrink: 0; margin-left: 12px; }

.fortune-orb {
  width: 56px;
  height: 56px;
  border-radius: 9999px;
  background: rgba(255,255,255,0.20);
  display: flex;
  align-items: center;
  justify-content: center;
}

.fortune-orb-emoji { font-size: 30px; }
.fortune-orb-img { width: 48px; height: 48px; border-radius: 12px; }

.deco-star {
  position: absolute;
  color: rgba(255,255,255,0.55);
  pointer-events: none;
  font-size: 16px;
}
.deco-star--1 { top: 10px; right: 72px; font-size: 12px; }
.deco-star--2 { bottom: 12px; right: 56px; font-size: 18px; }
.deco-star--3 { top: 16px; right: 90px; font-size: 9px; }

/* ── Section ── */
.section-header { margin-bottom: 12px; }
.section-title {
  font-size: 17px;
  font-weight: 600;
  color: #2C1F14;
}

/* ── 功能网格 ── */
.feature-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 20px;
}

.feature-card {
  border-radius: 16px;
  padding: 16px 14px;
  cursor: pointer;
  transition: transform 0.15s;
  border: 1px solid rgba(44, 31, 20, 0.05);
  &:active { transform: scale(0.95); }
}

.feature-icon { font-size: 30px; display: block; margin-bottom: 8px; }
.feature-icon-img { width: 48px; height: 48px; border-radius: 12px; display: block; margin-bottom: 8px; }
.feature-name {
  font-size: 15px;
  font-weight: 600;
  color: #2C1F14;
  display: block;
  margin-bottom: 3px;
}
.feature-sub { font-size: 12px; color: #857268; }

/* ── 最近动态 ── */
.recent-list {
  background: #FFFFFF;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.recent-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  border-bottom: 1px solid rgba(44, 31, 20, 0.05);
  cursor: pointer;
  &:last-child { border-bottom: none; }
  &:active { background: rgba(232, 133, 90, 0.04); }
}

.recent-icon { font-size: 22px; }

.recent-text { flex: 1; }
.recent-name { font-size: 14px; font-weight: 600; color: #2C1F14; display: block; margin-bottom: 2px; }
.recent-desc { font-size: 12px; color: #857268; }
.recent-arrow { font-size: 18px; color: #AE9D92; }

/* ── 分隔线 ── */
.divider-handdrawn {
  width: 100%;
  height: 16rpx;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 320 16' preserveAspectRatio='none'%3E%3Cpath d='M4 8 Q40 5 80 8.5 Q120 12 160 7.5 Q200 4 240 8.5 Q280 12 316 8' stroke='%23E8E3DE' stroke-width='1.5' fill='none' stroke-linecap='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-size: 100% 100%;
  margin: 4px 0 16px;
}

.section-title-underline {
  position: relative;
  display: inline-block;
  &::after {
    content: '';
    display: block;
    width: 80%;
    height: 12rpx;
    margin-top: 4rpx;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 120 12'%3E%3Cpath d='M2 8 Q15 2 28 8 Q41 14 54 8 Q67 2 80 8 Q93 14 106 8 Q113 4 118 7' stroke='%23E8855A' stroke-width='2.5' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-size: 100% 100%;
  }
}

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
  letter-spacing: 1px;
}

.bottom-spacer { height: 20px; }

/* ── TabBar ── */
.tabbar {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  z-index: 200;
  height: 60px;
  padding-bottom: env(safe-area-inset-bottom);
  background: rgba(255, 255, 255, 0.97);
  box-shadow: 0 -1px 6px rgba(26, 26, 46, 0.08);
  display: flex;
  align-items: stretch;
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
  padding-top: 4px;
}

.tabbar-item--write {
  padding-top: 0;
  margin-top: -18px;
}

.tabbar-write-btn {
  width: 52px;
  height: 52px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 4px 16px rgba(232, 133, 90, 0.42);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s;
}

.tabbar-item--write:active .tabbar-write-btn { transform: scale(0.90); }

.tabbar-write-icon {
  font-size: 22px;
  filter: brightness(0) invert(1);
}

.tabbar-icon-emoji {
  font-size: 20px;
  opacity: 0.45;
  line-height: 1;
}

.tabbar-icon-emoji--active { opacity: 1; }

.tabbar-label {
  font-size: 11px;
  color: #AE9D92;
  font-weight: 500;
  line-height: 1;
}

.tabbar-label--active { color: #E8855A; }
</style>
