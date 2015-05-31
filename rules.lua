users = {}

function users.__row__(fieldsIdx, row)
  row[fieldsIdx["email"]] = "alice.bob@example.com"
  return row
end

function users.name(orignal_value)
  return "Alice Bob"
end
