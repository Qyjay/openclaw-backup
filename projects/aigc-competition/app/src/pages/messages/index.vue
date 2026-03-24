<template>
  <view class="page page-root">

    <!-- ── 顶栏 ── -->
    <view class="navbar">
      <text class="navbar-title font-handwrite">消息</text>
    </view>

    <!-- ── 滚动内容区 ── -->
    <view class="page-scroll">

      <!-- AI 伙伴置顶 -->
      <view class="ai-chat-card" @click="openAI">
        <view class="ai-left">
          <view class="ai-avatar">
            <text class="ai-avatar-icon">🤖</text>
          </view>
          <view class="ai-info">
            <view class="ai-name-row">
              <text class="ai-name">AI 伙伴</text>
              <text class="ai-time">刚刚</text>
            </view>
            <text class="ai-preview">看到你昨天的雅思全对了...</text>
          </view>
        </view>
        <view class="unread-badge">
          <text class="unread-num">2</text>
        </view>
      </view>

      <!-- ── 搭子消息 ── -->
      <view class="section-sep">
        <view class="sep-line" />
        <text class="sep-label font-handwrite">搭子消息</text>
        <view class="sep-line" />
      </view>

      <view class="buddy-list">
        <view
          v-for="buddy in buddyMessages"
          :key="buddy.id"
          class="buddy-item"
          @click="openBuddy(buddy)"
        >
          <view class="buddy-avatar" :style="{ background: buddy.avatarBg }">
            <text class="buddy-avatar-emoji">{{ buddy.emoji }}</text>
          </view>
          <view class="buddy-info">
            <view class="buddy-name-row">
              <text class="buddy-name">{{ buddy.name }}</text>
              <text class="buddy-time">{{ buddy.time }}</text>
            </view>
            <text class="buddy-preview">{{ buddy.lastMsg }}</text>
          </view>
          <view v-if="buddy.unread > 0" class="unread-badge">
            <text class="unread-num">{{ buddy.unread }}</text>
          </view>
        </view>
      </view>

      <!-- ── 系统通知 ── -->
      <view class="section-sep">
        <view class="sep-line" />
        <text class="sep-label font-handwrite">系统通知</text>
        <view class="sep-line" />
      </view>

      <view class="system-list">
        <view
          v-for="notif in systemNotifications"
          :key="notif.id"
          class="system-item"
          @click="handleSystemNotif(notif)"
        >
          <view class="system-icon-wrap">
            <text class="system-icon">{{ notif.emoji }}</text>
          </view>
          <view class="system-info">
            <view class="system-name-row">
              <text class="system-name">{{ notif.type }}</text>
              <text class="system-time">{{ notif.time }}</text>
            </view>
            <text class="system-content">{{ notif.content }}</text>
          </view>
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
          'tabbar-item--active': index === 3,
          'tabbar-item--write': index === 2
        }"
        @click="switchTab(index)"
      >
        <view v-if="index === 2" class="tabbar-write-btn">
          <text class="tabbar-write-icon">✏️</text>
        </view>
        <template v-else>
          <text class="tabbar-icon-emoji" :class="{ 'tabbar-icon-emoji--active': index === 3 }">{{ tab.emoji }}</text>
          <text class="tabbar-label" :class="{ 'tabbar-label--active': index === 3 }">{{ tab.text }}</text>
        </template>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
const buddyMessages = [
  {
    id: 1,
    emoji: '🧑‍🎓',
    avatarBg: 'linear-gradient(135deg, #7BB8D4, #A8D4E8)',
    name: '学习搭子 · 小明',
    lastMsg: '明天一起去图书馆吗？',
    time: '3小时前',
    unread: 0,
  },
  {
    id: 2,
    emoji: '🏃',
    avatarBg: 'linear-gradient(135deg, #F2B49B, #F7CDB5)',
    name: '运动搭子 · 小红',
    lastMsg: '晨跑 6:30，老地方见！',
    time: '昨天',
    unread: 1,
  },
  {
    id: 3,
    emoji: '🍳',
    avatarBg: 'linear-gradient(135deg, #5BAF85, #8ECFAD)',
    name: '美食搭子 · 小华',
    lastMsg: '发现了一家新开的奶茶店！',
    time: '2天前',
    unread: 0,
  },
]

const systemNotifications = [
  {
    id: 1,
    emoji: '🏆',
    type: '成就解锁 · 今天',
    content: '"连续7天写日记" 成就已解锁！',
    time: '今天',
    path: '/pages/growth/achievements',
  },
  {
    id: 2,
    emoji: '🌱',
    type: '成长提醒 · 昨天',
    content: '本周成长值 +125，排名上升 3 位',
    time: '昨天',
    path: '/pages/growth/index',
  },
]

function openAI() {
  uni.navigateTo({ url: '/pages/chat/index' })
}

function openBuddy(buddy: any) {
  uni.showToast({ title: '搭子聊天开发中', icon: 'none' })
}

function handleSystemNotif(notif: any) {
  if (notif.path) {
    uni.navigateTo({ url: notif.path })
  }
}

const tabList = [
  { emoji: '📔', text: '日记' },
  { emoji: '🧭', text: '发现' },
  { emoji: '✏️', text: '写' },
  { emoji: '💬', text: '消息' },
  { emoji: '👤', text: '我的' },
]

function switchTab(index: number) {
  if (index === 3) return
  if (index === 2) { uni.navigateTo({ url: '/pages/write/index' }); return }
  const paths = ['/pages/index/index', '/pages/discover/index', '', '/pages/messages/index', '/pages/profile/index']
  uni.switchTab({ url: paths[index] })
}
</script>

<style lang="scss" scoped>
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
}

/* ── AI 伙伴置顶卡 ── */
.ai-chat-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 12px 16px;
  padding: 14px 16px;
  background: #FFFFFF;
  border-radius: 16px;
  border-left: 4rpx solid #E8855A;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  &:active { background: #FEF8F5; }
}

.ai-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.ai-avatar {
  width: 46px;
  height: 46px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(232, 133, 90, 0.30);
}

.ai-avatar-icon { font-size: 22px; }

.ai-info {
  flex: 1;
  min-width: 0;
}

.ai-name-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.ai-name {
  font-size: 15px;
  font-weight: 600;
  color: #2C1F14;
}

.ai-time {
  font-size: 11px;
  color: #AE9D92;
  flex-shrink: 0;
}

.ai-preview {
  font-size: 13px;
  color: #857268;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

.unread-badge {
  flex-shrink: 0;
  background: #E8855A;
  border-radius: 9999px;
  min-width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 5px;
}

.unread-num { font-size: 11px; color: #FFFFFF; font-weight: 700; }

/* ── 分隔 ── */
.section-sep {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px 10px;
}

.sep-line {
  flex: 1;
  height: 1px;
  background: linear-gradient(90deg, transparent, #D4C4B8, transparent);
}

.sep-label { font-size: 12px; color: #857268; white-space: nowrap; }

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
}

/* ── 搭子消息列表 ── */
.buddy-list {
  margin: 0 16px;
  background: #FFFFFF;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.buddy-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  border-bottom: 1px solid rgba(44, 31, 20, 0.05);
  cursor: pointer;
  &:last-child { border-bottom: none; }
  &:active { background: rgba(232, 133, 90, 0.04); }
}

.buddy-avatar {
  width: 46px;
  height: 46px;
  border-radius: 9999px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.buddy-avatar-emoji { font-size: 22px; }

.buddy-info { flex: 1; min-width: 0; }

.buddy-name-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 4px;
}

.buddy-name { font-size: 15px; font-weight: 600; color: #2C1F14; }
.buddy-time { font-size: 11px; color: #AE9D92; }

.buddy-preview {
  font-size: 13px;
  color: #AE9D92;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

/* ── 系统通知 ── */
.system-list {
  margin: 0 16px;
  background: #F5F0EB;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(44, 31, 20, 0.04);
}

.system-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  border-bottom: 1px solid rgba(44, 31, 20, 0.05);
  cursor: pointer;
  &:last-child { border-bottom: none; }
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.system-icon-wrap {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: #FFFFFF;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.system-icon { font-size: 20px; }

.system-info { flex: 1; min-width: 0; }

.system-name-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 4px;
}

.system-name { font-size: 13px; color: #4A3628; font-weight: 600; }
.system-time { font-size: 11px; color: #AE9D92; }

.system-content {
  font-size: 13px;
  color: #857268;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
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

.tabbar-item--write { padding-top: 0; margin-top: -18px; }

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
