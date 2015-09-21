module GoogleMapsService::Apis

  # Performs requests to the Google Maps Elevation API.
  module Elevation

    # Provides elevation data for locations provided on the surface of the
    # earth, including depth locations on the ocean floor (which return negative
    # values).
    #
    # @example Single point elevation
    #   results = client.elevation({latitude: 40.714728, longitude: -73.998672})
    #
    # @example Multiple points elevation
    #   locations = [[40.714728, -73.998672], [-34.397, 150.644]]
    #   results = client.elevation(locations)
    #
    # @param [Array] locations A single latitude/longitude hash, or an array of
    #         latitude/longitude hash from which you wish to calculate
    #         elevation data.
    #
    # @return [Array] Array of elevation data responses
    def elevation(locations)
      params = {
        locations: GoogleMapsService::Convert.waypoints(locations)
      }

      return get('/maps/api/elevation/json', params)[:results]
    end

    # Provides elevation data sampled along a path on the surface of the earth.
    #
    # @example Elevation along path
    #   locations = [[40.714728, -73.998672], [-34.397, 150.644]]
    #   results = client.elevation_along_path(locations, 5)
    #
    # @param [String, Array] path A encoded polyline string, or a list of
    #         latitude/longitude pairs from which you wish to calculate
    #         elevation data.
    # @param [Integer] samples The number of sample points along a path for which to
    #         return elevation data.
    #
    # @return [Array] Array of elevation data responses
    def elevation_along_path(path, samples)
      if path.kind_of?(String)
        path = "enc:%s" % path
      else
        path = GoogleMapsService::Convert.waypoints(path)
      end

      params = {
        path: path,
        samples: samples
      }

      return get('/maps/api/elevation/json', params)[:results]
    end
  end
end