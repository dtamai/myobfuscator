require "rules"

function read_query(packet)
  if packet:byte() ~= proxy.COM_QUERY then return end

  local cmd = string.lower(string.sub(packet, 2))
  if string.match(cmd, "^select [^@]") then
    proxy.queries:append(1, packet, {resultset_is_needed = true})

    responseRows = {}
    return proxy.PROXY_SEND_QUERY
  end
end

function read_query_result(inj)
  local lowerQuery = string.lower(inj.query)
  local tblName = string.gsub(string.match(lowerQuery, "from (%b``)"), "`", "")
  local queryStar = string.match(lowerQuery, "[ .]%*")

  local modTable = _G[tblName]
  if not modTable then return end

  local fields = {}
  local fieldsIdx = {}
  for n = 1, #inj.resultset.fields do
    fields[#fields + 1] = {
      type = inj.resultset.fields[n].type,
      name = inj.resultset.fields[n].name,
    }
    fieldsIdx[inj.resultset.fields[n].name] = n
  end

  for row in inj.resultset.rows do
    if queryStar and modTable.__row__ then
      row = modTable.__row__(fieldsIdx, row)
    end

    for k = 1, #fields do
      if row[k] ~= nil and modTable[fields[k].name] then
        row[k] = modTable[fields[k].name](row[k])
      end
    end

    responseRows[#responseRows + 1] = row
  end

  proxy.response = {
    type = proxy.MYSQLD_PACKET_OK, resultset = { rows = responseRows }
  }

  proxy.response.resultset.fields = fields
  return proxy.PROXY_SEND_RESULT
end
