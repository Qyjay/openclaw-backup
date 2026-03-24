<template>
  <view class="page">
    <CustomNavBar title="搭子匹配" left-icon="back" />

    <scroll-view class="scroll" scroll-y>
      <view class="content">

        <!-- ── 匹配推荐 ── -->
        <view class="section-card">
          <text class="section-title">── 匹配推荐 ──</text>

          <swiper
            class="rec-swiper"
            :current="swiperCurrent"
            circular
            previous-margin="40rpx"
            next-margin="40rpx"
            @change="onSwiperChange"
          >
            <swiper-item
              v-for="user in recommendations"
              :key="user.id"
              class="swiper-item-wrap"
            >
              <view class="rec-card">
                <!-- 头像区 -->
                <view class="rec-avatar-row">
                  <view class="rec-avatar">
                    <text class="rec-avatar-emoji">{{ user.avatar }}</text>
                  </view>
                  <view class="rec-avatar-info">
                    <text class="rec-name">{{ user.name }}</text>
                    <text class="rec-meta">{{ user.school }} · {{ user.major }}</text>
                    <text class="rec-grade">{{ user.grade }}</text>
                  </view>
                  <!-- 匹配度角标 -->
                  <view class="rec-score-badge">
                    <text class="rec-score-num">{{ user.matchScore }}</text>
                    <text class="rec-score-unit">%</text>
                  </view>
                </view>

                <!-- 匹配度进度条 -->
                <view class="rec-match-row">
                  <text class="rec-match-label">匹配度</text>
                  <view class="rec-progress-wrap">
                    <view
                      class="rec-progress-bar"
                      :style="{ width: user.matchScore + '%' }"
                    />
                  </view>
                  <text class="rec-match-score">{{ user.matchScore }}%</text>
                </view>

                <!-- 兴趣标签 -->
                <view class="rec-interests">
                  <view
                    v-for="tag in user.interests"
                    :key="tag"
                    class="rec-tag"
                  >
                    <text class="rec-tag-text">{{ tag }}</text>
                  </view>
                </view>

                <!-- 学习时段 -->
                <view class="rec-study-row">
                  <text class="rec-study-icon">⏰</text>
                  <text class="rec-study-text">学习时段：{{ user.studyTime }}</text>
                </view>

                <!-- 操作按钮 -->
                <view class="rec-btns">
                  <view class="rec-btn rec-btn-primary" @click="onSayHi(user.name)">
                    <text class="rec-btn-text">👋 打招呼</text>
                  </view>
                  <view class="rec-btn rec-btn-secondary" @click="onNext">
                    <text class="rec-btn-text rec-btn-text-sec">⏭ 下一位</text>
                  </view>
                </view>
              </view>
            </swiper-item>
          </swiper>
        </view>

        <!-- ── 我的搭子 ── -->
        <view class="section-card">
          <text class="section-title">── 我的搭子 ({{ buddies.length }}) ──</text>

          <view
            v-for="buddy in buddies"
            :key="buddy.id"
            class="buddy-row"
            :class="{ 'buddy-row-border': buddy.id > 1 }"
            @click="onBuddyClick"
          >
            <view class="buddy-avatar">
              <text class="buddy-avatar-emoji">{{ buddy.avatar }}</text>
            </view>
            <view class="buddy-info">
              <text class="buddy-name">{{ buddy.name }}</text>
              <text class="buddy-type">{{ buddy.type }}</text>
            </view>
            <view class="buddy-right">
              <text class="buddy-last">{{ buddy.lastActive }}</text>
              <view class="buddy-status">
                <view
                  class="buddy-dot"
                  :class="buddy.online ? 'buddy-dot-online' : 'buddy-dot-offline'"
                />
                <text class="buddy-status-text" :class="buddy.online ? 'buddy-online-text' : ''">
                  {{ buddy.online ? '在线' : '离线' }}
                </text>
              </view>
            </view>
          </view>
        </view>

        <view class="bottom-safe" />
      </view>
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'

// ── 推荐用户 ──
const recommendations = [
  {
    id: 1,
    name: '小明',
    avatar: '🧑‍🎓',
    school: '南开大学',
    major: '计算机科学',
    grade: '大三',
    matchScore: 92,
    interests: ['学习', '编程', '美食'],
    studyTime: '20:00-23:00',
  },
  {
    id: 2,
    name: '小红',
    avatar: '👩‍🎓',
    school: '天津大学',
    major: '软件工程',
    grade: '大二',
    matchScore: 87,
    interests: ['运动', '音乐', '美食'],
    studyTime: '19:00-22:00',
  },
  {
    id: 3,
    name: '小华',
    avatar: '🧑‍💻',
    school: '南开大学',
    major: '人工智能',
    grade: '研一',
    matchScore: 85,
    interests: ['编程', '阅读', '写作'],
    studyTime: '21:00-00:00',
  },
  {
    id: 4,
    name: '小李',
    avatar: '👨‍🎓',
    school: '北京大学',
    major: '数据科学',
    grade: '大四',
    matchScore: 78,
    interests: ['学习', '旅行', '摄影'],
    studyTime: '18:00-21:00',
  },
  {
    id: 5,
    name: '小芳',
    avatar: '👩‍💼',
    school: '清华大学',
    major: '金融科技',
    grade: '研二',
    matchScore: 72,
    interests: ['阅读', '电影', '社交'],
    studyTime: '20:00-23:00',
  },
]

// ── 我的搭子 ──
const buddies = [
  {
    id: 1,
    name: '小明',
    avatar: '🧑‍🎓',
    type: '学习搭子',
    lastActive: '今天 14:30',
    online: true,
  },
  {
    id: 2,
    name: '小红',
    avatar: '🏃',
    type: '运动搭子',
    lastActive: '昨天 06:30',
    online: false,
  },
  {
    id: 3,
    name: '小华',
    avatar: '🍳',
    type: '美食搭子',
    lastActive: '3月21日',
    online: false,
  },
]

// ── Swiper ──
const swiperCurrent = ref(0)

function onSwiperChange(e: any) {
  swiperCurrent.value = e.detail.current
}

function onNext() {
  swiperCurrent.value = (swiperCurrent.value + 1) % recommendations.length
}

// ── 交互 ──
function onSayHi(name: string) {
  uni.showToast({ title: `已向 ${name} 打招呼！`, icon: 'success' })
}

function onBuddyClick() {
  uni.showToast({ title: '搭子聊天功能开发中', icon: 'none' })
}
</script>

<style lang="scss" scoped>
.page {
  height: 100%;
  background: #FDF8F3;
}

.scroll {
  flex: 1; overflow-y: auto;
  /* flex handles height */
}

.content {
  padding: 24rpx 32rpx 0;
}

/* 分组卡片 */
.section-card {
  background: #FFFFFF;
  border-radius: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  padding: 0 32rpx 32rpx;
  margin-bottom: 24rpx;
  overflow: hidden;
}

.section-title {
  display: block;
  font-size: 24rpx;
  color: #AE9D92;
  font-weight: 600;
  letter-spacing: 2rpx;
  text-align: center;
  padding: 24rpx 0 20rpx;
}

/* ── Swiper ── */
.rec-swiper {
  height: 680rpx;
  margin: 0 -20rpx;
}

.swiper-item-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 16rpx;
  height: 100%;
}

/* 推荐卡片 */
.rec-card {
  width: 100%;
  background: #FFFFFF;
  border-radius: 32rpx;
  box-shadow: 0 8rpx 32rpx rgba(232, 133, 90, 0.12);
  padding: 40rpx;
  border: 1.5rpx solid rgba(232, 133, 90, 0.1);
  display: flex;
  flex-direction: column;
  gap: 28rpx;
  height: 640rpx;
  box-sizing: border-box;
}

/* 头像行 */
.rec-avatar-row {
  display: flex;
  align-items: center;
  gap: 24rpx;
  position: relative;
}

.rec-avatar {
  width: 100rpx;
  height: 100rpx;
  border-radius: 9999rpx;
  background: linear-gradient(135deg, #FDF0E8 0%, #FEF3EE 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.rec-avatar-emoji {
  font-size: 88rpx;
  line-height: 1;
}

.rec-avatar-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.rec-name {
  font-size: 40rpx;
  color: #2C1F14;
  font-weight: 700;
}

.rec-meta {
  font-size: 26rpx;
  color: #4A3628;
}

.rec-grade {
  font-size: 24rpx;
  color: #AE9D92;
}

.rec-score-badge {
  position: absolute;
  top: 0;
  right: 0;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  border-radius: 16rpx;
  padding: 8rpx 16rpx;
  display: flex;
  align-items: baseline;
  gap: 2rpx;
}

.rec-score-num {
  font-size: 36rpx;
  color: #FFFFFF;
  font-weight: 700;
}

.rec-score-unit {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.85);
}

/* 匹配度进度条 */
.rec-match-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.rec-match-label {
  font-size: 26rpx;
  color: #AE9D92;
  width: 64rpx;
  flex-shrink: 0;
}

.rec-progress-wrap {
  flex: 1;
  height: 8rpx;
  background: #F5EDE4;
  border-radius: 9999rpx;
  overflow: hidden;
}

.rec-progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #E8855A 0%, #F0A882 100%);
  border-radius: 9999rpx;
  transition: width 0.6s ease;
}

.rec-match-score {
  font-size: 26rpx;
  color: #E8855A;
  font-weight: 600;
  width: 56rpx;
  text-align: right;
  flex-shrink: 0;
}

/* 兴趣标签 */
.rec-interests {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.rec-tag {
  background: rgba(232, 133, 90, 0.1);
  border-radius: 12rpx;
  padding: 8rpx 20rpx;
}

.rec-tag-text {
  font-size: 24rpx;
  color: #E8855A;
  font-weight: 500;
}

/* 学习时段 */
.rec-study-row {
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: #FDF8F3;
  border-radius: 16rpx;
  padding: 20rpx 24rpx;
}

.rec-study-icon {
  font-size: 32rpx;
}

.rec-study-text {
  font-size: 26rpx;
  color: #4A3628;
}

/* 操作按钮 */
.rec-btns {
  display: flex;
  gap: 16rpx;
  margin-top: auto;
}

.rec-btn {
  flex: 1;
  height: 88rpx;
  border-radius: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity 0.15s, transform 0.1s;

  &:active {
    opacity: 0.8;
    transform: scale(0.97);
  }
}

.rec-btn-primary {
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 4rpx 16rpx rgba(232, 133, 90, 0.3);
}

.rec-btn-secondary {
  background: #F5EDE4;
}

.rec-btn-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}

.rec-btn-text-sec {
  color: #4A3628;
}

/* ── 搭子列表 ── */
.buddy-row {
  display: flex;
  align-items: center;
  gap: 20rpx;
  padding: 28rpx 0;
  transition: opacity 0.15s;

  &:active {
    opacity: 0.7;
  }
}

.buddy-row-border {
  border-top: 1rpx solid rgba(174, 157, 146, 0.15);
}

.buddy-avatar {
  width: 88rpx;
  height: 88rpx;
  border-radius: 9999rpx;
  background: linear-gradient(135deg, #FDF0E8 0%, #FEF3EE 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.buddy-avatar-emoji {
  font-size: 72rpx;
  line-height: 1;
}

.buddy-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6rpx;
}

.buddy-name {
  font-size: 30rpx;
  color: #2C1F14;
  font-weight: 600;
}

.buddy-type {
  font-size: 24rpx;
  color: #AE9D92;
}

.buddy-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8rpx;
}

.buddy-last {
  font-size: 24rpx;
  color: #AE9D92;
}

.buddy-status {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.buddy-dot {
  width: 12rpx;
  height: 12rpx;
  border-radius: 9999rpx;
}

.buddy-dot-online {
  background: #5BBF8E;
}

.buddy-dot-offline {
  background: #AE9D92;
}

.buddy-status-text {
  font-size: 22rpx;
  color: #AE9D92;
}

.buddy-online-text {
  color: #5BBF8E;
}

.bottom-safe {
  height: 40rpx;
}
</style>
