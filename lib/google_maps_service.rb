# Google Maps Web Service API.
module GoogleMapsService
  class << self
    # @see Client#key
    # @return [String] The global key.
    attr_accessor :key

    # @see Client#client_id
    # @return [String] The global client_id.
    attr_accessor :client_id

    # @see Client#client_secret
    # @return [String] The global client_secret.
    attr_accessor :client_secret

    # @see Client#retry_timeout
    # @return [Integer] The global retry_timeout.
    attr_accessor :retry_timeout

    # @see Client#queries_per_second
    # @return [Integer] Global queries_per_second.
    attr_accessor :queries_per_second

    # Configure the global parameters.
    # @yield [config]
    def configure
      yield self
      self
    end
  end

  require 'google_maps_service/version'
  require 'google_maps_service/client'
  require 'google_maps_service/polyline'
end
