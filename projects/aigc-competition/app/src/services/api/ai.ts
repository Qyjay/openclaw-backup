import { USE_MOCK, API_BASE_URL } from '../config'
import * as mock from '../mock/ai'

export interface Fortune {
  overall: number
  study: number
  social: number
  health: number
  tip: string
  luckyColor: string
  luckyNumber: number
}

export interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
  timestamp: number
}

export async function chat(messages: ChatMessage[]): Promise<string> {
  if (USE_MOCK) return mock.chat(messages)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/chat`, method: 'POST', data: { messages } })
  return res.data as any
}

export async function generateFortune(): Promise<Fortune> {
  if (USE_MOCK) return mock.generateFortune()
  const res = await uni.request({ url: `${API_BASE_URL}/ai/fortune` })
  return res.data as any
}

export async function generateComic(diaryId: string, style: string): Promise<string> {
  if (USE_MOCK) return mock.generateComic(diaryId, style)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/comic`, method: 'POST', data: { diaryId, style } })
  return res.data as any
}

export async function generateShareCard(diaryId: string, template: string): Promise<string> {
  if (USE_MOCK) return mock.generateShareCard(diaryId, template)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/share-card`, method: 'POST', data: { diaryId, template } })
  return res.data as any
}

export async function generateBGM(diaryId: string): Promise<string> {
  if (USE_MOCK) return mock.generateBGM(diaryId)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/bgm`, method: 'POST', data: { diaryId } })
  return res.data as any
}

export async function textToSpeech(text: string, voice: string): Promise<string> {
  if (USE_MOCK) return mock.textToSpeech(text, voice)
  const res = await uni.request({ url: `${API_BASE_URL}/ai/tts`, method: 'POST', data: { text, voice } })
  return res.data as any
}

export async function generateNovelChapter(): Promise<string> {
  if (USE_MOCK) return mock.generateNovelChapter()
  const res = await uni.request({ url: `${API_BASE_URL}/ai/novel-chapter`, method: 'POST' })
  return res.data as any
}
