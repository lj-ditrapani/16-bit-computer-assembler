require './lib/assembler/base'
require './lib/assembler/command_list'
require './lib/assembler/symbol_table'
require './lib/assembler/instructions'
require './lib/assembler/directives'
require './lib/assembler/pseudo_instructions'
require './lib/assembler/source'

# All code for project contained within this top-level module
module Assembler
  # Has main algorithm and state of source, commands, and symbol_table
  class Assembler
    BAD_FIRST_WORD_MSG = "First word '%s' not a valid directive, " \
                         'instruction or pseudo-intruction.'

    def initialize(input)
      @source = make_source input
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
      handle_command line
    end

    def machine_code
      machine_code_arr = @commands.machine_code @symbol_table
      machine_code_arr.pack('S>*')
    end

    private

    def make_source(input)
      if input.key? :file_path
        make_source_with_file(input[:file_path])
      else
        make_source_with_lines(input[:lines])
      end
    end

    def make_source_with_file(file_path)
      begin
        Args.new('F').parse(file_path)
      rescue AsmError => e
        $stderr.puts "\n\n***\n#{e.message}\n***\n\n"
        exit(1)
      end
      Source.new.include_file file_path
    end

    def make_source_with_lines(lines)
      Source.new.include_lines lines
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
        handle_error first_sym
      end
    end

    def handle_error(first_sym)
      if first_sym == :'.end-long-string'
        fail AsmError, '.end-long-string directive must come after ' \
                       '.long-string-directive'
      else
        fail AsmError, BAD_FIRST_WORD_MSG % first_sym
      end
    end
  end

  def self.main(file_path)
    asm = Assembler.new(file_path: file_path)
    print asm.assemble
  end
end
