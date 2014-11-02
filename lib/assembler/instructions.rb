module Assembler::Instructions

  class HBY < Assembler::Command
    def initialize(args_str)
      super()
      value_str, register = args_str.split
      @value = Assembler::Token.new value_str
      @register = Assembler::Token.new register
    end

    def machine_code(symbol_table)
      value = if @value.type == :int
                @value.value
              else
                symbol_table[@value.value]
              end
      register = if @register.type == :int
                   @register.value
                 else
                   symbol_table[@register.value]
                 end
      [1 << 12 | value << 4 | register]
    end
  end

  class LBY < Assembler::Command
    def initialize(args_str)
      super()
      value_str, register = args_str.split
      @value = Assembler::Token.new value_str
      @register = Assembler::Token.new register
    end

    def machine_code(symbol_table)
      value = if @value.type == :int
                @value.value
              else
                symbol_table[@value.value]
              end
      register = if @register.type == :int
                   @register.value
                 else
                   symbol_table[@register.value]
                 end
      [2 << 12 | value << 4 | register]
    end
  end

  def self.handle(op_code_symbol, args_str)
    if [:HBY, :LBY].include? op_code_symbol
      const_get(op_code_symbol).new args_str
    end
  end

end
