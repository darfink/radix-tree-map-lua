# Radix Tree Map

A radix tree implemented in Lua.

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
  Returns whether an entry exists for a key or not.

- `TrieMap:insert(key, value)`  
  Inserts or replaces a key and its value (if an existing entry exists, its value is returned).  
  **NOTE**: This is an expensive operation.

- `TrieMap:remove(key)`  
  Removes an entry from the trie and returns the value, or `nil` if it doesn't exist.

- `TrieMap:nodes()`  
  Returns the number of nodes used for representing the tree.  
  **NOTE**: This is mostly useful for unit tests.

- `TrieMap:len()`  
  Returns the number of entries in the trie.

- `TrieMap:is_empty()`  
  Returns whether the trie is empty or not.

- `TrieMap:clear()`  
  Clears the trie of all entries.

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

The keys are stored in lexicographic order. To mirror the behavior with
tables, `nil` values are not allowed. To save memory, edges are not
represented in the tree, instead intermediate nodes are used (if they lack a
`value` field they are only auxiliary).

## Sources

- [Radix tree on Wikipedia](https://en.wikipedia.org/wiki/Radix_tree)