require './lib/assembler/base'
require './lib/assembler/instructions'
require './lib/assembler/directives'
require './lib/assembler/pseudo_instructions'

# All code for project contained within this top-level module
module Assembler
  def self.main(file_path)
    source, commands, symbol_table = init_state(file_path)
    begin
      # can't use each_with_index since the line_number and word_index
      # can change by a variable # based on the command
      process_next_line(source, symbol_table, commands) until source.empty?
    rescue AsmError => e
      elaborate_error(e, source.current_line.source_info)
    else
      machine_code(commands, symbol_table)
    end
  end

  def self.init_state(file_path)
    source = Source.new.include_file(file_path)
    [source, CommandList.new, SymbolTable.new]
  end

  def self.process_next_line(source, symbol_table, commands)
    line = source.pop_line
    return if line.empty?
    distpatch(line, source, symbol_table, commands)
  end

  def self.distpatch(line, source, symbol_table, commands)
    first_word = line.first_word
    args_str = line.args_str
    case line_type(first_word)
    when :label
      label(first_word, symbol_table, commands.word_index)
    when :set_directive
      set_directive(args_str, symbol_table)
    when :include_directive
      source.include_file args_str
    when :command
      handle_command(first_word, args_str, source, commands, symbol_table)
    end
  end

  def self.elaborate_error(error, source_info)
    msg_lines = ["\n\n****"] +
                source_info.error_info +
                ["#{error.message}",
                 "#{error.backtrace.join "\n    "}\n****\n\n"]
    $stderr.print msg_lines.join("\n")
  end

  def self.machine_code(commands, symbol_table)
    machine_code_arr = commands.machine_code symbol_table
    machine_code_str = machine_code_arr.pack('S>*')
    print machine_code_str
  end

  def self.strip(line)
    new_line = line.strip
    return '' if new_line.empty? || new_line[0] == '#'
    first_word = new_line.split(' ', 2)[0]
    return new_line if first_word == '.str'
    new_line.split('#', 2)[0].strip
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

  def self.label(first_word, symbol_table, word_index)
    symbol_table[first_word[1...-1]] = word_index
  end

  def self.set_directive(args_str, symbol_table)
    name, str_value = args_str.split(/\s+/, 2)
    token = Token.new str_value
    symbol_table.set_token(name, token)
  end

  def self.handle_command(first_word_str,
                          args_str,
                          source,
                          commands,
                          symbol_table)
    first_word = first_word_str.to_sym
    word_index = commands.word_index
    extra_args = [source, word_index, symbol_table]
    command = create_command(first_word, args_str, extra_args)
    commands.add_command command
  end

  def self.pseudo_instruction?(first_word)
    pseudo_instructions_list = [:CPY, :NOP, :WRD, :INC, :DEC, :JMP]
    pseudo_instructions_list.include? first_word
  end

  def self.create_command(first_word, args_str, extra_args)
    if first_word.to_s[0] == '.'
      Directives.handle(first_word, args_str, *extra_args)
    elsif pseudo_instruction? first_word
      PseudoInstructions.handle(first_word, args_str)
    else
      Instructions.handle(first_word, args_str)
    end
  end
end
