module Assembler::PseudoInstructions

  class CYP < Assembler::Command
    def initialize(args_str)
      super
    end
  end

  class NOP < Assembler::Command
    def initialize(args_str)
      super
    end
  end

  class WRD < Assembler::Command
    def initialize(args_str)
      # get value, store for later
      value_str, register = args_str.split
      @value = Assembler::Token.new value_str
      @register = Assembler::Token.new register
      @word_length = 2
    end

    def machine_code(symbol_table)
      value = @value.get_int symbol_table
      high_byte = value >> 8
      low_byte = value & 0x00FF
      rd = @register.get_int symbol_table
      [1 << 12 | high_byte << 4 | rd, 2 << 12 | low_byte << 4 | rd]
    end
  end

  class INC < Assembler::Command
    def initialize(args_str)
      super()
      @register = Assembler::Token.new args_str
    end

    def machine_code(symbol_table)
      register = @register.get_int symbol_table
      [7 << 12 | register << 8 | 1 << 4 | register]
    end
  end

  class DEC < Assembler::Command
    def initialize(args_str)
      super()
      @register = Assembler::Token.new args_str
    end

    def machine_code(symbol_table)
      register = @register.get_int symbol_table
      [8 << 12 | register << 8 | 1 << 4 | register]
    end
  end

  class JMP < Assembler::Command
    def initialize(args_str)
      super()
      @register = Assembler::Token.new args_str
    end

    def machine_code(symbol_table)
      register = @register.get_int symbol_table
      [0xE << 12 | 0 << 8 | register << 4 | 7]
    end
  end

  def self.handle(op_code_symbol, args_str)
    const_get(op_code_symbol).new(args_str)
  end
end
