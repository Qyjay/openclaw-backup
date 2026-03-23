import { USE_MOCK, API_BASE_URL } from '../config'
import * as mock from '../mock/study'

export interface Pomodoro {
  id: string
  task: string
  subject: string
  duration: number
  completedAt?: number
  createdAt: number
}

export interface Todo {
  id: string
  content: string
  completed: boolean
  priority: 'low' | 'medium' | 'high'
  createdAt: number
}

export async function getPomodoros(): Promise<Pomodoro[]> {
  if (USE_MOCK) return mock.getPomodoros()
  const res = await uni.request({ url: `${API_BASE_URL}/study/pomodoros` })
  return res.data as any
}

export async function createPomodoro(data: Partial<Pomodoro>): Promise<Pomodoro> {
  if (USE_MOCK) return mock.createPomodoro(data)
  const res = await uni.request({ url: `${API_BASE_URL}/study/pomodoros`, method: 'POST', data })
  return res.data as any
}

export async function completePomodoro(id: string): Promise<void> {
  if (USE_MOCK) return mock.completePomodoro(id)
  await uni.request({ url: `${API_BASE_URL}/study/pomodoros/${id}/complete`, method: 'POST' })
}

export async function getTodos(): Promise<Todo[]> {
  if (USE_MOCK) return mock.getTodos()
  const res = await uni.request({ url: `${API_BASE_URL}/study/todos` })
  return res.data as any
}

export async function createTodo(data: Partial<Todo>): Promise<Todo> {
  if (USE_MOCK) return mock.createTodo(data)
  const res = await uni.request({ url: `${API_BASE_URL}/study/todos`, method: 'POST', data })
  return res.data as any
}

export async function toggleTodo(id: string): Promise<Todo> {
  if (USE_MOCK) return mock.toggleTodo(id)
  const res = await uni.request({ url: `${API_BASE_URL}/study/todos/${id}/toggle`, method: 'POST' })
  return res.data as any
}
