require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Instructions do
  tests = [
    [:HBY, '$AB RC', 0x1ABC],
    [:LBY, '$CB RA', 0x2CBA],
    [:LOD, 'RA RC', 0x3A0C],
    [:STR, 'RB RC', 0x4BC0],
    [:ADD, 'RA RB RC', 0x5ABC],
    [:END, nil, 0x0000],
  ]
  symbol_table = { :RA => 10, :RB => 11, :RC => 12}
  tests.each do |op_code, args_str, expected_machine_code|
    describe op_code do
      str = "Given #{op_code} #{args_str}, "
      str += "returns machine code of #{expected_machine_code}"
      it str do
        cmd = Assembler::Instructions.handle(op_code, args_str)
        actual_machine_code = cmd.machine_code symbol_table
        assert_equal 1, cmd.word_length
        assert_equal expected_machine_code, actual_machine_code[0]
      end
    end
  end
end
