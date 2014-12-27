require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Instructions do
  tests = [
    [:END, '', 0x0000],
    [:HBY, '$AB RC', 0x1ABC],
    [:LBY, '$CB RA', 0x2CBA],
    [:LOD, 'RA RC', 0x3A0C],
    [:STR, 'RB RC', 0x4BC0],
    [:ADD, 'RA RB RC', 0x5ABC],
    [:SUB, 'RB RA RC', 0x6BAC],
    [:ADI, 'RA 3 RC', 0x7A3C],
    [:ADI, 'RA x RC', 0x7A7C],
    [:SBI, 'RC 8 RA', 0x8C8A],
    [:SBI, 'RC y RA', 0x8CFA],
    [:AND, 'RA RB RC', 0x9ABC],
    [:ORR, 'RA RB RC', 0xAABC],
    [:XOR, 'RA RB RC', 0xBABC],
    [:NOT, 'RA RC', 0xCA0C],
    [:SHF, 'RB R 7 RC', 0xDBEC],
    [:SHF, 'RB R 1 RC', 0xDB8C],
    [:SHF, 'RB R 8 RC', 0xDBFC],
    [:SHF, 'RB L 1 RC', 0xDB0C],
    [:SHF, 'RB L 8 RC', 0xDB7C],
    [:BRN, 'RC NZ RA', 0xECA6],
    [:BRN, 'RC NZP RA', 0xECA7],
    [:BRN, 'RC ZP RA', 0xECA3],
    [:BRN, 'RC P RA', 0xECA1],
    [:BRN, '- RB', 0xE0B8],
    [:BRN, 'C RB', 0xE0B9],
    [:BRN, 'V RB', 0xE0BA],
    [:SPC, 'RA', 0xF00A]
  ]
  symbol_table = { RA: 10, RB: 11, RC: 12, x: 7, y: 15 }
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

  describe 'BRN Exception' do
    it 'Raises exception when flag condition is invalid' do
      err = assert_raises Assembler::AsmError do
        Assembler::Instructions.handle(:BRN, 'N RA')
      end
      assert_match(/got "N" instead/, err.message)
    end
  end

end
