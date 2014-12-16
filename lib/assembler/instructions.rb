module Assembler
  # Contains instruction classes and knows how to handle an instruction
  module Instructions
    # Basic functionality for all Instructions
    class Instruction
      def word_length
        1
      end

      def machine_code(symbol_table)
        [Assembler::Instructions.make_word(*nibbles(symbol_table))]
      end
    end

    # Superclass for any Instruction where
    # all its arguments must be tokenized by the Assembler::Token class
    class InstructionWithOnlyTokenArgs < Instruction
      def initialize(args_str)
        @tokens = args_str.split.map { |a| Assembler::Token.new a }
      end

      private

      def nibbles(symbol_table)
        ints = @tokens.map { |token| token.get_int(symbol_table) }
        [self.class::OP_CODE] + get_3_nibbles(*ints)
      end

      # Default implementation for instructions with 3 Token arguments
      # Override for individual Instruction classes with 2 Token arguments
      def get_3_nibbles(*args)
        args
      end
    end

    # Define instructions that have 3 Token arguments
    instructions_with_3_operands = [
      [:ADD, 5],
      [:SUB, 6],
      [:ADI, 7],
      [:SBI, 8],
      [:AND, 9],
      [:ORR, 10],
      [:XOR, 11]
    ]
    instructions_with_3_operands.each do |name, code|
      c = Class.new(InstructionWithOnlyTokenArgs)
      c::OP_CODE = code
      const_set name, c
    end

    # Define instructions that have 2 Token arguments

    get_3_nibbles_HBY_LBY = lambda do |value, register|
      [value >> 4, value & 0xFF, register]
    end

    get_3_nibbles_LOD_NOT =
        lambda do |source_register, destination_register|
          [source_register, 0, destination_register]
        end

    get_3_nibbles_STR = lambda do |address, register|
      [address, register, 0]
    end

    instructions_with_2_operands = [
      [:HBY, 1, get_3_nibbles_HBY_LBY],
      [:LBY, 2, get_3_nibbles_HBY_LBY],
      [:LOD, 3, get_3_nibbles_LOD_NOT],
      [:STR, 4, get_3_nibbles_STR],
      [:NOT, 0xC, get_3_nibbles_LOD_NOT]
    ]
    instructions_with_2_operands.each do |name, code, function|
      c = Class.new(InstructionWithOnlyTokenArgs) do
        define_method(:get_3_nibbles, &function)
        private :get_3_nibbles
      end
      c::OP_CODE = code
      const_set name, c
    end

    class ENDi < Instruction
      def initialize(_)
      end

      def nibbles(_)
        [0, 0, 0, 0]
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
          str = 'Bad condition code in BRN, should be - C or V, but got'\
                " #{cv.inspect} instead"
          value = case cv
                  when 'V' then 2
                  when 'C' then 1
                  when '-' then 0
                  else fail Assembler::AsmError, str
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
      # END is a reserved word; rename to ENDi
      op_code_symbol = :ENDi if op_code_symbol == :END
      const_get(op_code_symbol).new args_str
    end
  end
end
