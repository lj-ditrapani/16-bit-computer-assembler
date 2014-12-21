require './lib/assembler/base'
require './lib/assembler/instructions'
require './lib/assembler/directives'
require './lib/assembler/pseudo_instructions'

# All code for project contained within this top-level module
module Assembler
  # Has main algorithm and state of source, commands, and symbol_table
  class Assembler
    def initialize(file_path)
      @source = Source.new.include_file(file_path)
      @commands, @symbol_table = CommandList.new, SymbolTable.new
    end

    def assemble
      process_next_line until @source.empty?
    rescue AsmError => e
      ::Assembler.elaborate_error(e, @source.current_line.source_info)
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
      when :label then a.label(line, @symbol_table)
      when :set_directive then a.set_directive(args_str, @symbol_table)
      when :include_directive then @source.include_file args_str
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
      if first_sym.to_s[0] == '.'
        Directives.handle(line, @source, @symbol_table)
      elsif ::Assembler.pseudo_instruction? first_sym
        PseudoInstructions.handle(first_sym, args_str)
      else
        Instructions.handle(first_sym, args_str)
      end
    end
  end

  def self.main(file_path)
    asm = Assembler.new file_path
    print asm.assemble
  end

  def self.elaborate_error(error, source_info)
    msg_lines = ["\n\n****"] +
                source_info.error_info +
                ["#{error.message}",
                 "#{error.backtrace.join "\n    "}\n****\n\n"]
    $stderr.print msg_lines.join("\n")
  end

  def self.to_int(str)
    fail AsmError, 'Malformed integer' if /^\d[x|X]/ =~ str[0..1]
    start, base = get_start_and_base str[0]
    num = to_int_with_start_and_base(str, start, base)
    fail AsmError, "Number greater than $FFFF: #{str}" if num > 0xFFFF
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
    raise AsmError, 'Malformed integer'
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

  def self.label(line, symbol_table)
    symbol_table[line.first_word[1...-1]] = line.word_index
  end

  def self.set_directive(args_str, symbol_table)
    name, str_value = args_str.split(/\s+/, 2)
    token = Token.new str_value
    symbol_table.set_token(name, token)
  end

  def self.pseudo_instruction?(first_word)
    pseudo_instructions_list = [:CPY, :NOP, :WRD, :INC, :DEC, :JMP]
    pseudo_instructions_list.include? first_word
  end
end
