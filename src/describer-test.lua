require "describer"
require "utils"

local test_class_table = {
    "class Pessoa",
    "vars num, banana",
    "method calc()",
    "vars y, z",
    "begin",
    "y = x + self.num",
    "io.print(y)",
    "y = new Base",
    "return y",
    "end-method",
    "method mult(x, y)",
    "vars z",
    "begin",
    "y = x + self.num",
    "io.print(y)",
    "y = new Base",
    "return y",
    "end-method",
    "end-class"
}

local test_method_table = {
    "method calc(x)",
    "vars y, z",
    "begin",
    "y = x + self.num",
    "io.print(y)",
    "y = new Base",
    "return y",
    "end-method"
}

local function test_set_class()
    local describer = Get_describer()

    describer:insert_class(test_class_table)

    --print("\nDescricao da Classe")
    --print(describer.classes["Pessoa"].name)
    --print("Attr:")
    --Print_table(describer.classes["Pessoa"].attr)
    --print("------------")
    --for key, value in pairs(describer.classes["Pessoa"].methods) do
    --Print_table(value.body)
    --print("------------")
    --end

    describer:class_dump("Pessoa")

end

local function test_set_method()
    local describer = Get_describer()

    local described_method_table = describer:describe_method(test_method_table)

    print(described_method_table.name)
    Print_table(described_method_table.params)
    Print_table(described_method_table.vars)
    print(describer:string_table_concat(described_method_table.body))

end

test_set_class()
print("\n===========\n")
test_set_method()
