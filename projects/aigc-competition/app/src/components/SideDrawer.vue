<template>
  <teleport to="body">
    <transition name="drawer">
      <view v-if="visible" class="drawer-overlay" @click="close">
        <view class="drawer-panel" @click.stop>
          <!-- 用户卡片 -->
          <view class="user-card">
            <image
              class="user-avatar"
              src="https://picsum.photos/seed/draweravatar/160/160"
              mode="aspectFill"
            />
            <view class="user-info">
              <text class="user-name">Kylin</text>
              <text class="user-school">南开大学 · 软件工程</text>
              <text class="user-stats">📔 127篇日记  🔥 23天连续</text>
            </view>
          </view>

          <view class="divider" />

          <!-- 导航列表 -->
          <view class="nav-list">
            <view class="nav-item" @click="navigate('emotion-calendar')">
              <text class="nav-icon">📅</text>
              <text class="nav-label">日记日历</text>
            </view>
            <view class="nav-item" @click="navigate('emotion-calendar')">
              <text class="nav-icon">📊</text>
              <text class="nav-label">情绪统计</text>
            </view>
            <view class="nav-item" @click="navigate('growth')">
              <text class="nav-icon">🌱</text>
              <text class="nav-label">成长轨迹</text>
            </view>
            <view class="nav-item" @click="navigate('achievements')">
              <text class="nav-icon">🏆</text>
              <text class="nav-label">我的成就</text>
            </view>
            <view class="nav-item" @click="navigate('novel')">
              <text class="nav-icon">📖</text>
              <text class="nav-label">自传小说</text>
            </view>
          </view>

          <view class="divider" />

          <!-- AI洞察卡 -->
          <view class="insight-card">
            <text class="insight-title">🔮 今日运势</text>
            <text class="insight-stars">★★★★☆</text>
            <text class="insight-tip">今天适合去图书馆</text>
          </view>

          <view class="divider" />

          <!-- 设置 -->
          <view class="nav-item" @click="navigate('settings')">
            <text class="nav-icon">⚙️</text>
            <text class="nav-label">设置</text>
          </view>
        </view>
      </view>
    </transition>
  </teleport>
</template>

<script setup lang="ts">
const props = defineProps<{
  visible: boolean
}>()

const emit = defineEmits<{
  'update:visible': [boolean]
}>()

function close() {
  emit('update:visible', false)
}

function navigate(page: string) {
  close()
  const urlMap: Record<string, string> = {
    'emotion-calendar': '/pages/diary/emotion-calendar',
    'growth': '/pages/growth/index',
    'achievements': '/pages/growth/achievements',
    'novel': '/pages/novel/index',
    'settings': '/pages/profile/settings',
  }
  const url = urlMap[page]
  if (url) {
    uni.navigateTo({ url })
  }
}
</script>

<style lang="scss" scoped>
.drawer-overlay {
  position: fixed;
  inset: 0;
  z-index: 9998;
  background: rgba(0, 0, 0, 0.4);
}

.drawer-panel {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 75vw;
  background: #FFFFFF;
  padding-top: env(safe-area-inset-top);
  overflow-y: auto;
}

.user-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 40px 24px 24px;
  gap: 8px;
}

.user-avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  border: 3px solid #E8855A;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.user-name {
  font-size: 18px;
  font-weight: 700;
  color: #2C1F14;
}

.user-school {
  font-size: 13px;
  color: #4A3628;
}

.user-stats {
  font-size: 12px;
  color: #AE9D92;
  margin-top: 4px;
}

.divider {
  height: 1px;
  background: rgba(0, 0, 0, 0.06);
  margin: 8px 16px;
}

.nav-list {
  padding: 8px 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 24px;
  transition: background 0.15s;
}

.nav-item:active {
  background: rgba(232, 133, 90, 0.08);
}

.nav-icon {
  font-size: 20px;
}

.nav-label {
  font-size: 15px;
  color: #2C1F14;
  font-weight: 500;
}

.insight-card {
  padding: 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.insight-title {
  font-size: 15px;
  font-weight: 600;
  color: #2C1F14;
}

.insight-stars {
  font-size: 16px;
  color: #E8855A;
  letter-spacing: 2px;
}

.insight-tip {
  font-size: 13px;
  color: #4A3628;
}

/* 动画 */
.drawer-enter-active,
.drawer-leave-active {
  transition: opacity 0.3s ease;
}

.drawer-enter-active .drawer-panel,
.drawer-leave-active .drawer-panel {
  transition: transform 0.3s ease-out;
}

.drawer-enter-from,
.drawer-leave-to {
  opacity: 0;
}

.drawer-enter-from .drawer-panel,
.drawer-leave-to .drawer-panel {
  transform: translateX(-100%);
}
</style>
