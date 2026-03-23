<template>
  <view class="page page-root">

    <!-- ── 顶栏 ── -->
    <view class="navbar">
      <text class="navbar-title font-handwrite">消息</text>
      <text class="navbar-badge">2</text>
    </view>

    <!-- ── 滚动内容区 ── -->
    <view class="page-scroll">

      <!-- AI 助手置顶 -->
      <view class="ai-chat-card" @click="openAI">
        <view class="ai-avatar">
          <text class="ai-avatar-icon">🤖</text>
        </view>
        <view class="ai-chat-body">
          <view class="ai-chat-header">
            <text class="ai-chat-name">你的 AI 伙伴</text>
            <view class="ai-badge-dot" />
          </view>
          <text class="ai-chat-preview">「今天运势不错，适合学习。来写日记吧 ✨」</text>
        </view>
        <text class="ai-chat-time">刚刚</text>
      </view>

      <!-- 分隔 -->
      <view class="section-sep">
        <view class="sep-line" />
        <text class="sep-label font-handwrite">搭子消息</text>
        <view class="sep-line" />
      </view>

      <!-- 搭子消息列表 -->
      <view class="chat-list">
        <view
          v-for="chat in chats"
          :key="chat.id"
          class="chat-item"
          @click="openChat(chat)"
        >
          <view class="chat-avatar" :style="{ background: chat.avatarBg }">
            <text class="chat-avatar-text">{{ chat.avatar }}</text>
          </view>
          <view class="chat-body">
            <view class="chat-header">
              <text class="chat-name">{{ chat.name }}</text>
              <text class="chat-time">{{ chat.time }}</text>
            </view>
            <text class="chat-preview" :class="{ 'chat-preview--unread': chat.unread > 0 }">
              {{ chat.lastMsg }}
            </text>
          </view>
          <view v-if="chat.unread > 0" class="unread-badge">
            <text class="unread-num">{{ chat.unread }}</text>
          </view>
        </view>
      </view>

      <!-- 空态提示 -->
      <view class="empty-tip">
        <text class="empty-icon">💬</text>
        <text class="empty-text font-handwrite">去发现页找搭子，开始聊天吧！</text>
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
const chats = [
  {
    id: 1,
    avatar: '小明',
    avatarBg: 'linear-gradient(135deg, #7BB8D4, #A8D4E8)',
    name: '自习搭子·小明',
    lastMsg: '明天图书馆见！',
    time: '14:30',
    unread: 2,
  },
  {
    id: 2,
    avatar: '小红',
    avatarBg: 'linear-gradient(135deg, #F2B49B, #F7CDB5)',
    name: '饭搭子·小红',
    lastMsg: '新食堂二楼好吃！推荐番茄牛腩！',
    time: '昨天',
    unread: 0,
  },
  {
    id: 3,
    avatar: '阿强',
    avatarBg: 'linear-gradient(135deg, #5BAF85, #8ECFAD)',
    name: '跑步搭子·阿强',
    lastMsg: '明早六点半操场！',
    time: '昨天',
    unread: 1,
  },
]

function openAI() {
  uni.showToast({ title: 'AI 对话功能即将开放', icon: 'none' })
}

function openChat(chat: any) {
  uni.showToast({ title: `打开与 ${chat.name} 的对话`, icon: 'none' })
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
  gap: 8px;
  background: rgba(253, 248, 243, 0.95);
  backdrop-filter: blur(12px);
  box-shadow: 0 1px 0 rgba(44, 31, 20, 0.06);
}

.navbar-title {
  font-size: 18px;
  font-weight: 700;
  color: #2C1F14;
}

.navbar-badge {
  background: #E8855A;
  color: #FFFFFF;
  font-size: 11px;
  font-weight: 700;
  padding: 1px 6px;
  border-radius: 9999px;
}

.page-scroll {
  position: absolute;
  top: 44px; left: 0; right: 0; bottom: 60px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

/* ── AI 助手卡 ── */
.ai-chat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: rgba(232, 133, 90, 0.05);
  border-bottom: 1px solid rgba(44, 31, 20, 0.06);
  cursor: pointer;
  &:active { background: rgba(232, 133, 90, 0.10); }
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

.ai-chat-body { flex: 1; }

.ai-chat-header {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 4px;
}

.ai-chat-name {
  font-size: 15px;
  font-weight: 600;
  color: #2C1F14;
}

.ai-badge-dot {
  width: 7px;
  height: 7px;
  border-radius: 9999px;
  background: #E8855A;
  animation: pulse 2s ease infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%       { opacity: 0.6; transform: scale(1.3); }
}

.ai-chat-preview {
  font-size: 13px;
  color: #857268;
  display: block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 220px;
}

.ai-chat-time { font-size: 11px; color: #AE9D92; flex-shrink: 0; align-self: flex-start; margin-top: 2px; }

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

/* ── 消息列表 ── */
.chat-list {
  background: #FFFFFF;
  border-radius: 16px;
  margin: 0 16px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.chat-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  border-bottom: 1px solid rgba(44, 31, 20, 0.05);
  cursor: pointer;
  &:last-child { border-bottom: none; }
  &:active { background: rgba(232, 133, 90, 0.04); }
}

.chat-avatar {
  width: 46px;
  height: 46px;
  border-radius: 9999px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chat-avatar-text { font-size: 13px; color: #FFFFFF; font-weight: 600; }

.chat-body { flex: 1; min-width: 0; }

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 4px;
}

.chat-name { font-size: 15px; font-weight: 600; color: #2C1F14; }
.chat-time { font-size: 11px; color: #AE9D92; }

.chat-preview {
  font-size: 13px;
  color: #AE9D92;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  display: block;
}

.chat-preview--unread { color: #4A3628; font-weight: 500; }

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

/* ── 空态 ── */
.empty-tip {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 32px 16px;
  opacity: 0.6;
}

.empty-icon { font-size: 40px; }
.empty-text { font-size: 14px; color: #857268; }

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
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
