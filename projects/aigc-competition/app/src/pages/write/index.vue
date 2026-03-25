<template>
  <view class="write-page">
    <!-- ── CustomNavBar ── -->
    <CustomNavBar title="记录此刻" left-icon="none" @left-click="handleClose">
      <template #left>
        <view class="nav-close press-feedback" @click="handleClose">
          <DoodleIcon name="cross" color="#2C1F14" :size="36" />
        </view>
      </template>
      <template #right>
        <view class="nav-style-btn press-feedback" @click="showStylePicker = true">
          <text class="style-label">{{ currentStyle }}</text>
          <text class="style-arrow"> ▾</text>
        </view>
      </template>
    </CustomNavBar>

    <!-- NavBar 占位 -->
    <view class="nav-placeholder" :style="{ height: navPlaceholderHeight + 'px' }" />

    <!-- ── 日期天气行 ── -->
    <view class="date-bar">
      <text class="date-text">{{ todayLabel }}</text>
      <view class="weather-info">
        <DoodleIcon name="cloud" color="#AE9D92" :size="24" />
        <text class="weather-text"> 多云 18°C</text>
      </view>
    </view>

    <!-- ── 素材时间线 ── -->
    <scroll-view
      class="timeline-scroll"
      scroll-y
      :style="{ height: timelineHeight + 'px' }"
      :scroll-into-view="scrollIntoId"
    >
      <view class="timeline-inner">
        <!-- 素材卡片列表 -->
        <view
          v-for="(item, index) in materials"
          :key="item.id"
          class="material-item"
          :id="`mat-${item.id}`"
        >
          <!-- 时间线节点 -->
          <view class="timeline-node">
            <view class="node-dot" />
            <view v-if="index < materials.length - 1" class="node-line" />
          </view>

          <!-- 素材卡片 -->
          <view class="material-card">
            <!-- 时间戳 -->
            <text class="mat-time">{{ formatTime(item.createdAt) }}</text>

            <!-- 图片素材 -->
            <view v-if="item.type === 'image'" class="mat-image-wrap">
              <image class="mat-image" :src="item.mediaUrl || item.content" mode="aspectFill" />
            </view>

            <!-- 文字素材 -->
            <view v-else-if="item.type === 'text'" class="mat-text-wrap">
              <text class="mat-text-content">{{ item.content }}</text>
            </view>

            <!-- 语音素材 -->
            <view v-else-if="item.type === 'voice'" class="mat-voice-wrap">
              <DoodleIcon name="voice" color="#E8855A" :size="32" />
              <text class="mat-voice-text">{{ item.content || '语音内容...' }}</text>
            </view>

            <!-- 位置行 -->
            <view v-if="item.location && item.location.address" class="mat-location">
              <DoodleIcon name="pin" color="#AE9D92" :size="20" />
              <text class="mat-location-text">{{ item.location.address }}</text>
            </view>

            <!-- 情绪标签 -->
            <view class="mat-footer">
              <view v-if="item.emotion && item.emotion.label" class="mat-emotion">
                <text class="emotion-emoji">{{ item.emotion.emoji }}</text>
                <text class="emotion-label">{{ item.emotion.label }}</text>
                <text class="emotion-score">{{ (item.emotion.score * 100).toFixed(0) }}%</text>
              </view>
              <view v-else class="mat-emotion-loading">
                <text class="emotion-loading-text">情绪分析中...</text>
              </view>

              <!-- 润色按钮（仅文字素材） -->
              <view v-if="item.type === 'text'" class="polish-btn press-feedback" @click="handlePolish(item)">
                <text class="polish-text">润色</text>
              </view>

              <!-- 删除按钮 -->
              <view class="mat-delete press-feedback" @click="deleteMaterial(index)">
                <DoodleIcon name="cross" color="#AE9D92" :size="20" />
              </view>
            </view>
          </view>
        </view>

        <!-- 空状态 -->
        <view v-if="materials.length === 0" class="empty-state">
          <DoodleIcon name="pen" color="#D4C4B8" :size="80" />
          <text class="empty-text">点击下方按钮记录此刻</text>
          <text class="empty-sub">可以添加照片、语音或文字</text>
        </view>

        <view class="timeline-bottom-spacer" />
      </view>
    </scroll-view>

    <!-- ── 底部操作栏 ── -->
    <view class="bottom-bar">
      <!-- 素材类型按钮 -->
      <view class="media-btns">
        <view class="media-btn press-feedback" @click="addPhoto">
          <text class="media-icon">📷</text>
          <text class="media-label">拍照</text>
        </view>
        <view class="media-btn press-feedback" @click="addVoice">
          <text class="media-icon">🎤</text>
          <text class="media-label">语音</text>
        </view>
        <view class="media-btn press-feedback" @click="showTextInput = true">
          <text class="media-icon">📝</text>
          <text class="media-label">文字</text>
        </view>
      </view>

      <!-- 生成日记按钮 -->
      <view
        class="generate-btn press-feedback"
        :class="{ disabled: materials.length === 0 }"
        @click="handleGenerate"
      >
        <DoodleIcon v-if="generating" name="loading" color="#FFFFFF" :size="32" class="spin-anim" :filtered="false" />
        <template v-else>
          <DoodleIcon name="sparkle" color="#FFFFFF" :size="36" :filtered="false" />
          <text class="generate-text">生成今日日记</text>
        </template>
      </view>
    </view>

    <!-- ── 文字输入弹窗 ── -->
    <view v-if="showTextInput" class="overlay" @click="showTextInput = false">
      <view class="text-sheet" @click.stop>
        <view class="sheet-header">
          <text class="sheet-title">添加文字素材</text>
          <view class="sheet-close press-feedback" @click="showTextInput = false">
            <DoodleIcon name="cross" color="#AE9D92" :size="28" />
          </view>
        </view>
        <textarea
          v-model="textInput"
          class="text-input"
          placeholder="写下此刻的感受..."
          :placeholder-style="'color: #AE9D92; font-size: 30rpx;'"
          :auto-height="true"
          maxlength="500"
        />
        <view class="sheet-footer">
          <text class="char-count">{{ textInput.length }}/500</text>
          <view class="add-btn press-feedback" @click="addText">
            <text class="add-btn-text">添加</text>
          </view>
        </view>
      </view>
    </view>

    <!-- ── 文风选择弹窗 ── -->
    <view v-if="showStylePicker" class="overlay" @click="showStylePicker = false">
      <view class="style-sheet" @click.stop>
        <view class="sheet-header">
          <text class="sheet-title">选择文风</text>
          <view class="sheet-close press-feedback" @click="showStylePicker = false">
            <DoodleIcon name="cross" color="#AE9D92" :size="28" />
          </view>
        </view>
        <view class="style-grid">
          <view
            v-for="s in styles"
            :key="s"
            class="style-option press-feedback"
            :class="{ selected: currentStyle === s }"
            @click="selectStyle(s)"
          >
            <text class="style-option-text">{{ s }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- ── 关闭确认弹窗 ── -->
    <view v-if="showCloseConfirm" class="overlay" @click="showCloseConfirm = false">
      <view class="confirm-sheet" @click.stop>
        <text class="confirm-title">放弃记录？</text>
        <text class="confirm-desc">已添加 {{ materials.length }} 条素材，确定要退出吗？</text>
        <view class="confirm-btns">
          <view class="confirm-cancel press-feedback" @click="showCloseConfirm = false">
            <text class="cancel-text">继续记录</text>
          </view>
          <view class="confirm-sure press-feedback" @click="forceClose">
            <text class="sure-text">放弃</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'
import DoodleIcon from '@/components/DoodleIcon.vue'
import { createMaterial, extractEmotion, polishText } from '@/services/api/material'
import type { RawMaterial } from '@/services/api/material'
import { generateDiary } from '@/services/api/diary'

const styles = ['文艺', '幽默', '简洁', '温暖', '中二', '古风', '科幻', '电影']

const materials = ref<RawMaterial[]>([])
const currentStyle = ref('简洁')
const generating = ref(false)
const showTextInput = ref(false)
const showStylePicker = ref(false)
const showCloseConfirm = ref(false)
const textInput = ref('')
const scrollIntoId = ref('')

const navPlaceholderHeight = ref(64)
const timelineHeight = ref(500)

const todayLabel = computed(() => {
  const d = new Date()
  const m = d.getMonth() + 1
  const day = d.getDate()
  const w = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][d.getDay()]
  return `${m}月${day}日 ${w}`
})

onMounted(() => {
  const info = uni.getSystemInfoSync()
  navPlaceholderHeight.value = (info.statusBarHeight ?? 20) + 44
  // date-bar 约60rpx ≈ 30px, bottom-bar 约 180rpx ≈ 90px
  const dateBarH = 50
  const bottomBarH = 180
  timelineHeight.value = info.windowHeight - navPlaceholderHeight.value - dateBarH - bottomBarH
})

function formatTime(ts: number): string {
  const d = new Date(ts)
  const h = String(d.getHours()).padStart(2, '0')
  const min = String(d.getMinutes()).padStart(2, '0')
  return `${h}:${min}`
}

function scrollToBottom() {
  nextTick(() => {
    if (materials.value.length === 0) return
    const last = materials.value[materials.value.length - 1]
    scrollIntoId.value = ''
    setTimeout(() => {
      scrollIntoId.value = `mat-${last.id}`
    }, 100)
  })
}

async function afterAddMaterial(mat: RawMaterial) {
  // Show material without emotion first
  materials.value.push(mat)
  scrollToBottom()

  // Auto-extract emotion
  try {
    const emotion = await extractEmotion(mat.id)
    const idx = materials.value.findIndex(m => m.id === mat.id)
    if (idx >= 0) {
      materials.value[idx] = { ...materials.value[idx], emotion }
    }
  } catch {
    // silently ignore
  }
}

async function addPhoto() {
  uni.chooseImage({
    count: 1,
    success: async (res) => {
      const url = res.tempFilePaths[0]
      const today = new Date().toISOString().slice(0, 10)
      try {
        const mat = await createMaterial({ type: 'image', mediaUrl: url, date: today })
        await afterAddMaterial(mat)
      } catch {
        uni.showToast({ title: '添加失败', icon: 'none' })
      }
    },
    fail: async () => {
      // H5 fallback: mock image
      const mockUrl = `https://picsum.photos/seed/${Date.now()}/400/400`
      const today = new Date().toISOString().slice(0, 10)
      try {
        const mat = await createMaterial({ type: 'image', mediaUrl: mockUrl, date: today })
        await afterAddMaterial(mat)
      } catch {
        uni.showToast({ title: '添加失败', icon: 'none' })
      }
    }
  })
}

async function addVoice() {
  // In H5 fallback: simulate voice transcription
  uni.showLoading({ title: '录音中...', mask: true })
  await new Promise(resolve => setTimeout(resolve, 1500))
  uni.hideLoading()
  const transcription = '今天天气真好，阳光明媚，心情不错'
  const today = new Date().toISOString().slice(0, 10)
  try {
    const mat = await createMaterial({ type: 'voice', content: transcription, date: today })
    await afterAddMaterial(mat)
    uni.showToast({ title: '语音已转文字', icon: 'success' })
  } catch {
    uni.showToast({ title: '添加失败', icon: 'none' })
  }
}

async function addText() {
  const text = textInput.value.trim()
  if (!text) {
    uni.showToast({ title: '请输入内容', icon: 'none' })
    return
  }
  showTextInput.value = false
  const today = new Date().toISOString().slice(0, 10)
  try {
    const mat = await createMaterial({ type: 'text', content: text, date: today })
    textInput.value = ''
    await afterAddMaterial(mat)
  } catch {
    uni.showToast({ title: '添加失败', icon: 'none' })
  }
}

async function handlePolish(item: RawMaterial) {
  uni.showLoading({ title: '润色中...', mask: true })
  try {
    const result = await polishText(item.id, currentStyle.value)
    const idx = materials.value.findIndex(m => m.id === item.id)
    if (idx >= 0) {
      materials.value[idx] = { ...materials.value[idx], content: result.polished }
    }
    uni.showToast({ title: '润色完成 ✨', icon: 'success' })
  } catch {
    uni.showToast({ title: '润色失败', icon: 'none' })
  } finally {
    uni.hideLoading()
  }
}

function deleteMaterial(index: number) {
  materials.value.splice(index, 1)
}

async function handleGenerate() {
  if (materials.value.length === 0) {
    uni.showToast({ title: '请先添加素材', icon: 'none' })
    return
  }
  if (generating.value) return

  generating.value = true
  uni.showLoading({ title: 'AI 生成日记中...', mask: true })

  try {
    const today = new Date().toISOString().slice(0, 10)
    const diary = await generateDiary(today, '多云 18°C')
    uni.hideLoading()
    generating.value = false

    // Navigate to preview page
    uni.navigateTo({
      url: `/pages/diary/preview?id=${diary.id}&title=${encodeURIComponent(diary.title)}&content=${encodeURIComponent(diary.content)}&editCount=${diary.editCount}&maxEdits=${diary.maxEdits}`
    })
  } catch {
    uni.hideLoading()
    generating.value = false
    uni.showToast({ title: '生成失败，请重试', icon: 'none' })
  }
}

function selectStyle(s: string) {
  currentStyle.value = s
  showStylePicker.value = false
  uni.showToast({ title: `已切换为 ${s} 文风`, icon: 'none' })
}

function handleClose() {
  if (materials.value.length > 0) {
    showCloseConfirm.value = true
  } else {
    uni.navigateBack()
  }
}

function forceClose() {
  uni.navigateBack()
}
</script>

<style lang="scss" scoped>
.write-page {
  background: #FDF8F3;
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.nav-placeholder {}

/* ── NavBar 插槽 ── */
.nav-close {
  padding: 8rpx 16rpx;
}

.nav-style-btn {
  display: flex;
  align-items: center;
  padding: 8rpx 16rpx;
  background: rgba(232, 133, 90, 0.1);
  border-radius: 20rpx;
}

.style-label {
  font-size: 26rpx;
  color: #E8855A;
  font-weight: 600;
}

.style-arrow {
  font-size: 22rpx;
  color: #E8855A;
}

/* ── 日期天气行 ── */
.date-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16rpx 32rpx;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(44, 31, 20, 0.04);
}

.date-text {
  font-size: 28rpx;
  color: #2C1F14;
  font-weight: 600;
}

.weather-info {
  display: flex;
  align-items: center;
  gap: 4rpx;
}

.weather-text {
  font-size: 26rpx;
  color: #AE9D92;
}

/* ── 时间线 ── */
.timeline-scroll {
  flex: 1;
}

.timeline-inner {
  padding: 24rpx 24rpx 0 24rpx;
}

.material-item {
  display: flex;
  gap: 16rpx;
  margin-bottom: 24rpx;
}

/* 时间线节点 */
.timeline-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-shrink: 0;
  padding-top: 8rpx;
}

.node-dot {
  width: 16rpx;
  height: 16rpx;
  border-radius: 50% 60% 40% 55%;
  background: #E8855A;
  flex-shrink: 0;
}

.node-line {
  width: 2rpx;
  flex: 1;
  min-height: 40rpx;
  background: repeating-linear-gradient(
    to bottom,
    #D4C4B8 0,
    #D4C4B8 8rpx,
    transparent 8rpx,
    transparent 16rpx
  );
  margin-top: 8rpx;
}

/* 素材卡片 */
.material-card {
  flex: 1;
  background: #FFFFFF;
  border-radius: 16rpx 20rpx 16rpx 18rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.06);
  padding: 20rpx 24rpx;
  display: flex;
  flex-direction: column;
  gap: 12rpx;
  min-width: 0;
}

.mat-time {
  font-size: 22rpx;
  color: #AE9D92;
}

.mat-image {
  width: 100%;
  height: 320rpx;
  border-radius: 12rpx;
  display: block;
}

.mat-image-wrap {
  border-radius: 12rpx;
  overflow: hidden;
}

.mat-text-content {
  font-size: 30rpx;
  color: #4A3628;
  line-height: 1.6;
}

.mat-voice-wrap {
  display: flex;
  align-items: center;
  gap: 12rpx;
  background: #FDF0E8;
  border-radius: 12rpx;
  padding: 16rpx 20rpx;
}

.mat-voice-text {
  font-size: 28rpx;
  color: #4A3628;
  flex: 1;
}

.mat-location {
  display: flex;
  align-items: center;
  gap: 4rpx;
}

.mat-location-text {
  font-size: 24rpx;
  color: #AE9D92;
}

.mat-footer {
  display: flex;
  align-items: center;
  gap: 12rpx;
}

.mat-emotion {
  display: flex;
  align-items: center;
  gap: 6rpx;
  flex: 1;
}

.emotion-emoji {
  font-size: 28rpx;
}

.emotion-label {
  font-size: 24rpx;
  color: #E8855A;
  font-weight: 600;
}

.emotion-score {
  font-size: 22rpx;
  color: #AE9D92;
}

.mat-emotion-loading {
  flex: 1;
}

.emotion-loading-text {
  font-size: 22rpx;
  color: #D4C4B8;
}

.polish-btn {
  background: rgba(232, 133, 90, 0.1);
  border-radius: 12rpx;
  padding: 6rpx 16rpx;
}

.polish-text {
  font-size: 24rpx;
  color: #E8855A;
  font-weight: 600;
}

.mat-delete {
  padding: 4rpx;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120rpx 0;
  gap: 16rpx;
}

.empty-text {
  font-size: 32rpx;
  color: #AE9D92;
  font-weight: 500;
}

.empty-sub {
  font-size: 26rpx;
  color: #D4C4B8;
}

.timeline-bottom-spacer {
  height: 24rpx;
}

/* ── 底部操作栏 ── */
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.97);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.media-btns {
  display: flex;
  gap: 16rpx;
  justify-content: center;
}

.media-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4rpx;
  padding: 12rpx 32rpx;
  background: #FDF8F3;
  border-radius: 16rpx;
  border: 2rpx solid rgba(232, 133, 90, 0.15);
  &:active { opacity: 0.7; }
}

.media-icon {
  font-size: 40rpx;
}

.media-label {
  font-size: 22rpx;
  color: #4A3628;
}

.generate-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10rpx;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 44rpx;
  height: 88rpx;
  box-shadow: 2px 3px 0 rgba(232, 133, 90, 0.25);
  &:active { opacity: 0.85; }

  &.disabled {
    background: #D4C4B8;
    box-shadow: none;
  }
}

.generate-text {
  font-size: 32rpx;
  color: #FFFFFF;
  font-weight: 700;
}

/* ── 弹窗 ── */
.overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.text-sheet,
.style-sheet,
.confirm-sheet {
  width: 100%;
  background: #FFFFFF;
  border-radius: 24rpx 24rpx 0 0;
  padding: 24rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
}

.sheet-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20rpx;
}

.sheet-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #2C1F14;
}

.sheet-close {
  padding: 8rpx;
  &:active { opacity: 0.6; }
}

.text-input {
  width: 100%;
  min-height: 200rpx;
  font-size: 30rpx;
  color: #2C1F14;
  line-height: 1.6;
  border: 2rpx solid #EAE0D6;
  border-radius: 16rpx;
  padding: 20rpx;
  box-sizing: border-box;
  background: #FDF8F3;
}

.sheet-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16rpx;
}

.char-count {
  font-size: 24rpx;
  color: #AE9D92;
}

.add-btn {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 20rpx;
  padding: 16rpx 40rpx;
  &:active { opacity: 0.85; }
}

.add-btn-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}

.style-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
}

.style-option {
  padding: 12rpx 24rpx;
  border-radius: 20rpx;
  border: 2rpx solid #EAE0D6;
  background: #F5F0EB;
  min-width: 128rpx;
  text-align: center;
  &:active { transform: scale(0.95); }

  &.selected {
    border-color: #E8855A;
    background: #FDF0E8;
  }
}

.style-option-text {
  font-size: 28rpx;
  color: #4A3628;
  .selected & { color: #E8855A; font-weight: 600; }
}

.confirm-sheet {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
  padding-top: 40rpx;
}

.confirm-title {
  font-size: 36rpx;
  font-weight: 700;
  color: #2C1F14;
  text-align: center;
}

.confirm-desc {
  font-size: 28rpx;
  color: #4A3628;
  text-align: center;
  line-height: 1.5;
}

.confirm-btns {
  display: flex;
  gap: 16rpx;
  margin-top: 8rpx;
}

.confirm-cancel {
  flex: 1;
  background: #F5F0EB;
  border-radius: 20rpx;
  padding: 24rpx;
  text-align: center;
  &:active { opacity: 0.8; }
}

.cancel-text {
  font-size: 30rpx;
  color: #4A3628;
  font-weight: 500;
}

.confirm-sure {
  flex: 1;
  background: #E8855A;
  border-radius: 20rpx;
  padding: 24rpx;
  text-align: center;
  &:active { opacity: 0.85; }
}

.sure-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}

/* spin 动画 */
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.spin-anim {
  animation: spin 1s linear infinite;
}
</style>
