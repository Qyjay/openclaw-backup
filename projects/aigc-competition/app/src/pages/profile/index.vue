<template>
  <view class="page page-root">

    <!-- ── 顶栏 ── -->
    <view class="navbar">
      <text class="navbar-title font-handwrite">我的</text>
      <view class="navbar-settings" @click="openSettings">
        <text class="settings-icon">⚙️</text>
      </view>
    </view>

    <!-- ── 内容滚动区 ── -->
    <view class="page-scroll">

      <!-- 用户卡片 -->
      <view class="profile-card">
        <view class="profile-avatar-wrap">
          <view class="profile-avatar">
            <image class="profile-avatar-img" src="/static/brand/logo-d-mascot.png" mode="aspectFill" />
          </view>
          <view class="profile-level-badge">
            <text class="profile-level-text">Lv.12</text>
          </view>
        </view>
        <view class="profile-info">
          <text class="profile-name">Kylin</text>
          <text class="profile-school">南开大学 · 软件工程 · 大三</text>
          <view class="profile-title-badge">
            <text class="profile-title-text">🌟 探索者</text>
          </view>
        </view>
        <!-- 手绘装饰 -->
        <text class="deco-star profile-deco-1">✦</text>
        <text class="deco-star profile-deco-2">✧</text>
      </view>

      <!-- 数据统计卡 -->
      <view class="stats-card">
        <view class="stat-item" @click="showStat('diary')">
          <text class="stat-icon">📔</text>
          <text class="stat-num font-mono">127</text>
          <text class="stat-label">日记</text>
        </view>
        <view class="stat-divider" />
        <view class="stat-item" @click="showStat('match')">
          <text class="stat-icon">👥</text>
          <text class="stat-num font-mono">23</text>
          <text class="stat-label">搭子</text>
        </view>
        <view class="stat-divider" />
        <view class="stat-item" @click="showStat('trophy')">
          <text class="stat-icon">🏆</text>
          <text class="stat-num font-mono">15</text>
          <text class="stat-label">成就</text>
        </view>
      </view>

      <!-- 经验条 -->
      <view class="exp-card">
        <view class="exp-header">
          <text class="exp-label font-handwrite">探索者 Lv.12</text>
          <text class="exp-value">2,450 / 3,000 XP</text>
        </view>
        <view class="exp-bar-bg">
          <view class="exp-bar-fill" :style="{ width: '82%' }" />
        </view>
        <text class="exp-hint">再写 18 篇日记升至 Lv.13 🌟</text>
      </view>

      <!-- 功能列表 -->
      <view class="menu-card">
        <view
          v-for="item in menuItems"
          :key="item.key"
          class="menu-item"
          @click="handleMenu(item)"
        >
          <view class="menu-icon-wrap" :style="{ background: item.iconBg }">
            <text class="menu-icon">{{ item.icon }}</text>
          </view>
          <text class="menu-name">{{ item.name }}</text>
          <text class="menu-arrow">›</text>
        </view>
      </view>

      <!-- 退出登录 -->
      <view class="logout-btn" @click="handleLogout">
        <text class="logout-text">退出登录</text>
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
          'tabbar-item--active': index === 4,
          'tabbar-item--write': index === 2
        }"
        @click="switchTab(index)"
      >
        <view v-if="index === 2" class="tabbar-write-btn">
          <text class="tabbar-write-icon">✏️</text>
        </view>
        <template v-else>
          <text class="tabbar-icon-emoji" :class="{ 'tabbar-icon-emoji--active': index === 4 }">{{ tab.emoji }}</text>
          <text class="tabbar-label" :class="{ 'tabbar-label--active': index === 4 }">{{ tab.text }}</text>
        </template>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
const menuItems = [
  { key: 'stats',   icon: '📊', name: '我的数据',   iconBg: 'rgba(232, 133, 90, 0.10)' },
  { key: 'skill',   icon: '🌳', name: '技能树',     iconBg: 'rgba(91, 175, 133, 0.12)' },
  { key: 'report',  icon: '📄', name: '学期报告',   iconBg: 'rgba(123, 184, 212, 0.12)' },
  { key: 'privacy', icon: '🔒', name: '隐私设置',   iconBg: 'rgba(174, 157, 146, 0.12)' },
  { key: 'about',   icon: 'ℹ️', name: '关于 App',   iconBg: 'rgba(230, 184, 112, 0.12)' },
]

function handleMenu(item: any) {
  uni.showToast({ title: `${item.name} 即将开放`, icon: 'none' })
}

function showStat(key: string) {
  uni.showToast({ title: `查看${key}详情`, icon: 'none' })
}

function openSettings() {
  uni.showToast({ title: '设置', icon: 'none' })
}

function handleLogout() {
  uni.showModal({
    title: '退出登录',
    content: '确定要退出吗？',
    success(res) {
      if (res.confirm) uni.showToast({ title: '已退出', icon: 'success' })
    }
  })
}

const tabList = [
  { emoji: '📔', text: '日记' },
  { emoji: '🧭', text: '发现' },
  { emoji: '✏️', text: '写' },
  { emoji: '💬', text: '消息' },
  { emoji: '👤', text: '我的' },
]

function switchTab(index: number) {
  if (index === 4) return
  if (index === 2) { uni.navigateTo({ url: '/pages/write/index' }); return }
  const paths = ['/pages/index/index', '/pages/discover/index', '', '/pages/messages/index', '/pages/profile/index']
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
  justify-content: space-between;
  padding: 0 16px;
  background: rgba(253, 248, 243, 0.95);
  backdrop-filter: blur(12px);
  box-shadow: 0 1px 0 rgba(44, 31, 20, 0.06);
}

.navbar-title { font-size: 18px; font-weight: 700; color: #2C1F14; }
.navbar-settings { cursor: pointer; padding: 4px; }
.settings-icon { font-size: 20px; }

.page-scroll {
  position: absolute;
  top: 44px; left: 0; right: 0; bottom: 60px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding: 16px 16px 0;
}

/* ── 用户卡片 ── */
.profile-card {
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 70%, #F7CDB5 100%);
  border-radius: 20px;
  padding: 24px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 14px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 6px 20px rgba(232, 133, 90, 0.28);
}

.profile-avatar-wrap {
  position: relative;
  flex-shrink: 0;
}

.profile-avatar {
  width: 64px;
  height: 64px;
  border-radius: 9999px;
  background: rgba(255,255,255,0.30);
  border: 2.5px solid rgba(255,255,255,0.60);
  display: flex;
  align-items: center;
  justify-content: center;
}

.profile-avatar-emoji { font-size: 32px; }
.profile-avatar-img { width: 100%; height: 100%; border-radius: 9999px; }

.profile-level-badge {
  position: absolute;
  bottom: -4px;
  right: -6px;
  background: #FFFFFF;
  border-radius: 9999px;
  padding: 2px 8px;
  box-shadow: 0 1px 4px rgba(44, 31, 20, 0.15);
}

.profile-level-text { font-size: 11px; color: #E8855A; font-weight: 700; }

.profile-info { flex: 1; }

.profile-name {
  font-size: 20px;
  font-weight: 700;
  color: #FFFFFF;
  display: block;
  margin-bottom: 3px;
}

.profile-school {
  font-size: 12px;
  color: rgba(255,255,255,0.88);
  display: block;
  margin-bottom: 8px;
}

.profile-title-badge {
  background: rgba(255,255,255,0.22);
  border-radius: 9999px;
  padding: 3px 10px;
  display: inline-flex;
}

.profile-title-text { font-size: 12px; color: #FFFFFF; font-weight: 600; }

/* 装饰星星 */
.deco-star { position: absolute; color: rgba(255,255,255,0.50); pointer-events: none; }
.profile-deco-1 { top: 12px; right: 18px; font-size: 16px; }
.profile-deco-2 { bottom: 14px; right: 36px; font-size: 10px; }

/* ── 统计卡 ── */
.stats-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 16px;
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  &:active { opacity: 0.7; }
}

.stat-icon { font-size: 22px; }
.stat-num { font-size: 22px; font-weight: 700; color: #2C1F14; font-family: "DIN Alternate", monospace; }
.stat-label { font-size: 12px; color: #857268; }

.stat-divider {
  width: 1px;
  height: 36px;
  background: rgba(44, 31, 20, 0.08);
}

/* ── 经验条 ── */
.exp-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 14px 16px;
  margin-bottom: 12px;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.exp-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.exp-label { font-size: 14px; font-weight: 600; color: #2C1F14; }
.exp-value { font-size: 12px; color: #857268; font-family: "DIN Alternate", monospace; }

.exp-bar-bg {
  height: 8px;
  background: #F5EDE4;
  border-radius: 9999px;
  overflow: hidden;
  margin-bottom: 8px;
}

.exp-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #E8855A, #F0A882);
  border-radius: 9999px;
  transition: width 0.8s ease;
}

.exp-hint { font-size: 12px; color: #AE9D92; }

/* ── 功能列表 ── */
.menu-card {
  background: #FFFFFF;
  border-radius: 16px;
  overflow: hidden;
  margin-bottom: 16px;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 15px 16px;
  border-bottom: 1px solid rgba(44, 31, 20, 0.05);
  cursor: pointer;
  &:last-child { border-bottom: none; }
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.menu-icon-wrap {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.menu-icon { font-size: 18px; }
.menu-name { flex: 1; font-size: 15px; color: #2C1F14; font-weight: 500; }
.menu-arrow { font-size: 18px; color: #AE9D92; }

/* ── 退出 ── */
.logout-btn {
  background: #FFFFFF;
  border-radius: 14px;
  padding: 15px;
  text-align: center;
  cursor: pointer;
  margin-bottom: 24px;
  &:active { background: #FEF3EE; }
}

.logout-text { font-size: 15px; color: #D95C4A; font-weight: 500; }

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
}

.font-mono {
  font-family: "DIN Alternate", "SF Mono", monospace;
  font-variant-numeric: tabular-nums;
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
.tabbar-write-icon { font-size: 22px; filter: brightness(0) invert(1); }

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
