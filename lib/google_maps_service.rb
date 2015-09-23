# Google Maps Web Service API.
module GoogleMapsService
  class << self

    # Global key.
    # @see Client#key
    # @return [String]
    attr_accessor :key

    # Global client_id.
    # @see Client#client_id
    # @return [String]
    attr_accessor :client_id

    # Global client_secret.
    # @see Client#client_secret
    # @return [String]
    attr_accessor :client_secret

    # Global retry_timeout.
    # @see Client#retry_timeout
    # @return [Integer]
    attr_accessor :retry_timeout

    # Global queries_per_second.
    # @see Client#queries_per_second
    # @return [Integer]
    attr_accessor :queries_per_second

    # Global request_options.
    # @see Client#initialize-instance_method
    # @return [Hurley::RequestOptions]
    attr_accessor :request_options

    # Global ssl_options.
    # @see Client#initialize-instance_method
    # @return [Hurley::SslOptions]
    attr_accessor :ssl_options

    # Global connection.
    # @see Client#initialize-instance_method
    # @return [Object]
    attr_accessor :connection

    # Configure global parameters.
    # @yield [config]
    def configure
      yield self
      true
    end
  end

  require 'google_maps_service/version'
  require 'google_maps_service/client'
  require 'google_maps_service/polyline'
end
