<template>
  <view class="page">
    <CustomNavBar title="待办事项" left-icon="back" />
    <view class="content">
      <text class="placeholder">待办事项页 - 开发中</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import CustomNavBar from '@/components/CustomNavBar.vue'
</script>

<style lang="scss" scoped>
.page {
  min-height: 100vh;
  background: #FDF8F3;
}
.content {
  display: flex;
  align-items: center;
  justify-content: center;
  height: calc(100vh - 88px);
}
.placeholder {
  font-size: 15px;
  color: #AE9D92;
}
</style>
