------------------------------------------
-- Class definition
------------------------------------------

local TrieMap = {}
TrieMap.__index = TrieMap

------------------------------------------
-- Constructor
------------------------------------------

-- Creates a new trie map
function TrieMap.new()
  local self = setmetatable({}, TrieMap)
  self.root = {}
  self.size = 0
  return self
end

------------------------------------------
-- Public methods
------------------------------------------

-- Returns an iterator over entries keys with an optional prefix
function TrieMap:entries(prefix)
  return coroutine.wrap(function()
    local startNode = self:_find_closest_node(prefix)
    self:_visit_node_recurse(startNode, function(node, prefixes)
      return table.concat(prefixes), node.value
    end)
  end)
end

-- Returns an iterator over all keys with an optional prefix
function TrieMap:keys(prefix)
  return coroutine.wrap(function()
    local startNode = self:_find_closest_node(prefix)
    self:_visit_node_recurse(startNode, function(node, prefixes)
      return table.concat(prefixes)
    end)
  end)
end

-- Returns an iterator over all values with an optional prefix
function TrieMap:values(prefix)
  return coroutine.wrap(function()
    local startNode = self:_find_closest_node(prefix)
    self:_visit_node_recurse(startNode, function(node, prefixes)
      return node.value
    end)
  end)
end

-- Returns a key's value
function TrieMap:get(key)
  local node, isExactMatch = self:_find_closest_node(key)
  return isExactMatch and node.value or nil
end

-- Inserts or replaces a key and its value (any previous value is returned)
function TrieMap:insert(key, value)
  assert(type(key) == 'string' and key:len() > 0)
  assert(value ~= nil)

  local closestNode, isExactMatch, parentNode, ancestorLength, prefixLength, closestNodeIndex =
    self:_find_closest_node(key)

  if isExactMatch then
    local oldValue = closestNode.value
    closestNode.value = value

    if oldValue == nil then
      -- Update the size if the exact match was an intermediate node
      self.size = self.size + 1
    end

    return oldValue
  end

  parentNode.children = parentNode.children or {}
  local keySuffix = key:sub(ancestorLength + prefixLength + 1)

  if not closestNode then
    local i = 1
    while parentNode.children[i] and keySuffix > parentNode.children[i].label do i = i + 1 end

    -- No children share a prefix with the key, so insert it in lexicographic order
    table.insert(parentNode.children, i, { label = keySuffix, value = value })
  else
    -- Determine the shared prefix of the key and the closest node's label
    local sharedPrefix = key:sub(ancestorLength + 1, ancestorLength + prefixLength)
    closestNode.label = closestNode.label:sub(prefixLength + 1)

    if keySuffix:len() == 0 then
      -- The key is a complete prefix of the closest node, therefore it becomes the intermediate
      parentNode.children[closestNodeIndex] = {
        label = sharedPrefix,
        value = value,
        children = { closestNode }
      }
    else
      local nodeToInsert = { label = keySuffix, value = value }

      -- Insert an intermediate for the shared prefix of the key and the closest node
      parentNode.children[closestNodeIndex] = {
        label = sharedPrefix,
        children = closestNode.label < nodeToInsert.label
          and { closestNode, nodeToInsert }
          or { nodeToInsert, closestNode }
      }
    end
  end

  self.size = self.size + 1
end

-- Removes a key and its value
function TrieMap:remove(key)
  assert(type(key) == 'string' and key:len() > 0)

  local closestNode, isExactMatch, parentNode, _, _, closestNodeIndex =
    self:_find_closest_node(key)

  if not isExactMatch then
    return
  end

  local oldValue = closestNode.value

  if closestNode.children ~= nil then
    if #closestNode.children == 1 then
      -- Merge the removed node with its sole child
      self:_merge_nodes(closestNode, closestNode.children[1])
    else
      -- Remove the node's value to indicate it's an intermediate
      closestNode.value = nil
    end
  else
    table.remove(parentNode.children, closestNodeIndex)
    if #parentNode.children == 1 and not parentNode.value then
      -- Merge the intermediate parent with it's only remaining child
      self:_merge_nodes(parentNode, parentNode.children[1])
    end
  end

  self.size = self.size - 1
  return oldValue
end

-- Returns whether the key exists or not
function TrieMap:has(key)
  return self:get(key) ~= nil
end

-- Returns the number of entries
function TrieMap:len()
  return self.size
end

-- Returns whether the trie is empty or not
function TrieMap:is_empty()
  return self.size == 0
end

------------------------------------------
-- Private methods
------------------------------------------

function TrieMap:_find_closest_node(label)
  local labelLength = string.len(label or '')

  if labelLength == 0 then
    return self.root, true, nil, 0, 0, nil
  end

  local ancestorLength = 0
  local traverseNode = self.root

  while true do
    local childNode, isExactMatch, prefixLength, childIndex =
      self:_find_child_node_with_lcp(traverseNode, label:sub(ancestorLength + 1))

    if not isExactMatch or ancestorLength + childNode.label:len() >= labelLength then
      return childNode, isExactMatch, traverseNode, ancestorLength, prefixLength, childIndex
    end

    ancestorLength = ancestorLength + childNode.label:len()
    traverseNode = childNode
  end
end

-- Returns the child node with the longest common prefix (LCP)
function TrieMap:_find_child_node_with_lcp(parentNode, label)
  local isExactMatch = false
  local prefixLength = 0
  local closestChild = nil
  local childIndex = nil

  if parentNode.children ~= nil then
    -- TODO: Binary search could be used instead
    for nodeIndex in ipairs(parentNode.children) do
      local childNode = parentNode.children[nodeIndex]
      local minLength = math.min(#label, #childNode.label)

      local i = 0
      while i < minLength and label:byte(i + 1) == childNode.label:byte(i + 1) do
        i = i + 1
      end

      if i > 0 then
        closestChild = childNode
        prefixLength = i
        isExactMatch = i == #childNode.label
        childIndex = nodeIndex
        break
      end
    end
  end

  return closestChild, isExactMatch, prefixLength, childIndex
end

function TrieMap:_visit_node_recurse(node, transform, prefixes)
  if not node then return end

  prefixes = prefixes or {}
  prefixes[#prefixes + 1] = node.label

  if node.value then
    coroutine.yield(transform(node, prefixes))
  end

  if node.children then
    for index in ipairs(node.children) do
      local childNode = node.children[index]
      self:_visit_node_recurse(childNode, transform, prefixes)
    end
  end

  prefixes[#prefixes] = nil
end

function TrieMap:_merge_nodes(parentNode, childNode)
  parentNode.label = parentNode.label .. childNode.label
  parentNode.value = childNode.value
  parentNode.children = childNode.children
end

------------------------------------------
-- Exports
------------------------------------------

return { new = TrieMap.new }
