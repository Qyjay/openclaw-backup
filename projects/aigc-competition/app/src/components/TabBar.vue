<template>
  <view class="tabbar">
    <view
      v-for="(item, index) in tabs"
      :key="index"
      class="tabbar-item"
      :class="{ 'tabbar-item--active': currentIndex === index, 'tabbar-item--home': index === 2 }"
      @click="switchTab(index)"
    >
      <!-- 首页中间凸起按钮 -->
      <view v-if="index === 2" class="tabbar-home-btn">
        <text class="tabbar-home-icon">{{ item.icon }}</text>
      </view>
      <!-- 普通 tab -->
      <template v-else>
        <text class="tabbar-item-icon">{{ item.icon }}</text>
        <text class="tabbar-item-label" :class="{ 'tabbar-item-label--active': currentIndex === index }">
          {{ item.text }}
        </text>
      </template>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  current?: number
}>()

const currentIndex = ref(props.current ?? 2)

const tabs = [
  { icon: '📔', text: '日记', path: '/pages/diary/index' },
  { icon: '📚', text: '学习', path: '/pages/study/index' },
  { icon: '🏠', text: '首页', path: '/pages/index/index' },
  { icon: '👥', text: '社交', path: '/pages/social/index' },
  { icon: '👤', text: '我的', path: '/pages/profile/index' },
]

function switchTab(index: number) {
  currentIndex.value = index
  uni.switchTab({ url: tabs[index].path })
}
</script>

<style lang="scss">
.tabbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  height: 120rpx;
  padding-bottom: env(safe-area-inset-bottom);
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 -2rpx 12rpx rgba(26, 26, 46, 0.08);
  display: flex;
  align-items: center;
  padding-top: 8rpx;
}

.tabbar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4rpx;
  cursor: pointer;
  padding-top: 8rpx;
}

.tabbar-item-icon {
  font-size: 44rpx;
  line-height: 1;
  opacity: 0.5;
  transition: opacity 0.2s, transform 0.2s;
}

.tabbar-item--active .tabbar-item-icon {
  opacity: 1;
  transform: scale(1.1);
}

.tabbar-item-label {
  font-size: 22rpx;
  color: #AE9D92;
  font-weight: 500;
  transition: color 0.2s;
}

.tabbar-item-label--active {
  color: #E8855A;
}

/* 首页中间凸起 */
.tabbar-item--home {
  margin-top: -36rpx;
}

.tabbar-home-btn {
  width: 96rpx;
  height: 96rpx;
  border-radius: 9999rpx;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 8rpx 20rpx rgba(232, 133, 90, 0.40);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s, box-shadow 0.15s;
}

.tabbar-item--home:active .tabbar-home-btn {
  transform: scale(0.92);
  box-shadow: 0 4rpx 12rpx rgba(232, 133, 90, 0.30);
}

.tabbar-home-icon {
  font-size: 44rpx;
  line-height: 1;
}
</style>
