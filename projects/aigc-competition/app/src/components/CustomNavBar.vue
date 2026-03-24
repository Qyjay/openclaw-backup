<template>
  <view class="nav-bar" :style="{ paddingTop: statusBarHeight + 'px' }">
    <view class="nav-bar-content">
      <!-- 左侧 -->
      <view class="nav-left" @click="handleLeftClick">
        <image
          v-if="leftIcon === 'avatar'"
          class="nav-avatar"
          src="https://picsum.photos/seed/navavatar/80/80"
          mode="aspectFill"
        />
        <text v-else-if="leftIcon === 'back'" class="nav-back">←</text>
        <view v-else />
      </view>

      <!-- 中间标题 -->
      <text class="nav-title">{{ title }}</text>

      <!-- 右侧 -->
      <view class="nav-right" @click="emit('rightClick')">
        <text v-if="rightText" class="nav-right-text">{{ rightText }}</text>
        <text v-else-if="rightIcon" class="nav-right-icon">{{ rightIcon }}</text>
        <view v-else />
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const props = withDefaults(defineProps<{
  title: string
  leftIcon?: 'avatar' | 'back' | 'none'
  rightIcon?: string
  rightText?: string
}>(), {
  leftIcon: 'none',
})

const emit = defineEmits<{
  leftClick: []
  rightClick: []
}>()

const statusBarHeight = ref(20)

onMounted(() => {
  const info = uni.getSystemInfoSync()
  statusBarHeight.value = info.statusBarHeight ?? 20
})

function handleLeftClick() {
  if (props.leftIcon === 'back') {
    uni.navigateBack()
  } else {
    emit('leftClick')
  }
}
</script>

<style lang="scss" scoped>
.nav-bar {
  background: #FDF8F3;
  position: relative;
  z-index: 100;
}

.nav-bar-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 44px;
  padding: 0 16px;
}

.nav-left,
.nav-right {
  width: 60px;
  display: flex;
  align-items: center;
}

.nav-left {
  justify-content: flex-start;
}

.nav-right {
  justify-content: flex-end;
}

.nav-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 2px solid #E8855A;
}

.nav-back {
  font-size: 22px;
  color: #2C1F14;
  line-height: 1;
}

.nav-title {
  font-size: 17px;
  font-weight: 600;
  color: #2C1F14;
  flex: 1;
  text-align: center;
}

.nav-right-text {
  font-size: 15px;
  color: #E8855A;
  font-weight: 500;
}

.nav-right-icon {
  font-size: 20px;
}
</style>
