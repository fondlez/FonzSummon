local A = FonzSummon

A.module 'util.string'

function M.isempty(s)
  return s == nil or s == ''
end

-- Named Parameters and Format String in Same Table
-- http://lua-users.org/wiki/StringInterpolation
function M.replace_vars(str, vars)
  -- Allow replace_vars{str, vars} syntax as well as replace_vars(str, {vars})
  if not vars then
    vars = str
    str = vars[1]
  end
  return (string.gsub(str, "({([^}]+)})",
    function(whole, key)
      return vars[key] or whole
    end))
end

function M.strmatch(str, pattern, index)
  local i, j = string.find(str, pattern, index, false)
  if not i then return nil end
  return string.sub(str, i, j)
end

-- splitByPlainSeparator
-- http://lua-users.org/wiki/SplitJoin
function M.strsplit(sep, str, nmax)
  local find, sub, gsub = string.find, string.sub, string.gsub
  local z = string.len(sep)
  sep = '^.-' .. gsub(sep, '[$%%()*+%-.?%[%]^]', '%%%0')
  local t, n, p, q, r = {}, 1, 1, find(str, sep)
  while q and n ~= nmax do
      t[n], n, p = sub(str, q, r-z), n+1, r+1
      q, r = find(str, sep, p)
  end
  t[n] = sub(str, p)
  return unpack(t)
end