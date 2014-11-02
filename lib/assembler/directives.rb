module Assembler::Directives

  def self.directive_to_class_name(symbol)
    symbol[1..-1].split('-').map(&:capitalize).push('Directive').join.to_sym
  end

  class MoveDirective < Assembler::Command
    def initialize(args_str, asm, word_index)
      super()
    end
  end

  class WordDirective < Assembler::Command
    def initialize(args_str, asm, word_index)
      super()
    end
  end

  class ArrayDirective < Assembler::Command
    def initialize(args_str, asm, word_index)
      super()
    end
  end

  def self.handle(directive_symbol, args_str, asm, word_index)
    class_name = directive_to_class_name directive_symbol
    const_get(class_name).new(args_str, asm, word_index)
  end

end
