require 'minitest/autorun'
require 'fileutils'

FAIL_DIR = 'spec/assembly-programs/failures'

def get_err_path(err_file, asm_path)
  if err_file.nil?
    asm_path
  else
    "#{FAIL_DIR}/#{err_file}.asm"
  end
end

def run_failing_cli_test(name, reg_ex, line_num, err_file = nil)
  asm_path = "#{FAIL_DIR}/#{name}.asm"
  err_path = get_err_path err_file, asm_path
  stderr_path = "spec/stderr/#{name}.txt"
  describe "When the #{name}.asm program is given as CL input" do
    `./bin/assembler #{asm_path} 2> #{stderr_path}`
    it 'It outputs an AsmError on stderr' do
      compare_stderr(stderr_path, reg_ex, err_path, line_num)
    end
  end
end

def compare_stderr(stderr_path, reg_ex, asm_path, line_num)
  File.open(stderr_path) do |f|
    str = f.read
    assert_match reg_ex, str
    assert_match "ASSEMBLER ERROR in file #{asm_path}", str
    assert_match("LINE # #{line_num}", str)
  end
end

tests = [
  ['bad-int', /Malformed integer: '3bad'/, 2],
  ['bad-symbol', /Undefined symbol: :R16/, 2],
  ['not-a-directive', /First word '\.NOT' not/, 4],
  ['not-an-instruction', /First word 'MAD' not/, 2],
  ['error-from-included', /First word 'include' not/, 3, 'included'],
  ['neg-set', /Undefined symbol: :"-5"/, 1]
]

tests.each { |args| run_failing_cli_test(*args) }
