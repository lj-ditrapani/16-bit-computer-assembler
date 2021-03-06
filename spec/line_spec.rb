require 'minitest/autorun'
require './lib/assembler/base'

describe Assembler::Source::Line do
  Line = Assembler::Source::Line
  before do
    text = 'ADD R1 R2 R3  # a comment'
    @line = Line.new('test.asm', 42, text)
  end
  describe 'text' do
    it 'returns the raw text as is' do
      text = 'ADD R1 R2 R3  # a comment'
      line = Line.new('test.asm', 42, text)
      assert_equal text, line.text
    end
  end
  describe 'source_info' do
    it 'Returns source_info with file_name and line_number' do
      error_lines = ['ASSEMBLER ERROR in file test.asm',
                     'LINE # 42',
                     'SOURCE CODE: ADD R1 R2 R3  # a comment']
      assert_equal error_lines, @line.source_info.error_info
    end
  end
  line_with_text = ->(text) { Line.new('test.asm', 42, text) }
  describe 'strip' do
    strip_text = ->(text) { line_with_text.call(text).strip }
    it 'should remove line comments at beginning of line' do
      text = "# this is a comment\n"
      assert_empty strip_text.call(text)
    end
    it 'should strip white space and beginning and end of line' do
      text = "  \t .word  42  \t  \n"
      assert_equal '.word  42', strip_text.call(text)
    end
    it 'should remove comment at end of line' do
      text = "  ADI R1 $A R3 \t # My comment\n"
      assert_equal 'ADI R1 $A R3', strip_text.call(text)
    end
  end
  describe 'first_word' do
    it 'ADD R1 R2 R3 # a comment -> ADD' do
      assert_equal 'ADD', @line.first_word
      assert_equal 'ADD', @line.first_word, 'Must be idempotent'
    end
  end
  describe 'args_str' do
    it 'ADD R1 R2 R3 # a comment -> R1 R2 R3' do
      assert_equal 'R1 R2 R3', @line.args_str
      assert_equal 'R1 R2 R3', @line.args_str, 'Must be idempotent'
    end
    it 'should not remove comment at end of .str directive' do
      text = '  .str " my string " # My comment'
      line = line_with_text.call text
      assert_equal '.str', line.first_word
      assert_equal '" my string " # My comment', line.args_str
    end
  end
end
