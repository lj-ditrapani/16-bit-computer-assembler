# Toplevel module
module Assembler
  # Instructions, pseudo-instructions, and most directives
  # are commands (or follow the Command interface).
  # They generate machine code and know how long the
  # machine code will be via the word_length method.
  class Command
    attr_reader :word_length

    def initialize
      @word_length = 1
    end

    def machine_code(_symbol_table)
      []
    end
  end

  class AsmError < StandardError
  end

  # A Token contains an int or a symbol that refers to an int
  class Token
    attr_reader :type, :value

    def initialize(str)
      if ['$', '%', /\d/].any? { |match| match === str[0] }
        @type = :int
        @value = Assembler.to_int str
      else
        @type = :symbol
        @value = str.to_sym
        # could check for invalid symbols
      end
    end

    def get_int(symbol_table)
      if @type == :int
        @value
      else
        symbol_table[@value]
      end
    end

    def to_s
      "#<Assembler::Token #{@type} #{@value}>"
    end
  end

  # Holds the list of assembly lines yet to be processed
  class Assembly
    attr_reader :line_number

    def initialize(lines)
      @line_number = 0
      @lines = lines
    end

    def pop_line
      @line_number += 1
      @lines.shift.chomp
    end

    def empty?
      @lines.empty?
    end

    def include(lines)
      @lines = lines + @lines
    end
  end

  # Holds the list of commands parsed so far
  # Once the first pass is finished, the command list will contain all
  # the commands and the symbol table will be complete.
  # The second pass can actually generate the machine code, since the
  # symbol table is complete at that point.
  class CommandList
    attr_reader :word_index

    def initialize
      # The index of the next free address
      @word_index = 0
      @commands = []
    end

    def add_command(cmd)
      @commands.push cmd
      inc_words cmd.word_length
    end

    def inc_words(n)
      @word_index += n
    end

    def word_length
      @word_index
    end

    def machine_code(symbol_table)
      array = @commands.map { |cmd| cmd.machine_code symbol_table }
      array.flatten
    end

    def machine_code(symbol_table)
      @commands.reduce([]) do |array, cmd|
        array.concat cmd.machine_code(symbol_table)
      end
    end
  end
end
