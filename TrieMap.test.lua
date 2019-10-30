local TrieMap = require "TrieMap"

function sample_trie()
  local trie = TrieMap.new()
  trie:insert('foobar', 1)
  trie:insert('foocar', 2)
  trie:insert('foodar', 3)
  return trie
end

function iter_to_array(iterator)
  local array = {}
  for value in iterator do
    array[#array + 1] = value
  end
  return array
end

describe('TrieMap', function()
  it('should be empty when created', function()
    local trie = TrieMap.new()
    assert.truthy(trie:is_empty())
    assert.same(trie:len(), 0)
  end)

  it('should be possible to insert values', function()
    local trie = sample_trie()
    assert.falsy(trie:is_empty())
    assert.same(trie:len(), 3)
  end)

  it('should be possible to replace existing values', function()
    local trie = sample_trie()
    assert.same(trie:insert('foocar', 4), 2)
    assert.same(trie:get('foocar'), 4)
    assert.same(trie:len(), 3)
  end)

  it('should be possible to iterate without a prefix', function()
    local trie = sample_trie()
    local index = 1
    for value in trie:iter() do
      assert.same(value, index)
      index = index + 1
    end
  end)

  it('should be possible to iterate with a prefix', function()
    local trie = sample_trie()
    trie:insert('barcaz', 4)
    trie:insert('barfoo', 5)
    trie:insert('barcar', 6)

    local entries = iter_to_array(trie:iter('barca'))
    assert.same(entries, {4, 6})
  end)
end)
