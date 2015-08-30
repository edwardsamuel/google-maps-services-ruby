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

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
