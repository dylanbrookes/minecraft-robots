// yoinked and modified from: https://stackoverflow.com/questions/42919469/efficient-way-to-implement-priority-queue-in-javascript/42919752#42919752

const top = 0;
// const parent = (i: number) => ((i + 1) >>> 1) - 1;
// const left = (i: number) => (i << 1) + 1;
// const right = (i: number) => (i + 1) << 1;
const parent = (i: number) => Math.floor((i + 1) / 2) - 1;
const left = (i: number) => (i * 2) + 1;
const right = (i: number) => (i + 1) * 2;

export default class PriorityQueue<T> {
  private heap: T[] = [];

  constructor(private comparator = (a: T, b: T) => a > b) { }
  
  clear() {
    this.heap = [];
  }
  size(): number {
    return this.heap.length;
  }
  isEmpty(): boolean {
    return this.size() === 0;
  }
  peek(): T | undefined {
    return this.heap[top];
  }
  push(...values: T[]): number {
    values.forEach(value => {
      this.heap.push(value);
      this.siftUp();
    });
    return this.size();
  }
  pop(): T | undefined {
    const poppedValue = this.peek();
    const bottom = this.size() - 1;
    if (bottom > top) {
      this.swap(top, bottom);
    }
    this.heap.pop();
    this._siftDown();
    return poppedValue;
  }
  replace(value: T): T | undefined {
    const replacedValue = this.peek();
    this.heap[top] = value;
    this._siftDown();
    return replacedValue;
  }
  private greater(i: number, j: number): boolean {
    return this.comparator(this.heap[i], this.heap[j]);
  }
  private swap(i: number, j: number): void {
    [this.heap[i], this.heap[j]] = [this.heap[j], this.heap[i]];
  }
  private siftUp(): void {
    let node = this.size() - 1;
    while (node > top && this.greater(node, parent(node))) {
      this.swap(node, parent(node));
      node = parent(node);
    }
  }
  _siftDown(): void {
    let node = top;
    while (
      (left(node) < this.size() && this.greater(left(node), node)) ||
      (right(node) < this.size() && this.greater(right(node), node))
    ) {
      let maxChild = (right(node) < this.size() && this.greater(right(node), left(node))) ? right(node) : left(node);
      this.swap(node, maxChild);
      node = maxChild;
    }
  }
}