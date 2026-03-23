import type { Fortune, ChatMessage } from '../api/ai'

export const mockFortune: Fortune = {
  overall: 4,
  study: 4,
  social: 5,
  health: 3,
  tip: '今天适合去图书馆',
  luckyColor: '天空蓝',
  luckyNumber: 7,
}

const chatHistory: ChatMessage[] = [
  { role: 'user', content: '最近感觉压力好大，雅思和留学申请同时进行有点喘不过气来', timestamp: Date.now() - 3600000 * 8 },
  { role: 'assistant', content: '我理解这种感觉！多线作战确实很累。不过你想想，每完成一个任务就是离目标更近一步。把大目标拆成小目标会轻松很多哦～', timestamp: Date.now() - 3600000 * 7 },
  { role: 'user', content: '可是我总是拖延怎么办...每次计划好要学习，结果刷手机就过去了好几个小时', timestamp: Date.now() - 3600000 * 6 },
  { role: 'assistant', content: '试试"两分钟法则"！告诉自己只学两分钟，一般开始后就停不下来了。另外可以把手机放到另一个房间，或者用Forest这类专注APP来阻断干扰～', timestamp: Date.now() - 3600000 * 5 },
  { role: 'user', content: '哈哈好的！对了，你觉得我申请港大还是新加坡国立比较好？', timestamp: Date.now() - 3600000 * 4 },
  { role: 'assistant', content: '两个都是很棒的选择！港大离内地近，文化差异小；NUS在QS排名更靠前，工科方向很强。建议根据专业排名来选，另外看看哪个城市的 生活成本更适合你～', timestamp: Date.now() - 3600000 * 3 },
  { role: 'user', content: '有道理！我再研究研究。谢谢你呀，今天聊完心情好多了', timestamp: Date.now() - 3600000 * 2 },
  { role: 'assistant', content: '不客气！记住，你已经很努力了，偶尔休息一下也是正常的。保持好节奏，相信自己，一定可以拿到理想offer的！🍀', timestamp: Date.now() - 3600000 * 1 },
  { role: 'user', content: '今天做了套雅思阅读全对了！', timestamp: Date.now() - 3600000 * 0.5 },
  { role: 'assistant', content: '太棒了！！！🎉 这就是你努力的回报！继续保持这个状态，7.5分指日可待！', timestamp: Date.now() - 3600000 * 0.3 },
]

export function chat(messages: ChatMessage[]): string {
  if (messages.length === 0) return '你好呀！有什么想聊的吗？'
  const lastMsg = messages[messages.length - 1]
  if (lastMsg.content.includes('雅思') || lastMsg.content.includes('阅读')) {
    return '加油！雅思一定能过的！'
  }
  if (lastMsg.content.includes('谢谢') || lastMsg.content.includes('开心')) {
    return '很开心能帮到你！记得每天都要元气满满哦～'
  }
  return '我理解你的感受！不管发生什么，都要好好照顾自己呀。'
}

export function generateFortune(): Fortune {
  return mockFortune
}

export function generateComic(diaryId: string, style: string): string {
  return `https://picsum.photos/seed/comic${diaryId}/600/800`
}

export function generateShareCard(diaryId: string, template: string): string {
  return `https://picsum.photos/seed/share${diaryId}/600/400`
}

export function generateBGM(diaryId: string): string {
  return 'https://example.com/bgm/placeholder.mp3'
}

export function textToSpeech(text: string, voice: string): string {
  return 'https://example.com/tts/placeholder.mp3'
}

export function generateNovelChapter(): string {
  return '清晨的阳光透过窗帘洒进房间，我揉了揉眼睛，看了眼手机——今天是考研出分的日子...'
}
