require_relative './base'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps Geocoding API.
    class Geocoding < Base
      # Base path of Geocoding API
      BASE_PATH = '/maps/api/geocode/json'.freeze

      # Geocoding is the process of converting addresses
      # (like `"1600 Amphitheatre Parkway, Mountain View, CA"`) into geographic
      # coordinates (like latitude 37.423021 and longitude -122.083739), which
      # you can use to place markers or position the map.
      #
      # @example Geocode an address
      #   results = client.geocode('Sydney')
      #
      # @example Geocode a component only
      #   results = client.geocode(nil,
      #                            components: { administrative_area: 'TX',
      #                                          country: 'US' })
      #
      # @example Geocode an address and component
      #   results = client.geocode('Sydney',
      #                            components: { administrative_area: 'TX',
      #                                          country: 'US' })
      #
      # @example Multiple parameters
      #   results = client.geocode('Sydney',
      #       components: { administrative_area: 'TX', country: 'US' },
      #       bounds: {
      #         northeast: { lat: 32.7183997, lng: -97.26864001970849 },
      #         southwest: { lat: 32.7052583, lng: -97.27133798029149 }
      #       },
      #       region: 'us')
      #
      # @param [String] address The address to geocode.
      #    You must specify either this value and/or `components`.
      # @option options [Hash] components A component filter for which you wish
      #    to obtain a geocode,
      #    for example: `{'administrative_area': 'TX','country': 'US'}`
      # @option options [String, Hash] bounds The bounding box of the viewport
      #    within which to bias geocode results more prominently.
      #    Accept string or hash with `northeast` and `southwest` keys.
      # @option options [String] region The region code, specified as a ccTLD
      #    (_top-level domain_) two-character value.
      # @option options [String] language The language in which to return
      #    results.
      #
      # @return [Array] Array of geocoding results.
      def geocode(address, options = {})
        params = options.clone
        params[:address] = address if address

        convert params, :components, with: :components
        convert params, :bounds, with: :bounds

        get(BASE_PATH, params)[:results]
      end

      # Reverse geocoding is the process of converting geographic coordinates
      # into a human-readable address.
      #
      # @example Simple lat/lon pair
      #   client.reverse_geocode({ lat: 40.714224, lng: -73.961452 })
      #
      # @example Multiple parameters
      #   client.reverse_geocode([40.714224, -73.961452],
      #       location_type: ['ROOFTOP', 'RANGE_INTERPOLATED'],
      #       result_type: ['street_address', 'route'],
      #       language: 'es')
      #
      # @param [Hash, Array] latlng The latitude/longitude value for which you
      #    wish to obtain the closest, human-readable address.
      # @option options [String, Array<String>] location_type One or more
      #    location types to restrict results to.
      # @option options [String, Array<String>] result_type One or more address
      #    types to restrict results to.
      # @option options [String] language The language in which to return
      #    results.
      #
      # @return [Array] Array of reverse geocoding results.
      def reverse_geocode(latlng, options = {})
        params = options.clone
        params[:latlng] = latlng

        convert params, :latlng, with: :latlng
        convert params, :result_type, with: :join_list
        convert params, :location_type, with: :join_list

        get(BASE_PATH, params)[:results]
      end
    end
  end
end
