require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Directives do
  tests = [
    [:'.word', '0x00FF', 0x0010, [], [0] * 239],
    [:'.word', 'audio', 0x005, [], [0] * 1000],
    [:'.array', []],
    [:'.move', []],
  ]
  symbol_table = { :RA => 10, :RB => 11, :RC => 12}
  def self.handle(directive_symbol, args_str, asm, word_index, symbol_table)
  tests.each do |directive, args_str, asm, word_index, expected_machine_code|
    describe directive do
      str = "Given #{directive} #{args_str}, "
      str += "returns machine code of #{expected_machine_code}"
      it str do
        cmd = Assembler::Instructions.handle(directive, args_str)
        actual_machine_code = cmd.machine_code symbol_table
        assert_equal 1, cmd.word_length
        assert_equal expected_machine_code, actual_machine_code[0]
      end
    end
  end
end
