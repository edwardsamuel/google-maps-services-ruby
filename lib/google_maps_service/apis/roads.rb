require_relative './base'
require_relative '../response_handlers/roads'

module GoogleMapsService
  module Apis
    # Performs requests to the Google Maps Roads API.
    class Roads < Base
      # Base URL of Google Maps Roads API
      ROADS_BASE_URL = 'https://roads.googleapis.com'.freeze

      # Google Maps Roads API response handler
      ROADS_RESP_HANDLER = GoogleMapsService::RoadsResponseHandler

      # Snaps a path to the most likely roads travelled.
      #
      # Takes up to 100 GPS points collected along a route, and returns
      # a similar set of data with the points snapped to the most likely roads
      # the vehicle was traveling along.
      #
      # @example Single point snap
      #   results = client.snap_to_roads([40.714728, -73.998672])
      #
      # @example Multi points snap
      #   path = [
      #       [-33.8671, 151.20714],
      #       [-33.86708, 151.20683000000002],
      #       [-33.867070000000005, 151.20674000000002],
      #       [-33.86703, 151.20625]
      #   ]
      #   results = client.snap_to_roads(path, interpolate: true)
      #
      # @param [Array] path The path to be snapped.
      #         Array of latitude/longitude pairs.
      # @option options [Boolean] interpolate Whether to interpolate a path
      #         to include all points forming the full road-geometry. When true,
      #         additional interpolated points will also be returned,
      #         resulting in a path that smoothly follows the geometry of
      #         the road, even around corners and through tunnels.
      #         Interpolated paths may contain more points than
      #         the original path.
      #
      # @return [Array] Array of snapped points.
      def snap_to_roads(path, options = {})
        path = GoogleMapsService::Convert.waypoints(path)

        params = {
          path: path
        }
        params[:interpolate] = 'true' if options[:interpolate]

        get('/v1/snapToRoads', params,
            base_url: ROADS_BASE_URL,
            accepts_client_id: false,
            response_handler: ROADS_RESP_HANDLER)[:snappedPoints]
      end

      # Returns the posted speed limit (in km/h) for given road segments.
      #
      # @example Multi places snap
      #   place_ids = [
      #     'ChIJ0wawjUCuEmsRgfqC5Wd9ARM',
      #     'ChIJ6cs2kkCuEmsRUfqC5Wd9ARM'
      #   ]
      #   results = client.speed_limits(place_ids)
      #
      # @param [String, Array<String>] place_ids The Place ID
      #         of the road segment. Place IDs are returned by
      #         the `snap_to_roads` function.
      #         You can pass up to 100 Place IDs.
      #
      # @return [Array] Array of speed limits.
      def speed_limits(place_ids)
        params = GoogleMapsService::Convert.as_list(place_ids).map do |place_id|
          ['placeId', place_id]
        end

        get('/v1/speedLimits', params,
            base_url: ROADS_BASE_URL,
            accepts_client_id: false,
            response_handler: ROADS_RESP_HANDLER)[:speedLimits]
      end

      # Returns the posted speed limit (in km/h) for given road segments.
      #
      # The provided points will first be snapped to the most likely roads the
      # vehicle was traveling along.
      #
      # @example Multi points snap
      #   path = [
      #       [-33.8671, 151.20714],
      #       [-33.86708, 151.20683000000002],
      #       [-33.867070000000005, 151.20674000000002],
      #       [-33.86703, 151.20625]
      #   ]
      #   results = client.snapped_speed_limits(path)
      #
      # @param [Hash, Array] path The path of points to be snapped.
      #         A list of (or single) latitude/longitude tuples.
      #
      # @return [Hash] A hash with both a list of speed limits and a list
      #         of the snapped points.
      def snapped_speed_limits(path)
        path = GoogleMapsService::Convert.waypoints(path)
        params = { path: path }

        get('/v1/speedLimits', params,
            base_url: ROADS_BASE_URL,
            accepts_client_id: false,
            response_handler: ROADS_RESP_HANDLER)
      end
    end
  end
end
