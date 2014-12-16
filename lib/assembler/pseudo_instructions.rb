# Contains pseudo-instructions classes and knows how to handle a
# pseudo-instruction
module Assembler::PseudoInstructions
  class CPY < Assembler::Instructions::ADI
    def initialize(args_str)
      source, destination = args_str.split
      super("#{source} 0 #{destination}")
    end
  end

  class NOP < Assembler::Instructions::ADI
    def initialize(_args_str)
      # ADI R0 0 R0   ---  R0 + 0 => R0
      super("0 0 0")
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

  class INC < Assembler::Instructions::ADI
    def initialize(args_str)
      super("#{args_str} 1 #{args_str}")
    end
  end

  class DEC < Assembler::Instructions::SBI
    def initialize(args_str)
      super("#{args_str} 1 #{args_str}")
    end
  end

  class JMP < Assembler::Instructions::BRN
    def initialize(args_str)
      super("0 NZP " + args_str)
    end
  end

  def self.handle(op_code_symbol, args_str)
    const_get(op_code_symbol).new(args_str)
  end
end
