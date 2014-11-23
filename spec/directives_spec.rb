require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Directives do
  tests = [
    ['$00FF', 0x0010, 239],
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
        assert_equal 0, machine_code[0]
        assert_equal 0, machine_code[-1]
      end
    end
  end
  tests = [
    ['42', 42],
    ['audio', 0xD800],
  ]
  tests.each do |args_str, word|
    describe ".word Directive" do
      it ".word #{args_str} -> [#{word}]" do
        d = Assembler::Directives
        cmd = d.handle(:".word", args_str, [], 0, symbol_table)
        machine_code = cmd.machine_code symbol_table
        assert_equal 1, cmd.word_length
        assert_equal 1, machine_code.length
        assert_equal word, machine_code[0]
      end
    end
  end
  tests = [
    ["[1 2 3]", [], [1, 2, 3]],
    ["[ 1 2 3", ["  4 5 6", "  7 8 9]"], [1, 2, 3, 4, 5, 6, 7, 8, 9]],
    ["[", ["\t1", " 2", "]\t"], [1, 2]],
    [
      "[$FFFF %0110_0000_1001_1111 64]",
      [],
      [0xFFFF, 0b0110_0000_1001_1111, 64]
    ],
  ]
  tests.each do |args_str, lines, words|
    describe ".array Directive" do
      it ".array #{args_str} -> #{words.inspect}" do
        d = Assembler::Directives
        asm = Assembler::Assembly.new lines
        cmd = d.handle(:".array", args_str, asm, 0, {})
        machine_code = cmd.machine_code({})
        length = words.length
        assert_equal length, cmd.word_length
        assert_equal length, machine_code.length
        assert_equal words, machine_code
        assert asm.empty?
      end
    end
  end
end
