module GoogleMaps
  class << self
    attr_accessor :key, :client_id, :client_secret, :ssl, :connection_middleware

    def configure
      yield self
      true
    end
  end

  require 'google_maps/version'
  require 'google_maps/errors'
  require 'google_maps/convert'
  require 'google_maps/directions'
  require 'google_maps/distance_matrix'
  require 'google_maps/elevation'
  require 'google_maps/geocoding'
  require 'google_maps/roads'
  require 'google_maps/time_zone'
  require 'google_maps/client'
end
