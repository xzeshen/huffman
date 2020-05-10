# huffman
Huffman encode/decode for Nim.

# API: huffman

```nim
import huffman
```

## **proc** readHuffman

Encodes data.

```nim
proc readHuffman(s: Stream): string {.inline, raises: [Defect, IOError, OSError], tags: [ReadIOEffect].}
```

## **proc** readHuffman

Encodes data.

```nim
proc readHuffman(s: string = "input.txt"): string {.inline, raises: [Defect, IOError, OSError], tags: [ReadIOEffect].}
```

## **proc** huffman

Decodes data.

```nim
proc huffman(text: string; path = "output.txt") {.inline, raises: [KeyError, Defect, IOError, OSError, Exception], tags: [WriteIOEffect].}
```
