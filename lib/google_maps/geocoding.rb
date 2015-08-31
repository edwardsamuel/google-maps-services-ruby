"""Performs requests to the Google Maps Geocoding API."""

module GoogleMaps
  module Geocoding

    # Geocoding is the process of converting addresses
    # (like +"1600 Amphitheatre Parkway, Mountain View, CA"+) into geographic
    # coordinates (like latitude 37.423021 and longitude -122.083739), which you
    # can use to place markers or position the map.
    #
    # @param [String] address The address to geocode.
    # @param [Hash] components A component filter for which you wish to obtain a geocode,
    #                    for example: +{'administrative_area': 'TX','country': 'US'}+
    # @param [String, Hash] bounds The bounding box of the viewport within which to bias geocode
    #                results more prominently. Accept string or hash with northeast and southwest keys.
    # @param [String] region The region code, specified as a ccTLD ("top-level domain")
    #                two-character value.
    # @param [String] language The language in which to return results.
    #
    # @return list of geocoding results.
    def geocode(address, components=nil, bounds=nil, region=nil, language=nil)
      params = {}

      if address
        params["address"] = address
      end

      if components
        params["components"] = GoogleMaps::Convert.components(components)
      end

      if bounds
        params["bounds"] = GoogleMaps::Convert.bounds(bounds)
      end

      if region
        params["region"] = region
      end

      if language
        params["language"] = language
      end

      return get("/maps/api/geocode/json", params)
    end

    # Reverse geocoding is the process of converting geographic coordinates into a
    # human-readable address.
    #
    # @param [Hash, Array] latlng The latitude/longitude value for which you wish to obtain the
    #                closest, human-readable address#
    # @param [String, Array<String>] result_type One or more address types to restrict results to.
    # @param [Array<String>] location_type One or more location types to restrict results to.
    # @param [String] language: The language in which to return results.
    #
    # @string list of reverse geocoding results.
    def reverse_geocode(latlng, result_type=nil, location_type=nil, language=nil)
      params = {
          "latlng": convert.latlng(latlng)
      }

      if result_type
        params["result_type"] = convert.join_list("|", result_type)
      end
      if location_type
        params["location_type"] = convert.join_list("|", location_type)
      end
      if language
        params["language"] = language
      end
      return client._get("/maps/api/geocode/json", params)["results"]
    end

  end
end
