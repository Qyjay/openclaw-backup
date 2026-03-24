import { USE_MOCK, API_BASE_URL } from '../config'
import * as mock from '../mock/user'

export interface UserProfile {
  name: string
  school: string
  major: string
  level: number
  diaryCount: number
  streakDays: number
  pomodoroCount: number
  avatar: string
}

export interface Achievement {
  id: string
  title: string
  description: string
  icon: string
  unlocked: boolean
  unlockedAt?: number
}

export interface GrowthData {
  diaries: { date: string; count: number }[]
  emotions: { label: string; count: number }[]
  tags: { label: string; count: number }[]
  pomodoros: { date: string; count: number }[]
  streak: number[]
}

export interface Settings {
  theme: 'light' | 'dark'
  notifications: boolean
  autoBGM: boolean
  diaryPrivacy: 'private' | 'friends' | 'public'
  language: string
}

export interface SemesterReport {
  totalDiaries: number
  totalPomodoros: number
  topEmotions: { label: string; count: number }[]
  topTags: { label: string; count: number }[]
  writingTime: number
  avgEmotion: number
  streak: number
  achievements: number
  highlights: string[]
}

export async function getUserProfile(): Promise<UserProfile> {
  if (USE_MOCK) return mock.getUserProfile()
  const res = await uni.request({ url: `${API_BASE_URL}/user/profile` })
  return res.data as any
}

export async function getAgentPortrait(): Promise<string> {
  if (USE_MOCK) return mock.getAgentPortrait()
  const res = await uni.request({ url: `${API_BASE_URL}/user/agent-portrait` })
  return res.data as any
}

export async function getGrowthData(): Promise<GrowthData> {
  if (USE_MOCK) return mock.getGrowthData()
  const res = await uni.request({ url: `${API_BASE_URL}/user/growth` })
  return res.data as any
}

export async function getAchievements(): Promise<Achievement[]> {
  if (USE_MOCK) return mock.getAchievements()
  const res = await uni.request({ url: `${API_BASE_URL}/user/achievements` })
  return res.data as any
}

export async function getSettings(): Promise<Settings> {
  if (USE_MOCK) return mock.getSettings()
  const res = await uni.request({ url: `${API_BASE_URL}/user/settings` })
  return res.data as any
}

export async function updateSettings(data: Partial<Settings>): Promise<Settings> {
  if (USE_MOCK) return mock.updateSettings(data)
  const res = await uni.request({ url: `${API_BASE_URL}/user/settings`, method: 'POST', data })
  return res.data as any
}

export async function getSemesterReport(): Promise<SemesterReport> {
  if (USE_MOCK) return mock.getSemesterReport()
  const res = await uni.request({ url: `${API_BASE_URL}/user/semester-report` })
  return res.data as any
}
