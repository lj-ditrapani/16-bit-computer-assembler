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
    [:sixteen, :eight, :four].each_with_index do |key, i|
      v = symbol_table[key]
      msg = "Value must be less than #{v}: '#{v}'"
      err = assert_raises Assembler::AsmError do
        args[i].get_int symbol_table
      end
      assert_match msg, err.message
    end
  end

  symbol_table = { R0: 0, R1: 1, R2: 2, RF: 15, big: 65_535, med: 255 }

  it "'4 4 4' and 'R0 R1 R2' -> 3 Tokens" do
    args = Args.new('4 4 4').parse('R0 R1 R2')
    assert_equal [0, 1, 2], args.map { |e| e.get_int symbol_table }
  end

  it "'S T' and 'my-label big' -> [my-label, Token(big)]" do
    args = Args.new('S T').parse('my-label big')
    assert_equal 2, args.size
    assert_equal 'my-label', args[0]
    assert_equal 65_535, args[1].get_int(symbol_table)
  end

  it "'8 4' and 'med RF' -> [Token(med), Token(RF)]" do
    args = Args.new('8 4').parse('med RF')
    assert_equal 2, args.size
    assert_equal [255, 15], args.map { |e| e.get_int symbol_table }
  end

  it "'4 S S 4' and 'R1 R 7 R0' -> [Token(R1), 'R', '7', Token(R0)]" do
    args = Args.new('4 S S 4').parse('R1 R 7 R0')
    assert_equal 4, args.size
    assert_equal %w(R 7), args[1..2]
    r_numbers = [args[0], args[3]].map { |e| e.get_int symbol_table }
    assert_equal [1, 0], r_numbers
  end
end
