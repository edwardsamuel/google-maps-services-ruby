require 'google_maps_service/convert'

module GoogleMapsService::Apis

  # Performs requests to the Google Maps Geocoding API.
  module Geocoding

    # Geocoding is the process of converting addresses
    # (like `"1600 Amphitheatre Parkway, Mountain View, CA"`) into geographic
    # coordinates (like latitude 37.423021 and longitude -122.083739), which you
    # can use to place markers or position the map.
    #
    # @example Geocode an address
    #   results = client.geocode('Sydney')
    #
    # @example Geocode a component only
    #   results = client.geocode(nil, components: {administrative_area: 'TX', country: 'US'})
    #
    # @example Geocode an address and component
    #   results = client.geocode('Sydney', components: {administrative_area: 'TX', country: 'US'})
    #
    # @example Multiple parameters
    #   results = client.geocode('Sydney',
    #       components: {administrative_area: 'TX', country: 'US'},
    #       bounds: {
    #         northeast: {lat: 32.7183997, lng: -97.26864001970849},
    #         southwest: {lat: 32.7052583, lng: -97.27133798029149}
    #       },
    #       region: 'us')
    #
    # @param [String] address The address to geocode. You must specify either this value and/or `components`.
    # @param [Hash] components A component filter for which you wish to obtain a geocode,
    #                    for example: `{'administrative_area': 'TX','country': 'US'}`
    # @param [String, Hash] bounds The bounding box of the viewport within which to bias geocode
    #                results more prominently. Accept string or hash with `northeast` and `southwest` keys.
    # @param [String] region The region code, specified as a ccTLD (_top-level domain_)
    #                two-character value.
    # @param [String] language The language in which to return results.
    #
    # @return [Array] Array of geocoding results.
    def geocode(address, components: nil, bounds: nil, region: nil, language: nil)
      params = {}

      params[:address] = address if address
      params[:components] = GoogleMapsService::Convert.components(components) if components
      params[:bounds] = GoogleMapsService::Convert.bounds(bounds) if bounds
      params[:region] = region if region
      params[:language] = language if language

      return get('/maps/api/geocode/json', params)[:results]
    end

    # Reverse geocoding is the process of converting geographic coordinates into a
    # human-readable address.
    #
    # @example Simple lat/lon pair
    #   client.reverse_geocode({lat: 40.714224, lng: -73.961452})
    #
    # @example Multiple parameters
    #   client.reverse_geocode([40.714224, -73.961452],
    #       location_type: ['ROOFTOP', 'RANGE_INTERPOLATED'],
    #       result_type: ['street_address', 'route'],
    #       language: 'es')
    #
    # @param [Hash, Array] latlng The latitude/longitude value for which you wish to obtain
    #                the closest, human-readable address.
    # @param [String, Array<String>] location_type One or more location types to restrict results to.
    # @param [String, Array<String>] result_type One or more address types to restrict results to.
    # @param [String] language The language in which to return results.
    #
    # @return [Array] Array of reverse geocoding results.
    def reverse_geocode(latlng, location_type: nil, result_type: nil, language: nil)
      params = {
        latlng: GoogleMapsService::Convert.latlng(latlng)
      }

      params[:result_type] = GoogleMapsService::Convert.join_list('|', result_type) if result_type
      params[:location_type] = GoogleMapsService::Convert.join_list('|', location_type) if location_type
      params[:language] = language if language

      return get('/maps/api/geocode/json', params)[:results]
    end

  end
end
