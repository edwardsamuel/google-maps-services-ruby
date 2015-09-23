# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_maps_service/version'

Gem::Specification.new do |spec|
  spec.name          = 'google_maps_service'
  spec.version       = GoogleMapsService::VERSION
  spec.authors       = ['Edward Samuel Pasaribu']
  spec.email         = ['edwardsamuel92@gmail.com']

  spec.summary       = %q{Ruby gem for Google Maps Web Service APIs }
  spec.homepage      = %q{https://github.com/edwardsamuel/google-maps-services-ruby}
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']
  spec.has_rdoc      = 'yard'

  spec.add_runtime_dependency 'multi_json', '~> 1.11'
  spec.add_runtime_dependency 'hurley', '~> 0.1'
  spec.add_runtime_dependency 'retriable', '~> 2.0'
end
