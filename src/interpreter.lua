require "patterns"
require "files"
require "reader"
require "executor"
require "describer"


--- Função que inicia a interpretação do programa
local function main()
    local file = Get_file(arg[1])
    local line = Read_line(file)
    local describer = Get_describer()
    local class_block, main_block

    while line do
        -- <class-def> encontrado
        if line:match("^" .. _Class_def_begin_pattern_ .. "$") then
            class_block = Read_class_block(file, line)
            describer:insert_class(class_block)

        -- <main-body> encontrado
        elseif line:match("^" .. _Main_body_begin_pattern_ .. "$") then
            main_block = Read_main_block(file, line)
            describer:insert_main(main_block)
            break

        elseif not line:match(_Empty_line_pattern_) then
            Error("Erro em Main: Erro de sintaxe\nLinha: " .. line)
        end

        line = Read_line(file)
    end

    while line do
        line = Read_line(file)
        if line and not line:match(_Empty_line_pattern_) then
            Error("Erro em Main: Linha não vazia após a leitura do bloco principal")
        end
    end

    -- Busca o buffer da main pelo descritor
    local main_block_buffer = describer:string_table_concat(describer.main)
    local main_env = Env:new()

    -- Executa a main
    Main_executor(main_env, main_block_buffer)

    file:close()
end


-- Início da interpretação do programa
main()
