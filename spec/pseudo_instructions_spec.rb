require 'minitest/autorun'
require './lib/assembler'

describe Assembler::PseudoInstructions::WRD do
  tests = [
    ['$1234 R7', [0x1127, 0x2347]],
    ['audio RF', [0x1D8F, 0x200F]]
  ]
  tests.each do |args_str, words|
    it "WRD #{args_str} -> #{words}" do
      cmd = Assembler::PseudoInstructions.handle(:WRD, args_str)
      actual_machine_code = cmd.machine_code(Assembler::SymbolTable.new)
      assert_equal 2, cmd.word_length
      assert_equal words, actual_machine_code
    end
  end
end

describe Assembler::PseudoInstructions do
  PI = Assembler::PseudoInstructions
  tests = [
    [:NOP, '', 0x7000],
    [:CPY, 'R1 R2', 0x7102],
    [:CPY, '$F $A', 0x7F0A],
    [:CPY, '%0100 $5', 0x7405],
    [:INC, 'R3', 0x7313],     # ADI R3 1 R3
    [:DEC, 'R4', 0x8414],     # SBI R4 1 R4
    [:JMP, 'RA', 0xE0A7]      # BRN R0 NZP RA -> BRN RV RP cond
  ]
  tests.each do |pseudo_instruction, args_str, word|
    it "#{pseudo_instruction} #{args_str} -> [#{word}]" do
      cmd = PI.handle(pseudo_instruction, args_str)
      actual_machine_code = cmd.machine_code(Assembler::SymbolTable.new)
      assert_equal 1, cmd.word_length
      assert_equal [word], actual_machine_code
    end
  end
end
