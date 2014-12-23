require './lib/assembler/base'
require './lib/assembler/source'
require './lib/assembler/command_list'
require './lib/assembler/symbol_table'
require './lib/assembler/instructions'
require './lib/assembler/directives'
require './lib/assembler/pseudo_instructions'

# All code for project contained within this top-level module
module Assembler
  # Has main algorithm and state of source, commands, and symbol_table
  class Assembler
    BAD_FIRST_WORD_MSG = "First word '%s' not a valid directive, " \
                         'instruction or pseudo-intruction.'

    def initialize(file_path)
      @source = Source.new.include_file(file_path)
      @commands, @symbol_table = CommandList.new, SymbolTable.new
    end

    def assemble
      process_next_line until @source.empty?
    rescue AsmError => e
      ::Assembler.handle_error(e, @source.current_line.source_info)
    else
      machine_code
    end

    def process_next_line
      line = @source.pop_line
      return if line.empty?
      line.word_index = @commands.word_index
      dispatch line
    end

    def machine_code
      machine_code_arr = @commands.machine_code @symbol_table
      machine_code_arr.pack('S>*')
    end

    private

    def dispatch(line)
      a = ::Assembler
      args_str = line.args_str
      case a.line_type(line.first_word)
      when :label then handle_label(line)
      when :set_directive then handle_set_directive(args_str)
      when :include_directive then handle_include_directive(args_str)
      when :command then handle_command(line)
      end
    end

    def handle_command(line)
      command = create_command(line)
      command.source_info = line.source_info
      @commands.add_command command
    end

    def create_command(line)
      first_sym, args_str = line.first_word.to_sym, line.args_str
      if Directives.directive? first_sym
        Directives.handle(line, @source, @symbol_table)
      elsif PseudoInstructions.pseudo_instruction? first_sym
        PseudoInstructions.handle(first_sym, args_str)
      elsif Instructions.instruction? first_sym
        Instructions.handle(first_sym, args_str)
      else
        fail AsmError, BAD_FIRST_WORD_MSG % first_sym
      end
    end

    def handle_label(line)
      @symbol_table[line.first_word[1...-1]] = line.word_index
    end

    def handle_set_directive(args_str)
      name, str_value = args_str.split(/\s+/, 2)
      token = Token.new str_value
      @symbol_table.set_token(name, token)
    end

    def handle_include_directive(args_str)
      @source.include_file args_str
    end
  end

  def self.main(file_path)
    asm = Assembler.new file_path
    print asm.assemble
  end

  def self.line_type(first_word)
    if first_word[0] == '('
      :label
    elsif first_word == '.set'
      :set_directive
    elsif first_word == '.include'
      :include_directive
    else
      :command
    end
  end
end
