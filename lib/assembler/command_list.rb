module Assembler
  # Holds the list of commands parsed so far
  # Once the first pass is finished, the command list will contain all
  # the commands and the symbol table will be complete.
  # The second pass can actually generate the machine code, since the
  # symbol table is complete at that point.
  class CommandList
    attr_reader :word_index

    def initialize
      # The index of the next free address
      @word_index = 0
      @commands = []
    end

    def add_command(cmd)
      @commands.push cmd
      inc_words cmd.word_length
    end

    def inc_words(n)
      @word_index += n
    end

    def word_length
      word_index
    end

    def machine_code(symbol_table)
      array = @commands.map { |cmd| cmd.machine_code symbol_table }
      array.flatten
    end

    def machine_code(symbol_table)
      @commands.reduce([]) do |array, cmd|
        begin
          array.concat cmd.machine_code(symbol_table)
        rescue AsmError => e
          ::Assembler.elaborate_error(e, cmd.source_info)
        end
      end
    end
  end
end
