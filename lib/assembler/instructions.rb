module Assembler::Instructions

  class Instruction
    attr_reader :word_length

    def word_length
      1
    end

    def machine_code(symbol_table)
      [Assembler::Instructions.make_word(*nibbles(symbol_table))]
    end
  end

  class Instruction3 < Instruction
    def initialize(args_str)
      rs1, rs2, rd = args_str.split
      @rs1 = Assembler::Token.new rs1
      @rs2 = Assembler::Token.new rs2
      @rd = Assembler::Token.new rd
    end

    def nibbles(symbol_table)
      rs1 = @rs1.get_int symbol_table
      rs2 = @rs2.get_int symbol_table
      rd = @rd.get_int symbol_table
      [self.class::OP_CODE, rs1, rs2, rd]
    end
  end

  instructions_with_3_operands = [
    [:ADD, 5],
    [:SUB, 6],
    [:ADI, 7],
    [:SBI, 8],
    [:AND, 9],
    [:ORR, 10],
    [:XOR, 11],
  ]
  instructions_with_3_operands.each do |name, code|
    c = Class.new(Instruction3)
    c::OP_CODE = code
    const_set name, c
  end

  class END_ < Instruction
    def initialize(_)
    end

    def nibbles(_)
      [0, 0, 0, 0]
    end
  end

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

  class NOT < Assembler::Command
    def initialize(args_str)
      super()
      rs1, rd = args_str.split
      @rs1 = Assembler::Token.new rs1
      @rd = Assembler::Token.new rd
    end

    def machine_code(symbol_table)
      rs1 = @rs1.get_int symbol_table
      rd = @rd.get_int symbol_table
      [0xC << 12 | rs1 << 8 | rd]
    end
  end

  class SHF < Instruction
    def initialize(args_str)
      rs1, dir, ammount, rd = args_str.split
      @rs1 = Assembler::Token.new rs1
      @dir = dir
      @ammount = Assembler::Token.new ammount
      @rd = Assembler::Token.new rd
    end

    def nibbles(symbol_table)
      rs1 = @rs1.get_int symbol_table
      ammount = @ammount.get_int(symbol_table) - 1
      ammount += 8 if @dir == 'R'
      rd = @rd.get_int symbol_table
      [0xD, rs1, ammount, rd]
    end
  end

  class BRN < Instruction
    def initialize(args_str)
      args = args_str.split
      if args.length == 3
        @value_register = Assembler::Token.new args.shift
        nzp = args.shift
        cond = 0
        cond += 4 if nzp =~ /N/
        cond += 2 if nzp =~ /Z/
        cond += 1 if nzp =~ /P/
        @cond = cond
      else
        @value_register = Assembler::Token.new '0'
        cv = args.shift
        str = "Bad condition code in BRN, should be - C or V, but got"\
              " #{cv.inspect} instead"
        value = case cv
                when 'V' then 2
                when 'C' then 1
                when '-' then 0
                else raise Assembler::AsmError, str
                end
        @cond = 8 | value
      end
      @address_register = Assembler::Token.new args.shift
    end

    def nibbles(symbol_table)
      rv = @value_register.get_int symbol_table
      rp = @address_register.get_int symbol_table
      [0xE, rv, rp, @cond]
    end
  end

  class SPC < Instruction
    def initialize(args_str)
      @rs1 = Assembler::Token.new args_str
    end

    def nibbles(symbol_table)
      rs1 = @rs1.get_int symbol_table
      [0xF, 0, 0, rs1]
    end
  end

  def self.make_word(op_code, a, b, c)
    op_code << 12 | a << 8 | b << 4 | c
  end

  def self.handle(op_code_symbol, args_str)
    # END is a reserved word; rename to END_
    if op_code_symbol == :END
      op_code_symbol = :END_
    end
    const_get(op_code_symbol).new args_str
  end

end
