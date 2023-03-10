require "patterns"
require "utils"
require "args"
require "utils"


--- Verifica o formato do lexer
---@param lexer table: {types: {}, tokens: {}}
---@param parser_id string
---@param type string
---@param qty_tokens number
---@return nil
local function check_lexer(lexer, parser_id, type, qty_tokens)
    if lexer == nil or lexer.types == nil or lexer.tokens == nil then
        Error("Erro em " .. parser_id .. ": Lexer vazio")
        return
    end

    if lexer.types.type ~= type then
        Error("Erro em " .. parser_id .. ": Lexer não é do tipo '" .. type .. "'")
        return
    end

    if #lexer.tokens < qty_tokens then
        Error("Erro em " .. parser_id .. ": Tokens não suficientes no Lexer")
        return
    end
end


--- Analisa a sintaxe de uma atribuição e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type, lhs, rhs}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- lhs: {type: string, arg: Arg_var | Arg_attr }
---- rhs: {type: string, arg: Arg_Number | Arg_Var | Arg_Attr | Arg_Obj_Creation | Arg_Method_Call}
function Parser_assign(lexer)
    check_lexer(lexer, "Parser_assign", "assignment", 1)

    local ast = {
        lhs = {},
        rhs = {}
    }
    local index = 1
    ast.type = lexer.types.type
    ast.lhs.type = lexer.types.lhs

    if lexer.types.lhs == "var_arg" then
        ast.lhs.arg = Arg_var(lexer.tokens[1])
    elseif lexer.types.lhs == "attr_arg" then
        ast.lhs.arg = Arg_attr(lexer.tokens[1], lexer.tokens[2])
        index = index + 1
    else
        Error("Erro em Parser_assign: Tipo de lhs não reconhecido")
        return {}
    end

    ast.rhs.type = lexer.types.rhs
    if lexer.types.rhs == "number_arg" then
        local number = lexer.tokens[index + 1]
        ast.rhs.arg = Arg_number(number)

    elseif lexer.types.rhs == "var_arg" then
        local var_name = lexer.tokens[index + 1]
        ast.rhs.arg = Arg_var(var_name)

    elseif lexer.types.rhs == "attr_arg" then
        local var_name = lexer.tokens[index + 1]
        local attr_name = lexer.tokens[index + 2]
        ast.rhs.arg = Arg_attr(var_name, attr_name)

    elseif lexer.types.rhs == "method_call_arg" then
        local var_name = lexer.tokens[index + 1]
        local method_name = lexer.tokens[index + 2]
        local vars_list = Arg_var_list(lexer.tokens[index + 3])
        ast.rhs.arg = Arg_method_call(var_name, method_name, vars_list)

    elseif lexer.types.rhs == "obj_creation_arg" then
        local class_name = lexer.tokens[index + 1]
        ast.rhs.arg = Arg_obj_creation(class_name)

    elseif lexer.types.rhs == "binary_operation_arg" then
        local var_name1 = lexer.tokens[index + 1]
        local var_name2 = lexer.tokens[index + 3]
        local operator = lexer.tokens[index + 2]
        ast.rhs.arg = Arg_binary_operation(var_name1, var_name2, operator)

    else
        Error("Erro em Parser_assign: Tipo de rhs não reconhecido")
        return {}
    end

    return ast
end


--- Analisa a sintaxe de uma declaração de variáveis e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- var_list: Arg_var_list
function Parser_vars_def(lexer)
    check_lexer(lexer, "Parser_vars_def", "vars_def", 1)

    local ast = {}
    local vars_string

    vars_string = lexer.tokens[1]
    ast.type = lexer.types.type
    ast.var_list = Arg_var_list(vars_string)

    return ast
end


--- Analisa a sintaxe de uma meta-ação e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- action_type: string
---- str_no_nl: string
---- arg: Arg_Method_Call {var_name, method_name, params: line_number}
function Parser_meta_action(lexer)
    check_lexer(lexer, "Parser_meta_action", "meta_action", 5)

    local ast = {}
    local var_name, method_name, line_number

    var_name = lexer.tokens[1]
    method_name = lexer.tokens[2]
    line_number = { line_number = tonumber(lexer.tokens[4]) }

    ast.type = lexer.types.type
    ast.arg = Arg_method_call(var_name, method_name, line_number)
    ast.action_type = lexer.tokens[3] or {}
    ast.str_no_nl = lexer.tokens[5]

    return ast
end


--- Analisa a sintaxe de um _prototype e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- lhs: Arg_var {var_name}
---- rhs: Arg_var {var_name}
function Parser_prototype(lexer)
    check_lexer(lexer, "Parser_prototype", "prototype", 2)

    local ast = {}
    local lhs_name, rhs_name
    lhs_name = Arg_var(lexer.tokens[1])
    rhs_name = Arg_var(lexer.tokens[2])
    ast.type = lexer.types.type
    ast.lhs = lhs_name
    ast.rhs = rhs_name

    return ast
end


--- Analisa a sintaxe de um retorno e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- arg: Arg_var
function Parser_return(lexer)
    check_lexer(lexer, "Parser_return", "return", 1)

    local ast = {}
    ast.type = lexer.types.type
    ast.arg = Arg_var(lexer.tokens[1])

    return ast
end


--- Analisa a sintaxe de uma chamada de método e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- arg: Arg_method_call {var_name, method_name, params: Arg_var_list}
function Parser_method_call(lexer)
    check_lexer(lexer, "Parser_method_call", "method_call", 3)

    local ast = {}
    local var_name, method_name, vars_list
    var_name = lexer.tokens[1]
    method_name = lexer.tokens[2]
    -- Parser_vars_def({types={type="vars_def"}, tokens=lexer.tokens[3]})
    if (lexer.tokens[3] == "") then
        vars_list = {}
    else
        vars_list = Arg_var_list(lexer.tokens[3])
    end
    ast.type = lexer.types.type
    ast.arg = Arg_method_call(var_name, method_name, vars_list)

    return ast
end


--- Analisa a sintaxe de um if ou if-else e constrói uma AST (Abstract Syntax Tree)
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast:
---- type: string
---- lhs: Arg_var
---- rhs: Arg_var
---- cmp: string
---- if_block: string
---- else_block: string
function Parser_if(lexer)
    check_lexer(lexer, "Parser_if", "if", 4)

    local if_block
    local ast = {}
    ast.type = lexer.types.type
    ast.lhs = Arg_var(lexer.tokens[1]) or {}
    ast.rhs = Arg_var(lexer.tokens[3]) or {}
    ast.cmp = lexer.tokens[2] or ""
    if_block = lexer.tokens[4] or {}


    if (if_block == nil) then
        Error("Erro em Parser_if: Lexer não possui o if_block")
        return {}
    end

    -- Checar se é um if-block ou um if-else-block
    local blocks = { if_block:match(_Else_pattern_) }
    if #blocks == 2 then
        -- É um bloco if-else-block
        ast.if_block = blocks[1]
        ast.else_block = blocks[2]
    else
        ast.if_block = if_block
    end

    return ast
end


--- Seleciona o Parser de acordo com o tipo de lexer da Main
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast
function Parser_main_stmt(lexer)
    if lexer.types.type == "method_call" then
        return Parser_method_call(lexer)
    elseif lexer.types.type == "meta_action" then
        return Parser_meta_action(lexer)
    elseif lexer.types.type == "if" then
        return Parser_if(lexer)
    elseif lexer.types.type == "assignment" then
        return Parser_assign(lexer)
    elseif lexer.types.type == "prototype" then
        return Parser_prototype(lexer)
    else
        Error("Erro em Parser_main_stmt: Declaração com sintaxe incorreta")
        return {}
    end
end


--- Seleciona o Parser de acordo com o tipo de lexer da Method
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast
function Parser_method_stmt(lexer)
    if lexer.types.type == "method_call" then
        return Parser_method_call(lexer)
    elseif lexer.types.type == "meta_action" then
        return Parser_meta_action(lexer)
    elseif lexer.types.type == "if" then
        return Parser_if(lexer)
    elseif lexer.types.type == "assignment" then
        return Parser_assign(lexer)
    elseif lexer.types.type == "return" then
        return Parser_return(lexer)
    elseif lexer.types.type == "prototype" then
        return Parser_prototype(lexer)
    else
        Error("Erro em Parser_method_stmt: Declaração com sintaxe incorreta")
        return {}
    end
end


--- Seleciona o Parser de acordo com o tipo de lexer da If
---@param lexer table: {types: {type}, tokens: {}}
---@return table:
--- Returns ast
function Parser_if_stmt(lexer)
    if lexer.types.type == "method_call" then
        return Parser_method_call(lexer)
    elseif lexer.types.type == "meta_action" then
        return Parser_meta_action(lexer)
    elseif lexer.types.type == "assignment" then
        return Parser_assign(lexer)
    elseif lexer.types.type == "return" then
        return Parser_return(lexer)
    else
        Error("Erro em Parser_if_stmt: Declaração com sintaxe incorreta")
        return {}
    end
end
