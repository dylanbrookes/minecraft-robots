// just a sorted linked list
type Item<T> = {
  value: T,
  next: Item<T> | null,
};

export default class PriorityList<T> implements Iterable<[number, T]> {
  private head: Item<T> | null = null;
  private _size: number = 0;

  constructor(private comparator = (a: T, b: T) => a > b) { }

  get size(): number {
    return this._size;
  }
  isEmpty(): boolean {
    return this.size === 0;
  }
  [Symbol.iterator](): Iterator<[number, T]> {
    let item = this.head;
    let i = 0;
    return {
      next(): IteratorResult<[number, T]> {
        if (item) {
          const { value, next } = item;
          item = next;
          return { value: [i++, value], done: false };
        } else {
          return { value: undefined, done: true };
        }
      }
    }
  }
  get(idx: number): T | undefined {
    if (idx >= this.size) return undefined;
    let item = this.head;
    for (let i = 0; i < idx; i++) {
      if (!item) throw new Error(`Missing item ${i}`);
      item = item.next;
    }
    return item?.value;
  }
  peek(): T | undefined {
    return this.head?.value;
  }
  push(...values: T[]): number {
    if (!values.length) return this.size;

    values.sort((a, b) => this.comparator(a, b) ? 1 : -1); // sort desc
    let item = this.head;
    let lastItem: Item<T> | null = null;
    for (const value of values) {
      this._size++;
      if (!item) {
        if (!lastItem) {
          item = this.head = {
            value,
            next: null,
          };
        } else {
          lastItem.next = item = {
            value,
            next: null,
          };
        }
      } else if (this.comparator(value, item.value)) {
        const vItem = {
          value,
          next: item,
        };
        if (!lastItem) {
          this.head = vItem;
        } else {
          lastItem.next = vItem;
        }
      }

      item = item?.next;
      lastItem = item;
    }
    return this.size;
  }
  pop(): T | null {
    const head = this.head;
    if (head) {
      this._size--;
      this.head = head.next;
      return head.value;
    } else {
      return head;
    }
  }

  remove(idx: number) {
    if (idx > this.size - 1) throw new Error("Cannot remove out of bounds");
    let item = this.head;
    let lastItem: Item<T> | null = null;
    for (let i = 0; i < idx; i++) {
      if (!item) throw new Error("Missing item");
      lastItem = item;
      item = item.next;
    }
    if (!item) throw new Error("Missing item");

    if (!lastItem) {
      this.head = item.next;
    } else {
      lastItem.next = item.next;
    }
    item.next = null;
  }
}