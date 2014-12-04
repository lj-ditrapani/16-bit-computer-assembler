require 'minitest/autorun'
require './lib/assembler'

describe Assembler::PseudoInstructions::NOP do
  it 'It returns [0x7000] as machine_code' do
    cmd = Assembler::PseudoInstructions.handle(:NOP, nil)
    actual_machine_code = cmd.machine_code({})
    assert_equal 1, cmd.word_length
    assert_equal [0x7000], actual_machine_code
  end
end

describe Assembler::PseudoInstructions::CPY do
  tests = [
    ['R1 R2', 0x7102],
    ['$F $A', 0x7F0A],
    ['%0100 $5', 0x7405]
  ]
  symbol_table = { R1: 1, R2: 2 }
  tests.each do |args_str, word|
    it "CPY #{args_str} -> [#{word}]" do
      cmd = Assembler::PseudoInstructions.handle(:CPY, args_str)
      actual_machine_code = cmd.machine_code(symbol_table)
      assert_equal 1, cmd.word_length
      assert_equal [word], actual_machine_code
    end
  end
end
