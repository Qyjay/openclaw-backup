<template>
  <view class="page page-root">

    <!-- ── 顶栏（44px 单行） ── -->
    <view class="navbar">
      <view class="navbar-left">
        <text class="navbar-date font-handwrite">{{ todayLabel }}</text>
      </view>
      <view class="navbar-right">
        <text class="navbar-emotion" @click="showEmotionPicker = true">{{ todayEmotion.emoji }}</text>
        <view class="navbar-avatar" @click="goProfile">
          <image class="avatar-img" src="/static/brand/logo-d-mascot.png" mode="aspectFill" />
        </view>
      </view>
    </view>

    <!-- ── 滚动内容区 ── -->
    <view class="page-scroll">

      <!-- ─── 今天 ─── -->
      <view class="date-divider">
        <view class="divider-line" />
        <text class="divider-label font-handwrite">今天</text>
        <view class="divider-line" />
      </view>

      <!-- 日记卡：午饭 -->
      <view class="diary-card diary-card-handdrawn" @click="openDiary(1)">
        <view class="diary-card-inner">
          <view class="diary-meta-row">
            <text class="diary-time">12:30</text>
            <view class="diary-tag">#美食</view>
            <text class="diary-emotion-icon">😋</text>
          </view>
          <text class="diary-title font-handwrite">午饭日记</text>
          <text class="diary-excerpt">今天食堂出了新菜，番茄牛腩真的太香了！配上白米饭吃了两碗都不够。</text>
          <view class="diary-photos">
            <view class="diary-photo-placeholder">
              <text class="photo-icon">🍱</text>
            </view>
          </view>
        </view>
      </view>

      <!-- AI 洞察卡（穿插） -->
      <view class="ai-insight-card">
        <view class="ai-insight-header">
          <text class="ai-icon">✨</text>
          <text class="ai-insight-title">AI 洞察</text>
        </view>
        <text class="ai-insight-text">你连续 3 天心情不错，最近爱写美食日记 📝</text>
        <text class="ai-insight-sub">基于最近 47 篇日记 · 点击查看完整分析 →</text>
      </view>

      <!-- 日记卡：算法课 -->
      <view class="diary-card diary-card-handdrawn" @click="openDiary(2)">
        <view class="diary-card-inner">
          <view class="diary-meta-row">
            <text class="diary-time">10:00</text>
            <view class="diary-tag">#学习</view>
            <text class="diary-emotion-icon">📝</text>
          </view>
          <text class="diary-title font-handwrite">算法课笔记</text>
          <text class="diary-excerpt">红黑树插入删除讲完了，脑子有点绕。课后把代码手写了一遍才理清楚。</text>
        </view>
      </view>

      <!-- ─── 昨天 ─── -->
      <view class="date-divider">
        <view class="divider-line" />
        <text class="divider-label font-handwrite">昨天</text>
        <view class="divider-line" />
      </view>

      <!-- 日记卡：游戏 -->
      <view class="diary-card diary-card-handdrawn" @click="openDiary(3)">
        <view class="diary-card-inner">
          <view class="diary-meta-row">
            <text class="diary-time">22:15</text>
            <view class="diary-tag">#日常</view>
            <text class="diary-emotion-icon">🌙</text>
          </view>
          <text class="diary-title font-handwrite">和室友打了一晚上游戏</text>
          <text class="diary-excerpt">连赢五局，室友说我是平时最认真的一次，哈哈。</text>
        </view>
      </view>

      <!-- 日记卡：图书馆 -->
      <view class="diary-card diary-card-handdrawn" @click="openDiary(4)">
        <view class="diary-card-inner">
          <view class="diary-meta-row">
            <text class="diary-time">15:30</text>
            <view class="diary-tag">#学习</view>
            <text class="diary-emotion-icon">😌</text>
          </view>
          <text class="diary-title font-handwrite">图书馆自习</text>
          <text class="diary-excerpt">在图书馆待了五个小时，终于把数据结构大作业搞完了，状态很好。</text>
        </view>
      </view>

      <!-- ─── 3月21日 周五 ─── -->
      <view class="date-divider">
        <view class="divider-line" />
        <text class="divider-label font-handwrite">3月21日 周五</text>
        <view class="divider-line" />
      </view>

      <!-- 日记卡：早晨跑步 -->
      <view class="diary-card diary-card-handdrawn" @click="openDiary(5)">
        <view class="diary-card-inner">
          <view class="diary-meta-row">
            <text class="diary-time">07:00</text>
            <view class="diary-tag">#运动</view>
            <text class="diary-emotion-icon">💪</text>
          </view>
          <text class="diary-title font-handwrite">晨跑 5km</text>
          <text class="diary-excerpt">天气很好，操场上没什么人，跑完感觉整个人都清醒了，要保持这个习惯。</text>
          <view class="diary-photos">
            <view class="diary-photo-placeholder">
              <text class="photo-icon">🌅</text>
            </view>
            <view class="diary-photo-placeholder">
              <text class="photo-icon">🏃</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 底部留白 -->
      <view class="bottom-spacer" />
    </view>

    <!-- FAB 悬浮写日记按钮 -->
    <view class="fab" @click="goWrite">
      <text class="fab-icon">✏️</text>
    </view>

    <!-- ── 情绪选择弹窗 ── -->
    <view v-if="showEmotionPicker" class="emotion-overlay" @click="showEmotionPicker = false">
      <view class="emotion-sheet" @click.stop>
        <view class="sheet-handle" />
        <text class="sheet-title font-handwrite">今日心情如何？</text>
        <view class="emotion-grid">
          <view
            v-for="em in emotions"
            :key="em.key"
            class="emotion-item"
            :class="{ 'emotion-item--active': todayEmotion.key === em.key }"
            @click="selectEmotion(em)"
          >
            <text class="emotion-emoji">{{ em.emoji }}</text>
            <text class="emotion-label">{{ em.label }}</text>
          </view>
        </view>
        <view class="sheet-confirm" @click="showEmotionPicker = false">
          <text class="sheet-confirm-text">确定</text>
        </view>
      </view>
    </view>

    <!-- ── TabBar ── -->
    <view class="tabbar">
      <view
        v-for="(tab, index) in tabList"
        :key="index"
        class="tabbar-item"
        :class="{
          'tabbar-item--active': index === 0,
          'tabbar-item--write': index === 2
        }"
        @click="switchTab(index)"
      >
        <view v-if="index === 2" class="tabbar-write-btn">
          <text class="tabbar-write-icon">✏️</text>
        </view>
        <template v-else>
          <text class="tabbar-icon-emoji" :class="{ 'tabbar-icon-emoji--active': index === 0 }">
            {{ tab.emoji }}
          </text>
          <text class="tabbar-label" :class="{ 'tabbar-label--active': index === 0 }">
            {{ tab.text }}
          </text>
        </template>
      </view>
    </view>

  </view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// ── 日期 ──
const now = new Date()
const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
const todayLabel = computed(() => {
  const m = now.getMonth() + 1
  const d = now.getDate()
  const w = weekDays[now.getDay()]
  return `${m}月${d}日 ${w}`
})

// ── 情绪 ──
const emotions = [
  { key: 'happy', emoji: '😊', label: '开心' },
  { key: 'calm',  emoji: '😌', label: '平静' },
  { key: 'sad',   emoji: '😔', label: '难过' },
  { key: 'angry', emoji: '😤', label: '烦躁' },
  { key: 'tired', emoji: '😴', label: '疲惫' },
  { key: 'excited', emoji: '🤩', label: '兴奋' },
  { key: 'anxious', emoji: '😰', label: '焦虑' },
  { key: 'satisfied', emoji: '😋', label: '满足' },
  { key: 'grateful', emoji: '🥰', label: '感恩' },
  { key: 'cool',  emoji: '😎', label: '酷酷' },
]
const todayEmotion = ref({ key: 'happy', emoji: '😊', label: '开心' })
const showEmotionPicker = ref(false)

function selectEmotion(em: { key: string; emoji: string; label: string }) {
  todayEmotion.value = em
  uni.showToast({ title: `今天 ${em.label} ${em.emoji}`, icon: 'none' })
}

function openDiary(id: number) {
  uni.showToast({ title: '打开日记详情', icon: 'none' })
}

function goWrite() {
  uni.navigateTo({ url: '/pages/write/index' })
}

function goProfile() {
  uni.switchTab({ url: '/pages/profile/index' })
}

// ── TabBar ──
const tabList = [
  { emoji: '📔', text: '日记' },
  { emoji: '🧭', text: '发现' },
  { emoji: '✏️', text: '写' },
  { emoji: '💬', text: '消息' },
  { emoji: '👤', text: '我的' },
]

function switchTab(index: number) {
  if (index === 0) return
  if (index === 2) { goWrite(); return }
  const paths = [
    '/pages/index/index',
    '/pages/discover/index',
    '/pages/write/index',
    '/pages/messages/index',
    '/pages/profile/index',
  ]
  uni.switchTab({ url: paths[index] })
}
</script>

<style lang="scss">
@import '@/common/styles/handdrawn.scss';

/* ── 容器 ── */
.page {
  position: absolute;
  inset: 0;
  height: 100% !important;
  min-height: 0 !important;
  max-height: 100% !important;
  background: #FDF8F3;
  overflow: hidden;
}

/* ── 顶栏 44px 单行 ── */
.navbar {
  position: absolute;
  top: 0; left: 0; right: 0;
  z-index: 100;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  background: rgba(253, 248, 243, 0.95);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  box-shadow: 0 1px 0 rgba(44, 31, 20, 0.06);
}

.navbar-left { flex: 1; }
.navbar-date {
  font-size: 15px;
  font-weight: 600;
  color: #2C1F14;
}

.navbar-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.navbar-emotion {
  font-size: 22px;
  cursor: pointer;
  transition: transform 0.15s;
  &:active { transform: scale(0.88); }
}

.navbar-avatar {
  width: 30px;
  height: 30px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.avatar-text { font-size: 15px; line-height: 1; }
.avatar-img { width: 100%; height: 100%; border-radius: 9999px; }

/* ── 滚动区 ── */
.page-scroll {
  position: absolute;
  top: 44px;
  left: 0;
  right: 0;
  bottom: 60px;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding: 12px 16px 0;
}

/* ── 日期分隔符 ── */
.date-divider {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 20px 0 12px;
}

.divider-line {
  flex: 1;
  height: 1px;
  background: linear-gradient(90deg, transparent, #D4C4B8, transparent);
}

.divider-label {
  font-size: 13px;
  color: #857268;
  font-weight: 500;
  white-space: nowrap;
  padding: 0 4px;
}

/* ── 日记卡片 ── */
.diary-card {
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 1px 8px rgba(44, 31, 20, 0.06);
  margin-bottom: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
  &:active {
    transform: scale(0.985);
    box-shadow: 0 4px 16px rgba(232, 133, 90, 0.14);
  }
}

.diary-card-inner {
  padding: 14px 14px 14px 20px;
}

.diary-meta-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.diary-time {
  font-size: 12px;
  color: #AE9D92;
  font-family: "DIN Alternate", monospace;
}

.diary-tag {
  font-size: 11px;
  color: #E8855A;
  background: rgba(232, 133, 90, 0.10);
  padding: 2px 8px;
  border-radius: 9999px;
  font-weight: 500;
}

.diary-emotion-icon {
  font-size: 16px;
  margin-left: auto;
}

.diary-title {
  font-size: 16px;
  font-weight: 600;
  color: #2C1F14;
  display: block;
  margin-bottom: 5px;
  line-height: 1.3;
}

.diary-excerpt {
  font-size: 13px;
  color: #857268;
  line-height: 1.6;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.diary-photos {
  display: flex;
  gap: 8px;
  margin-top: 10px;
  overflow-x: auto;
}

.diary-photo-placeholder {
  flex-shrink: 0;
  width: 72px;
  height: 72px;
  border-radius: 10px;
  background: linear-gradient(135deg, #FDF0E8, #F7CDB5);
  display: flex;
  align-items: center;
  justify-content: center;
}

.photo-icon { font-size: 28px; }

/* ── AI 洞察卡 ── */
.ai-insight-card {
  background: rgba(232, 133, 90, 0.06);
  border: 1px solid rgba(232, 133, 90, 0.18);
  border-radius: 16px;
  padding: 14px 16px;
  margin-bottom: 10px;
}

.ai-insight-header {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;
}

.ai-icon { font-size: 16px; }
.ai-insight-title {
  font-size: 13px;
  font-weight: 600;
  color: #E8855A;
}

.ai-insight-text {
  font-size: 14px;
  color: #4A3628;
  line-height: 1.65;
  display: block;
  margin-bottom: 6px;
}

.ai-insight-sub {
  font-size: 12px;
  color: #AE9D92;
}

/* ── FAB ── */
.fab {
  position: absolute;
  right: 20px;
  bottom: 76px;  /* tabbar 60px + 16px 间距 */
  z-index: 500;
  width: 52px;
  height: 52px;
  border-radius: 9999px;
  background: linear-gradient(135deg, #E8855A 0%, #F0A882 100%);
  box-shadow: 0 6px 20px rgba(232, 133, 90, 0.42);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
  &:active {
    transform: scale(0.90);
    box-shadow: 0 3px 10px rgba(232, 133, 90, 0.28);
  }
}

.fab-icon {
  font-size: 22px;
  line-height: 1;
  filter: brightness(0) invert(1);
}

/* ── 情绪选择弹窗 ── */
.emotion-overlay {
  position: fixed;
  inset: 0;
  z-index: 2000;
  background: rgba(44, 31, 20, 0.35);
  display: flex;
  align-items: flex-end;
}

.emotion-sheet {
  width: 100%;
  background: #FDF8F3;
  border-radius: 24px 24px 0 0;
  padding: 16px 20px 32px;
}

.sheet-handle {
  width: 40px;
  height: 4px;
  background: #D4C4B8;
  border-radius: 9999px;
  margin: 0 auto 16px;
}

.sheet-title {
  font-size: 18px;
  font-weight: 600;
  color: #2C1F14;
  display: block;
  margin-bottom: 20px;
  text-align: center;
}

.emotion-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: center;
  margin-bottom: 20px;
}

.emotion-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  padding: 10px 14px;
  border-radius: 14px;
  background: #FFFFFF;
  border: 2px solid transparent;
  transition: all 0.15s;
  &:active { transform: scale(0.92); }
}

.emotion-item--active {
  border-color: #E8855A;
  background: rgba(232, 133, 90, 0.08);
}

.emotion-emoji { font-size: 28px; }
.emotion-label {
  font-size: 12px;
  color: #857268;
  font-weight: 500;
}

.sheet-confirm {
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 14px;
  padding: 14px;
  text-align: center;
  cursor: pointer;
  &:active { opacity: 0.85; }
}

.sheet-confirm-text {
  font-size: 16px;
  color: #FFFFFF;
  font-weight: 600;
}

/* ── 底部留白 ── */
.bottom-spacer { height: 20px; }

/* ── TabBar ── */
.tabbar {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  z-index: 200;
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
  transition: transform 0.15s;
}

.tabbar-item--write:active .tabbar-write-btn { transform: scale(0.90); }

.tabbar-write-icon {
  font-size: 22px;
  filter: brightness(0) invert(1);
}

.tabbar-icon-emoji {
  font-size: 20px;
  opacity: 0.45;
  line-height: 1;
  transition: opacity 0.2s;
}

.tabbar-icon-emoji--active {
  opacity: 1;
}

.tabbar-label {
  font-size: 11px;
  color: #AE9D92;
  font-weight: 500;
  line-height: 1;
}

.tabbar-label--active { color: #E8855A; }

.font-handwrite {
  font-family: 'ZcoolKuaiLe', 'ZCOOL KuaiLe', 'STXingkai', 'KaiTi', 'PingFang SC', sans-serif !important;
  letter-spacing: 1px;
}
</style>
