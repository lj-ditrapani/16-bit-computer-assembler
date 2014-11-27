require 'minitest/autorun'
require 'fileutils'

def run_cli_test(name, qualified_name)
  asm_file = "#{qualified_name}.asm"
  exe_file = "#{qualified_name}.exe"
  exe_path = "actual-executables/#{exe_file}"
  expected_exe_path = "expected-executables/#{name}.exe"
  describe "When the #{asm_file} program is given as CL input" do
    `./bin/assembler assembly-programs/#{asm_file} > #{exe_path}`
    it "Should produce the #{exe_file} file as output" do
      assert FileUtils.cmp(exe_path, expected_exe_path)
    end
  end
end

describe 'Assembler CLI' do
  program_names = %w(adding branching while-loop)
  program_names.each do |name|
    run_cli_test name, "#{name}.no-symbols"
    run_cli_test name, "#{name}.symbols"
  end
end
