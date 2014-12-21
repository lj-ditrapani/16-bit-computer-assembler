# Toplevel module
module Assembler
  # Instructions, pseudo-instructions, and most directives
  # are commands (or follow the Command interface).
  # They generate machine code and know how long the
  # machine code will be via the word_length method.
  # Command is subclassed by PseudoInstructions::WRD & all Directives
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

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      value = super(key.to_sym)
      message = "Undefined symbol: #{key.inspect}"
      fail(Assembler::AsmError, message) if value.nil?
      value
    end

    def set_token(name_symbol, value_token)
      self[name_symbol] = get_int value_token
    end

    private

    def get_int(value_token)
      if value_token.type == :symbol
        self[value_token.value]
      else
        value_token.value
      end
    end
  end

  # Holds the list of source assembly lines yet to be processed
  class Source
    attr_reader :line_number, :current_line

    def initialize
      @lines = []
    end

    def pop_line
      @current_line = @lines.shift
    end

    def empty?
      @lines.empty?
    end

    def include_file(file_name)
      text_lines = File.readlines(file_name)
      include_lines text_lines, file_name
      self
    end

    def include_lines(text_lines, file_name = 'no-file-given')
      new_lines = text_to_lines(file_name, text_lines)
      @lines = new_lines + @lines
      self
    end

    def text_to_lines(file_name, text_lines)
      text_lines.map.with_index(1) do |text, line_number|
        Line.new(file_name, line_number, text.chomp)
      end
    end

    private :text_to_lines

    # Holds a line of source assembly text
    class Line
      attr_accessor :word_length
      attr_reader :text, :source_info

      def initialize(file_name, line_number, text)
        @source_info = SourceInfo.new file_name, line_number, text
        @text = text
      end

      def first_word
        @first_word ||= strip.split(' ', 2)[0]
      end

      def args_str
        @args_str ||= text_to_split.split(' ', 2)[1]
      end

      # Removes white space a begining and end and comments
      # Do not call on .str or lines betwenn .long-string
      def strip
        @strip ||= _strip
      end

      def empty?
        strip.empty?
      end

      private

      def text_to_split
        if first_word == '.str'   # don't strip a .str directive
          @text
        else                      # only strip if not a .str directive
          strip
        end
      end

      def _strip
        text_line = @text.strip
        return '' if text_line.empty? || text_line[0] == '#'
        text_line.split('#', 2)[0].strip
      end

      # Contains `file_name`, `line_number`, and `text` state.
      # Has `error_info` method.
      # Holds information for Line and Command objects so when an
      # exception occurs, source line information can be presented to
      # the user.
      class SourceInfo
        def initialize(file_name, line_number, text)
          @file_name, @line_number, @text = file_name, line_number, text
        end

        def error_info
          ["ASSEMBLER ERROR in file #{@file_name}",
           "LINE # #{@line_number}",
           "SOURCE CODE: #{@text}"]
        end
      end
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
