module Assembler
  # Contains instruction classes and knows how to handle an instruction
  module Instructions
    instruction_list_str = %w(END HBY LBY LOD STR ADD SUB ADI
                              SBI AND ORR XOR NOT SHF BRN SPC)
    INSTRUCTION_LIST = instruction_list_str.map(&:to_sym)

    def self.instruction?(first_word_symbol)
      INSTRUCTION_LIST.include? first_word_symbol
    end

    # Basic functionality for all Instructions
    class Instruction < Command
      def word_length
        1
      end

      def machine_code(symbol_table)
        [Instructions.make_word(*nibbles(symbol_table))]
      end
    end

    # Superclass for any Instruction where
    # all its arguments must be tokenized by the Assembler::Token class
    class InstructionWithOnlyTokenArgs < Instruction
      def initialize(args_str)
        @tokens = args_str.split.map { |a| Token.new a }
      end

      private

      def nibbles(symbol_table)
        ints = @tokens.map { |token| token.get_int(symbol_table) }
        [self.class::OP_CODE] + get_3_nibbles(*ints)
      end

      # Default implementation for instructions with 3 Token arguments
      # Override for Instruction classes with 2 Token arguments
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

    # get_3_nibbles for HBY and LBY instructions
    get_3_nibbles_hby_lby = lambda do |value, register|
      [value >> 4, value & 0xFF, register]
    end

    # get_3_nibbles for LOD and NOT instructions
    get_3_nibbles_lod_not =
        lambda do |source_register, destination_register|
          [source_register, 0, destination_register]
        end

    # get_3_nibbles for STR instruction
    get_3_nibbles_str = lambda do |address, register|
      [address, register, 0]
    end

    instructions_with_2_operands = [
      [:HBY, 1, get_3_nibbles_hby_lby],
      [:LBY, 2, get_3_nibbles_hby_lby],
      [:LOD, 3, get_3_nibbles_lod_not],
      [:STR, 4, get_3_nibbles_str],
      [:NOT, 0xC, get_3_nibbles_lod_not]
    ]
    instructions_with_2_operands.each do |name, code, function|
      c = Class.new(InstructionWithOnlyTokenArgs) do
        define_method(:get_3_nibbles, &function)
        private :get_3_nibbles
      end
      c::OP_CODE = code
      const_set name, c
    end

    # The end program (halt) instruction
    class ENDi < Instruction
      def initialize(_)
      end

      def nibbles(_)
        [0, 0, 0, 0]
      end
    end

    # The shift instruction
    class SHF < Instruction
      def initialize(args_str)
        rs1, dir, ammount, rd = args_str.split
        @rs1 = Token.new rs1
        @dir = dir
        @ammount = Token.new ammount
        @rd = Token.new rd
      end

      def nibbles(symbol_table)
        rs1 = @rs1.get_int symbol_table
        ammount = @ammount.get_int(symbol_table) - 1
        ammount += 8 if @dir == 'R'
        rd = @rd.get_int symbol_table
        [0xD, rs1, ammount, rd]
      end
    end

    # The branch instruction
    class BRN < Instruction
      def initialize(args_str)
        args = args_str.split
        @cond, value_str =
          if args.length == 3
            parse_nzp_condition_value(args)
          else
            parse_cv_condition_value(args)
          end
        @value_register = Token.new(value_str)
        @address_register = Token.new(args[-1])
      end

      def nibbles(symbol_table)
        rv = @value_register.get_int symbol_table
        rp = @address_register.get_int symbol_table
        [0xE, rv, rp, @cond]
      end

      private

      def parse_nzp_condition_value(args)
        nzp = args[1]
        cond = 0
        cond += 4 if nzp =~ /N/
        cond += 2 if nzp =~ /Z/
        cond += 1 if nzp =~ /P/
        [cond, args[0]]
      end

      def parse_cv_condition_value(args)
        code = parse_cv_code(args[0])
        [8 | code, '0']
      end

      def parse_cv_code(cv)
        str = 'Bad condition code in BRN, should be - C or V, ' \
              "but got #{cv.inspect} instead"
        case cv
        when 'V' then 2
        when 'C' then 1
        when '-' then 0
        else fail AsmError, str
        end
      end
    end

    # The "save the program counter" instruction
    class SPC < Instruction
      def initialize(args_str)
        @rs1 = Token.new args_str
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
      const_get(op_code_symbol).new(args_str)
    end
  end
end
