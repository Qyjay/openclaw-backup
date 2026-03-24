import type { Match, MatchRequest, Message } from '../api/social'

export function getMatches(): Match[] {
  return [
    {
      id: 'm1',
      nickname: '小鹿',
      avatar: 'https://picsum.photos/seed/match1/200/200',
      school: '天津大学',
      commonTags: ['学习', '留学'],
      matchedAt: Date.now() - 86400000 * 3,
    },
    {
      id: 'm2',
      nickname: '星空',
      avatar: 'https://picsum.photos/seed/match2/200/200',
      school: '南开大学',
      commonTags: ['雅思', '心情'],
      matchedAt: Date.now() - 86400000 * 7,
    },
  ]
}

export function createMatchRequest(data: Partial<MatchRequest>): MatchRequest {
  return {
    id: `mr${Date.now()}`,
    fromUid: data.fromUid ?? 'me',
    toUid: data.toUid ?? '',
    status: 'pending',
    createdAt: Date.now(),
  }
}

export function getMessages(): Message[] {
  return []
}
