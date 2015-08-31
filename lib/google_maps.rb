module GoogleMaps
  class << self
    attr_accessor :key, :ssl, :connection_middleware

    def configure
      yield self
      true
    end
  end

  require 'google_maps/version'
  require 'google_maps/convert'
  require 'google_maps/client'
end
