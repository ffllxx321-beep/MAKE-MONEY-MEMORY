import { LocalStore } from './LocalStore'

export class InMemoryStore implements LocalStore {
  private data: Map<string, Object> = new Map()

  get<T>(key: string, fallback: T): T {
    const value = this.data.get(key)
    return (value as T) ?? fallback
  }

  set<T>(key: string, value: T): void {
    this.data.set(key, value as Object)
  }

  remove(key: string): void {
    this.data.delete(key)
  }
}
