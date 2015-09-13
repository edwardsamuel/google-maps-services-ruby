require 'google_maps_service/convert'

module GoogleMapsService

  # Performs requests to the Google Maps Geocoding API.
  module Geocoding

    # Geocoding is the process of converting addresses
    # (like +"1600 Amphitheatre Parkway, Mountain View, CA"+) into geographic
    # coordinates (like latitude 37.423021 and longitude -122.083739), which you
    # can use to place markers or position the map.
    #
    # @param [String] address The address to geocode.
    # @param [Hash] components A component filter for which you wish to obtain a geocode,
    #                    for example: `{ 'administrative_area': 'TX','country': 'US' }`
    # @param [String, Hash] bounds The bounding box of the viewport within which to bias geocode
    #                results more prominently. Accept string or hash with northeast and southwest keys.
    # @param [String] region The region code, specified as a ccTLD ("top-level domain")
    #                two-character value.
    # @param [String] language The language in which to return results.
    #
    # @return Array of geocoding results.
    def geocode(address: nil, components: nil, bounds: nil, region: nil, language: nil)
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
    # @param [Hash, Array] latlng The latitude/longitude value for which you wish to obtain the
    #                closest, human-readable address#
    # @param [String, Array<String>] result_type One or more address types to restrict results to.
    # @param [Array<String>] location_type One or more location types to restrict results to.
    # @param [String] language The language in which to return results.
    #
    # @return Array of reverse geocoding results.
    def reverse_geocode(latlng: nil, result_type: nil, location_type: nil, language: nil)
      params = {
        latlng: GoogleMapsService::Convert.latlng(latlng)
      }

      params[:result_type] = GoogleMapsService::Convert.join_list("|", result_type) if result_type
      params[:location_type] = GoogleMapsService::Convert.join_list("|", location_type) if location_type
      params[:language] = language if language

      return get('/maps/api/geocode/json', params)[:results]
    end

  end
end
