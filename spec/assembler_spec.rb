require 'minitest/autorun'
require './lib/assembler'

describe Assembler do
  describe 'strip' do
    it 'should remove line comments at beginning of line' do
      line = "# this is a comment\n"
      new_line = Assembler.strip(line)
      assert_empty new_line
    end
    it 'should strip white space and beginning and end of line' do
      line = "  \t .word  42  \t  \n"
      new_line = Assembler.strip(line)
      assert_equal '.word  42', new_line
    end
    it 'should not remove comment at end of .str directive' do
      line = '  .str " my string " # My comment'
      new_line = Assembler.strip(line)
      assert_equal '.str " my string " # My comment', new_line
    end
    it 'should remove comment at end of line' do
      line = "  ADI R1 $A R3 \t # My comment\n"
      new_line = Assembler.strip(line)
      assert_equal 'ADI R1 $A R3', new_line
    end
  end

  describe 'to_int' do
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
        assert_equal num, Assembler.to_int(str)
      end
    end
    tests = ['0xFF00', '$FFEZ', 'hello', '13F']
    tests.each do |str|
      it "#{str.inspect} raises exception" do
        err = assert_raises Assembler::AsmError do
          Assembler.to_int str
        end
        assert_match 'Malformed integer', err.message
      end
    end
    tests = ['$10000', '66000']
    tests.each do |str|
      it "#{str.inspect} raises exception" do
        err = assert_raises Assembler::AsmError do
          Assembler.to_int str
        end
        assert_match 'Number greater than $FFFF', err.message
      end
    end
  end

  describe 'make_symbol_table has pre-defined symbols' do
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
    st = Assembler.make_symbol_table
    tests.each do |key, value|
      it "has value #{value} associated with key #{key}" do
        assert_equal value, st[key]
      end
    end
  end

  describe 'line_type' do
    it 'returns label for a label' do
      type = Assembler.line_type '(my-label)'
      assert_equal :label, type
    end
    it 'returns :set_directive for a .set directive' do
      type = Assembler.line_type '.set'
      assert_equal :set_directive, type
    end
  end

end

describe Assembler::Assembly do
  before do
    lines = %W(a\n b\n c\n)
    @state = Assembler::Assembly.new(lines)
  end

  describe 'pop_line' do
    before do
      @line = @state.pop_line
    end
    it 'should return the first line' do
      assert_equal 'a', @line
    end
    it 'should increment the line_number' do
      assert_equal 1, @state.line_number
    end
  end

  describe 'pop 2 lines' do
    before do
      @line = @state.pop_line
      @line = @state.pop_line
    end
    it 'should return the second line' do
      assert_equal 'b', @line
    end
    it 'should increment the line_number twice' do
      assert_equal 2, @state.line_number
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
end
