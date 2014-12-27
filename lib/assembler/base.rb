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

    def args(args_str)
      Args.new(self.class::FORMAT).parse(args_str)
    end
  end

  AsmError = Class.new(StandardError)

  # A Token contains an int or a symbol that refers to an int
  class Token
    attr_reader :type, :value

    def initialize(str, limit_exp = 16)
      @limit_exp = limit_exp
      if [/\$/, /%/, /\d/].any? { |match| match =~ str[0] }
        @type = :int
        @value = to_int str
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
        to_int(symbol_table[@value].to_s)
      end
    end

    def to_s
      "#<Assembler::Token #{@type} #{@value}>"
    end

    private

    def to_int(str)
      Int16.to_int str, @limit_exp
    end
  end

  # Code to parse 16-bit integer from string.
  # `to_int` is the public method
  module Int16
    POWERS_2 = { 4 => 16, 8 => 256, 16 => 65_536 }

    def self.to_int(str, limit_exp = 16)
      raise_malformed str if /^\d[x|X]/ =~ str[0..1]
      start, base = get_start_and_base str[0]
      num = to_int_with_start_and_base(str, start, base)
      limit = POWERS_2[limit_exp]
      raise_too_large(str, limit) if num >= limit
      raise_negative str if num < 0
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
      raise_asm_error "Malformed integer: '#{str}'"
    end

    def self.raise_too_large(str, limit)
      raise_asm_error "Value must be less than #{limit}: '#{str}'"
    end

    def self.raise_negative(str)
      raise_asm_error "Negative numbers not allowed: '#{str}'"
    end

    def self.raise_asm_error(message)
      fail AsmError, message
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

  # Parses the argument string of a command according to the given
  # format.
  # Returns a list of the parsed arguments.
  # fails if the argument string does not match the given format.
  class Args
    def initialize(format)
      format = '' if format == '-'
      @format = format.split
    end

    def parse(args_str)
      parse_all(args_str)
    end

    private

    def parse_all(args_str)
      count = @format.size
      msg = "Expected #{count} arguments, received: '#{args_str}'"
      fail AsmError, msg unless count == args_str.split.size
      @format.zip(args_str.split).map { |f, arg| parse_one(f, arg) }
    end

    def parse_one(format, arg)
      if format == 'S'
        arg
      elsif format == 'F'
        check_file_name arg
      else
        make_token format, arg
      end
    end

    def check_file_name(file_name)
      unless File.file?(file_name)
        fail AsmError, "File does not exist: '#{file_name}'"
      end
      file_name
    end

    def make_token(format, arg)
      limit_exp = { 'T' => 16, '8' => 8, '4' => 4 }[format]
      Token.new arg, limit_exp
    end
  end
end
