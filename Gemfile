source 'https://rubygems.org'

# Specify your gem's dependencies in google_maps_service.gemspec
gemspec

group :development do
  gem 'bundler', '~> 1.6'
  gem 'rake', '~> 10.0'
  gem 'rspec', '~> 3.3'
  gem 'simplecov', '~> 0.10'
  gem 'coveralls', '~> 0.8.2'
  gem 'webmock', '~> 1.21'
end

platforms :ruby do
  group :development do
    gem 'yard', '~> 0.8'
    gem 'redcarpet', '~> 3.2'
  end
end

if ENV['RAILS_VERSION']
  gem 'rails', ENV['RAILS_VERSION']
end
