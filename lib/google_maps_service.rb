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

    # Global connect_timeout.
    # @see Client#connect_timeout
    # @return [Integer]
    attr_accessor :connect_timeout

    # Global read_timeout.
    # @see Client#read_timeout
    # @return [Integer]
    attr_accessor :read_timeout

    # Global retry_timeout.
    # @see Client#retry_timeout
    # @return [Integer]
    attr_accessor :retry_timeout

    # Global queries_per_second.
    # @see Client#queries_per_second
    # @return [Integer]
    attr_accessor :queries_per_second

    def configure
      yield self
      true
    end
  end

  require 'google_maps_service/version'
  require 'google_maps_service/client'
end
