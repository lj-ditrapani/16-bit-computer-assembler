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
    line_index = 0
    word_index = 0
    new_lines = []
    # can't use each_with_index since the line_number and word_index can
    # change by a variable # based on the command
    until lines.empty?
      line = strip(lines.shift)
      if line.empty?
        next
      end
      new_lines.push line
    end
    puts new_lines
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
