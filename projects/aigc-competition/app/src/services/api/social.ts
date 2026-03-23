import { USE_MOCK, API_BASE_URL } from '../config'
import * as mock from '../mock/social'

export interface Match {
  id: string
  nickname: string
  avatar: string
  school: string
  commonTags: string[]
  matchedAt: number
}

export interface MatchRequest {
  id: string
  fromUid: string
  toUid: string
  status: 'pending' | 'accepted' | 'rejected'
  createdAt: number
}

export interface Message {
  id: string
  matchId: string
  fromUid: string
  content: string
  timestamp: number
}

export async function getMatches(): Promise<Match[]> {
  if (USE_MOCK) return mock.getMatches()
  const res = await uni.request({ url: `${API_BASE_URL}/social/matches` })
  return res.data as any
}

export async function createMatchRequest(data: Partial<MatchRequest>): Promise<MatchRequest> {
  if (USE_MOCK) return mock.createMatchRequest(data)
  const res = await uni.request({ url: `${API_BASE_URL}/social/match-requests`, method: 'POST', data })
  return res.data as any
}

export async function getMessages(): Promise<Message[]> {
  if (USE_MOCK) return mock.getMessages()
  const res = await uni.request({ url: `${API_BASE_URL}/social/messages` })
  return res.data as any
}
