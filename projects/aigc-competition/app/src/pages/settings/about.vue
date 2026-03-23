<template>
  <view class="page page-root">
    <CustomNavBar title="关于 App" left-icon="back" />
    <view class="page-scroll">
      <!-- Logo Area -->
      <view class="logo-section">
        <view class="logo-wrap">
          <image class="logo-img" src="/static/brand/logo-d-mascot.png" mode="aspectFill" />
        </view>
        <text class="app-name">半日</text>
        <text class="app-slogan">你的 AI 生活伙伴</text>
        <view class="version-badge">
          <text class="version-text">v1.0.0</text>
        </view>
      </view>

      <!-- Info Cards -->
      <view class="info-card">
        <view class="info-row">
          <text class="info-label">App 名称</text>
          <text class="info-value">半日</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">版本号</text>
          <text class="info-value">v1.0.0</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">所属平台</text>
          <text class="info-value">MiniMax AI 能力创作大赛</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">开发团队</text>
          <text class="info-value">Kylin Studio</text>
        </view>
      </view>

      <!-- Competition Info -->
      <view class="section-title">
        <text class="section-title-text">🏆 比赛信息</text>
      </view>
      <view class="info-card">
        <view class="info-row">
          <text class="info-label">赛事名称</text>
          <text class="info-value">MiniMax AI 开放平台</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">赛道</text>
          <text class="info-value">AI 原生应用赛道</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">开发框架</text>
          <text class="info-value">UniApp + Vue 3 + TypeScript</text>
        </view>
        <view class="info-divider" />
        <view class="info-row">
          <text class="info-label">AI 能力</text>
          <text class="info-value">通义千问 / 豆包 / Seedance</text>
        </view>
      </view>

      <!-- Features -->
      <view class="section-title">
        <text class="section-title-text">✨ 核心功能</text>
      </view>
      <view class="feature-grid">
        <view class="feature-item" v-for="f in features" :key="f.icon">
          <text class="feature-icon">{{ f.icon }}</text>
          <text class="feature-name">{{ f.name }}</text>
        </view>
      </view>

      <!-- Footer -->
      <view class="footer">
        <text class="footer-text">© 2026 Kylin Studio</text>
        <text class="footer-text">Made with ❤️ for everyone</text>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import CustomNavBar from '@/components/CustomNavBar.vue'

const features = [
  { icon: '📔', name: 'AI 日记' },
  { icon: '🎨', name: '心情漫画' },
  { icon: '🔮', name: 'AI 运势' },
  { icon: '🍅', name: '番茄钟' },
  { icon: '🤖', name: 'AI 对话' },
  { icon: '📊', name: '成长数据' },
]
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

.page-scroll {
  position: absolute;
  top: 88px;
  left: 0;
  right: 0;
  bottom: 0;
  overflow-y: auto;
  padding: 20px 16px;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 24px 0 32px;
}

.logo-wrap {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6px 20px rgba(232, 133, 90, 0.30);
  overflow: hidden;
}

.logo-img { width: 100%; height: 100%; }

.app-name {
  font-size: 24px;
  font-weight: 700;
  color: #2C1F14;
}

.app-slogan {
  font-size: 14px;
  color: #857268;
}

.version-badge {
  background: rgba(232, 133, 90, 0.10);
  border-radius: 9999px;
  padding: 4px 14px;
  margin-top: 4px;
}

.version-text {
  font-size: 13px;
  color: #E8855A;
  font-weight: 600;
}

.info-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 4px 0;
  margin-bottom: 16px;
  box-shadow: 0 1px 6px rgba(44, 31, 20, 0.06);
}

.info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
}

.info-label {
  font-size: 14px;
  color: #4A3628;
}

.info-value {
  font-size: 14px;
  color: #857268;
}

.info-divider {
  height: 1px;
  background: rgba(44, 31, 20, 0.05);
  margin: 0 16px;
}

.section-title {
  margin-bottom: 10px;
}

.section-title-text {
  font-size: 16px;
  font-weight: 600;
  color: #2C1F14;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 32px;
}

.feature-item {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 16px 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  box-shadow: 0 1px 4px rgba(44, 31, 20, 0.05);
}

.feature-icon { font-size: 24px; }

.feature-name {
  font-size: 12px;
  color: #4A3628;
  text-align: center;
}

.footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 16px 0 32px;
}

.footer-text {
  font-size: 12px;
  color: #AE9D92;
}
</style>
