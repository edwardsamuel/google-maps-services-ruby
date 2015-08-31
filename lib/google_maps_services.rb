module GoogleMapsServices
  class << self
    attr_accessor :key, :ssl, :connection_middleware

    def configure
      yield self
      true
    end
  end

  require 'google_maps_services/version'
  require 'google_maps_services/convert'
  require 'google_maps_services/client'
end
