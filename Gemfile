source 'https://rubygems.org'

# Specify your gem's dependencies in google_maps_service.gemspec
gemspec

group :development do
  gem 'bundler', '~> 1.6'
  gem 'rake', '~> 11.0'
  gem 'rspec', '~> 3.3'
  gem 'simplecov', '~> 0.10'
  gem 'coveralls', '~> 0.8.2'
  gem 'webmock', '~> 1.21'

  gem 'rubocop', '~> 0.39.0', require: false
end

platforms :ruby do
  group :development do
    gem 'yard', '~> 0.8', require: false
    gem 'redcarpet', '~> 3.2', require: false
  end
end

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
