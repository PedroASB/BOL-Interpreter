require "patterns"
require "utils"
require "args"
require "utils"
require "parser"

local if_else_body = [==[
  if a eq b then
      x = y
      className.method()
  else
      y = a + b  
      var._prototype = obj
  end-if
]==]

local if_body = [==[
  if a eq b then
      x = y
      className.method()
      y = a + b  
      var._prototype = obj
  end-if
]==]

local function Test_parser_if()
  local types, current_pattern, match
  types, current_pattern = table.unpack(Statements_patterns[5])
  print("IF TEST")
  match = { if_body:match("^" .. current_pattern .. "\n") }

  if #match >= 1 then
    local ast = Parser_if({ types = types, tokens = match })
    Print_table(ast)
  end

  print("IF-ELSE TEST")
  match = { if_else_body:match("^" .. current_pattern .. "\n") }
  if match then
    local ast = Parser_if({ types = types, tokens = match })
    Print_table(ast)
  end
end

local function Test_arg_var_list()
  local match
  local vars_string = "vars a, b, c\n"
  match = { vars_string:match("^" .. _Variables_def_pattern_ .. "\n") }
  Print_table(match)
  if #match >= 1 then
    local ast = Arg_var_list(match[1])
    Print_table(ast)
  end
end

local function Test_parser_method_call()
  local match, types, pattern
  local method_call_string = "variable.methodo(abedecadara, b, c)\n"
  local method_call_string = "io.print(var)\n"
  types, pattern = table.unpack(Statements_patterns[1])
  match = { method_call_string:match("^" .. pattern .. "\n") }
  Print_table(match)
  if #match >= 1 then
    local ast = Parser_method_call({ types = types, tokens = match })
    Print_table(ast)
    Print_table(ast.arg)
    Print_table(ast.arg.params)
  end
end

local function Test_parser_return()
  local match, types, pattern
  local method_call_string = "return x\n"
  types, pattern = table.unpack(Statements_patterns[4])
  match = { method_call_string:match("^" .. pattern .. "\n") }
  Print_table(match)
  if #match >= 1 then
    local ast = Parser_return({ types = types, tokens = match })
    Print_table(ast)
    Print_table(ast.arg)
  end

end

local function Test_parser_prototype()
  local match, types, pattern
  local prototype_string = "obj._prototype =   object\n"
  types, pattern = table.unpack(Statements_patterns[3])
  match = { prototype_string:match("^" .. pattern .. "\n") }
  Print_table(match)
  if #match >= 1 then
    local ast = Parser_prototype({ types = types, tokens = match })
    Print_table(ast)
    Print_table(ast.rhs)
    Print_table(ast.lhs)
  end
end

local function Test_parser_meta_action()
  local match, types, pattern
  local meta_action_string = "variable.methodo._delete(1):\n"
  types, pattern = table.unpack(Statements_patterns[2])
  match = { meta_action_string:match("^" .. pattern .. "\n") }
  Print_table(match)
  if #match >= 1 then
    types = nil
    local ast = Parser_meta_action({ types = types, tokens = match })
    print("AST: ")
    Print_table(ast)
    print("END-AST")
    print("ARG")
    Print_table(ast.arg)
    print("END-ARG")
    print("PARAMS")
    Print_table(ast.arg.params)
    print("END-PARAMS")
  end
end

function Test_parser_vars_def()
  local match, ast
  local vars_string = "vars a, b, c\n"
  match = { vars_string:match("^" .. _Variables_def_pattern_ .. "\n") }
  Print_table(match)
  if #match >= 1 then
    ast = Parser_vars_def({types={type="vars_def"}, tokens=match})
    Print_table(ast)
    Print_table(ast.var_list)
  end
  return ast
end

local function Test_parser_assign()
  local match
  local vars_string = "var.att = 10\n"
  local types, pattern, tokens

  for index, pattern_info in ipairs(Statements_patterns) do
    types, pattern = table.unpack(pattern_info)
    tokens = {vars_string:match("^" .. pattern .. "\n")}
    if #tokens >= 1 then
      local ast = Parser_assign({types=types, tokens=tokens})
      Print_table(ast)
      print("LHS")
      Print_table(ast.lhs)
      print("\nARG-LHS")
      Print_table(ast.lhs.arg)
      print("\nRHS")
      Print_table(ast.rhs)
      print("\nARG-RHS")
      Print_table(ast.rhs.arg)
    end
  end

end

-- Test_parser_assign()
-- Test_parser_vars_def()
-- Test_parser_if()
-- Test_parser_method_call()
-- Test_parser_prototype()
-- Test_parser_return()
-- Test_arg_var_list()