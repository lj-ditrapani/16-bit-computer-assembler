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

  class SUB < Assembler::Command
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
      [6 << 12 | rs1 << 8 | rs2 << 4 | rd]
    end
  end

  class ADI < Assembler::Command
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
      [7 << 12 | rs1 << 8 | rs2 << 4 | rd]
    end
  end

  class SBI < Assembler::Command
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
      [8 << 12 | rs1 << 8 | rs2 << 4 | rd]
    end
  end

  class SHF < Assembler::Command
    def initialize(args_str)
      super()
      rs1, dir, ammount, rd = args_str.split
      @rs1 = Assembler::Token.new rs1
      @dir = dir
      @ammount = Assembler::Token.new ammount
      @rd = Assembler::Token.new rd
    end

    def machine_code(symbol_table)
      rs1 = @rs1.get_int symbol_table
      ammount = @ammount.get_int(symbol_table) - 1
      ammount += 8 if @dir == 'R'
      rd = @rd.get_int symbol_table
      [0xD << 12 | rs1 << 8 | ammount << 4 | rd]
    end
  end

  class BRN < Assembler::Command
    def initialize(args_str)
      super()
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
                else raise Assembler::AsmError.new, str
                end
        @cond = 8 | value
      end
      @address_register = Assembler::Token.new args.shift
    end

    def machine_code(symbol_table)
      rv = @value_register.get_int symbol_table
      rp = @address_register.get_int symbol_table
      [0xE << 12 | rv << 8 | rp << 4 | @cond]
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
    list = [
      :END, :HBY, :LBY, :LOD, :STR, :ADD, :SUB, :ADI, :SBI, :SHF, :BRN
    ]
    if list.include? op_code_symbol
      # END is a reserved word; rename to END_
      if op_code_symbol == :END
        op_code_symbol = :END_
      end
      const_get(op_code_symbol).new args_str
    end
  end

end
