require 'minitest/autorun'
require './lib/assembler'

symbol_table = Assembler::SymbolTable.new
symbol_table.merge!(too_big_4: 16, x: 7, y: 15)

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
    [:BRN, 'RC ZN RA', 0xECA6],
    [:BRN, 'RC NZP RA', 0xECA7],
    [:BRN, 'RC PZN RA', 0xECA7],
    [:BRN, 'RC PNZ RA', 0xECA7],
    [:BRN, 'RC ZP RA', 0xECA3],
    [:BRN, 'RC PZ RA', 0xECA3],
    [:BRN, 'RC P RA', 0xECA1],
    [:BRN, '- RB', 0xE0B8],
    [:BRN, 'C RB', 0xE0B9],
    [:BRN, 'V RB', 0xE0BA],
    [:SPC, 'RA', 0xF00A]
  ]
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

  describe 'Failing instructions raise AsmError' do
    flag = "Invalid flag condition, must be C V or -, received: '%s'"
    val = 'Invalid value condition, must be combination of NZP, ' \
          "received:  '%s'"
    b_args = "Expected 2 or 3 arguments, received: '%s'"
    tests = [
      [:SHF, '16 R 7 RC', "Value must be less than 16: '16'"],
      [:SHF, 'too_big_4 R 7 RC', "Value must be less than 16: '16'"],
      [:SHF, 'RB R 7 16', "Value must be less than 16: '16'"],
      [:SHF, 'RB R 7 too_big_4', "Value must be less than 16: '16'"],
      [:SHF, 'R0 U 8 R1', "Direction must be L or R, received: 'U'"],
      [:SHF, 'R0 8 R1', "Expected 4 arguments, received: 'R0 8 R1'"],
      [:SHF, 'R0 U 8 R1 R2', "Expected 4 arguments, received: 'R0 U 8 R1 R2'"],
      [:SHF, 'R0 L 0 R1', "Amount must be greater than 0, received: '0'"],
      [:SHF, 'R0 L 9 R1', "Amount must be less than 9, received: '9'"],
      [:BRN, 'RB ZP too_big_4', "Value must be less than 16: '16'"],
      [:BRN, 'RB ZP 16', "Value must be less than 16: '16'"],
      [:BRN, 'too_big_4 ZP RC', "Value must be less than 16: '16'"],
      [:BRN, 'RC ZP RA RB', b_args % 'RC ZP RA RB'],
      [:BRN, 'C RB RC', val % 'RB'],
      [:BRN, 'C N RC', "Undefined symbol: 'C'"],
      [:BRN, 'C', b_args % 'C'],
      [:BRN, 'R0 - R1', val % '-'],
      [:BRN, 'N RA', flag % 'N'],
      [:BRN, 'ZP RA', flag % 'ZP'],
      [:BRN, 'CV RB', flag % 'CV'],
      [:BRN, '-V RB', flag % '-V'],
      [:BRN, 'C- RB', flag % 'C-'],
      [:BRN, 'CV- RB', flag % 'CV-']
    ]
    tests.each do |mnemonic, args_str, error_msg|
      it "#{mnemonic} #{args_str} -> raises #{error_msg}" do
        err = assert_raises Assembler::AsmError do
          cmd = Assembler::Instructions.handle(mnemonic, args_str)
          cmd.machine_code symbol_table
        end
        assert_match error_msg, err.message
      end
    end
  end

end
