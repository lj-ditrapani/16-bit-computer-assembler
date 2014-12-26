require 'minitest/autorun'
require './lib/assembler/base'

describe Assembler::Args do
  Args = Assembler::Args
  it 'Can be instantiated' do
    Args.new '*'
  end

  it 'Returns raw args_str when format is *' do
    args_str = 'this is my string # :)'
    assert_equal args_str, Args.new('*').parse(args_str)
  end

  it 'Returns empty list when format is -' do
    assert_equal [], Args.new('-').parse('')
  end

  it "fails when format is - but args_str isn't empty string ''" do
    err = assert_raises Assembler::AsmError do
      Args.new('-').parse('hi')
    end
    assert_match "Expected 0 arguments, received: 'hi'", err.message
  end

  # Test arg count; all failing tests
  _tests = [
    ['4 4 4', 'R1 R2'],
    ['8 4', '$FF RA RB'],
    ['S', '1 2'],
    ['T', nil]
  ]
end
