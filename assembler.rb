#! /usr/bin/env ruby


module Assembler


  class AsmError < StandardError
  end


  class Assembly
    attr_reader :line_number

    def initialize(lines)
      @line_number = 0
      @lines = lines
    end

    def peek_line
      @lines[0]
    end

    def pop_line
      @line_number += 1
      @lines.shift
    end

    def empty?
      @lines.empty?
    end

  end


  class CommandList
    attr_reader :word_index

    def initialize()
      # The index of the next free address
      @word_index = 0
      @commands = []
    end

    def add_command(cmd)
      inc_words cmd.word_length
    end

    def inc_words(n)
      @word_index += n
    end

    def word_length
      @word_index
    end

  end


  def self.main
    usage = "Usage:  ./assembler.rb path/to/file.asm > path/to/file.exe"
    if ARGV.length != 1
      puts usage
      exit
    end
    lines = File.readlines(ARGV[0]).to_a
    asm = Assembly.new lines
    commands = CommandList.new
    symbol_table = make_symbol_table
    new_lines = []
    # can't use each_with_index since the line_number and word_index can
    # change by a variable # based on the command
    until asm.empty?
      line = strip(asm.pop_line)
      if line.empty?
        next
      end
      cmd_str, args_str = line.split(/\s+/, 2)
      if cmd_str[0] == '('
        # handle label
        symbol_table[line[1...-1].to_sym] = commands.word_index
      end
      if cmd_str == '.set'
        # handle .set
        name, str_value, rest = args_str.split(/\s+/, 3)
        value = begin
                  to_int(str_value)
                rescue
                  symbol_table[str_value.to_sym]
                  # need error handling here!
                end
        symbol_table[name] = value
      end
      new_lines.push line
    end
    puts new_lines
    symbol_table.each {|k, v| puts "  #{k.to_s.rjust(11)} => #{v}"}
  end


  def self.strip(line)
    new_line = line.strip
    if new_line[0] == '#'
      ''
    else
      new_line
    end
  end


  def self.make_symbol_table
    st = {
      :sound => 0xD800,
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
      :"frame-interrupt-vector" => 0xFFFF,
    }
    (0...16).each do |i|
      st[("R" + i.to_s).to_sym] = i
    end
    ('A'..'F').each_with_index do |c, i|
      st[("R" + c).to_sym] = i + 10
    end
    st
  end


  def self.to_int(str)
    if /^\d[x|X]/ === str[0..1]
      raise AsmError.new, "Malformed integer"
    end
    begin
      num = case str[0]
            when "%" then Integer(str[1..-1], 2)
            when "$" then Integer(str[1..-1], 16)
            else Integer str
            end
    rescue ArgumentError
      raise AsmError.new, "Malformed integer"
    end
    if num > 0xFFFF
      raise AsmError.new, "Number greater than $FFFF"
    end
    num
  end

end


if __FILE__ == $0
  Assembler.main()
end
