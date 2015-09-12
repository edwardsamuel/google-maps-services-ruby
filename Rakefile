require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end