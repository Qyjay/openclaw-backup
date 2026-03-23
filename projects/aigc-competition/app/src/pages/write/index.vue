<template>
  <!-- 写日记页：全屏，无 TabBar -->
  <view class="write-page page-root">

    <!-- ── 顶部操作栏 ── -->
    <view class="write-navbar">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
        <text class="back-text">返回</text>
      </view>
      <text class="write-date">{{ dateLabel }}</text>
      <view class="save-btn" @click="saveDiary">
        <text class="save-text">保存</text>
      </view>
    </view>

    <!-- ── 内容区 ── -->
    <view class="write-body">

      <!-- 情绪选择器（横排5个） -->
      <view class="mood-bar">
        <view
          v-for="em in emotions"
          :key="em.key"
          class="mood-item"
          :class="{ 'mood-item--active': selectedMood === em.key }"
          @click="selectedMood = em.key"
        >
          <text class="mood-emoji">{{ em.emoji }}</text>
          <text class="mood-label" :class="{ 'mood-label--active': selectedMood === em.key }">{{ em.label }}</text>
        </view>
      </view>

      <!-- 分隔 -->
      <view class="write-divider" />

      <!-- 媒体区（横向滚动） -->
      <view class="media-section">
        <view class="media-scroll">
          <view
            v-for="(img, i) in mediaList"
            :key="i"
            class="media-thumb"
          >
            <text class="media-thumb-icon">{{ img.icon }}</text>
          </view>
          <view class="media-add" @click="addMedia">
            <text class="media-add-icon">＋</text>
            <text class="media-add-text">添加</text>
          </view>
        </view>
      </view>

      <!-- 分隔 -->
      <view class="write-divider" />

      <!-- 标签区 -->
      <view class="tag-section">
        <view
          v-for="tag in tags"
          :key="tag"
          class="tag-chip"
          :class="{ 'tag-chip--active': selectedTags.includes(tag) }"
          @click="toggleTag(tag)"
        >
          <text class="tag-text">{{ tag }}</text>
        </view>
        <view class="tag-add" @click="addTag">
          <text class="tag-add-text">＋ 添加</text>
        </view>
      </view>

      <!-- 分隔 -->
      <view class="write-divider" />

      <!-- 文本输入区 -->
      <view class="text-area-wrap">
        <textarea
          v-model="diaryContent"
          class="diary-textarea font-handwrite"
          placeholder="在这里写下今天的故事..."
          :placeholder-style="'color: #D4C4B8; font-size: 15px;'"
          auto-height
          maxlength="-1"
        />
        <text v-if="diaryContent.length === 0" class="autosave-hint">自动保存 · AI 辅助写作</text>
      </view>

    </view>

    <!-- ── 底部工具栏 ── -->
    <view class="write-toolbar">
      <view class="toolbar-btn" @click="aiAssist">
        <text class="toolbar-icon">🤖</text>
        <text class="toolbar-label">AI 帮我写</text>
      </view>
      <view class="toolbar-divider" />
      <view class="toolbar-btn" @click="addLocation">
        <text class="toolbar-icon">📍</text>
        <text class="toolbar-label">添加位置</text>
      </view>
      <view class="toolbar-divider" />
      <view class="toolbar-btn" @click="addMedia">
        <text class="toolbar-icon">🖼️</text>
        <text class="toolbar-label">插入图片</text>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const now = new Date()
const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
const dateLabel = computed(() => {
  const m = now.getMonth() + 1
  const d = now.getDate()
  const h = String(now.getHours()).padStart(2, '0')
  const min = String(now.getMinutes()).padStart(2, '0')
  const w = weekDays[now.getDay()]
  return `${m}月${d}日 ${w} ${h}:${min}`
})

const emotions = [
  { key: 'happy',   emoji: '😊', label: '开心' },
  { key: 'calm',    emoji: '😌', label: '平静' },
  { key: 'excited', emoji: '🤩', label: '兴奋' },
  { key: 'sad',     emoji: '😔', label: '难过' },
  { key: 'tired',   emoji: '😴', label: '疲惫' },
]

const selectedMood = ref('happy')
const diaryContent = ref('')

const mediaList = ref<{icon: string}[]>([])
function addMedia() {
  const icons = ['🍱', '📚', '🌅', '😊', '🎮', '🏃']
  mediaList.value.push({ icon: icons[Math.floor(Math.random() * icons.length)] })
  uni.showToast({ title: '已添加媒体（模拟）', icon: 'none' })
}

const tags = ['#美食', '#学习', '#日常', '#运动', '#情感', '#思考']
const selectedTags = ref<string[]>(['#日常'])
function toggleTag(tag: string) {
  const idx = selectedTags.value.indexOf(tag)
  if (idx >= 0) selectedTags.value.splice(idx, 1)
  else selectedTags.value.push(tag)
}
function addTag() {
  uni.showToast({ title: '自定义标签即将开放', icon: 'none' })
}

function goBack() {
  uni.navigateBack()
}

function saveDiary() {
  if (!diaryContent.value.trim()) {
    uni.showToast({ title: '请先写点什么～', icon: 'none' })
    return
  }
  uni.showToast({ title: '日记已保存 ✓', icon: 'success' })
  setTimeout(() => uni.navigateBack(), 800)
}

function aiAssist() {
  uni.showToast({ title: 'AI 正在帮你构思...', icon: 'loading' })
  setTimeout(() => {
    diaryContent.value = diaryContent.value + (diaryContent.value ? '\n\n' : '') +
      '今天是平凡又充实的一天。早晨的阳光透过窗帘照进来，提醒我新的一天开始了。'
    uni.hideToast()
  }, 1500)
}

function addLocation() {
  uni.showToast({ title: '当前位置：南开大学 📍', icon: 'none' })
}
</script>

<style lang="scss">
@import '@/common/styles/handdrawn.scss';

.write-page {
  position: fixed;
  inset: 0;
  background: #FDF8F3;
  display: flex;
  flex-direction: column;
  height: 100vh;
  height: 100dvh;
}

/* ── 顶部操作栏 ── */
.write-navbar {
  flex-shrink: 0;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  background: rgba(253, 248, 243, 0.97);
  border-bottom: 1px solid rgba(44, 31, 20, 0.06);
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 2px;
  cursor: pointer;
  padding: 6px 8px 6px 0;
  &:active { opacity: 0.6; }
}

.back-icon { font-size: 22px; color: #2C1F14; line-height: 1; margin-top: -2px; }
.back-text { font-size: 15px; color: #2C1F14; font-weight: 500; }

.write-date { font-size: 13px; color: #857268; }

.save-btn {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 9999px;
  padding: 6px 16px;
  cursor: pointer;
  transition: opacity 0.15s;
  &:active { opacity: 0.8; }
}
.save-text { font-size: 14px; color: #FFFFFF; font-weight: 600; }

/* ── 内容区 ── */
.write-body {
  flex: 1;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  display: flex;
  flex-direction: column;
}

/* ── 情绪横排 ── */
.mood-bar {
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding: 14px 16px;
  background: #FFFFFF;
}

.mood-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  padding: 8px;
  border-radius: 12px;
  border: 2px solid transparent;
  transition: all 0.15s;
  &:active { transform: scale(0.92); }
}

.mood-item--active {
  border-color: #E8855A;
  background: rgba(232, 133, 90, 0.08);
}

.mood-emoji { font-size: 26px; }
.mood-label { font-size: 11px; color: #AE9D92; }
.mood-label--active { color: #E8855A; font-weight: 600; }

/* 分隔线 */
.write-divider {
  height: 1px;
  background: rgba(44, 31, 20, 0.06);
  flex-shrink: 0;
}

/* ── 媒体区 ── */
.media-section {
  padding: 12px 16px;
  background: #FFFFFF;
}

.media-scroll {
  display: flex;
  align-items: center;
  gap: 10px;
  overflow-x: auto;
  padding-bottom: 2px;
}

.media-thumb {
  flex-shrink: 0;
  width: 72px;
  height: 72px;
  border-radius: 12px;
  background: linear-gradient(135deg, #FDF0E8, #F7CDB5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
}

.media-add {
  flex-shrink: 0;
  width: 72px;
  height: 72px;
  border-radius: 12px;
  border: 2px dashed #D4C4B8;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  cursor: pointer;
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.media-add-icon { font-size: 22px; color: #AE9D92; }
.media-add-text { font-size: 11px; color: #AE9D92; }

/* ── 标签区 ── */
.tag-section {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 12px 16px;
  background: #FFFFFF;
  align-items: center;
}

.tag-chip {
  padding: 5px 12px;
  border-radius: 9999px;
  border: 1px solid #EAE0D6;
  background: #F5EDE4;
  cursor: pointer;
  transition: all 0.15s;
}

.tag-chip--active {
  border-color: #E8855A;
  background: rgba(232, 133, 90, 0.10);
}

.tag-text {
  font-size: 13px;
  color: #857268;
  .tag-chip--active & { color: #E8855A; font-weight: 500; }
}

.tag-add {
  padding: 5px 12px;
  border-radius: 9999px;
  border: 1px dashed #D4C4B8;
  cursor: pointer;
  &:active { background: rgba(232, 133, 90, 0.05); }
}

.tag-add-text { font-size: 13px; color: #AE9D92; }

/* ── 文本输入区 ── */
.text-area-wrap {
  flex: 1;
  position: relative;
  padding: 16px;
  background: #FDF8F3;
  min-height: 200px;
}

.diary-textarea {
  width: 100%;
  min-height: 180px;
  font-size: 15px;
  line-height: 1.85;
  color: #4A3628;
  background: transparent;
  border: none;
  outline: none;
  resize: none;
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'KaiTi', 'PingFang SC', sans-serif !important;
}

.autosave-hint {
  position: absolute;
  bottom: 12px;
  right: 16px;
  font-size: 11px;
  color: #D4C4B8;
}

/* ── 底部工具栏 ── */
.write-toolbar {
  flex-shrink: 0;
  height: 52px;
  display: flex;
  align-items: center;
  background: #FFFFFF;
  border-top: 1px solid rgba(44, 31, 20, 0.06);
  padding-bottom: env(safe-area-inset-bottom);
}

.toolbar-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  cursor: pointer;
  height: 100%;
  &:active { background: rgba(232, 133, 90, 0.06); }
}

.toolbar-icon { font-size: 18px; }
.toolbar-label { font-size: 13px; color: #4A3628; font-weight: 500; }

.toolbar-divider {
  width: 1px;
  height: 24px;
  background: rgba(44, 31, 20, 0.08);
}

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
}
</style>
