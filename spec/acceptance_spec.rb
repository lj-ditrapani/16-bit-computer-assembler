require 'minitest/autorun'
require 'fileutils'


def run_cli_test(name, asm_file)
  exe_file = "#{name}.exe"
  exe_path = "actual-executables/#{exe_file}"
  expected_exe_path = "expected-executables/#{exe_file}"
  describe "When the #{asm_file} program is given as CL input" do
    %x(./bin/assembler assembly-programs/#{asm_file} > #{exe_path})
    it "Should produce the #{exe_file} file as output" do
      assert FileUtils.cmp(exe_path, expected_exe_path)
    end
  end
end


describe "Assembler CLI" do
  program_names = %w(adding branching while-loop)
  program_names.each do |name|
    run_cli_test name, "#{name}.no-symbols.asm"
    run_cli_test name, "#{name}.symbols.asm"
  end
end
