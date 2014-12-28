require 'minitest/autorun'
require './lib/assembler'

describe Assembler::Directives do
  Source = Assembler::Source
  SYMBOL_TABLE = Assembler::SymbolTable.new
  D = Assembler::Directives

  def check(cmd, expected_machine_code)
    actual_machine_code = cmd.machine_code SYMBOL_TABLE
    length = expected_machine_code.length
    assert_equal length, cmd.word_length
    assert_equal length, actual_machine_code.length
    assert_equal expected_machine_code, actual_machine_code
  end

  handle = lambda do |directive, args_str, word_index = 0, source = []|
    text = "#{directive}\t#{args_str}"
    line = Source::Line.new('f.asm', 5, text)
    line.word_index = word_index
    source = Source.new.include_lines(source) if source.class == Array
    Assembler::Directives.handle(line, source, SYMBOL_TABLE)
  end

  describe D::MoveDirective do
    tests = [
      ['$00FF', 0x0010, 239],
      ['audio', 0x005, (0xD800 - 5)]
    ]
    tests.each do |args_str, word_index, word_length|
      it ".move #{args_str} -> array of #{word_length} zeros" do
        cmd = handle.call(:'.move', args_str, word_index)
        check(cmd, [0] * word_length)
      end
    end
  end

  describe D::WordDirective do
    tests = [
      ['42', 42],
      ['audio', 0xD800]
    ]
    tests.each do |args_str, word|
      it ".word #{args_str} -> [#{word}]" do
        cmd = handle.call(:'.word', args_str)
        check(cmd, [word])
      end
    end
  end

  describe D::ArrayDirective do
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
      it ".array #{args_str} -> #{words.inspect}" do
        source = Source.new.include_lines lines
        cmd = handle.call(:'.array', args_str, 0, source)
        check(cmd, words)
        assert source.empty?
      end
    end
  end

  describe D::FillArrayDirective do
    tests = [
      ['1 0', [0]],
      ['3 42', [42, 42, 42]],
      ['4 $FF', [0xFF, 0xFF, 0xFF, 0xFF]],
      ['2 %1010_1100', [0xAC, 0xAC]],
      ['3 audio', [0xD800, 0xD800, 0xD800]]
    ]
    tests.each do |args_str, words|
      it ".fill-array #{args_str} -> #{words.inspect}" do
        cmd = handle.call(:'.fill-array', args_str)
        check(cmd, words)
      end
    end
  end

  describe D::StrDirective do
    tests = [
      '', 'a', 'a ', "a \t", 'abc', 'a b c', 'a "b" c', 'Hellow World',
      'She said "hi" '
    ]
    tests.each do |args_str|
      words = args_str.split('').map(&:ord)
      words.unshift words.size
      it ".str #{args_str} -> #{words.inspect}" do
        cmd = handle.call(:'.str', args_str)
        check(cmd, words)
      end
    end
  end

  describe D::LongStringDirective do
    list = [
      ['.end-long-string'],
      [' a b ', '.end-long-string  # end'],
      [' a', 'b ', ".end-long-string\t# end"],
      ['a', "\t\"b\"  \t", 'c d', '.end-long-string']
    ]
    tests = list.map { |lines| ['keep-newlines', "\n", lines.dup] } +
            list.map { |lines| ['strip-newlines', '', lines.dup] }
    tests.each do |args_str, char, lines|
      source_lines = lines.dup
      str_lines = lines.dup
      str_lines.pop
      words = str_lines.join(char).split('').map(&:ord)
      words.unshift words.size
      it ".long-string #{args_str} #{lines} -> #{words.inspect}" do
        cmd = handle.call(:'.long-string', args_str, 0, source_lines)
        check(cmd, words)
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
        actual_class_name = D.directive_to_class_name directive
        assert_equal expected_class_name, actual_class_name
      end
    end
  end

  describe 'Failing directives raise AsmError' do
    tests = [
      ['.set', 'my-var not-defined', 'Undefined symbol: :"not-defined"']
    ]
    tests.each do |directive, args_str, error_msg|
      it "#{directive} #{args_str} -> raises #{error_msg}" do
        err = assert_raises Assembler::AsmError do
          cmd = handle.call(directive, args_str)
          cmd.machine_code SYMBOL_TABLE
        end
        assert_match error_msg, err.message
      end
    end
  end
end
