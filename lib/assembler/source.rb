module Assembler
  # Holds the list of source assembly lines yet to be processed
  class Source
    attr_reader :line_number, :current_line

    def initialize
      @lines = []
    end

    def pop_line
      @current_line = @lines.shift
    end

    def pop_sub_line
      @lines.shift
    end

    def empty?
      @lines.empty?
    end

    def include_file(file_name)
      text_lines = File.readlines(file_name)
      include_lines text_lines, file_name
      self
    end

    def include_lines(text_lines, file_name = 'no-file-given')
      new_lines = text_to_lines(file_name, text_lines)
      @lines = new_lines + @lines
      self
    end

    def text_to_lines(file_name, text_lines)
      text_lines.map.with_index(1) do |text, line_number|
        Line.new(file_name, line_number, text.chomp)
      end
    end

    private :text_to_lines

    # Holds a line of source assembly text
    class Line
      Label = Directives::LabelDirective
      attr_accessor :word_index
      attr_reader :text, :source_info

      def initialize(file_name, line_number, text)
        @source_info = SourceInfo.new file_name, line_number, text
        @text = if Label.label? text
                  Label.to_directive_form text
                else
                  text
                end
      end

      def first_word
        @first_word ||= strip.split(' ', 2)[0]
      end

      def args_str
        @args_str ||= text_to_split.split(' ', 2)[1]
      end

      # Removes white space a begining and end and comments
      # Do not call on .str or lines betwenn .long-string
      def strip
        @strip ||= _strip
      end

      def empty?
        strip.empty?
      end

      private

      def text_to_split
        if first_word == '.str'   # don't strip a .str directive
          @text
        else                      # only strip if not a .str directive
          strip
        end
      end

      def _strip
        text_line = @text.strip
        return '' if text_line.empty? || text_line[0] == '#'
        text_line.split('#', 2)[0].strip
      end

      # Contains `file_name`, `line_number`, and `text` state.
      # Has `error_info` method.
      # Holds information for Line and Command objects so when an
      # exception occurs, source line information can be presented to
      # the user.
      class SourceInfo
        def initialize(file_name, line_number, text)
          @file_name, @line_number, @text = file_name, line_number, text
        end

        def error_info
          ["ASSEMBLER ERROR in file #{@file_name}",
           "LINE # #{@line_number}",
           "SOURCE CODE: #{@text}"]
        end
      end
    end
  end
end
