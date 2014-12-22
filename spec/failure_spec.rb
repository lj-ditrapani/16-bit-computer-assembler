require 'minitest/autorun'
require 'fileutils'

def run_failing_cli_test(name, reg_ex, line_num = nil)
  asm_path = "spec/assembly-programs/failures/#{name}.asm"
  stderr_path = "spec/stderr/#{name}.txt"
  describe "When the #{name}.asm program is given as CL input" do
    `./bin/assembler #{asm_path} 2> #{stderr_path}`
    it 'It outputs an AsmError on stderr' do
      compare_stderr(stderr_path, reg_ex, asm_path, line_num)
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

run_failing_cli_test 'bad-int', /Malformed integer/, 2
run_failing_cli_test 'bad-symbol', /Undefined symbol: :R16/, 2
