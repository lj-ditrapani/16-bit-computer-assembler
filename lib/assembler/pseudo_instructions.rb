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
    end
  end

  class INC < Assembler::Command
    def initialize(args_str)
    end
  end

  class DEC < Assembler::Command
    def initialize(args_str)
    end
  end

  class JMP < Assembler::Command
    def initialize(args_str)
    end
  end

  def self.handle(op_code_symbol, args_str)
    const_get(op_code_symbol).new(args_str)
  end
end
