local TrieMap = require 'TrieMap'

function sample_trie()
  local trie = TrieMap.new()
  trie:insert('foobar', 1)
  trie:insert('foocar', 2)
  trie:insert('foodar', 3)
  return trie
end

function iter_to_table(iterator)
  local result = {}
  for key, value in iterator do
    if value == nil then
      result[#result + 1] = key
    else
      result[key] = value
    end
  end
  return result
end

describe('TrieMap', function()
  it('should be empty when created', function()
    local trie = TrieMap.new()
    assert.truthy(trie:is_empty())
    assert.same(trie:get(), nil)
    assert.same(trie:len(), 0)
  end)

  it('should be possible to insert values', function()
    local trie = sample_trie()
    assert.same(trie:get('foocar'), 2)
    assert.falsy(trie:is_empty())
    assert.same(trie:len(), 3)
  end)

  it('should be possible to replace existing values', function()
    local trie = sample_trie()
    assert.same(trie:insert('foocar', 4), 2)
    assert.same(trie:get('foocar'), 4)
    assert.same(trie:len(), 3)
  end)

  it('should be possible to remove keys', function()
    local trie = TrieMap.new()
    trie:insert('test', 1)
    trie:insert('team', 2)
    trie:insert('toast', 3)

    assert.same(trie:remove('toast'), 3)
    assert.same(trie:get('toast'), nil)
    assert.same(trie:nodes(), 4)
    assert.same(trie:len(), 2)
  end)

  it('should be possible to remove intermediate nodes', function()
    local trie = TrieMap.new()
    trie:insert('test', 1)
    trie:insert('te', 2)

    -- Remove an intermediate node with a single child
    trie:remove('te')

    assert.same(trie:nodes(), 2)
    assert.same(trie:len(), 1)

    trie:insert('te', 2)
    trie:insert('team', 3)

    -- Remove an intermediate node with multiple children
    trie:remove('te')

    assert.same(trie:nodes(), 4)
    assert.same(trie:len(), 2)
  end)

  it('should be possible to iterate values without a prefix', function()
    local trie = sample_trie()
    local index = 1
    for value in trie:values() do
      assert.same(value, index)
      index = index + 1
    end
  end)

  it('should be possible to iterate values with a prefix', function()
    local trie = sample_trie()
    trie:insert('barcaz', 4)
    trie:insert('barfoo', 5)
    trie:insert('barcar', 6)

    local values = iter_to_table(trie:values('barca'))
    assert.same(values, { 6, 4 })
  end)

  it('should store keys in lexicographic order', function()
    local trie = TrieMap.new()
    trie:insert('z', 1)
    trie:insert('a', 2)

    local keys = iter_to_table(trie:keys())
    assert.same(keys, { 'a', 'z' })

    trie:clear()
    trie:insert('test', 1)
    trie:insert('team', 2)

    local keys = iter_to_table(trie:keys())
    assert.same(keys, { 'team', 'test' })
  end)

  it('should update size when inserting a value that replaces an intermediate node', function()
    local trie = TrieMap.new()

    -- Insert keys to create an intermediate node with label 'te'
    trie:insert('test', 1)
    trie:insert('team', 2)

    -- Insert a key with the same label as the intermediate node
    assert.falsy(trie:insert('te', 3))
    assert.same(trie:len(), 3)
  end)

  it('should create an intermediate node if a key is a complete prefix of an existing label', function()
    local trie = TrieMap.new()
    trie:insert('test', 1)
    trie:insert('te', 2)
    assert.same(trie:nodes(), 3)
    assert.same(trie:len(), 2)
  end)
end)
