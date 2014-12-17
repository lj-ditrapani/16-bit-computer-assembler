# Contains directive classes and knows how to handle directives
module Assembler::Directives
  def self.directive_to_class_name(symbol)
    str_list = symbol[1..-1].split('-').map(&:capitalize)
    str_list.push('Directive').join.to_sym
  end

  class WordDirective < Assembler::Command
    def initialize(args_str, _asm, _word_index, _symbol_table)
      super()
      @value = Assembler::Token.new args_str
    end

    def machine_code(symbol_table)
      [@value.get_int(symbol_table)]
    end
  end

  class MoveDirective < Assembler::Command
    def initialize(args_str, _asm, word_index, symbol_table)
      address_token = Assembler::Token.new args_str
      address = address_token.get_int symbol_table
      @word_length = address - word_index
    end

    def machine_code(_symbol_table)
      (0...@word_length).map { 0x0000 }
    end
  end

  class ArrayDirective < Assembler::Command
    def initialize(args_str, asm, _word_index, _symbol_table)
      unless args_str[0] == '['
        fail Assembler::AsmError, "Array must start with '['"
      end
      line = args_str[1..-1]
      lines = [line]
      until line =~ /]/
        line = Assembler.strip(asm.pop_line)
        lines.push line
      end
      # Remove trailing ']'
      lines[-1] = lines[-1].gsub!(']', '')
      str = lines.join ' '
      @tokens = str.split.map { |e| Assembler::Token.new(e) }
    end

    def word_length
      @tokens.length
    end

    def machine_code(symbol_table)
      @tokens.map { |t| t.get_int(symbol_table) }
    end
  end

  class FillArrayDirective < Assembler::Command
    def initialize(args_str, _asm, _word_index, _symbol_table)
      size, fill = args_str.split
      @word_length = Assembler.to_int size
      @fill = Assembler::Token.new fill
    end

    def machine_code(symbol_table)
      [@fill.get_int(symbol_table)] * @word_length
    end
  end

  class StrDirective < Assembler::Command
    def initialize(args_str, _asm, _word_index, _symbol_table)
      @code = args_str.split('').map(&:ord)
      @code.unshift @code.length
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end
  end

  class LongStringDirective < Assembler::Command
    def initialize(args_str, asm, _word_index, _symbol_table)
      msg = 'Missing .end-long-string to end .long-string directive'
      lines = []
      fail(Assembler::AsmError, msg) if asm.empty?
      line = asm.pop_line
      until Assembler.strip(line) == '.end-long-string'
        lines.push line
        fail(Assembler::AsmError, msg) if asm.empty?
        line = asm.pop_line
      end
      msg = '.long-string parameter must be keep-newlines or ' \
            "strip-newlines. Received #{args_str.inspect} instead"
      char = case args_str
             when 'keep-newlines'
               "\n"
             when 'strip-newlines'
               ''
             else
               fail Assembler::AsmError, msg
             end
      @code = lines.join(char).split('').map(&:ord)
      @code.unshift @code.length
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end
  end

  class CopyDirective < Assembler::Command
    def initialize(args_str, _asm, _word_index, _symbol_table)
      @code = IO.read(args_str).unpack('S>*')
      @word_length = @code.length
    end

    def machine_code(_symbol_table)
      @code
    end
  end

  def self.handle(directive, args_str, asm, word_index, symbol_table)
    class_name = directive_to_class_name directive
    const_get(class_name).new(args_str, asm, word_index, symbol_table)
  end
end
