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
end


describe Assembler::AssemblyState do
  before do
    lines = [
      'a',
      'b',
      'c'
    ]
    @state = Assembler::AssemblyState.new(lines)
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
