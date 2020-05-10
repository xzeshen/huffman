import priorityqueue, tables, streams, bitops


type
  # HuffmanTree
  TreeObj = object
    left: Tree
    right: Tree
    value: char
    priority: float

  Tree = ref TreeObj

  Bit = ref object
    mark: int
    value: uint8


proc newTree(left: Tree = nil, right: Tree = nil, value = '\0',
    priority = 0.0): Tree {.inline.} =
  Tree(left: left, right: right, value: value, priority: priority)

proc `$`(t: Tree): string =
  result = $t.value
  if t.left != nil:
    result.add($t.left)
  if t.right != nil:
    result.add($t.right)

proc isLeaf(t: Tree): bool {.inline.} =
  return t.left == nil and t.right == nil

proc buildTable(t: Tree, st: var Table[char, string], s: string) {.inline.} =
  if t.isLeaf:
    st[t.value] = s
    return

  buildTable(t.left, st, s & "0")
  buildTable(t.right, st, s & "1")

proc buildTable(t: Tree): Table[char, string] {.inline.} =
  var
    st: Table[char, string]
    s: string

  buildTable(t, st, s)
  result = st

proc writeBit(s: Stream, value: bool, wBit: Bit) {.inline.} =
  if wbit.mark < 7:
    if value:
      setBit(wbit.value, 7 - wbit.mark)
    inc(wbit.mark)
  else:
    if value:
      setBit(wbit.value, 7 - wbit.mark)
    s.write(wbit.value)
    wbit.mark = 0
    wbit.value = 0

proc writeBit(s: Stream, value: char, wBit: Bit) {.inline.} = 
  if wbit.mark > 0:
    s.write(wbit.value)
    wbit.mark = 0
    wbit.value = 0
  s.write(value)

proc writeTrie(s: Stream, t: Tree, wBit: Bit) {.inline.} =
  if t.isLeaf:
    s.writeBit(true, wBit)
    s.writeBit(t.value, wBit)
    return

  s.writeBit(false, wBit)
  writeTrie(s, t.left, wBit)
  writeTrie(s, t.right, wBit)

proc writeCode(s: Stream, text: string, tree: Tree, lookup: Table[char, string], wBit: Bit) {.inline.} =
  writeTrie(s, tree, wBit)

  if wBit.mark > 0:
    s.write(wBit.value)
    wBit.mark = 0
    wBit.value = 0

  s.write(uint32(text.len))

  for item in text:
    let code = lookup[item]
    for c in code:
      if c == '1':
        s.writeBit(true, wBit)
      else:
        s.writeBit(false, wBit)

  if wBit.mark > 0:
    s.write(wbit.value)
    wBit.value = 0
    wBit.mark = 0

proc readTrie(s: Stream, rBit: Bit): Tree {.inline.} =
  if rBit.mark == 0:
    rBit.value = s.readUint8
  if testBit(rBit.value, 7 - rBit.mark):
    rBit.mark = 0
    result = newTree(value = s.readChar)
  else:
    inc(rBit.mark)
    if rBit.mark == 8:
      rBit.mark = 0
    result = newTree(readTrie(s, rBit), readTrie(s, rBit))

proc readHuffmanBit(s: Stream, node: var Tree, res: var string, root: Tree, rBit: Bit) {.inline.} =
  for i in 0 .. 7:
    if node == nil:
      return
    if testBit(rBit.value, 7 - i):
      node = node.right
    else:
      node = node.left
    if node.isLeaf:
      res.add(node.value)
      node = root

proc readHuffman*(s: Stream): string {.inline.} =
  ## Encodes data.
  
  var 
    rBit = Bit(mark: 0, value: 0)

  let
    root = s.readTrie(rBit)
    n = s.readInt32

  var node = root

  result = newStringOfCap(n)
  while not s.atEnd:
    rBit.value = s.readUint8
    readHuffmanBit(s, node, result, root, rBit)

proc readHuffman*(s: string = "input.txt"): string {.inline.} =
  ## Encodes data.
  
  let strm = newFileStream(s, fmRead)
  readHuffman(strm)

proc huffman*(text: string, path = "output.txt") {.inline.} =
  ## Decodes data.

  # ignore empty text
  if text.len == 0:
    return

  var
    s = newPriorityQueue[Tree](maxQueue = false)
    counter = toCountTable(text)
    wBit = Bit(mark: 0, value: 0)

  for k, v in counter:
    s.push(Tree(value: k, priority: float(v)), float(v))

  while s.len > 1:
    let
      t1 = s.pop
      t2 = s.pop
    s.push(newTree(t1, t2, '\0', t1.priority + t2.priority), t1.priority + t2.priority)

  let 
    tree = s.pop
    dict = buildTable(tree)

  var output: string
  for c in text:
    output.add(dict[c])
  
  var strm = newFileStream(path, fmWrite)
  writeCode(strm, text, tree, dict, wBit)
  strm.close()


when isMainModule:
  # import random, os
  # randomize(1024)
  # var
  #   n = 1000
  #   res: string = newString(n)
  #   letters = toSeq('a' .. 'z')
  # for i in 0 ..< n:
  #   res[i] = sample(letters)
  # res = "ABRACADABRA!"
  import os

  let 
    input = newFileStream("input.txt", fmRead)
    text = input.readAll
  huffman(text)
  input.close()
  let 
    strm = newFileStream("output.txt", fmRead)
    output = readHuffman(strm)
  doAssert text == output
  echo os.getFileSize("input.txt")
  echo os.getFileSize("output.txt")
  strm.close()
