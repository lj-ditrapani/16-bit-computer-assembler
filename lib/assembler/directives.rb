module Assembler
  # Contains directive classes and knows how to handle directives
  module Directives
    DIRECTIVE_LIST = [
      :'.label',
      :'.set',
      :'.word',
      :'.array',
      :'.fill-array',
      :'.str',
      :'.long-string',  # .end-long-string consumed by LongString class
      :'.move',
      :'.include',
      :'.copy'
    ]

    def self.directive?(first_word_symbol)
      DIRECTIVE_LIST.include? first_word_symbol
    end

    def self.directive_to_class_name(symbol)
      str_list = symbol[1..-1].split('-').map(&:capitalize)
      str_list.push('Directive').join.to_sym
    end

    # insert 16-bit value at current memory address
    class WordDirective < Command
      FORMAT = 'T'

      def initialize(args_str)
        @value = args(args_str)[0]
        super()
      end

      def machine_code(symbol_table)
        [@value.get_int(symbol_table)]
      end
    end

    # Move cursor forward to memory address and zero-fill hole
    class MoveDirective < Command
      FORMAT = 'T'

      def initialize(args_str, word_index, symbol_table)
        address_token = args(args_str)[0]
        address = address_token.get_int symbol_table
        @word_length = address - word_index
      end

      def machine_code(_symbol_table)
        (0...@word_length).map { 0x0000 }
      end
    end

    # Set contiguous memory addresses to specified values
    class ArrayDirective < Command
      def initialize(args_str, source)
        check_for_open_bracket(args_str)
        lines = get_array_lines(args_str, source)
        @tokens = lines_to_tokens(lines)
        @word_length = @tokens.length
      end

      def machine_code(symbol_table)
        @tokens.map { |t| t.get_int(symbol_table) }
      end

      private

      def check_for_open_bracket(args_str)
        found = args_str[0] == '['
        fail AsmError, "Array must start with '['" unless found
      end

      def get_array_lines(args_str, source)
        line = args_str[1..-1]
        lines = [line]
        until line =~ /]/
          fail AsmError, "Missing ']' to end array" if source.empty?
          line = source.pop_sub_line.strip
          lines.push line
        end
        lines
      end

      def lines_to_tokens(lines)
        # Remove trailing ']'
        lines[-1] = lines[-1].gsub!(']', '')
        str = lines.join ' '
        str.split.map { |e| Token.new(e) }
      end
    end

    # Set contiguous memory addresses all to same value
    class FillArrayDirective < Command
      FORMAT = 'T T'

      def initialize(args_str, _, symbol_table)
        size, @fill = args(args_str)
        @word_length = size.get_int symbol_table
      end

      def machine_code(symbol_table)
        [@fill.get_int(symbol_table)] * @word_length
      end
    end

    # Set following memory address to ASCII values of string
    class StrDirective < Command
      def initialize(args_str)
        @code = args_str.split('').map(&:ord)
        @code.unshift @code.length
        @word_length = @code.length
      end

      def machine_code(_symbol_table)
        @code
      end
    end

    # Set following memory address to ASCII values of multi-line string
    class LongStringDirective < Command
      FORMAT = 'S'

      def initialize(args_str, source)
        char = get_join_char(args(args_str)[0])
        lines = get_string_lines(source)
        @code = lines.join(char).split('').map(&:ord)
        @code.unshift @code.length
        @word_length = @code.length
      end

      def machine_code(_symbol_table)
        @code
      end

      private

      def get_string_lines(source)
        lines = []
        line = check_and_pop source
        until line.strip == '.end-long-string'
          lines.push line.text
          line = check_and_pop source
        end
        lines
      end

      def check_and_pop(source)
        msg = 'Missing .end-long-string to end .long-string directive'
        fail(AsmError, msg) if source.empty?
        source.pop_sub_line
      end

      def get_join_char(args_str)
        msg = '.long-string parameter must be keep-newlines or ' \
              "strip-newlines. Received #{args_str.inspect} instead"
        case args_str
        when 'keep-newlines'
          "\n"
        when 'strip-newlines'
          ''
        else
          fail AsmError, msg
        end
      end
    end

    # Copy binary value from file directly into program
    class CopyDirective < Command
      FORMAT = 'F'

      def initialize(args_str)
        @code = IO.read(args(args_str)[0]).unpack('S>*')
        @word_length = @code.length
      end

      def machine_code(_symbol_table)
        @code
      end
    end

    # A command that does not generate any machine code
    class NoMachineCodeCommand < Command
      def word_length
        0
      end

      def machine_code(_symbol_table)
        []
      end
    end

    # Sets entry in symbol table with key as label name and value as
    # current word index.  User text is of form `(label-name)`, but Line
    # text is transformed to `.label (label-name)`
    class LabelDirective < NoMachineCodeCommand
      FORMAT = 'S'

      def self.label?(text)
        text[0] == '('
      end

      def self.to_directive_form(text)
        '.label ' + text
      end

      def initialize(args_str, word_index, symbol_table)
        args(args_str)            # Ensure exactly 1 argument
        unless args_str[-1] == ')'
          fail AsmError, "Missing closing ')' in label '#{args_str}'"
        end
        symbol_table[args_str[1...-1]] = word_index
      end
    end

    # Add entry in symbol table with key as first argument and
    # value as second argument
    class SetDirective < NoMachineCodeCommand
      FORMAT = 'S T'

      def initialize(args_str, _word_index, symbol_table)
        name, token = args args_str
        symbol_table.set_token(name, token)
      end
    end

    # Include in source lines from file specified by file-name argument
    class IncludeDirective < NoMachineCodeCommand
      FORMAT = 'F'

      def initialize(args_str, source)
        source.include_file(args(args_str)[0])
      end
    end

    def self.handle(line, source, symbol_table)
      directive = line.first_word.to_sym
      directive_class = const_get directive_to_class_name directive
      args = [line.args_str]
      case directive
      when :'.move', :'.set', :'.label', :'.fill-array'
        args += [line.word_index, symbol_table]
      when :'.array', :'.long-string', :'.include'
        args.push(source)
      end
      directive_class.new(*args)
    end
  end
end
