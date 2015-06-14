# myobfuscator
Lua script to manipulate MySQL SELECT results

# Usage

Create a file _rules.lua_, or rename and modify the file _rules.lua_ then start the proxy with

```shell
mysql-proxy --proxy-lua-script=path/to/obfuscator.lua --lua-path=path/to/myobfuscator/?.lua
```

# How it works

The _obfuscator.lua_ script intercepts any query that begins with `SELECT` (case insensitive).

If the query selects every column, for example:

```sql
SELECT * FROM `table`;
SELECT `table`.* FROM `table`;
```

then the script will call the special `__row__` function (see below) that allows you to manipulate all fields in a row.

Otherwise the script will check, for each field, if there is a function defined for the name of that field, then call that function with the original value from the database, the return value of that function will substitute de original value.

Functions must be defined for each table. The table name is captured after `FROM` in the query, and **the name must be surrounded by backticks (`)**.

## Join

It **may** work, I did not check because the use case for this script is only obfuscating simple data extraction.

## Rename/Alias

A query that renames a column, like

```sql
SELECT name AS user_name FROM `users`;
```

will trigger the function `users.user_name`, not `users.name`.

But aliasing a table does not change which function is triggered, so a query like

```sql
SELECT name FROM users AS u;
```

will trigger the function `users.name` not `u.name`.

# rules.lua

For each table in the database that requires obfuscation create a table variable.

```lua
-- To manipulate the Users table create a table variable
users = {}
```

Then create a function for each column that requires obfuscation in that table's table. This functions receives the original value for that column.

```lua
-- Function to change the data for column email in users table
function users.email(originalValue)
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

## Randomization

To make the random values repeatable (two clients running the same query will receive the same response) just fix the seed, or comment/remove the line

```lua
math.randomseed(os.time())
```

in the _rules.lua_ file.

# utils.lua

This file contains some functions that help generate randomized data.
