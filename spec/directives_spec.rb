require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Directives do
  tests = [
    ['$00FF', 0x0010, 239],
    ['audio', 0x005, (0xD800 - 5)]
  ]
  symbol_table = { audio: 0xD800 }
  tests.each do |args_str, word_index, word_length|
    describe '.move Directive' do
      it ".move #{args_str} -> array of #{word_length} zeros" do
        d = Assembler::Directives
        cmd = d.handle(:'.move', args_str, [], word_index, symbol_table)
        machine_code = cmd.machine_code symbol_table
        assert_equal word_length, cmd.word_length
        assert_equal word_length, machine_code.length
        assert_equal 0, machine_code[0]
        assert_equal 0, machine_code[-1]
      end
    end
  end
  tests = [
    ['42', 42],
    ['audio', 0xD800]
  ]
  tests.each do |args_str, word|
    describe '.word Directive' do
      it ".word #{args_str} -> [#{word}]" do
        d = Assembler::Directives
        cmd = d.handle(:'.word', args_str, [], 0, symbol_table)
        machine_code = cmd.machine_code symbol_table
        assert_equal 1, cmd.word_length
        assert_equal 1, machine_code.length
        assert_equal word, machine_code[0]
      end
    end
  end
  tests = [
    ['[1 2 3]', [], [1, 2, 3]],
    ['[ 1 2 3', ['  4 5 6', '  7 8 9]'], [1, 2, 3, 4, 5, 6, 7, 8, 9]],
    ['[', ["\t1", ' 2', "]\t"], [1, 2]],
    [
      '[$FFFF %0110_0000_1001_1111 64]',
      [],
      [0xFFFF, 0b0110_0000_1001_1111, 64]
    ]
  ]
  tests.each do |args_str, lines, words|
    describe '.array Directive' do
      it ".array #{args_str} -> #{words.inspect}" do
        d = Assembler::Directives
        source = Assembler::Source.new.include_lines lines
        cmd = d.handle(:'.array', args_str, source, 0, {})
        machine_code = cmd.machine_code({})
        length = words.length
        assert_equal length, cmd.word_length
        assert_equal length, machine_code.length
        assert_equal words, machine_code
        assert source.empty?
      end
    end
  end
  tests = [
    ['1 0', [0]],
    ['3 42', [42, 42, 42]],
    ['4 $FF', [0xFF, 0xFF, 0xFF, 0xFF]],
    ['2 %1010_1100', [0xAC, 0xAC]],
    ['3 audio', [0xD800, 0xD800, 0xD800]]
  ]
  tests.each do |args_str, words|
    describe '.fill-array Directive' do
      it ".fill-array #{args_str} -> #{words.inspect}" do
        d = Assembler::Directives
        cmd = d.handle(:'.fill-array', args_str, [], 0, {})
        machine_code = cmd.machine_code(symbol_table)
        length = words.length
        assert_equal length, cmd.word_length
        assert_equal length, machine_code.length
        assert_equal words, machine_code
      end
    end
  end
  tests = [
    '', 'a', 'a ', "a \t", 'abc', 'a b c', 'a "b" c', 'Hellow World',
    'She said "hi" '
  ]
  tests.each do |args_str|
    describe '.str Directive' do
      words = args_str.split('').map(&:ord)
      words.unshift words.size
      it ".str #{args_str} -> #{words.inspect}" do
        d = Assembler::Directives
        cmd = d.handle(:'.str', args_str, [], 0, {})
        machine_code = cmd.machine_code(symbol_table)
        length = words.length
        assert_equal length, cmd.word_length
        assert_equal length, machine_code.length
        assert_equal words, machine_code
      end
    end
  end
  list = [
    ['.end-long-string'],
    [' a b ', '.end-long-string  # end'],
    [' a', 'b ', ".end-long-string\t# end"],
    ['a', "\t\"b\"  \t", 'c d', '.end-long-string']
  ]
  tests = list.map { |lines| ['keep-newlines', lines] } +
          list.map { |lines| ['strip-newlines', lines] }
  tests.each do |args_str, lines|
    describe '.long-string Directive' do
      d = Assembler::Directives
      source = Assembler::Source.new.include_lines lines.dup
      lines = lines.dup
      lines.pop
      char = if args_str == 'keep-newlines'
               "\n"
             else
               ''
             end
      words = lines.join(char).split('').map(&:ord)
      words.unshift words.size
      it ".long-string #{args_str} #{lines} -> #{words.inspect}" do
        cmd = d.handle(:'.long-string', args_str, source, 0, {})
        machine_code = cmd.machine_code(symbol_table)
        length = words.length
        assert_equal length, cmd.word_length
        assert_equal length, machine_code.length
        assert_equal words, machine_code
      end
    end
  end

  describe 'directive_to_class_name' do
    tests = [
      [:'.set', :SetDirective],
      [:'.word', :WordDirective],
      [:'.array', :ArrayDirective],
      [:'.fill-array', :FillArrayDirective],
      [:'.string', :StringDirective],
      [:'.long-string', :LongStringDirective],
      [:'.end-long-string', :EndLongStringDirective],
      [:'.move', :MoveDirective],
      [:'.include', :IncludeDirective],
      [:'.copy', :CopyDirective]
    ]
    tests.each do |directive, expected_class_name|
      it "#{directive} --> #{expected_class_name}" do
        d = Assembler::Directives
        actual_class_name = d.directive_to_class_name directive
        assert_equal expected_class_name, actual_class_name
      end
    end
  end
end
