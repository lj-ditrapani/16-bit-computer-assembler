require 'minitest/autorun'
require './assembler.rb'


describe Assembler do
  describe "strip" do
    it "should remove line comments at beginning of line" do
      line = "# this is a comment\n"
      new_line = Assembler.strip(line)
      assert_empty new_line
    end
    it "should strip white space and beginning and end of line" do
      line = "  \t .word  42  \t  \n"
      new_line = Assembler.strip(line)
      assert_equal '.word  42', new_line
    end
  end
  describe "make_symbol_table has pre-defined symbols" do
    tests = [
      [:R0, 0],
      [:R1, 1],
      [:RA, 10],
      [:RF, 15],
      [:sound,           0xD800],
      [:"net-in",        0xDC00],
      [:"storage-out",   0xE800],
      [:"cell-x-y-flip", 0xFD60],
      [:sprites,         0xFE8C],
      [:"sprite-colors", 0xFFAC],
      [:keyboard,        0xFFFA],
      [:"net-status",    0xFFFB],
      [:"enable-bits",   0xFFFC],
      [:"storage-read-address",   0xFFFD],
      [:"storage-write-address",  0xFFFE],
      [:"frame-interrupt-vector", 0xFFFF],
    ]
    st = Assembler.make_symbol_table
    tests.each do |key, value|
      it "has value #{value} associated with key #{key}" do
        assert_equal value, st[key]
      end
    end
  end
end


describe Assembler::Assembly do
  before do
    lines = [
      'a',
      'b',
      'c'
    ]
    @state = Assembler::Assembly.new(lines)
  end

  describe 'peek_line' do
    let(:line) { @state.peek_line() }
    it 'should not alter the line_number' do
      assert_equal 0, @state.line_number
    end
    it 'should return the top-most line' do
      assert_equal 'a', line
    end
    it 'should still return the top-most line' do
      line = @state.peek_line()
      assert_equal 'a', line
    end
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

  
  describe 'peek_line after poke line' do
    before do
      @state.pop_line()
      @line = @state.peek_line()
    end
    it 'should not alter the line_number' do
      assert_equal 1, @state.line_number
    end
    it 'should return the top-most line' do
      assert_equal 'b', @line
    end
  end

end


describe Assembler::CommandList do
  before do
    @state = Assembler::CommandList.new
  end
  describe 'add_command' do
    before do
      class MockCommand
        attr_accessor :word_length
      end
      @cmd = MockCommand.new
    end
    describe 'when command is 1 machine word long' do
      it 'should increment the word_index by one (no args)' do
        @cmd.word_length = 1
        @state.add_command @cmd
        assert_equal 1, @state.word_index
      end
    end
    describe 'when command is 4 machine words long' do
      it 'should incement the word_index by 4' do
        @cmd.word_length = 4
        @state.add_command @cmd
        assert_equal 4, @state.word_index
      end
    end
    describe 'when 2 commands of 1 and 4 machine words in length' do
      it 'should incement the word_index by 5' do
        @cmd.word_length = 1
        @state.add_command @cmd
        @cmd.word_length = 4
        @state.add_command @cmd
        assert_equal 5, @state.word_index
      end
    end
  end
end
