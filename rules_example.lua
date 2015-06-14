require "utils"

math.randomseed(os.time())

users = {}

function users.__row__(fieldsIdx, row)
  name = firstName() .. " " .. lastName()
  row[fieldsIdx["name"]] = name
  row[fieldsIdx["email"]] = string.lower(string.gsub(name, " ", ".")) .. "_" .. string.random(6, "%l%d") .. "@example.com"
  return row
end

function users.name(originalValue)
  return originalValue .. " " .. lastName()
end
