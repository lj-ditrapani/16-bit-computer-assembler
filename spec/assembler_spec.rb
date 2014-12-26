require 'minitest/autorun'
require './lib/assembler'

describe Assembler do
  describe Assembler::Int16 do
    tests = [
      ['$10', 16],
      ['$FF', 255],
      ['$FFFF', 0xFFFF],
      ['$FF_FF', 0xFFFF],
      ['$FEED', 0xFEED],
      ['%0101_1111', 0x5F],
      ['%1010_0101_0000_1101', 0xA50D],
      ['%1010010100001101', 0xA50D],
      ['10', 10],
      ['65_000', 0xFDE8],
      ['65000', 0xFDE8]
    ]
    tests.each do |str, num|
      it "#{str.inspect} --> #{num}" do
        assert_equal num, Assembler::Int16.to_int(str)
      end
    end
    tests = ['0xFF00', '$FFEZ', 'hello', '13F']
    tests.each do |str|
      it "#{str.inspect} raises exception" do
        err = assert_raises Assembler::AsmError do
          Assembler::Int16.to_int str
        end
        assert_match "Malformed integer: '#{str}'", err.message
      end
    end
    tests = ['$10000', '66000']
    tests.each do |str|
      it "#{str.inspect} raises 'Value too large' exception" do
        err = assert_raises Assembler::AsmError do
          Assembler::Int16.to_int str
        end
        assert_match "Value must be less than 65536: '#{str}'",
                     err.message
      end
    end
    tests = ['-100', '$-600', '%-100']
    tests.each do |str|
      it "#{str.inspect} raises exception" do
        err = assert_raises Assembler::AsmError do
          Assembler::Int16.to_int str
        end
        assert_match "Negative numbers not allowed: '#{str}'",
                     err.message
      end
    end
    tests = [
      ['$FFF', 16, 0xFFF],
      ['$10', 8, 16],
      ['$FF', 8, 255],
      ['$F', 4, 15],
      ['%1111', 4, 15]
    ]
    tests.each do |str, limit, num|
      it "#{str.inspect} with limit #{limit} --> #{num}" do
        assert_equal num, Assembler::Int16.to_int(str, limit)
      end
    end
    tests = [
      ['$1_0000', 16],
      ['$100', 8],
      ['%1_0000_0000', 8],
      ['16', 4],
      ['$10', 4],
      ['%1_0000', 4]
    ]
    tests.each do |str, limit_exp|
      it "Fails given #{str.inspect} and limit_exp #{limit_exp}" do
        err = assert_raises Assembler::AsmError do
          Assembler::Int16.to_int str, limit_exp
        end
        limit = 2**limit_exp
        assert_match "Value must be less than #{limit}: '#{str}'",
                     err.message
      end
    end
  end

  describe 'symbol_table has pre-defined symbols' do
    tests = [
      [:R0, 0],
      [:R1, 1],
      [:RA, 10],
      [:RF, 15],
      [:audio,           0xD800],
      [:'net-in',        0xDC00],
      [:'storage-out',   0xE800],
      [:'cell-x-y-flip', 0xFD60],
      [:sprites,         0xFE8C],
      [:'sprite-colors', 0xFFAC],
      [:keyboard,        0xFFFA],
      [:'net-status',    0xFFFB],
      [:'enable-bits',   0xFFFC],
      [:'storage-read-address',   0xFFFD],
      [:'storage-write-address',  0xFFFE],
      [:'frame-interrupt-vector', 0xFFFF]
    ]
    st = Assembler::SymbolTable.new
    tests.each do |key, value|
      it "has value #{value} associated with key #{key}" do
        assert_equal value, st[key]
      end
    end
  end
end

describe Assembler::Source do
  before do
    lines = %W(a\n b\n c\n)
    @source = Assembler::Source.new.include_lines(lines)
  end

  describe 'pop_line' do
    before do
      @line = @source.pop_line
    end
    it 'should return the first line' do
      assert_equal 'a', @line.text
      assert_equal 'LINE # 1', @line.source_info.error_info[1]
    end
  end

  describe 'pop 2 lines' do
    before do
      @line = @source.pop_line
      @line = @source.pop_line
    end
    it 'should return the second line' do
      assert_equal 'b', @line.text
      assert_equal 'LINE # 2', @line.source_info.error_info[1]
    end
  end

end

describe Assembler::CommandList do
  before do
    @state = Assembler::CommandList.new
  end
  describe 'add_command' do
    before do
      # Mock of the Command class
      class MockCommand
        attr_accessor :word_length
      end
      @cmd = MockCommand.new
    end
    describe 'when command is 1 machine word long' do
      it 'increments the word_index by one (no args)' do
        @cmd.word_length = 1
        @state.add_command @cmd
        assert_equal 1, @state.word_index
      end
    end
    describe 'when command is 4 machine words long' do
      it 'incements the word_index by 4' do
        @cmd.word_length = 4
        @state.add_command @cmd
        assert_equal 4, @state.word_index
      end
    end
    describe 'when 2 commands of 1 and 4 machine words in length' do
      it 'incements the word_index by 5' do
        @cmd.word_length = 1
        @state.add_command @cmd
        @cmd.word_length = 4
        @state.add_command @cmd
        assert_equal 5, @state.word_index
      end
    end
  end
end

describe Assembler::Token do
  it 'handles symbols' do
    token = Assembler::Token.new 'my-label'
    assert_equal :symbol, token.type
    assert_equal :'my-label', token.value
  end
  it 'handles integers' do
    token = Assembler::Token.new '$F099'
    assert_equal :int, token.type
    assert_equal 0xF099, token.value
  end
  symbol_table = { a: 16, b: 256, c: 65_536 }
  tests = [
    ['16', 4],
    ['256', 8],
    ['65_536', 16],
    [:a, 4],
    [:b, 8],
    [:c, 16]
  ]
  tests.each do |str, limit_exp|
    it "Fails given #{str.inspect} and limit_exp #{limit_exp}" do
      err = assert_raises Assembler::AsmError do
        token = Assembler::Token.new str, limit_exp
        token.get_int symbol_table
      end
      limit = 2**limit_exp
      str = symbol_table[str] unless symbol_table[str].nil?
      assert_match "Value must be less than #{limit}: '#{str}'",
                   err.message
    end
  end
end
