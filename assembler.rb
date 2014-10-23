#! /usr/bin/env ruby


module Assembler


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
    symbol_table = {'R0' => 0, 'R1' => 1}
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
        symbol_table[line[1...-1]] = commands.word_index
      end
      if cmd_str == '.set'
        # handle .set
        name, str_value, rest = args_str.split(/\s+/, 3)
        value = begin
          Integer(str_value)
        rescue
          symbol_table[str_value]
          # need error handling here!
        end
        symbol_table[name] = value
      end
      new_lines.push line
    end
    puts new_lines
    puts symbol_table
  end


  def self.strip(line)
    new_line = line.strip
    if new_line[0] == '#'
      ''
    else
      new_line
    end
  end

end


if __FILE__ == $0
  Assembler.main()
end
