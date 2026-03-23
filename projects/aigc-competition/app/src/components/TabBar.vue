<template>
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
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps<{
  current?: number
}>()

const activeIndex = ref(props.current ?? 0)

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
  activeIndex.value = index
  if (index === 2) {
    // 写日记是全屏页，用 navigateTo
    uni.navigateTo({ url: '/pages/write/index' })
    return
  }
  uni.switchTab({ url: tabs[index].path })
}
</script>

<style lang="scss">
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
  transition: transform 0.15s, box-shadow 0.15s;
}

.tabbar-item--write:active .tabbar-write-btn {
  transform: scale(0.90);
  box-shadow: 0 2px 8px rgba(232, 133, 90, 0.28);
}

.tabbar-write-icon {
  font-size: 22px;
  line-height: 1;
  filter: brightness(0) invert(1);
}
</style>
