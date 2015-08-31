module GoogleMaps

  # Performs requests to the Google Maps Elevation API.
  module Elevation

    # Provides elevation data for locations provided on the surface of the
    # earth, including depth locations on the ocean floor (which return negative
    # values)
    #
    # @param [Array] locations A single latitude/longitude hash, or an array of
    #         latitude/longitude hash from which you wish to calculate
    #         elevation data.
    #
    # @return list of elevation data responses
    def elevation(locations)
      params = {}
      if locations.kind_of?(Array) and locations.length == 2 and not locations[0].kind_of?(Array)
        locations = [locations]
      end

      params["locations"] = _convert_locations(locations)

      return get("/maps/api/elevation/json", params)["results"]
    end

    # Provides elevation data sampled along a path on the surface of the earth.
    #
    # @param [String, Array] path A encoded polyline string, or a list of
    #         latitude/longitude tuples from which you wish to calculate
    #         elevation data.
    #
    # @param [Integer] samples The number of sample points along a path for which to
    #         return elevation data.
    #
    # @return Array of elevation data responses
    def elevation_along_path(path, samples)
      if path.kind_of?(String)
        path = "enc:%s" % path
      else
        path = _convert_locations(path)
      end

      params = {
        "path": path,
        "samples": samples
      }

      return get("/maps/api/elevation/json", params)["results"]
    end

    private
      def _convert_locations(locations)
        locations = GoogleMaps::Convert.as_list(locations)
        return GoogleMaps::Convert.join_list("|", locations.map { |k| k.kind_of?(String) ? k : GoogleMaps::Convert.latlng(k) })
      end
  end
end