require 'rake/testtask'
require 'yard'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end