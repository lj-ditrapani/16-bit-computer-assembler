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
  tests = [
    ['4 4 4', 'R1 R2'],
    ['8 4', '$FF RA RB'],
    ['S', '1 2'],
    ['T', '']
  ]
  tests.each do |format, args_str|
    desc = 'fails because of arg count when format is ' \
           "#{format} & args_str is #{args_str}"
    count = format.split.size
    msg = "Expected #{count} arguments, received: '#{args_str}'"
    it desc do
      err = assert_raises Assembler::AsmError do
        Args.new(format).parse(args_str)
      end
      assert_match msg, err.message
    end
  end

  it 'fails when format is F but file does not exist' do
    err = assert_raises Assembler::AsmError do
      Args.new('F').parse('file-dne.xyz')
    end
    assert_match "File does not exist: 'file-dne.xyz'", err.message
  end

  it 'Returns arg as is when format is S' do
    args = Args.new('S S').parse('one two')
    assert_equal %w(one two), args
  end

  it 'Returns limited Tokens when format uses T 8 4' do
    symbol_table = { sixteen: 65_536, eight: 256, four: 16 }
    args = Args.new('T 8 4').parse('sixteen eight four')
    v = symbol_table[:sixteen]
    msg = "Value must be less than #{v}: '#{v}'"
    err = assert_raises Assembler::AsmError do
      args[0].get_int symbol_table
    end
    assert_match msg, err.message
    v = symbol_table[:eight]
    msg = "Value must be less than #{v}: '#{v}'"
    err = assert_raises Assembler::AsmError do
      args[1].get_int symbol_table
    end
    assert_match msg, err.message
    v = symbol_table[:four]
    msg = "Value must be less than #{v}: '#{v}'"
    err = assert_raises Assembler::AsmError do
      args[2].get_int symbol_table
    end
    assert_match msg, err.message
  end
end
