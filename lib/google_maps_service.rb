module GoogleMapsService
  class << self
    attr_accessor :key, :client_id, :client_secret, :connect_timeout, :read_timeout, :retry_timeout

    def configure
      yield self
      true
    end
  end

  require 'google_maps_service/version'
  require 'google_maps_service/errors'
  require 'google_maps_service/convert'
  require 'google_maps_service/directions'
  require 'google_maps_service/distance_matrix'
  require 'google_maps_service/elevation'
  require 'google_maps_service/geocoding'
  require 'google_maps_service/roads'
  require 'google_maps_service/time_zone'
  require 'google_maps_service/client'
end
