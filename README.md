# myobfuscator
Lua script to manipulate MySQL SELECT results

# Usage

Modify the file _rules.lua_ and copy it `$MYSQL_PROXY_ROOT/lib/mysql-proxy/lua`, where `$MYSQL_PROXY_ROOT` is the root folder for the MySQL Proxy application.

Start the proxy with

```shell
mysql-proxy --proxy-lua=path/to/obfuscator.lua
```

# rules.lua

For each table in the database that requires obfuscation create a table variable.

```lua
-- To manipulate the Users table create a table variable
users = {}
```

Then create a function for each column that requires obfuscation in that table's table. This functions receives the original value for that column.

```lua
-- Function to change the data for column email in users table
function users.email(original_value)
  return "user@example.com"
end
```

You may create a special function `__row__` that receives a complete row, this enables you to obfuscate but keep data less randomized.

```lua
-- Special function that allows modification of all columns in a row
function users.__row__(fieldsIndex, row)
  fullName = row[fieldsIndex["first_name"]] .. "." .. row[fieldsIndex["last_name"]]
  row[fieldsIndex["email"]] = fullName .. "@example.com"
end
```

Any column specific funcion is called **after** the `__row__`, so they can change the data again.
