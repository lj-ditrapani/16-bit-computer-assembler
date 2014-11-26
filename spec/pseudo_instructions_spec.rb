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

