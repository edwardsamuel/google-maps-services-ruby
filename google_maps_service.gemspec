# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_maps_service/version'

Gem::Specification.new do |spec|
  spec.name          = 'google_maps_service'
  spec.version       = GoogleMapsService::VERSION
  spec.authors       = ['Edward Samuel Pasaribu']
  spec.email         = ['edwardsamuel92@gmail.com']

  spec.summary       = %q{Ruby client library (unofficial) for Google Maps API Web Services}
  spec.homepage      = %q{https://github.com/edwardsamuel/google-maps-services-ruby}
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.has_rdoc      = 'yard'

  spec.add_runtime_dependency 'multi_json', '~> 1.11'
  spec.add_runtime_dependency 'hurley', '~> 0.1'
  spec.add_runtime_dependency 'ruby-hmac', '~> 0.4.0'
  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.8.7.6'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'coveralls', '~> 0.8.2'
  spec.add_development_dependency 'webmock', '~> 1.21', '>= 1.21.0'
end
