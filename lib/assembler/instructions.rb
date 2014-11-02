module Assembler::Instructions

  class HBY < Assembler::Command
    def initialize(args_str)
      super()
      value_str, register = args_str.split
      @value = Assembler::Token.new value_str
      @register = Assembler::Token.new register
    end

    def machine_code(symbol_table)
      value = @value.get_int symbol_table
      register = @register.get_int symbol_table
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
      value = @value.get_int symbol_table
      register = @register.get_int symbol_table
      [2 << 12 | value << 4 | register]
    end
  end

  class LOD < Assembler::Command
    def initialize(args_str)
      super()
      addr_str, register = args_str.split
      @address = Assembler::Token.new addr_str
      @register = Assembler::Token.new register
    end

    def machine_code(symbol_table)
      address = @address.get_int symbol_table
      register = @register.get_int symbol_table
      [3 << 12 | address << 8 | register]
    end
  end

  class STR < Assembler::Command
    def initialize(args_str)
      super()
      addr_str, register = args_str.split
      @address = Assembler::Token.new addr_str
      @register = Assembler::Token.new register
    end

    def machine_code(symbol_table)
      address = @address.get_int symbol_table
      register = @register.get_int symbol_table
      [4 << 12 | address << 8 | register << 4]
    end
  end

  class ADD < Assembler::Command
    def initialize(args_str)
      super()
      rs1, rs2, rd = args_str.split
      @rs1 = Assembler::Token.new rs1
      @rs2 = Assembler::Token.new rs2
      @rd = Assembler::Token.new rd
    end

    def machine_code(symbol_table)
      rs1 = @rs1.get_int symbol_table
      rs2 = @rs2.get_int symbol_table
      rd = @rd.get_int symbol_table
      [5 << 12 | rs1 << 8 | rs2 << 4 | rd]
    end
  end

  class END_ < Assembler::Command
    def initialize(args_str)
      super()
    end

    def machine_code(symbol_table)
      [0x0000]
    end
  end

  def self.handle(op_code_symbol, args_str)
    if [:HBY, :LBY, :LOD, :STR, :ADD, :END].include? op_code_symbol
      # END is a reserved word; rename to END_
      if op_code_symbol == :END
        op_code_symbol = :END_
      end
      const_get(op_code_symbol).new args_str
    end
  end

end
