------------------------------------------
-- Class definition
------------------------------------------

local TrieMap = {}
TrieMap.__index = TrieMap

------------------------------------------
-- Public methods
------------------------------------------

-- Creates a new trie map
function TrieMap.new()
  local self = setmetatable({}, TrieMap)
  self.root = {}
  self.size = 0
  return self
end

-- Returns an iterator over all values with an optional prefix
function TrieMap:iter(prefix)
  local function visit_node(node)
    if not node then return end

    if node.value then
      coroutine.yield(node.value)
    end

    if node.children then
      for index in ipairs(node.children) do
        visit_node(node.children[index])
      end
    end
  end

  return coroutine.wrap(function()
    visit_node(self:_find_closest_node(prefix))
  end)
end

-- Returns a key's value
function TrieMap:get(label)
  local node, isExactMatch = self:_find_closest_node(label)
  return isExactMatch and node.value or nil
end

-- Inserts or replaces a key and its value (any previous value is returned)
function TrieMap:insert(label, value)
  assert(type(label) == 'string' and label:len() > 0)

  local removeNode = value == nil
  local closestNode, isExactMatch, parentNode, sharedPrefixLength, sharedLabelLength, nodeIndex =
    self:_find_closest_node(label)

  if isExactMatch then
    local oldValue = closestNode.value

    if removeNode then
      self:_remove_node(closestNode, parentNode, nodeIndex)
    else
      closestNode.value = value
    end

    return oldValue
  elseif removeNode then
    return
  end

  if parentNode.children == nil then
    parentNode.children = {}
  end

  local nodeToInsert = {
    label = label:sub(sharedPrefixLength + sharedLabelLength + 1),
    value = value,
  }

  if not closestNode then
    table.insert(parentNode.children, nodeToInsert)
  else
    closestNode.label = closestNode.label:sub(sharedLabelLength + 1)
    parentNode.children[nodeIndex] = {
      label = label:sub(sharedPrefixLength + 1, sharedPrefixLength + sharedLabelLength),
      children = { closestNode, nodeToInsert },
    }
  end
  self.size = self.size + 1
end

-- Removes a key and its value
function TrieMap:remove(label)
  return self:insert(label, nil)
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
  local traverseNode = self.root
  local sharedPrefixLength = 0
  local labelLength = string.len(label or '')

  while sharedPrefixLength < labelLength do
    local childNode, isExactMatch, sharedLabelLength, childIndex =
      self:_get_child_node_with_lcp(traverseNode, label:sub(sharedPrefixLength + 1))

    if isExactMatch == false then
      return childNode, false, traverseNode, sharedPrefixLength, sharedLabelLength, childIndex
    end

    sharedPrefixLength = sharedPrefixLength + childNode.label:len()
    traverseNode = childNode
  end

  return traverseNode, true
end

-- Returns the child node with the longest common prefix (LCP)
function TrieMap:_get_child_node_with_lcp(parentNode, label)
  local isExactMatch = false
  local sharedPrefixLength = 0
  local closestChild = nil
  local childIndex = nil

  if parentNode.children ~= nil then
    for nodeIndex in ipairs(parentNode.children) do
      local childNode = parentNode.children[nodeIndex]
      local minLength = math.min(#label, #childNode.label)

      local i = 0
      while i < minLength and label:byte(i + 1) == childNode.label:byte(i + 1) do
        i = i + 1
      end

      if i > 0 then
        closestChild = childNode
        sharedPrefixLength = i
        isExactMatch = i == #childNode.label
        childIndex = nodeIndex
        break
      end
    end
  end

  return closestChild, isExactMatch, sharedPrefixLength, childIndex
end

function TrieMap:_remove_node(node, parentNode, nodeIndex)
  if node.children ~= nil then
    for index in node.children do
      local childNode = node.children[index]
      childNode.label = node.label .. childNode.label
      parentNode.children[#parentNode.children] = childNode
    end
  end

  table.remove(parentNode.children, nodeIndex)

  if #parentNode.children == 1 and not parentNode.value then
    local childNode = parentNode.children[0]
    parentNode.label = parentNode.label .. childNode.label
    parentNode.value = childNode.value
    parentNode.children = childNode.children
  end
end

return { new = TrieMap.new }
