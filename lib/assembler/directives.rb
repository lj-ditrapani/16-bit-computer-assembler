# Contains directive classes and knows how to handle directives
module Assembler::Directives
  def self.directive_to_class_name(symbol)
    str_list = symbol[1..-1].split('-').map(&:capitalize)
    str_list.push('Directive').join.to_sym
  end

  class WordDirective < Assembler::Command
    def initialize(args_str)
      super()
      @value = Assembler::Token.new args_str
    end

    def machine_code(symbol_table)
      [@value.get_int(symbol_table)]
    end
  end

  class MoveDirective < Assembler::Command
    def initialize(args_str, word_index, symbol_table)
      address_token = Assembler::Token.new args_str
      address = address_token.get_int symbol_table
      @word_length = address - word_index
    end

    def machine_code(_symbol_table)
      (0...@word_length).map { 0x0000 }
    end
  end

  class ArrayDirective < Assembler::Command
    def initialize(args_str, asm)
      check_for_open_bracket(args_str)
      lines = get_array_lines(args_str, asm)
      @tokens = lines_to_tokens(lines)
      @word_length = @tokens.length
    end

    def machine_code(symbol_table)
      @tokens.map { |t| t.get_int(symbol_table) }
    end

    private

    def check_for_open_bracket(args_str)
      found = args_str[0] == '['
      fail Assembler::AsmError, "Array must start with '['" unless found
    end

    def get_array_lines(args_str, asm)
      line = args_str[1..-1]
      lines = [line]
      until line =~ /]/
        line = Assembler.strip(asm.pop_line)
        lines.push line
      end
      lines
    end

    def lines_to_tokens(lines)
      # Remove trailing ']'
      lines[-1] = lines[-1].gsub!(']', '')
      str = lines.join ' '
      str.split.map { |e| Assembler::Token.new(e) }
    end
  end

  class FillArrayDirective < Assembler::Command
    def initialize(args_str)
      size, fill = args_str.split
      @fill = Assembler::Token.new fill
      @word_length = Assembler.to_int size
    end

    def machine_code(symbol_table)
      [@fill.get_int(symbol_table)] * @word_length
    end
  end

  class StrDirective < Assembler::Command
    def initialize(args_str)
      @code = args_str.split('').map(&:ord)
      @code.unshift @code.length
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end
  end

  class LongStringDirective < Assembler::Command
    def initialize(args_str, asm)
      lines = get_string_lines(asm)
      char = get_join_char(args_str)
      @code = lines.join(char).split('').map(&:ord)
      @code.unshift @code.length
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end

    private

    def get_string_lines(asm)
      msg = 'Missing .end-long-string to end .long-string directive'
      lines = []
      fail(Assembler::AsmError, msg) if asm.empty?
      line = asm.pop_line
      until Assembler.strip(line) == '.end-long-string'
        lines.push line
        fail(Assembler::AsmError, msg) if asm.empty?
        line = asm.pop_line
      end
      lines
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
        fail Assembler::AsmError, msg
      end
    end
  end

  class CopyDirective < Assembler::Command
    def initialize(args_str)
      @code = IO.read(args_str).unpack('S>*')
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end
  end

  def self.handle(directive, args_str, asm, word_index, symbol_table)
    directive_class = const_get directive_to_class_name directive
    args = [args_str]
    case directive
    when :'.move'
      args += [word_index, symbol_table]
    when :'.array', :'.long-string'
      args.push(asm)
    end
    directive_class.new(*args)
  end
end
