require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Directives do
  tests = [
    ['0x00FF', 0x0010, 239],
    ['audio', 0x005, (0xD800 - 5)],
  ]
  symbol_table = { :audio => 0xD800 }
  tests.each do |args_str, word_index, word_length|
    describe ".move Directive" do
      it ".move #{args_str} -> array of #{word_length} zeros" do
        d = Assembler::Directives
        cmd = d.handle(:".move", args_str, [], word_index, symbol_table)
        machine_code = cmd.machine_code symbol_table
        assert_equal word_length, cmd.word_length
        assert_equal word_length, machine_code.length
        assert_equal 0, actual_machine_code[0]
        assert_equal 0, actual_machine_code[-1]
      end
    end
  end
end
