# Toplevel module
module Assembler
  # Instructions, pseudo-instructions, and most directives
  # are commands.
  # They generate machine code (via the `machine_code` message) and know
  # how long the machine code will be via the `word_length` method.
  # They also hold a SourceInfo object for error reporting.
  # Command is subclassed by all commands in the Instructions,
  # PseudoInstructions, and Directives modules
  class Command
    attr_accessor :source_info
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
        @value = Int16.to_int str
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

  # Code to parse 16-bit integer from string.
  # `to_int` is the public method
  module Int16
    def self.to_int(str)
      raise_malformed str if /^\d[x|X]/ =~ str[0..1]
      start, base = get_start_and_base str[0]
      num = to_int_with_start_and_base(str, start, base)
      raise_too_large num, str if num > 0xFFFF
      num
    end

    def self.get_start_and_base(first_char)
      case first_char
      when '%' then [1, 2]
      when '$' then [1, 16]
      else [0, 10]
      end
    end

    def self.to_int_with_start_and_base(str, start, base)
      Integer(str[start..-1], base)
    rescue ArgumentError
      raise_malformed str
    end

    def self.raise_malformed(str)
      fail AsmError, "Malformed integer '#{str}'"
    end

    def self.raise_too_large(num, str)
      fail AsmError, "Number greater than $FFFF: #{str}" if num > 0xFFFF
    end
  end

  def self.handle_error(error, source_info)
    msg_lines = ["\n\n****"] +
                source_info.error_info +
                ["#{error.message}",
                 "****\n\n"]
    $stderr.print msg_lines.join("\n")
    exit(1)
  end
end
