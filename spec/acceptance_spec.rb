require 'minitest/autorun'
require 'fileutils'

def run_cli_test(name, expected_exe)
  asm_file = "#{name}.asm"
  exe_file = "#{name}.exe"
  exe_path = "actual-executables/#{exe_file}"
  expected_exe_path = "expected-executables/#{expected_exe}.exe"
  describe "When the #{asm_file} program is given as CL input" do
    `./bin/assembler assembly-programs/#{asm_file} > #{exe_path}`
    it "Should produce the #{expected_exe} file as output" do
      assert FileUtils.cmp(exe_path, expected_exe_path)
    end
  end
end

describe 'Assembler CLI' do
  program_names = %w(adding branching while-loop)
  program_names.each do |name|
    run_cli_test "#{name}.no-symbols", name
    run_cli_test "#{name}.symbols", name
  end
end

describe 'Assembler CLI' do
  program_names = %w(misc includer copier include-and-copy)
  program_names.each do |name|
    run_cli_test name, 'misc'
  end
  run_cli_test 'nested-include', 'nested-include'
  run_cli_test 'array-and-long-string', 'array-and-long-string'
end
