require_relative './base'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps Elevation API.
    class Elevation < Base
      # Base path of Elevation API
      BASE_PATH = '/maps/api/elevation/json'.freeze

      # Provides elevation data for locations provided on the surface of
      # the earth, including depth locations on the ocean floor (which return
      # negative values).
      #
      # @example Single point elevation
      #   results = client.elevation(
      #               {latitude: 40.714728, longitude: -73.998672}
      #             )
      #
      # @example Multiple points elevation
      #   locations = [[40.714728, -73.998672], [-34.397, 150.644]]
      #   results = client.elevation(locations)
      #
      # @param [Array] locations A single latitude/longitude hash, or an array
      #         of latitude/longitude hash from which you wish to calculate
      #         elevation data.
      #
      # @return [Array] Array of elevation data responses
      def elevation(locations)
        params = {
          locations: GoogleMapsService::Convert.waypoints(locations)
        }

        get(BASE_PATH, params)[:results]
      end

      # Provides elevation data sampled along a path on the surface
      # of the earth.
      #
      # @example Elevation along path
      #   locations = [[40.714728, -73.998672], [-34.397, 150.644]]
      #   results = client.elevation_along_path(locations, 5)
      #
      # @option options [String, Array] path A encoded polyline string,
      #         or a list of latitude/longitude pairs from which you wish to
      #         calculate elevation data.
      # @option options [Integer] samples The number of sample points along
      #         a path for which to return elevation data.
      #
      # @return [Array] Array of elevation data responses
      def elevation_along_path(path, samples)
        path = if path.is_a?(String)
                 "enc:#{path}"
               else
                 GoogleMapsService::Convert.waypoints(path)
               end

        params = {
          path: path,
          samples: samples
        }

        get(BASE_PATH, params)[:results]
      end
    end
  end
end
