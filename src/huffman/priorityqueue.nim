  
import heapqueue


type
  PriorityItem*[T] = tuple
    priority: float
    idx: int
    item: T

  PriorityQueue*[T] = ref object
    data*: HeapQueue[PriorityItem[T]]
    idx: int
    maxQueue: bool


proc `<`*[T](self, other: PriorityItem[T]): bool {.inline.} =
  ## Compares PriorityItem.
  return (self.priority, self.idx) < (other.priority, other.idx)

proc newPriorityQueue*[T](maxQueue = true): PriorityQueue[T] {.inline.} =
  ## Creates new PriorityQueue.
  new result
  result.maxQueue = maxQueue

proc push*[T](p: PriorityQueue[T], item: T, priority: float) {.inline.} =
  ## Adds ``item`` with its ``priority`` to PriorityQueue.
  if likely(p.maxQueue):
    p.data.push((-priority, p.idx, item))
  else:
    p.data.push((priority, p.idx, item))
  inc(p.idx)

proc pop*[T](p: PriorityQueue[T]): T {.inline.} =
  ## Deletes item from PriorityQueue.
  p.data.pop.item

proc len*[T](p: PriorityQueue[T]): int {.inline.} =
  ## Gets the length of PriorityQueue.
  p.data.len

proc `$`*[T](q: PriorityQueue[T]): string {.inline.} =
  $q.data


when isMainModule:
  type
    Student* = object
      id: int
      name: string
  var s = newPriorityQueue[Student]()
  s.push(Student(id: 12, name: "tom"), 3)
  s.push(Student(id: 12, name: "lili"), 4)
  s.push(Student(id: 12, name: "yui"), 5)
  s.push(Student(id: 12, name: "mu"), 1)
  echo s.pop
  echo s.pop
