import { USE_MOCK, API_BASE_URL } from '../config'
import * as mock from '../mock/diary'

export interface Diary {
  id: string
  content: string
  images: string[]
  emotion: { emoji: string; label: string; score: number }
  tags: string[]
  location: string
  weather: string
  style: string
  createdAt: number
  hasComic: boolean
  hasBGM: boolean
}

export async function getDiaries(page = 1, pageSize = 10): Promise<{ list: Diary[]; total: number }> {
  if (USE_MOCK) return mock.getDiaries(page, pageSize)
  const res = await uni.request({ url: `${API_BASE_URL}/diaries?page=${page}&pageSize=${pageSize}` })
  return res.data as any
}

export async function getDiaryDetail(id: string): Promise<Diary> {
  if (USE_MOCK) return mock.getDiaryDetail(id)
  const res = await uni.request({ url: `${API_BASE_URL}/diaries/${id}` })
  return res.data as any
}

export async function createDiary(data: Partial<Diary>): Promise<Diary> {
  if (USE_MOCK) return mock.createDiary(data)
  const res = await uni.request({ url: `${API_BASE_URL}/diaries`, method: 'POST', data })
  return res.data as any
}

export async function generateDiaryAI(images: string[], text: string, style: string): Promise<string> {
  if (USE_MOCK) return mock.generateDiaryAI(images, text, style)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/generate-diary`, method: 'POST', data: { images, text, style } })
  return res.data as any
}
