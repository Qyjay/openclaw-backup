<template>
  <view class="write-page">
    <!-- ── CustomNavBar ── -->
    <CustomNavBar
      title="新日记"
      left-icon="none"
      @left-click="handleClose"
    >
      <!-- 左插槽：关闭按钮 -->
      <template #left>
        <view class="nav-close press-feedback" @click="handleClose">
          <DoodleIcon name="cross" color="#2C1F14" :size="36" />
        </view>
      </template>
      <!-- 右插槽：完成按钮 -->
      <template #right>
        <view
          class="nav-done"
          :class="{ disabled: !canDone }"
          @click="handleDone"
        >
          <text class="done-text" :class="{ 'done-text--active': canDone }">完成</text>
          <DoodleIcon name="check" :color="canDone ? '#FFFFFF' : '#AE9D92'" :size="28" />
        </view>
      </template>
    </CustomNavBar>

    <!-- ── 内容区 ── -->
    <scroll-view class="write-body" scroll-y>
      <!-- 情绪选择栏 -->
      <view class="emotion-bar">
        <view
          v-for="em in emotions"
          :key="em.key"
          class="emotion-item press-feedback"
          :class="{ active: selectedEmotion.key === em.key }"
          @click="selectedEmotion = em"
        >
          <text class="emotion-emoji" :class="{ 'emoji-active': selectedEmotion.key === em.key }">{{ em.emoji }}</text>
          <text class="emotion-label" :class="{ 'label-active': selectedEmotion.key === em.key }">{{ em.label }}</text>
          <view v-if="selectedEmotion.key === em.key" class="emotion-dot" />
        </view>
      </view>

      <!-- 照片区域（横向滚动） -->
      <view class="photo-section">
        <scroll-view class="photo-scroll" scroll-x>
          <view
            v-for="(img, i) in photos"
            :key="i"
            class="photo-item"
          >
            <image class="photo-img" :src="img" mode="aspectFill" />
            <view class="photo-delete" @click="removePhoto(i)">
              <DoodleIcon name="cross" color="#FFFFFF" :size="12" :filtered="false" />
            </view>
          </view>
          <!-- 添加按钮 -->
          <view class="photo-add press-feedback" @click="addPhoto">
            <DoodleIcon name="plus" color="#AE9D92" :size="24" />
            <text class="add-text">添加</text>
          </view>
        </scroll-view>
      </view>

      <!-- 文本输入区 -->
      <view class="textarea-section">
        <textarea
          v-model="content"
          class="content-textarea"
          :placeholder="placeholderText"
          :placeholder-style="'color: #AE9D92; font-size: 32rpx;'"
          :auto-height="true"
          :min-height="300"
          maxlength="-1"
        />
      </view>

      <!-- 位置+天气 -->
      <view class="meta-row">
        <DoodleIcon name="pin" color="#AE9D92" :size="14" />
        <text class="meta-text"> 南开大学</text>
        <DoodleIcon name="cloud" color="#AE9D92" :size="14" style="margin-left: 12rpx" />
        <text class="meta-text"> 多云 18°C</text>
      </view>

      <!-- 标签栏 -->
      <view class="tag-bar">
        <view
          v-for="tag in selectedTags"
          :key="tag"
          class="tag-chip tag-selected"
          @click="removeTag(tag)"
        >
          <text class="tag-text">#{{ tag }}</text>
        </view>
        <view class="tag-add-btn" @click="showTagPicker = true">
          <text class="tag-add-text">+添加</text>
        </view>
      </view>
    </scroll-view>

    <!-- ── AI 工具栏（固定底部） ── -->
    <view class="ai-toolbar">
      <view class="toolbar-btn ai-btn press-feedback" @click="handleAIGenerate">
        <DoodleIcon v-if="aiLoading" name="loading" color="#FFFFFF" :size="18" class="spin-anim" :filtered="false" />
        <template v-else>
          <DoodleIcon name="sparkle" color="#FFFFFF" :size="32" :filtered="false" />
          <text class="ai-btn-text">AI生成</text>
        </template>
      </view>
      <view class="toolbar-btn style-btn press-feedback" @click="showStylePicker = true">
        <DoodleIcon name="wand" color="#E8855A" :size="16" />
        <text class="style-btn-text">文风</text>
      </view>
      <view class="toolbar-btn voice-btn press-feedback" @click="handleVoice">
        <DoodleIcon name="voice" color="#E8855A" :size="16" />
        <text class="voice-btn-text">语音</text>
      </view>
    </view>

    <!-- ── 标签选择弹窗 ── -->
    <view v-if="showTagPicker" class="tag-overlay" @click="showTagPicker = false">
      <view class="tag-sheet" @click.stop>
        <view class="sheet-title-row">
          <text class="sheet-title">选择标签</text>
          <view class="sheet-close press-feedback" @click="showTagPicker = false">
            <DoodleIcon name="cross" color="#AE9D92" :size="16" />
          </view>
        </view>
        <view class="tag-grid">
          <view
            v-for="tag in allTags"
            :key="tag"
            class="tag-option"
            :class="{ selected: selectedTags.includes(tag) }"
            @click="toggleTag(tag)"
          >
            <text class="tag-option-text">#{{ tag }}</text>
          </view>
        </view>
        <view class="tag-confirm-btn" @click="showTagPicker = false">
          <text class="tag-confirm-text">确定</text>
        </view>
      </view>
    </view>

    <!-- ── 文风选择弹窗 ── -->
    <view v-if="showStylePicker" class="style-overlay" @click="showStylePicker = false">
      <view class="style-sheet" @click.stop>
        <view class="sheet-title-row">
          <text class="sheet-title">选择文风</text>
          <view class="sheet-close press-feedback" @click="showStylePicker = false">
            <DoodleIcon name="cross" color="#AE9D92" :size="16" />
          </view>
        </view>
        <view class="style-grid">
          <view
            v-for="s in styles"
            :key="s"
            class="style-option"
            :class="{ selected: currentStyle === s }"
            @click="selectStyle(s)"
          >
            <text class="style-option-text">{{ s }}</text>
          </view>
        </view>
      </view>
    </view>

    <!-- ── 关闭确认弹窗 ── -->
    <view v-if="showCloseConfirm" class="confirm-overlay" @click="showCloseConfirm = false">
      <view class="confirm-sheet" @click.stop>
        <text class="confirm-title">放弃编辑？</text>
        <text class="confirm-desc">你编辑的内容尚未保存，确定要退出吗？</text>
        <view class="confirm-btns">
          <view class="confirm-cancel" @click="showCloseConfirm = false">
            <text class="cancel-text">取消</text>
          </view>
          <view class="confirm-sure" @click="forceClose">
            <text class="sure-text">放弃</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'
import DoodleIcon from '@/components/DoodleIcon.vue'

interface Emotion {
  key: string
  emoji: string
  label: string
}

const emotions: Emotion[] = [
  { key: 'happy',   emoji: '😊', label: '开心' },
  { key: 'sad',     emoji: '😢', label: '难过' },
  { key: 'angry',   emoji: '😤', label: '烦躁' },
  { key: 'tired',   emoji: '😴', label: '疲惫' },
  { key: 'blessed', emoji: '🥰', label: '幸福' },
  { key: 'funny',   emoji: '😂', label: '搞笑' },
  { key: 'think',   emoji: '🤔', label: '思考' },
  { key: 'cool',    emoji: '😎', label: '自信' },
]

const styles = ['简洁', '文艺', '搞笑', '中二', '武侠', '古风', '科幻', '电影']

const allTags = ['美食', '学习', '运动', '社交', '心情', '摄影', '音乐', '旅行', '读书', '游戏']

// ── 状态 ──
const mode = ref('text')
const selectedEmotion = ref<Emotion>(emotions[0])
const photos = ref<string[]>([
  'https://picsum.photos/seed/newdiary1/400/400',
  'https://picsum.photos/seed/newdiary2/400/400',
])
const content = ref('')
const selectedTags = ref<string[]>(['美食'])
const currentStyle = ref('简洁')
const aiLoading = ref(false)
const showTagPicker = ref(false)
const showStylePicker = ref(false)
const showCloseConfirm = ref(false)

// ── Computed ──
const placeholderText = computed(() => {
  const map: Record<string, string> = {
    photo: 'AI 会根据照片生成日记，你也可以补充几句...',
    album: 'AI 会根据照片生成日记，你也可以补充几句...',
    text: '写下此刻的心情...',
    voice: '语音转文字中...',
  }
  return map[mode.value] ?? '写下此刻的心情...'
})

const canDone = computed(() => {
  return content.value.trim().length > 0 || photos.value.length > 0
})

// ── 生命周期 ──
onMounted(() => {
  const pages = getCurrentPages()
  const current = pages[pages.length - 1]
  const options = (current as any)?.options ?? {}
  if (options.mode) mode.value = options.mode
})

// ── 方法 ──
function addPhoto() {
  // 在 H5 环境使用 input[type=file] 模拟
  // 实际调用 uni.chooseImage
  uni.chooseImage({
    count: 9,
    success: (res) => {
      photos.value.push(...res.tempFilePaths)
    },
    fail: () => {
      // H5 fallback: simulate adding a mock image
      photos.value.push(`https://picsum.photos/seed/${Date.now()}/400/400`)
      uni.showToast({ title: '已添加照片（模拟）', icon: 'none' })
    }
  })
}

function removePhoto(index: number) {
  photos.value.splice(index, 1)
}

function removeTag(tag: string) {
  const idx = selectedTags.value.indexOf(tag)
  if (idx >= 0) selectedTags.value.splice(idx, 1)
}

function toggleTag(tag: string) {
  const idx = selectedTags.value.indexOf(tag)
  if (idx >= 0) {
    selectedTags.value.splice(idx, 1)
  } else {
    selectedTags.value.push(tag)
  }
}

function selectStyle(s: string) {
  currentStyle.value = s
  showStylePicker.value = false
  uni.showToast({ title: `已切换为 ${s} 风格`, icon: 'none' })
}

async function handleAIGenerate() {
  if (aiLoading.value) return
  aiLoading.value = true
  uni.showLoading({ title: 'AI 生成中...', mask: true })

  await new Promise(resolve => setTimeout(resolve, 2000))

  content.value = '今天阳光正好，和朋友约在了学校旁边那家熟悉的咖啡馆。点了一杯拿铁，聊了很多关于未来的事情。窗外梧桐树的影子斑驳地落在桌面上，这一刻的时光仿佛被拉得很长很长。我们聊梦想、聊申请、聊雅思，也聊一些无聊的八卦，笑得肚子疼。这种简单而真实的快乐，大概就是大学生活最珍贵的部分吧。✨'
  aiLoading.value = false
  uni.hideLoading()
  uni.showToast({ title: 'AI 生成完成 ✨', icon: 'success' })
}

function handleVoice() {
  uni.showToast({ title: '语音功能开发中', icon: 'none' })
}

function handleClose() {
  const hasContent = content.value.trim().length > 0 || photos.value.length > 0
  if (hasContent) {
    showCloseConfirm.value = true
  } else {
    uni.navigateBack()
  }
}

function forceClose() {
  uni.navigateBack()
}

async function handleDone() {
  if (!canDone.value) return

  // 如果有图片但没文字，先 AI 生成
  if (photos.value.length > 0 && !content.value.trim()) {
    uni.showLoading({ title: 'AI 生成日记中...', mask: true })
    await new Promise(resolve => setTimeout(resolve, 2000))
    content.value = '今天的日记，由照片和心情组成。南开大学的校园里，阳光洒在梧桐树叶上，一切都显得那么宁静而美好。用心感受每一个平凡的瞬间，这就是记录的意义吧。🌿'
    uni.hideLoading()
  }

  console.log('📔 日记保存数据：', {
    content: content.value,
    photos: photos.value,
    emotion: selectedEmotion.value,
    tags: selectedTags.value,
    style: currentStyle.value,
  })

  uni.showToast({ title: '日记已保存 ✓', icon: 'success' })
  setTimeout(() => uni.navigateBack(), 800)
}
</script>

<style lang="scss" scoped>
.write-page {
  position: absolute;
  inset: 0;
  background: #FDF8F3;
  display: flex;
  flex-direction: column;
  height: 100%;
}

/* ── NavBar 插槽 ── */
.nav-close {
  padding: 8rpx 16rpx;
  &:active { opacity: 0.6; }
}

.close-text {
  font-size: 32rpx;
  color: #2C1F14;
  font-weight: 300;
}

.nav-done {
  padding: 8rpx 16rpx;
  border-radius: 20rpx;
  background: #D4C4B8;
  transition: background 0.2s;
}

.nav-done:not(.disabled) {
  background: #E8855A;
}

.done-text {
  font-size: 28rpx;
  color: #FFFFFF;
  font-weight: 600;
}

/* ── 内容区 ── */
.write-body {
  flex: 1;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding-bottom: 200rpx;
}

/* ── 情绪选择栏 ── */
.emotion-bar {
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 20rpx 8rpx;
  background: #FFFFFF;
  margin-bottom: 2rpx;
}

.emotion-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rpx;
  padding: 8rpx 4rpx;
  border-radius: 10rpx 14rpx 10rpx 12rpx;
  cursor: pointer;
  transition: transform 0.15s;
  &:active { transform: scale(0.9); }

  &.active {
    background: rgba(232, 133, 90, 0.08);
  }

  &.active .emotion-emoji {
    transform: scale(1.3);
  }
}

.emotion-emoji {
  font-size: 42rpx;
  transition: transform 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.emotion-label {
  font-size: 18rpx;
  color: #AE9D92;
  line-height: 1;
}

.label-active {
  color: #E8855A;
  font-weight: 600;
}

.emotion-dot {
  width: 6rpx;
  height: 6rpx;
  border-radius: 50% 60% 40% 55%;
  background: #E8855A;
  margin-top: 2rpx;
}

/* ── 照片区域 ── */
.photo-section {
  background: #FFFFFF;
  padding: 16rpx 0 16rpx 16rpx;
  margin-bottom: 2rpx;
}

.photo-scroll {
  display: flex;
  align-items: center;
  white-space: nowrap;
}

.photo-item {
  position: relative;
  display: inline-block;
  margin-right: 12rpx;
  flex-shrink: 0;
}

.photo-img {
  width: 160rpx;
  height: 160rpx;
  border-radius: 12rpx;
  display: block;
}

.photo-delete {
  position: absolute;
  top: -8rpx;
  right: -8rpx;
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  &:active { background: rgba(0, 0, 0, 0.7); }
}

.delete-icon {
  font-size: 20rpx;
  color: #FFFFFF;
  line-height: 1;
}

.photo-add {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 160rpx;
  height: 160rpx;
  border-radius: 12rpx;
  border: 2rpx dashed #D4C4B8;
  flex-shrink: 0;
  cursor: pointer;
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.add-icon {
  font-size: 40rpx;
  color: #AE9D92;
  line-height: 1;
}

.add-text {
  font-size: 22rpx;
  color: #AE9D92;
  margin-top: 4rpx;
}

/* ── 文本输入 ── */
.textarea-section {
  background: #FFFFFF;
  padding: 16rpx 24rpx;
  margin-bottom: 2rpx;
}

.content-textarea {
  width: 100%;
  min-height: 300rpx;
  font-size: 32rpx;
  color: #4A3628;
  line-height: 1.6;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
}

/* ── 位置天气 ── */
.meta-row {
  background: #FFFFFF;
  padding: 12rpx 24rpx;
  margin-bottom: 2rpx;
}

.meta-text {
  font-size: 26rpx;
  color: #AE9D92;
}

/* ── 标签栏 ── */
.tag-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 8rpx;
  padding: 12rpx 24rpx;
  background: #FFFFFF;
  align-items: center;
}

.tag-chip {
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
}

.tag-selected {
  background: #FDF0E8;
  &:active { opacity: 0.7; }
}

.tag-text {
  font-size: 24rpx;
  color: #E8855A;
}

.tag-add-btn {
  padding: 6rpx 16rpx;
  border-radius: 20rpx;
  border: 1rpx dashed #D4C4B8;
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.tag-add-text {
  font-size: 24rpx;
  color: #AE9D92;
}

/* ── AI 工具栏（固定底部） ── */
.ai-toolbar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  gap: 16rpx;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: rgba(255, 255, 255, 0.97);
  backdrop-filter: blur(12rpx);
  -webkit-backdrop-filter: blur(12rpx);
  box-shadow: 0 -2rpx 12rpx rgba(0, 0, 0, 0.06);
}

.toolbar-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 72rpx;
  border-radius: 36rpx;
  font-size: 28rpx;
  font-weight: 600;
  &:active { opacity: 0.85; }
}

.ai-btn {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  box-shadow: 2px 3px 0 rgba(232, 133, 90, 0.2);
  gap: 6rpx;
}

.ai-btn-text {
  color: #FFFFFF;
  font-size: 28rpx;
  font-weight: 600;
}

.style-btn,
.voice-btn {
  border: 3rpx solid #E8855A;
  background: transparent;
  gap: 6rpx;
}

.style-btn-text,
.voice-btn-text {
  color: #E8855A;
  font-size: 28rpx;
  font-weight: 600;
}

/* ── 标签选择弹窗 ── */
.tag-overlay,
.style-overlay,
.confirm-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.tag-sheet,
.style-sheet {
  width: 100%;
  background: #FFFFFF;
  border-radius: 24rpx 24rpx 0 0;
  padding: 24rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
}

.sheet-title-row {
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

.sheet-close text {
  font-size: 28rpx;
  color: #AE9D92;
}

.tag-grid,
.style-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12rpx;
  margin-bottom: 20rpx;
}

.tag-option,
.style-option {
  padding: 10rpx 20rpx;
  border-radius: 20rpx;
  border: 2rpx solid #EAE0D6;
  background: #F5F0EB;
  cursor: pointer;
  transition: all 0.15s;
  &:active { transform: scale(0.95); }

  &.selected {
    border-color: #E8855A;
    background: #FDF0E8;
  }
}

.tag-option-text,
.style-option-text {
  font-size: 26rpx;
  color: #4A3628;
  .selected & { color: #E8855A; font-weight: 600; }
}

.style-option {
  min-width: 140rpx;
  text-align: center;
}

.tag-confirm-btn {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 20rpx;
  padding: 20rpx;
  text-align: center;
  &:active { opacity: 0.85; }
}

.tag-confirm-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}

/* ── 关闭确认弹窗 ── */
.confirm-sheet {
  width: 100%;
  background: #FFFFFF;
  border-radius: 24rpx 24rpx 0 0;
  padding: 40rpx 32rpx calc(32rpx + env(safe-area-inset-bottom));
  display: flex;
  flex-direction: column;
  gap: 12rpx;
}

.confirm-title {
  font-size: 34rpx;
  font-weight: 600;
  color: #2C1F14;
  text-align: center;
  margin-bottom: 4rpx;
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
  margin-top: 12rpx;
}

.confirm-cancel {
  flex: 1;
  background: #F5F0EB;
  border-radius: 20rpx;
  padding: 20rpx;
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
  padding: 20rpx;
  text-align: center;
  &:active { opacity: 0.85; }
}

.sure-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}
</style>
