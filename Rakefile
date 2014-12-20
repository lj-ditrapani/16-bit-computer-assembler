require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.pattern = 'spec/*_spec.rb'
end

desc 'Word count'
task :wc do
  sh %(wc lib/assembler.rb lib/assembler/*)
  puts ''
  sh %(wc spec/*.rb)
end

desc 'Runs rubocop and tests'
task default: [:rubocop, :test]
