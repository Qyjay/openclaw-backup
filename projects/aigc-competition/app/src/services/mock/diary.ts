import type { Diary } from '../api/diary'

const now = Date.now()
const day = 86400000

export const mockDiaries: Diary[] = [
  {
    id: '1',
    content: '今天终于把雅思阅读真题做完了！第三篇居然全对，开心到飞起～晚上吃了妈妈做的红烧排骨，治愈一切疲惫。',
    images: ['https://picsum.photos/seed/diary1/400/300', 'https://picsum.photos/seed/diary1b/400/300'],
    emotion: { emoji: '😊', label: '开心', score: 92 },
    tags: ['学习', '美食'],
    location: '南开大学图书馆',
    weather: '☀️ 晴',
    style: '治愈系',
    createdAt: now - 1 * day,
    hasComic: true,
    hasBGM: false,
  },
  {
    id: '2',
    content: '申请季的压力真的好大...看着周围的同学都拿到了offer，自己却还在等消息。刷了一套TPO，感觉听力正确率又下滑了。',
    images: [],
    emotion: { emoji: '😢', label: '焦虑', score: 28 },
    tags: ['学习', '心情'],
    location: '宿舍',
    weather: '🌧️ 阴',
    style: '日记式',
    createdAt: now - 2 * day,
    hasComic: false,
    hasBGM: true,
  },
  {
    id: '3',
    content: '和室友去天大了！第一次在校外吃火锅，聊了好多关于未来的规划。虽然有点小争执，但总体是很棒的一天。',
    images: ['https://picsum.photos/seed/diary3/400/300', 'https://picsum.photos/seed/diary3b/400/300', 'https://picsum.photos/seed/diary3c/400/300'],
    emotion: { emoji: '🥰', label: '幸福', score: 88 },
    tags: ['社交', '美食'],
    location: '天津大学旁火锅店',
    weather: '☀️ 晴',
    style: '故事型',
    createdAt: now - 3 * day,
    hasComic: true,
    hasBGM: true,
  },
  {
    id: '4',
    content: '刷了3个小时算法题，终于把二分查找的边界条件搞清楚了！太不容易了，感觉脑子要烧掉了。',
    images: ['https://picsum.photos/seed/diary4/400/300'],
    emotion: { emoji: '😤', label: '激动', score: 76 },
    tags: ['学习'],
    location: '南开大学图书馆',
    weather: '🌤️ 多云',
    style: '热血型',
    createdAt: now - 4 * day,
    hasComic: false,
    hasBGM: false,
  },
  {
    id: '5',
    content: '今天什么都没干，就在宿舍躺了一天。追完了《繁花》，哭得稀里哗啦的。王家卫的光影美学真的太绝了。',
    images: [],
    emotion: { emoji: '😴', label: '慵懒', score: 55 },
    tags: ['心情', '娱乐'],
    location: '宿舍',
    weather: '☁️ 阴',
    style: '日记式',
    createdAt: now - 5 * day,
    hasComic: false,
    hasBGM: true,
  },
  {
    id: '6',
    content: '跑了5公里！天气虽然冷但跑起来一点都不冷，出一身汗的感觉太爽了。感觉整个人都轻快了。',
    images: ['https://picsum.photos/seed/diary6/400/300'],
    emotion: { emoji: '😂', label: '畅快', score: 85 },
    tags: ['运动'],
    location: '操场',
    weather: '🌤️ 多云',
    style: '活力型',
    createdAt: now - 6 * day,
    hasComic: false,
    hasBGM: false,
  },
  {
    id: '7',
    content: '实习第一天！mentor人超好，带我认识了整个团队。虽然还不太懂业务流程，但感觉很有意思。',
    images: ['https://picsum.photos/seed/diary7/400/300'],
    emotion: { emoji: '😊', label: '期待', score: 80 },
    tags: ['心情'],
    location: '华苑科技园',
    weather: '☀️ 晴',
    style: '治愈系',
    createdAt: now - 7 * day,
    hasComic: false,
    hasBGM: false,
  },
  {
    id: '8',
    content: '和社团的朋友们一起去唱歌了！好久没这么大声唱过了，虽然跑调跑得厉害但是超级开心。',
    images: ['https://picsum.photos/seed/diary8/400/300', 'https://picsum.photos/seed/diary8b/400/300'],
    emotion: { emoji: '🥰', label: '幸福', score: 90 },
    tags: ['社交', '娱乐'],
    location: '大悦城KTV',
    weather: '🌙 夜晚',
    style: '故事型',
    createdAt: now - 8 * day,
    hasComic: true,
    hasBGM: true,
  },
  {
    id: '9',
    content: '雅思出分了！overall 7.0，虽然听力只有6.5但已经够申请大多数学校了！一年的努力终于有回报了呜呜呜。',
    images: ['https://picsum.photos/seed/diary9/400/300'],
    emotion: { emoji: '😊', label: '开心', score: 95 },
    tags: ['学习', '心情'],
    location: '宿舍',
    weather: '☀️ 晴',
    style: '日记式',
    createdAt: now - 10 * day,
    hasComic: true,
    hasBGM: false,
  },
  {
    id: '10',
    content: '今天做了一个很特别的梦，梦到自己拿到了梦校的offer，整个人都在发光。醒来觉得未来还是有希望的。',
    images: [],
    emotion: { emoji: '😊', label: '温暖', score: 72 },
    tags: ['心情'],
    location: '宿舍',
    weather: '☀️ 晴',
    style: '治愈系',
    createdAt: now - 12 * day,
    hasComic: false,
    hasBGM: true,
  },
  {
    id: '11',
    content: '写完了一整章留学文书！虽然改了十几遍但感觉还是不太满意，算了先发给中介看看反馈吧。',
    images: [],
    emotion: { emoji: '😤', label: '疲惫', score: 58 },
    tags: ['学习'],
    location: '图书馆五楼',
    weather: '🌧️ 小雨',
    style: '日记式',
    createdAt: now - 14 * day,
    hasComic: false,
    hasBGM: false,
  },
  {
    id: '12',
    content: '发现了一家超级好吃的日料！三文鱼寿司入口即化，老板是日本人还送了我们玉子烧。必须收藏！',
    images: ['https://picsum.photos/seed/diary12/400/300', 'https://picsum.photos/seed/diary12b/400/300'],
    emotion: { emoji: '😊', label: '满足', score: 88 },
    tags: ['美食'],
    location: '时代奥城日料店',
    weather: '☀️ 晴',
    style: '故事型',
    createdAt: now - 16 * day,
    hasComic: false,
    hasBGM: false,
  },
]

export function getDiaries(page = 1, pageSize = 10) {
  const start = (page - 1) * pageSize
  const list = mockDiaries.slice(start, start + pageSize)
  return { list, total: mockDiaries.length }
}

export function getDiaryDetail(id: string) {
  return mockDiaries.find(d => d.id === id) ?? mockDiaries[0]
}

export function createDiary(data: Partial<Diary>): Diary {
  const newDiary: Diary = {
    id: String(Date.now()),
    content: data.content ?? '',
    images: data.images ?? [],
    emotion: data.emotion ?? { emoji: '😊', label: '平静', score: 50 },
    tags: data.tags ?? [],
    location: data.location ?? '',
    weather: data.weather ?? '',
    style: data.style ?? '日记式',
    createdAt: Date.now(),
    hasComic: false,
    hasBGM: false,
  }
  mockDiaries.unshift(newDiary)
  return newDiary
}

export function generateDiaryAI(images: string[], text: string, style: string): string {
  return `这是一篇${style}风格的日记。今天阳光很好，空气中弥漫着淡淡的花香。`
}
