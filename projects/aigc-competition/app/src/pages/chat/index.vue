<template>
  <view class="page page-root">
    <CustomNavBar title="AI 伙伴" left-icon="back" right-icon="···" @right-click="handleMenu" />

    <!-- NavBar 占位 -->
    <view class="nav-placeholder" :style="{ height: navPlaceholderHeight + 'px' }" />

    <view class="page-content">
      <!-- AI 伙伴信息卡 -->
      <view class="ai-info-card">
        <view class="ai-info-icon doodle-box-v3">
          <DoodleIcon name="robot" color="#FFFFFF" :size="44" :filtered="false" />
        </view>
        <view class="ai-info-text">
          <text class="ai-info-title">你的 AI 伙伴</text>
          <text class="ai-info-sub">已陪你写了 {{ profile.diaryCount }} 篇日记</text>
          <text class="ai-info-sub">了解你的 {{ interestTags }} 个兴趣标签</text>
        </view>
      </view>

      <!-- 消息列表 -->
      <scroll-view
        class="messages-scroll"
        scroll-y
        :scroll-into-view="scrollIntoId"
        :scroll-with-animation="true"
      >
        <view class="messages-inner">
          <view
            v-for="(msg, idx) in messages"
            :key="idx"
            :id="`msg-${idx}`"
            class="message-wrap"
            :class="msg.role === 'user' ? 'message-wrap--user' : 'message-wrap--ai'"
          >
            <!-- AI avatar -->
            <view v-if="msg.role === 'assistant'" class="msg-avatar doodle-box-v3">
              <DoodleIcon name="robot" color="#FFFFFF" :size="32" :filtered="false" />
            </view>

            <view class="message-bubble" :class="msg.role === 'user' ? 'bubble--user' : 'bubble--ai'">
              <text class="bubble-text" :class="msg.role === 'user' ? 'bubble-text--user' : ''">
                {{ msg.content }}
              </text>
            </view>
          </view>

          <!-- AI thinking indicator -->
          <view v-if="isThinking" class="message-wrap message-wrap--ai">
            <view class="msg-avatar doodle-box-v3">
              <DoodleIcon name="robot" color="#FFFFFF" :size="32" :filtered="false" />
            </view>
            <view class="message-bubble bubble--ai">
              <view class="thinking-dots">
                <view class="dot" />
                <view class="dot" />
                <view class="dot" />
              </view>
            </view>
          </view>
        </view>
      </scroll-view>

      <!-- 快捷操作 -->
      <view class="quick-actions">
        <scroll-view class="quick-scroll" scroll-x>
          <view
            v-for="action in quickActions"
            :key="action.label"
            class="quick-btn press-feedback"
            @click="handleQuickAction(action.path)"
          >
            <view class="quick-icon-wrap">
              <DoodleIcon :name="action.iconName" :color="action.iconColor" :size="28" />
            </view>
            <text class="quick-label">{{ action.label }}</text>
          </view>
        </scroll-view>
      </view>

      <!-- 输入栏 -->
      <view class="input-bar">
        <view class="input-row">
          <view class="attach-btn press-feedback" @click="handleAttach">
            <DoodleIcon name="attach" color="#AE9D92" :size="36" />
          </view>
          <input
            v-model="inputText"
            class="input-field"
            placeholder="说点什么..."
            placeholder-class="input-placeholder"
            confirm-type="send"
            :adjust-position="true"
            @confirm="handleSend"
          />
          <view class="voice-btn press-feedback" @click="handleVoice">
            <DoodleIcon name="voice" color="#AE9D92" :size="36" />
          </view>
          <view class="send-btn" :class="{ 'send-btn--active': inputText.trim() }" @click="handleSend">
            <DoodleIcon name="send" color="#FFFFFF" :size="36" :filtered="false" />
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'
import DoodleIcon from '@/components/DoodleIcon.vue'
import { getUserProfile } from '@/services/api/user'
import type { UserProfile } from '@/services/api/user'
import type { ChatMessage } from '@/services/api/ai'

const quickActions = [
  { iconName: 'pen',     iconColor: '#E8855A', label: '写日记', path: '/pages/write/index' },
  { iconName: 'crystal', iconColor: '#D4728A', label: '看运势', path: '/pages/fortune/index' },
  { iconName: 'tomato',  iconColor: '#E8855A', label: '开始番茄', path: '/pages/study/pomodoro' },
  { iconName: 'chart',   iconColor: '#C8A86B', label: '看成长', path: '/pages/growth/index' },
]

const aiReplies = [
  '这个想法很有意思！要不要写进日记里？',
  '看得出你今天状态不错～继续加油！',
  '嗯嗯，我理解你的感受。需要聊聊吗？',
  '哈哈，这太有趣了！你的生活很精彩呀～',
  '好的，我记住了。这对了解你很有帮助。',
  '太棒了！继续保持这个状态 💪',
  '有什么想记录下来的吗？我可以帮你～',
  '听起来很棒！我很期待你今天的日记 ✨',
]

const profile = ref<UserProfile>({
  name: 'Kylin',
  school: '南开大学',
  major: '软件工程',
  level: 12,
  diaryCount: 127,
  streakDays: 23,
  pomodoroCount: 247,
  avatar: '',
})

const interestTags = ref(23)

const messages = ref<ChatMessage[]>([
  {
    role: 'assistant',
    content: '嗨 Kylin！今天过得怎么样？看到你昨天的雅思阅读全对了，太棒了！🎉',
    timestamp: Date.now() - 60000,
  },
  {
    role: 'user',
    content: '今天有点累，在图书馆待了一下午',
    timestamp: Date.now() - 30000,
  },
  {
    role: 'assistant',
    content: '辛苦了！图书馆一下午说明很专注呢。要不要记一篇简短的日记？',
    timestamp: Date.now(),
  },
])

const inputText = ref('')
const isThinking = ref(false)
const scrollIntoId = ref('')

async function scrollToBottom() {
  await nextTick()
  const lastIdx = messages.value.length - 1
  scrollIntoId.value = ''
  setTimeout(() => {
    scrollIntoId.value = `msg-${lastIdx}`
  }, 50)
}

function handleSend() {
  const text = inputText.value.trim()
  if (!text) return

  messages.value.push({
    role: 'user',
    content: text,
    timestamp: Date.now(),
  })
  inputText.value = ''
  isThinking.value = true
  scrollToBottom()

  setTimeout(() => {
    isThinking.value = false
    const reply = aiReplies[Math.floor(Math.random() * aiReplies.length)]
    messages.value.push({
      role: 'assistant',
      content: reply,
      timestamp: Date.now(),
    })
    scrollToBottom()
  }, 2000)
}

function handleAttach() {
  uni.showToast({ title: '附件功能开发中', icon: 'none' })
}

function handleVoice() {
  uni.showToast({ title: '语音功能开发中', icon: 'none' })
}

function handleMenu() {
  uni.showToast({ title: '更多功能开发中', icon: 'none' })
}

function handleQuickAction(path: string) {
  uni.navigateTo({ url: path })
}

const navPlaceholderHeight = ref(64)

onMounted(async () => {
  const info = uni.getSystemInfoSync()
  navPlaceholderHeight.value = (info.statusBarHeight ?? 20) + 44
  profile.value = await getUserProfile()
  scrollToBottom()
})
</script>

<style lang="scss" scoped>
.page {
  position: relative;
  height: 100%;
  background: #FDF8F3;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.nav-placeholder {
  flex-shrink: 0;
}

.page-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.ai-info-card {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 24rpx;
  padding: 24rpx 32rpx;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(44, 31, 20, 0.06);
}

.ai-info-icon {
  width: 80rpx;
  height: 80rpx;
  background: linear-gradient(135deg, #E8855A, #F0A882) !important;
  border-color: transparent !important;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 1px 2px 0 rgba(232, 133, 90, 0.2);
}

.ai-info-text {
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.ai-info-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #2C1F14;
}

.ai-info-sub {
  font-size: 24rpx;
  color: #AE9D92;
}

.messages-scroll {
  flex: 1;
  overflow-y: auto;
}

.messages-inner {
  padding: 32rpx 32rpx 16rpx;
  display: flex;
  flex-direction: column;
  gap: 48rpx;
}

.message-wrap {
  display: flex;
  align-items: flex-end;
  gap: 16rpx;
}

.message-wrap--ai {
  justify-content: flex-start;
}

.message-wrap--user {
  justify-content: flex-end;
}

.msg-avatar {
  width: 64rpx;
  height: 64rpx;
  background: linear-gradient(135deg, #E8855A, #F0A882) !important;
  border-color: transparent !important;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 1px 2px 0 rgba(232, 133, 90, 0.15);
}

.message-bubble {
  max-width: 70%;
  padding: 20rpx 28rpx;
  line-height: 1.6;
}

.bubble--ai {
  background: #F5F0EB;
  border-radius: 0 20rpx 20rpx 20rpx;
}

.bubble--user {
  background: #E8855A;
  border-radius: 20rpx 0 20rpx 20rpx;
}

.bubble-text {
  font-size: 30rpx;
  color: #2C1F14;
  word-break: break-all;
}

.bubble-text--user {
  color: #FFFFFF;
}

.thinking-dots {
  display: flex;
  gap: 10rpx;
  padding: 8rpx 0;
  align-items: center;
}

.dot {
  width: 14rpx;
  height: 14rpx;
  border-radius: 50%;
  background: #AE9D92;
  animation: bounce 1.2s ease infinite;
}

.dot:nth-child(2) { animation-delay: 0.2s; }
.dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes bounce {
  0%, 60%, 100% { transform: translateY(0); }
  30% { transform: translateY(-10rpx); }
}

.quick-actions {
  flex-shrink: 0;
  background: #FFFFFF;
  border-top: 1px solid rgba(44, 31, 20, 0.06);
  padding: 16rpx 0;
}

.quick-scroll {
  white-space: nowrap;
  padding: 0 24rpx;
}

.quick-btn {
  display: inline-flex;
  align-items: center;
  gap: 12rpx;
  background: #FDF8F3;
  border-radius: 20rpx;
  padding: 16rpx 28rpx;
  margin-right: 16rpx;
  cursor: pointer;
  border: 1px solid rgba(232, 133, 90, 0.1);
}

.quick-icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
}

.quick-label {
  font-size: 26rpx;
  color: #4A3628;
  white-space: nowrap;
}

.input-bar {
  flex-shrink: 0;
  background: #FFFFFF;
  border-top: 1px solid rgba(44, 31, 20, 0.06);
  padding: 20rpx 24rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
}

.input-row {
  display: flex;
  align-items: center;
  gap: 16rpx;
}

.attach-btn, .voice-btn {
  width: 72rpx;
  height: 72rpx;
  border-radius: 50%;
  background: #F5F0EB;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  cursor: pointer;
}

.input-field {
  flex: 1;
  height: 80rpx;
  background: #F5F0EB;
  border-radius: 40rpx;
  padding: 0 32rpx;
  font-size: 30rpx;
  color: #2C1F14;
}

.input-placeholder {
  color: #AE9D92;
  font-size: 30rpx;
}

.send-btn {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50% 55% 45% 52%;
  background: #E8DDD5;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  cursor: pointer;
  transition: background 0.2s;
}

.send-btn--active {
  background: #E8855A;
}
</style>
