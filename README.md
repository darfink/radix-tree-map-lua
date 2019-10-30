# Radix Tree Map

This is a radix tree implemented in Lua.

## API

- `TrieMap.new()`  
  Creates an empty trie.

- `TrieMap:iter([prefix])`  
  Returns an iterator over all values in the trie, with an optional prefix.

- `TrieMap:get(key)`  
  Retrieves a key's value from the trie, or `nil` if it doesn't exist.

- `TrieMap:insert(key, value)`  
  Inserts or replaces a key and its value. If an existing entry exists, its value is returned.

- `TrieMap:remove(key)`  
  Removes an entry from the trie, returning the value, or `nil` if it doesn't exist.

## Example

```lua
local TrieMap = require 'TrieMap'
local trie = TrieMap.new()

trie:insert('foobar', 1)
trie:insert('foocar', 2)
trie:insert('foodar', 3)
trie:insert('barfoo', 4)

trie:remove('foodar')

for value in trie:iter('foo') do
  print(value)
end
```

## Remarks

To mirror the behavior with tables, `nil` values are not possible in the trie.
