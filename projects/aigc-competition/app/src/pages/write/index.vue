<template>
  <view class="write-page">
    <!-- ── CustomNavBar ── -->
    <CustomNavBar title="记录此刻" @left-click="handleClose">
      <template #left>
        <view class="nav-close press-feedback" @click="handleClose">
          <DoodleIcon name="cross" color="#2C1F14" :size="36" />
        </view>
      </template>
    </CustomNavBar>

    <!-- NavBar 占位 -->
    <view class="nav-placeholder" :style="{ height: navPlaceholderHeight + 'px' }" />

    <scroll-view class="page-scroll" scroll-y :style="{ height: scrollHeight + 'px' }">
      <!-- ── 顶部提示语 ── -->
      <view class="header-tip">
        <text class="header-emoji">✨</text>
        <text class="header-text">记录此刻的心情</text>
      </view>

      <!-- ── 三大按钮区 ── -->
      <view v-if="!activeType" class="type-btns">
        <view class="type-row">
          <view class="type-btn press-feedback" @click="selectType('photo')">
            <text class="type-icon">📷</text>
            <text class="type-label">拍照</text>
          </view>
          <view class="type-btn press-feedback" @click="selectType('voice')">
            <text class="type-icon">🎤</text>
            <text class="type-label">语音</text>
          </view>
        </view>
        <view class="type-row type-row-center">
          <view class="type-btn press-feedback" @click="selectType('text')">
            <text class="type-icon">📝</text>
            <text class="type-label">文字</text>
          </view>
        </view>
      </view>

      <!-- ── 文字输入区（选文字后展开）── -->
      <view v-if="activeType === 'text'" class="input-area">
        <textarea
          v-model="textInput"
          class="text-textarea"
          placeholder="写下此刻的感受..."
          :placeholder-style="'color: #AE9D92; font-size: 30rpx;'"
          :auto-height="true"
          maxlength="500"
          :focus="true"
        />
        <view class="input-footer">
          <text class="char-count">{{ textInput.length }}/500</text>
          <view class="input-actions">
            <view class="cancel-btn press-feedback" @click="cancelInput">
              <text class="cancel-text">取消</text>
            </view>
            <view class="save-btn press-feedback" :class="{ disabled: !textInput.trim() }" @click="saveText">
              <text class="save-text">{{ saving ? '保存中...' : '保存' }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- ── 语音录制区（选语音后展开）── -->
      <view v-if="activeType === 'voice'" class="voice-area">
        <view class="voice-hint">
          <text class="voice-hint-text">{{ recording ? '录音中，点击停止...' : '按住开始录音' }}</text>
        </view>
        <view
          class="record-btn"
          :class="{ recording }"
          @touchstart.prevent="startRecord"
          @touchend.prevent="stopRecord"
          @click="mockVoice"
        >
          <text class="record-icon">🎤</text>
        </view>
        <view class="cancel-row">
          <view class="cancel-btn press-feedback" @click="cancelInput">
            <text class="cancel-text">取消</text>
          </view>
        </view>
      </view>

      <!-- ── 分隔线 ── -->
      <view class="divider">
        <view class="divider-line" />
        <text class="divider-label">今日已记录</text>
        <view class="divider-line" />
      </view>

      <!-- ── 今日素材列表 ── -->
      <view class="today-list">
        <view v-if="loadingMaterials" class="list-loading">
          <text class="list-loading-text">加载中...</text>
        </view>
        <view
          v-for="item in todayMaterials"
          :key="item.id"
          class="today-item"
        >
          <view class="item-time-wrap">
            <text class="item-time">{{ formatTime(item.createdAt) }}</text>
            <text class="item-type-icon">{{ typeIcon(item.type) }}</text>
          </view>
          <view class="item-content">
            <!-- 图片 -->
            <view v-if="item.type === 'image'" class="item-image-wrap">
              <image class="item-image" :src="item.mediaUrl || item.content" mode="aspectFill" />
            </view>
            <!-- 文字/语音 -->
            <text v-else class="item-text">{{ item.content }}</text>
          </view>
          <!-- 情绪标签 -->
          <view v-if="item.emotion && item.emotion.label" class="item-emotion">
            <text class="emotion-emoji">{{ item.emotion.emoji }}</text>
            <text class="emotion-label">{{ item.emotion.label }}</text>
          </view>
        </view>

        <!-- 空状态 -->
        <view v-if="!loadingMaterials && todayMaterials.length === 0" class="empty-today">
          <text class="empty-today-text">今天还没有记录，快来添加第一条吧</text>
        </view>
      </view>

      <view class="bottom-spacer" />
    </scroll-view>
  </view>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'
import DoodleIcon from '@/components/DoodleIcon.vue'
import { createMaterial, getMaterials, extractEmotion } from '@/services/api/material'
import type { RawMaterial } from '@/services/api/material'

const navPlaceholderHeight = ref(64)
const scrollHeight = ref(600)

const activeType = ref<'photo' | 'voice' | 'text' | null>(null)
const textInput = ref('')
const saving = ref(false)
const recording = ref(false)
const todayMaterials = ref<RawMaterial[]>([])
const loadingMaterials = ref(false)

const today = new Date().toISOString().slice(0, 10)

onMounted(async () => {
  const info = uni.getSystemInfoSync()
  navPlaceholderHeight.value = (info.statusBarHeight ?? 20) + 44
  scrollHeight.value = info.windowHeight - navPlaceholderHeight.value
  await loadTodayMaterials()
})

async function loadTodayMaterials() {
  loadingMaterials.value = true
  try {
    todayMaterials.value = await getMaterials(today)
  } catch {
    // silently ignore
  } finally {
    loadingMaterials.value = false
  }
}

function formatTime(ts: number): string {
  const d = new Date(ts)
  const h = String(d.getHours()).padStart(2, '0')
  const min = String(d.getMinutes()).padStart(2, '0')
  return `${h}:${min}`
}

function typeIcon(type: string): string {
  if (type === 'image') return '📷'
  if (type === 'voice') return '🎤'
  return '📝'
}

function selectType(type: 'photo' | 'voice' | 'text') {
  if (type === 'photo') {
    // Immediately trigger photo picker, no intermediate state
    addPhoto()
    return
  }
  activeType.value = type
}

function cancelInput() {
  activeType.value = null
  textInput.value = ''
  recording.value = false
}

async function addPhoto() {
  uni.chooseImage({
    count: 1,
    success: async (res) => {
      const url = res.tempFilePaths[0]
      await saveMaterial({ type: 'image', mediaUrl: url, date: today })
    },
    fail: async () => {
      // H5 fallback: use a mock image
      const mockUrl = `https://picsum.photos/seed/${Date.now()}/400/400`
      await saveMaterial({ type: 'image', mediaUrl: mockUrl, date: today })
    },
  })
}

async function saveText() {
  const text = textInput.value.trim()
  if (!text || saving.value) return
  saving.value = true
  await saveMaterial({ type: 'text', content: text, date: today })
  textInput.value = ''
  saving.value = false
  cancelInput()
}

// Mock recording handlers for H5
function startRecord() {
  recording.value = true
}

function stopRecord() {
  recording.value = false
}

async function mockVoice() {
  if (recording.value) return
  uni.showLoading({ title: '录音中...', mask: true })
  await new Promise(resolve => setTimeout(resolve, 1500))
  uni.hideLoading()
  const transcription = '今天天气真好，阳光明媚，心情不错'
  await saveMaterial({ type: 'voice', content: transcription, date: today })
  cancelInput()
}

async function saveMaterial(data: { type: 'image' | 'voice' | 'text'; content?: string; mediaUrl?: string; date: string }) {
  try {
    const mat = await createMaterial(data)
    // Prepend to list immediately
    todayMaterials.value.unshift(mat)
    uni.showToast({ title: '已记录 ✓', icon: 'success' })

    // Background emotion extraction
    extractEmotion(mat.id).then(emotion => {
      const idx = todayMaterials.value.findIndex(m => m.id === mat.id)
      if (idx >= 0) {
        todayMaterials.value[idx] = { ...todayMaterials.value[idx], emotion }
      }
    }).catch(() => {})
  } catch {
    uni.showToast({ title: '记录失败，请重试', icon: 'none' })
  }
}

function handleClose() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.write-page {
  background: #FDF8F3;
  min-height: 100vh;
}

.nav-placeholder {}

.nav-close {
  padding: 8rpx 16rpx;
}

.page-scroll {
  box-sizing: border-box;
}

/* ── 顶部提示语 ── */
.header-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  padding: 40rpx 32rpx 20rpx;
}

.header-emoji {
  font-size: 40rpx;
}

.header-text {
  font-size: 36rpx;
  color: #2C1F14;
  font-weight: 700;
}

/* ── 三大按钮 ── */
.type-btns {
  padding: 24rpx 48rpx 32rpx;
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.type-row {
  display: flex;
  gap: 24rpx;
  justify-content: center;
}

.type-row-center {
  justify-content: center;
}

.type-btn {
  flex: 1;
  max-width: 260rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12rpx;
  background: #FFFFFF;
  border-radius: 24rpx 28rpx 20rpx 26rpx;
  padding: 40rpx 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.07);
  border: 2rpx solid rgba(232, 133, 90, 0.12);
  &:active { transform: scale(0.96); opacity: 0.85; }
}

.type-icon {
  font-size: 72rpx;
}

.type-label {
  font-size: 30rpx;
  color: #2C1F14;
  font-weight: 600;
}

/* ── 文字输入区 ── */
.input-area {
  margin: 0 24rpx 24rpx;
  background: #FFFFFF;
  border-radius: 20rpx;
  padding: 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
}

.text-textarea {
  width: 100%;
  min-height: 200rpx;
  font-size: 30rpx;
  color: #2C1F14;
  line-height: 1.7;
  background: #FDF8F3;
  border-radius: 16rpx;
  padding: 20rpx;
  box-sizing: border-box;
  border: 2rpx solid #EAE0D6;
}

.input-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16rpx;
}

.char-count {
  font-size: 24rpx;
  color: #AE9D92;
}

.input-actions {
  display: flex;
  gap: 16rpx;
  align-items: center;
}

.cancel-btn {
  padding: 16rpx 28rpx;
  border-radius: 20rpx;
  background: #F5F0EB;
  &:active { opacity: 0.8; }
}

.cancel-text {
  font-size: 28rpx;
  color: #4A3628;
}

.save-btn {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 20rpx;
  padding: 16rpx 40rpx;
  &:active { opacity: 0.85; }

  &.disabled {
    background: #D4C4B8;
  }
}

.save-text {
  font-size: 28rpx;
  color: #FFFFFF;
  font-weight: 600;
}

/* ── 语音区 ── */
.voice-area {
  margin: 0 24rpx 24rpx;
  background: #FFFFFF;
  border-radius: 20rpx;
  padding: 40rpx 24rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 32rpx;
}

.voice-hint-text {
  font-size: 28rpx;
  color: #AE9D92;
}

.record-btn {
  width: 160rpx;
  height: 160rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8rpx 24rpx rgba(232, 133, 90, 0.3);
  transition: transform 0.15s;
  &:active { transform: scale(0.94); }

  &.recording {
    background: #D4645C;
    box-shadow: 0 0 0 16rpx rgba(212, 100, 92, 0.2);
  }
}

.record-icon {
  font-size: 72rpx;
}

.cancel-row {
  display: flex;
  justify-content: center;
}

/* ── 分隔线 ── */
.divider {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 8rpx 24rpx 20rpx;
}

.divider-line {
  flex: 1;
  height: 1rpx;
  background: repeating-linear-gradient(
    to right,
    transparent 0,
    transparent 6rpx,
    #D4C4B8 6rpx,
    #D4C4B8 12rpx
  );
}

.divider-label {
  font-size: 24rpx;
  color: #AE9D92;
  white-space: nowrap;
  padding: 0 4rpx;
}

/* ── 今日素材列表 ── */
.today-list {
  padding: 0 24rpx;
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.list-loading {
  display: flex;
  justify-content: center;
  padding: 24rpx;
}

.list-loading-text {
  font-size: 26rpx;
  color: #AE9D92;
}

.today-item {
  background: #FFFFFF;
  border-radius: 16rpx 20rpx 14rpx 18rpx;
  padding: 20rpx 24rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.05);
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.item-time-wrap {
  display: flex;
  align-items: center;
  gap: 8rpx;
}

.item-time {
  font-size: 22rpx;
  color: #AE9D92;
}

.item-type-icon {
  font-size: 22rpx;
}

.item-content {}

.item-image-wrap {
  border-radius: 12rpx;
  overflow: hidden;
}

.item-image {
  width: 100%;
  height: 240rpx;
  display: block;
}

.item-text {
  font-size: 28rpx;
  color: #4A3628;
  line-height: 1.6;
}

.item-emotion {
  display: flex;
  align-items: center;
  gap: 6rpx;
}

.emotion-emoji {
  font-size: 26rpx;
}

.emotion-label {
  font-size: 22rpx;
  color: #E8855A;
  font-weight: 600;
}

/* ── 空状态 ── */
.empty-today {
  display: flex;
  justify-content: center;
  padding: 48rpx 0;
}

.empty-today-text {
  font-size: 26rpx;
  color: #D4C4B8;
  text-align: center;
}

.bottom-spacer {
  height: 60rpx;
}
</style>
