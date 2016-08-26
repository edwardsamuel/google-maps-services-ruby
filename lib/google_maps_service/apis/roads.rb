require 'multi_json'

module GoogleMapsService::Apis

  # Performs requests to the Google Maps Roads API.
  module Roads

    # Base URL of Google Maps Roads API
    ROADS_BASE_URL = "https://roads.googleapis.com"

    # Snaps a path to the most likely roads travelled.
    #
    # Takes up to 100 GPS points collected along a route, and returns a similar
    # set of data with the points snapped to the most likely roads the vehicle
    # was traveling along.
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
    # @param [Array] path The path to be snapped. Array of latitude/longitude pairs.
    # @param [Boolean] interpolate Whether to interpolate a path to include all points
    #         forming the full road-geometry. When true, additional interpolated
    #         points will also be returned, resulting in a path that smoothly
    #         follows the geometry of the road, even around corners and through
    #         tunnels.  Interpolated paths may contain more points than the
    #         original path.
    #
    # @return [Array] Array of snapped points.
    def snap_to_roads(path, interpolate: false)
      path = GoogleMapsService::Convert.waypoints(path)

      params = {
        path: path
      }

      params[:interpolate] = 'true' if interpolate

      return get('/v1/snapToRoads', params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))[:snappedPoints]
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
    # @param [String, Array<String>] place_ids The Place ID of the road segment. Place IDs are returned
    #         by the snap_to_roads function. You can pass up to 100 Place IDs.
    #
    # @return [Array] Array of speed limits.
    def speed_limits(place_ids)
      params = GoogleMapsService::Convert.as_list(place_ids).map { |place_id| ['placeId', place_id] }

      return get('/v1/speedLimits', params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))[:speedLimits]
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
    # @param [Hash, Array] path The path of points to be snapped. A list of (or single)
    #         latitude/longitude tuples.
    #
    # @return [Hash] A hash with both a list of speed limits and a list of the snapped
    #         points.
    def snapped_speed_limits(path)
      path = GoogleMapsService::Convert.waypoints(path)

      params = {
        path: path
      }

      return get('/v1/speedLimits', params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))
    end

    # Returns the nearest road segments for provided points.
    # The points passed do not need to be part of a continuous path.
    #
    # @example Single point snap
    #   results = client.nearest_roads([40.714728, -73.998672])
    #
    # @example Multi points snap
    #   points = [
    #       [-33.8671, 151.20714],
    #       [-33.86708, 151.20683000000002],
    #       [-33.867070000000005, 151.20674000000002],
    #       [-33.86703, 151.20625]
    #   ]
    #   results = client.nearest_roads(points)
    #
    # @param [Array] points The points to be used for nearest road segment lookup. Array of latitude/longitude pairs
    #                       which do not need to be a part of continuous part.
    #                       Takes up to 100 independent coordinates, and returns the closest road segment for each point.
    #
    # @return [Array] Array of snapped points.

    def nearest_roads(points)
      points = GoogleMapsService::Convert.waypoints(points)

      params = {
        points: points
      }

      return get('/v1/nearestRoads', params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))[:snappedPoints]
    end



    private
      # Extracts a result from a Roads API HTTP response.
      def extract_roads_body(response)
        begin
          body = MultiJson.load(response.body, :symbolize_keys => true)
        rescue
          unless response.status_code == 200
            check_response_status_code(response)
          end
          raise GoogleMapsService::Error::ApiError.new(response), 'Received a malformed response.'
        end

        check_roads_body_error(response, body)

        unless response.status_code == 200
          raise GoogleMapsService::Error::ApiError.new(response)
        end
        return body
      end

      # Check response body for error status.
      #
      # @param [Hurley::Response] response Response object.
      # @param [Hash] body Response body.
      def check_roads_body_error(response, body)
        error = body[:error]
        return unless error

        case error[:status]
          when 'INVALID_ARGUMENT'
            if error[:message] == 'The provided API key is invalid.'
              raise GoogleMapsService::Error::RequestDeniedError.new(response), error[:message]
            end
            raise GoogleMapsService::Error::InvalidRequestError.new(response), error[:message]
          when 'PERMISSION_DENIED'
            raise GoogleMapsService::Error::RequestDeniedError.new(response), error[:message]
          when 'RESOURCE_EXHAUSTED'
            raise GoogleMapsService::Error::RateLimitError.new(response), error[:message]
          else
            raise GoogleMapsService::Error::ApiError.new(response), error[:message]
        end
      end

  end
end
