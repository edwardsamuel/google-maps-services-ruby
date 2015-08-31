# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_maps_services/version'

Gem::Specification.new do |spec|
  spec.name          = "google_maps_services"
  spec.version       = GoogleMapsServices::VERSION
  spec.authors       = ["Edward Samuel Pasaribu"]
  spec.email         = ["edwardsamuel92@gmail.com"]

  spec.summary       = %q{Ruby client library (unofficial) for Google Maps API Web Services}
  spec.homepage      = %q{https://github.com/edwardsamuel/google-maps-services-ruby}
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.has_rdoc         = 'yard'

  spec.add_runtime_dependency "faraday", "~> 0.9.1"
  spec.add_runtime_dependency "faraday_middleware", "~> 0.10.0"
  spec.add_runtime_dependency "ruby-hmac", "~> 0.4.0"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.0.11"
  spec.add_development_dependency "yard", "~> 0.8.7.6"
end
