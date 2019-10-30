# Radix Tree Map

This is a radix tree implemented in Lua.

## API

- `TrieMap.new()`  
  Creates an empty trie.

- `TrieMap:entries([prefix])`  
  Returns an iterator over all entries in the trie, with an optional prefix.

- `TrieMap:keys([prefix])`  
  Returns an iterator over all keys in the trie, with an optional prefix.

- `TrieMap:values([prefix])`  
  Returns an iterator over all values in the trie, with an optional prefix.

- `TrieMap:get(key)`  
  Retrieves a key's value from the trie, or `nil` if it doesn't exist.

- `TrieMap:has(key)`  
  Returns whether an entry exists for the key or not.

- `TrieMap:insert(key, value)`  
  Inserts or replaces a key and its value. If an existing entry exists, its value is returned.  
  **NOTE**: This is an expensive operation.

- `TrieMap:remove(key)`  
  Removes an entry from the trie and returns the value, or `nil` if it doesn't exist.

## Example

```lua
local TrieMap = require 'TrieMap'
local trie = TrieMap.new()

trie:insert('foobar', 1)
trie:insert('foocar', 2)
trie:insert('foodar', 3)
trie:insert('barfoo', 4)

trie:remove('foodar')

for key, value in trie:entries('foo') do
  print(key, value)
end
```

## Remarks

The keys are stored in lexicographic order.

To mirror the behavior with tables, `nil` values are not allowed.