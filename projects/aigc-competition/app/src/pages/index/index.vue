<template>
  <view class="page">
    <CustomNavBar
      title="日记"
      left-icon="avatar"
      right-icon="🔍"
      @left-click="drawerVisible = true"
      @right-click="onSearch"
    />

    <!-- 侧边栏 -->
    <SideDrawer v-model:visible="drawerVisible" />

    <!-- 主内容滚动区 -->
    <scroll-view
      class="main-scroll"
      scroll-y
      :refresher-enabled="true"
      :refresher-triggered="refreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="onLoadMore"
    >
      <!-- ── AI 早安/晚安卡片 ── -->
      <view v-if="greetingCardVisible" class="greeting-card">
        <view class="greeting-inner" :class="isMorning ? 'greeting-morning' : 'greeting-night'">
          <view class="greeting-header">
            <text class="greeting-icon">{{ isMorning ? '☀️' : '🌙' }}</text>
            <text class="greeting-title">{{ isMorning ? '早上好 Kylin！' : '晚安 Kylin 🌙' }}</text>
            <view class="greeting-close" @click="greetingCardVisible = false">
              <text class="close-icon">✕</text>
            </view>
          </view>

          <template v-if="isMorning">
            <text class="greeting-desc">今天有数据结构课，雅思倒计时 43 天</text>
            <view class="greeting-todo">
              <text class="todo-icon">📋</text>
              <text class="todo-label">今日待办 (3)</text>
              <text class="todo-arrow"> 查看详情 → </text>
            </view>
          </template>

          <template v-else>
            <text class="greeting-desc">今日共写了 2 篇日记，情绪以😊开心为主</text>
            <text class="greeting-night-tip">早点休息，明天又是新的一天 ✨</text>
          </template>
        </view>
      </view>

      <!-- ── 日记列表 ── -->
      <view v-if="!loading || diaries.length > 0">
        <template v-for="(group, gIndex) in groupedDiaries" :key="gIndex">
          <!-- 日期分隔符 -->
          <view class="date-separator">
            <view class="sep-line" />
            <text class="sep-label">{{ group.label }}</text>
            <view class="sep-line" />
          </view>

          <!-- 日期下的日记卡片 -->
          <view
            v-for="(diary, dIndex) in group.diaries"
            :key="diary.id"
          >
            <!-- AI 洞察卡：穿插在第2和第5条日记后 -->
            <view v-if="shouldShowInsight(gIndex, dIndex)" class="ai-insight-card">
              <view class="insight-header">
                <text class="insight-icon">✨</text>
                <text class="insight-title">AI 洞察</text>
              </view>
              <text class="insight-text">{{ getInsightText(gIndex, dIndex) }}</text>
            </view>

            <DiaryCard
              :diary="diary"
              @click="goDetail"
              @tag-click="onTagClick"
              @action-click="onActionClick"
            />
          </view>
        </template>

        <!-- 加载状态 -->
        <view v-if="loading" class="loading-more">
          <text class="loading-text">加载中...</text>
        </view>
        <view v-else-if="noMore" class="loading-more">
          <text class="loading-text">没有更多日记了</text>
        </view>
      </view>

      <!-- ── 空状态 ── -->
      <view v-if="!loading && diaries.length === 0" class="empty-state">
        <text class="empty-emoji">📸</text>
        <text class="empty-title">还没有日记</text>
        <text class="empty-sub">拍张照片，开始你的第一篇日记</text>
        <view class="empty-btn" @click="goWrite">
          <text class="empty-btn-text">写日记</text>
        </view>
      </view>

      <view class="bottom-spacer" />
    </scroll-view>

    <!-- TabBar -->
    <TabBar :current="0" />
  </view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import CustomNavBar from '@/components/CustomNavBar.vue'
import SideDrawer from '@/components/SideDrawer.vue'
import DiaryCard from '@/components/DiaryCard.vue'
import TabBar from '@/components/TabBar.vue'
import { getDiaries } from '@/services/api/diary'
import type { Diary } from '@/services/api/diary'

const drawerVisible = ref(false)
const diaries = ref<Diary[]>([])
const loading = ref(false)
const refreshing = ref(false)
const page = ref(1)
const noMore = ref(false)

// ── 时间判断 ──
const now = new Date()
const hour = now.getHours()
const isMorning = hour >= 6 && hour < 12
const greetingCardVisible = ref(true)

// ── 加载数据 ──
onMounted(async () => {
  await loadDiaries(1)
})

async function loadDiaries(p: number, append = false) {
  loading.value = true
  const { list } = await getDiaries(p, 20)
  if (append) {
    diaries.value.push(...list)
  } else {
    diaries.value = list
  }
  noMore.value = list.length < 20
  loading.value = false
}

async function onRefresh() {
  refreshing.value = true
  page.value = 1
  noMore.value = false
  await loadDiaries(1)
  refreshing.value = false
  uni.showToast({ title: '刷新成功', icon: 'success' })
}

async function onLoadMore() {
  if (noMore.value || loading.value) return
  page.value++
  await loadDiaries(page.value, true)
}

// ── 按日期分组 ──
function getDateLabel(ts: number): string {
  const d = new Date(ts)
  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(yesterday.getDate() - 1)

  const isToday = d.toDateString() === today.toDateString()
  const isYesterday = d.toDateString() === yesterday.toDateString()

  if (isToday) return '今天'
  if (isYesterday) return '昨天'

  const m = d.getMonth() + 1
  const day = d.getDate()
  const w = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][d.getDay()]
  return `${m}月${day}日 ${w}`
}

interface DiaryGroup {
  label: string
  diaries: Diary[]
}

const groupedDiaries = computed<DiaryGroup[]>(() => {
  const map = new Map<string, Diary[]>()
  const sorted = [...diaries.value].sort((a, b) => b.createdAt - a.createdAt)

  for (const diary of sorted) {
    const label = getDateLabel(diary.createdAt)
    if (!map.has(label)) map.set(label, [])
    map.get(label)!.push(diary)
  }

  return Array.from(map.entries()).map(([label, list]) => ({ label, diaries: list }))
})

// ── AI 洞察：穿插在第2和第5条 ──
function shouldShowInsight(groupIndex: number, diaryIndex: number): boolean {
  // 在每组第2条(索引1)和第5条(索引4)后插入
  return diaryIndex === 1 || diaryIndex === 4
}

const insightTexts = [
  '你连续 3 天心情不错，最近爱写美食日记 📝',
  '最近学习相关的日记变多了，雅思备考进入关键期 💪',
  '本周你记录了 2 次社交活动，社交指数稳步上升 🌱',
  '根据你的日记分析，这周的情绪波动较小，整体状态良好 ✨',
]

function getInsightText(groupIndex: number, diaryIndex: number): string {
  const idx = (groupIndex * 2 + (diaryIndex === 1 ? 0 : 1)) % insightTexts.length
  return insightTexts[idx]
}

// ── 跳转 ──
function goDetail(id: string) {
  uni.navigateTo({ url: `/pages/diary/detail?id=${id}` })
}

function goWrite() {
  uni.navigateTo({ url: '/pages/write/index' })
}

function onSearch() {
  uni.showToast({ title: '搜索功能开发中', icon: 'none' })
}

function onTagClick(tag: string) {
  uni.showToast({ title: `#${tag}`, icon: 'none' })
}

function onActionClick(payload: { action: string; diaryId: string }) {
  const map: Record<string, string> = {
    comic: '/pages/diary/comic',
    share: '/pages/diary/share-card',
    bgm: '',
    tts: '',
  }
  if (payload.action === 'bgm' || payload.action === 'tts') {
    uni.showToast({ title: `${payload.action === 'bgm' ? 'BGM' : '有声朗读'}功能开发中`, icon: 'none' })
  } else {
    uni.navigateTo({ url: `${map[payload.action]}?id=${payload.diaryId}` })
  }
}
</script>

<style lang="scss" scoped>
.page {
  position: absolute;
  inset: 0;
  background: #FDF8F3;
  display: flex;
  flex-direction: column;
}

.main-scroll {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  padding-top: 88rpx; // statusBar + navBar
  padding-bottom: 60px;
}

/* ── AI 早安/晚安卡片 ── */
.greeting-card {
  margin: 16rpx 24rpx 0;
}

.greeting-inner {
  border-radius: 24rpx;
  padding: 24rpx;
  position: relative;
}

.greeting-morning {
  background: linear-gradient(135deg, #FDF0E8, #F7CDB5);
}

.greeting-night {
  background: linear-gradient(135deg, #E8E0F0, #D4C4E8);
}

.greeting-header {
  display: flex;
  align-items: center;
  gap: 8rpx;
  margin-bottom: 8rpx;
}

.greeting-icon {
  font-size: 36rpx;
}

.greeting-title {
  font-size: 32rpx;
  font-weight: 600;
  color: #2C1F14;
  flex: 1;
}

.greeting-close {
  padding: 4rpx 8rpx;
  &:active { opacity: 0.6; }
}

.close-icon {
  font-size: 24rpx;
  color: #4A3628;
}

.greeting-desc {
  font-size: 28rpx;
  color: #4A3628;
  display: block;
  margin-bottom: 12rpx;
}

.greeting-todo {
  display: flex;
  align-items: center;
  gap: 8rpx;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 12rpx;
  padding: 10rpx 16rpx;
}

.todo-icon { font-size: 28rpx; }
.todo-label { font-size: 26rpx; color: #4A3628; flex: 1; }
.todo-arrow { font-size: 24rpx; color: #E8855A; }

.greeting-night-tip {
  font-size: 26rpx;
  color: #4A3628;
}

/* ── 日期分隔符 ── */
.date-separator {
  display: flex;
  align-items: center;
  gap: 12rpx;
  margin: 24rpx 24rpx 12rpx;
}

.sep-line {
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

.sep-label {
  font-size: 24rpx;
  color: #AE9D92;
  white-space: nowrap;
  padding: 0 4rpx;
}

/* ── AI 洞察卡 ── */
.ai-insight-card {
  background: rgba(232, 133, 90, 0.07);
  border: 1px solid rgba(232, 133, 90, 0.16);
  border-radius: 20rpx;
  padding: 20rpx 24rpx;
  margin-bottom: 24rpx;
}

.insight-header {
  display: flex;
  align-items: center;
  gap: 6rpx;
  margin-bottom: 8rpx;
}

.insight-icon { font-size: 28rpx; }

.insight-title {
  font-size: 26rpx;
  font-weight: 600;
  color: #E8855A;
}

.insight-text {
  font-size: 28rpx;
  color: #4A3628;
  line-height: 1.6;
  display: block;
}

/* ── 加载状态 ── */
.loading-more {
  display: flex;
  justify-content: center;
  padding: 24rpx;
}

.loading-text {
  font-size: 26rpx;
  color: #AE9D92;
}

/* ── 空状态 ── */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 120rpx 48rpx 80rpx;
  gap: 12rpx;
}

.empty-emoji {
  font-size: 96rpx;
  margin-bottom: 8rpx;
}

.empty-title {
  font-size: 36rpx;
  font-weight: 600;
  color: #2C1F14;
}

.empty-sub {
  font-size: 28rpx;
  color: #AE9D92;
  text-align: center;
  line-height: 1.5;
}

.empty-btn {
  margin-top: 24rpx;
  background: linear-gradient(135deg, #E8855A, #F0A882);
  border-radius: 24rpx;
  padding: 16rpx 48rpx;
  box-shadow: 0 4rpx 16rpx rgba(232, 133, 90, 0.3);
  &:active { opacity: 0.85; }
}

.empty-btn-text {
  font-size: 30rpx;
  color: #FFFFFF;
  font-weight: 600;
}

/* ── 底部留白 ── */
.bottom-spacer {
  height: 24rpx;
}
</style>
