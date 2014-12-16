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
  end

  AsmError = Class.new(StandardError)

  # A Token contains an int or a symbol that refers to an int
  class Token
    attr_reader :type, :value

    def initialize(str)
      if [/\$/, /%/, /\d/].any? { |match| match =~ str[0] }
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

  # Mapping from symbols to integers
  class SymbolTable < Hash
    def self.add_register_symbols
      add_hex_register_symbols(add_decimal_register_symbols(BASE.dup))
    end

    def self.add_decimal_register_symbols(base)
      (0...16).each do |i|
        base[('R' + i.to_s).to_sym] = i
      end
      base
    end

    def self.add_hex_register_symbols(base)
      ('A'..'F').each_with_index do |c, i|
        base[('R' + c).to_sym] = i + 10
      end
      base
    end

    BASE = {
      :audio => 0xD800,
      :"net-in" => 0xDC00,
      :"net-out" => 0xE000,
      :"storage-in" => 0xE400,
      :"storage-out" => 0xE800,
      :tiles => 0xEC00,
      :grid => 0xF400,
      :"cell-x-y-flip" => 0xFD60,
      :sprites => 0xFE8C,
      :"cell-colors" => 0xFF8C,
      :"sprite-colors" => 0xFFAC,
      :keyboard => 0xFFFA,
      :"net-status" => 0xFFFB,
      :"enable-bits" => 0xFFFC,
      :"storage-read-address" => 0xFFFD,
      :"storage-write-address" => 0xFFFE,
      :"frame-interrupt-vector" => 0xFFFF
    }

    SYMBOL_TABLE = add_register_symbols

    def initialize
      super
      merge! SYMBOL_TABLE
    end

    def [](key)
      value = super
      fail Assembler::AsmError, "Undefined symbol: #{key.inspect}" if value.nil?
      value
    end

    def set_token(name_symbol, value_token)
      self[name_symbol] = if value_token.type == :symbol
                            self[value_token.value]
                          else
                            value_token.value
                          end
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
      word_index
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
