<template>
  <view v-if="visible" class="tabbar-wrapper">
    <!-- ActionSheet -->
    <transition name="sheet">
      <view v-if="showActionSheet" class="action-sheet-overlay" @click="closeActionSheet">
        <view class="action-sheet-panel" @click.stop>
          <view class="action-sheet-header">
            <text class="action-sheet-title">选择记录方式</text>
          </view>
          <view class="action-sheet-options">
            <view class="action-option" @click="chooseMode('photo')">
              <text class="action-icon">📸</text>
              <text class="action-label">拍照记录</text>
            </view>
            <view class="action-option" @click="chooseMode('album')">
              <text class="action-icon">🖼️</text>
              <text class="action-label">从相册选择</text>
            </view>
            <view class="action-option" @click="chooseMode('text')">
              <text class="action-icon">✍️</text>
              <text class="action-label">文字记录</text>
            </view>
            <view class="action-option" @click="chooseMode('voice')">
              <text class="action-icon">🎤</text>
              <text class="action-label">语音记录</text>
            </view>
          </view>
          <view class="action-sheet-cancel" @click="closeActionSheet">
            <text class="cancel-text">取消</text>
          </view>
        </view>
      </view>
    </transition>

    <!-- TabBar -->
    <view class="tabbar">
      <view
        v-for="(item, index) in tabs"
        :key="index"
        class="tabbar-item"
        :class="{
          'tabbar-item--active': activeIndex === index,
          'tabbar-item--write': index === 2
        }"
        @click="switchTab(index)"
      >
        <!-- 写日记：中间凸起圆形按钮 -->
        <view v-if="index === 2" class="tabbar-write-btn">
          <text class="tabbar-write-icon">✏️</text>
        </view>

        <!-- 普通 tab -->
        <template v-else>
          <view class="tabbar-icon-wrap">
            <image
              v-if="item.icon"
              class="tabbar-icon-img"
              :class="{ 'tabbar-icon-img--active': activeIndex === index }"
              :src="item.icon"
              mode="aspectFit"
            />
            <text v-else class="tabbar-icon-emoji" :class="{ 'tabbar-icon-emoji--active': activeIndex === index }">
              {{ item.emoji }}
            </text>
          </view>
          <text
            class="tabbar-label"
            :class="{ 'tabbar-label--active': activeIndex === index }"
          >{{ item.text }}</text>
        </template>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { onShow } from '@dcloudio/uni-app'

const props = defineProps<{
  current?: number
}>()

const activeIndex = ref(props.current ?? 0)
const showActionSheet = ref(false)

// 只在 Tab 一级页面显示 TabBar
const visible = ref(true)

// 不应显示 TabBar 的二级页面路由
const HIDE_ROUTES = [
  'pages/growth/index',
  'pages/growth/achievements',
  'pages/novel/index',
  'pages/novel/reader',
  'pages/social/match',
  'pages/profile/settings',
  'pages/profile/agent-portrait',
  'pages/profile/semester-report',
  'pages/settings/about',
  'pages/diary/detail',
  'pages/diary/comic',
  'pages/diary/share-card',
  'pages/diary/emotion-calendar',
  'pages/diary/style-engine',
  'pages/study/pomodoro',
  'pages/study/todo',
  'pages/fortune/index',
  'pages/chat/index',
]

onShow(() => {
  try {
    const pages = getCurrentPages()
    if (!pages || pages.length === 0) {
      visible.value = true
      return
    }
    const currentPage = pages[pages.length - 1]
    const route = currentPage.route || ''
    const shouldHide = HIDE_ROUTES.some(r => route === r || route.startsWith(r))
    visible.value = !shouldHide
  } catch (_) {
    visible.value = true
  }
})

watch(() => props.current, (v) => {
  if (v !== undefined) activeIndex.value = v
})

const tabs = [
  { emoji: '📔', text: '日记',  path: '/pages/index/index',    icon: '/static/tabbar/tab-diary.png' },
  { emoji: '🧭', text: '发现',  path: '/pages/discover/index',  icon: '' },
  { emoji: '✏️', text: '写',    path: '/pages/write/index',     icon: '' },
  { emoji: '💬', text: '消息',  path: '/pages/messages/index',  icon: '' },
  { emoji: '👤', text: '我的',  path: '/pages/profile/index',   icon: '/static/tabbar/tab-profile.png' },
]

function switchTab(index: number) {
  if (index === 2) {
    // 写日记：显示 ActionSheet
    showActionSheet.value = true
    return
  }
  activeIndex.value = index
  uni.switchTab({ url: tabs[index].path })
}

function closeActionSheet() {
  showActionSheet.value = false
}

function chooseMode(mode: string) {
  closeActionSheet()
  const modeMap: Record<string, string> = {
    photo: 'photo',
    album: 'album',
    text: 'text',
    voice: 'voice',
  }
  uni.navigateTo({ url: `/pages/write/index?mode=${modeMap[mode] ?? 'text'}` })
}
</script>

<style lang="scss">
.tabbar-wrapper {
  position: relative;
}

.tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 9999;
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

.tabbar-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44rpx;
  height: 44rpx;
}

.tabbar-icon-img {
  width: 44rpx;
  height: 44rpx;
  opacity: 0.4;
  transition: opacity 0.2s, transform 0.2s;
}

.tabbar-icon-img--active {
  opacity: 1;
  transform: scale(1.12);
}

.tabbar-icon-emoji {
  font-size: 22px;
  opacity: 0.45;
  transition: opacity 0.2s, transform 0.2s;
  line-height: 1;
}

.tabbar-icon-emoji--active {
  opacity: 1;
  transform: scale(1.12);
}

.tabbar-label {
  font-size: 11px;
  color: #AE9D92;
  font-weight: 500;
  transition: color 0.2s;
  line-height: 1;
}

.tabbar-label--active {
  color: #E8855A;
}

/* 写日记：中间凸起 */
.tabbar-item--write {
  padding-top: 0;
  margin-top: -20rpx;
}

.tabbar-write-btn {
  width: 96rpx;
  height: 96rpx;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 4rpx 16rpx rgba(232, 133, 90, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s, box-shadow 0.15s;
}

.tabbar-item--write:active .tabbar-write-btn {
  transform: scale(0.92);
  box-shadow: 0 2rpx 8rpx rgba(232, 133, 90, 0.25);
}

.tabbar-write-icon {
  font-size: 26px;
  line-height: 1;
  filter: brightness(0) invert(1);
}

/* ActionSheet */
.action-sheet-overlay {
  position: fixed;
  inset: 0;
  z-index: 99990;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.action-sheet-panel {
  width: 100%;
  background: #FFFFFF;
  border-radius: 24rpx 24rpx 0 0;
  padding-bottom: env(safe-area-inset-bottom);
  overflow: hidden;
}

.action-sheet-header {
  padding: 28rpx 0 20rpx;
  display: flex;
  justify-content: center;
}

.action-sheet-title {
  font-size: 15px;
  color: #2C1F14;
  font-weight: 600;
}

.action-sheet-options {
  display: flex;
  flex-direction: column;
  padding: 0 24rpx;
  gap: 4rpx;
}

.action-option {
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 28rpx 16rpx;
  border-radius: 16rpx;
  transition: background 0.15s;
}

.action-option:active {
  background: rgba(232, 133, 90, 0.08);
}

.action-icon {
  font-size: 24px;
}

.action-label {
  font-size: 16px;
  color: #2C1F14;
  font-weight: 500;
}

.action-sheet-cancel {
  margin: 16rpx 24rpx 0;
  padding: 28rpx 0;
  background: #F5F0EB;
  border-radius: 16rpx;
  display: flex;
  justify-content: center;
}

.cancel-text {
  font-size: 16px;
  color: #4A3628;
  font-weight: 500;
}

/* ActionSheet 动画 */
.sheet-enter-active,
.sheet-leave-active {
  transition: opacity 0.25s ease;
}

.sheet-enter-active .action-sheet-panel,
.sheet-leave-active .action-sheet-panel {
  transition: transform 0.3s ease-out;
}

.sheet-enter-from,
.sheet-leave-to {
  opacity: 0;
}

.sheet-enter-from .action-sheet-panel,
.sheet-leave-to .action-sheet-panel {
  transform: translateY(100%);
}
</style>
