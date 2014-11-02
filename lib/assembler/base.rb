module Assembler


  class Command
    attr_reader :word_length

    def initialize
      @word_length = 1
    end

    def machine_code(symbol_table)
      []
    end
  end


  class AsmError < StandardError
  end


  class Token
    attr_reader :type, :value

    def initialize(str)
      if ['$', '%', /\d/].any? {|match| match === str[0]}
        @type = :int
        @value = Assembler.to_int str
      else
        @type = :symbol
        @value = str.to_sym
        # could check for invalid symbols
      end
    end

    def to_s
      "#<Assembler::Token #{@type} #{@value}>"
    end
  end


  class Assembly
    attr_reader :line_number

    def initialize(lines)
      @line_number = 0
      @lines = lines
    end

    def peek_line
      @lines[0]
    end

    def pop_line
      @line_number += 1
      @lines.shift
    end

    def empty?
      @lines.empty?
    end

  end


  class CommandList
    attr_reader :word_index

    def initialize()
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
      array = @commands.map {|cmd| cmd.machine_code symbol_table}
      array.flatten
    end

    def machine_code(symbol_table)
      @commands.reduce([]) do |array, cmd|
        array.concat cmd.machine_code(symbol_table)
      end
    end

  end


end
