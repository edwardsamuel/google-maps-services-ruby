require 'multi_json'

module GoogleMapsService

  # Performs requests to the Google Maps Roads API."""
  module Roads

    # Base URL of Google Maps Roads API
    ROADS_BASE_URL = "https://roads.googleapis.com"

    # Snaps a path to the most likely roads travelled.
    #
    # Takes up to 100 GPS points collected along a route, and returns a similar
    # set of data with the points snapped to the most likely roads the vehicle
    # was traveling along.
    #
    # @param [] path The path to be snapped. A list of latitude/longitude tuples.
    # :type path: list
    #
    # @param [] interpolate Whether to interpolate a path to include all points
    #         forming the full road-geometry. When true, additional interpolated
    #         points will also be returned, resulting in a path that smoothly
    #         follows the geometry of the road, even around corners and through
    #         tunnels.  Interpolated paths may contain more points than the
    #         original path.
    # :type interpolate: bool
    #
    # :rtype: A list of snapped points.
    def snap_to_roads(path: nil, interpolate: false)
      path = GoogleMapsService::Convert.waypoints(path)

      params = {
        path: path
      }

      params[:interpolate] = "true" if interpolate

      return get("/v1/snapToRoads", params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))[:snappedPoints]
    end

    # Returns the posted speed limit (in km/h) for given road segments.
    #
    # @param [String, Array<String>] place_ids The Place ID of the road segment. Place IDs are returned
    #         by the snap_to_roads function. You can pass up to 100 Place IDs.
    # @return Array of speed limits.
    def speed_limits(place_ids: nil)
      params = GoogleMapsService::Convert.as_list(place_ids).map { |place_id| ["placeId", place_id] }

      return get("/v1/speedLimits", params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))[:speedLimits]
    end


    # Returns the posted speed limit (in km/h) for given road segments.
    #
    # The provided points will first be snapped to the most likely roads the
    # vehicle was traveling along.
    #
    # @param [Hash, Array] path The path of points to be snapped. A list of (or single)
    #         latitude/longitude tuples.
    #
    # @return [Hash] a dict with both a list of speed limits and a list of the snapped
    #         points.
    def snapped_speed_limits(path: nil)
      path = GoogleMapsService::Convert.waypoints(path)

      params = {
        path: path
      }

      return get("/v1/speedLimits", params,
                 base_url: ROADS_BASE_URL,
                 accepts_client_id: false,
                 custom_response_decoder: method(:extract_roads_body))
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
          raise GoogleMapsService::Error::ApiError.new(response), "Received a malformed response."
        end

        if body.has_key?(:error)
          error = body[:error]
          status = error[:status]

          case status
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

        unless response.status_code == 200
          raise GoogleMapsService::Error::ApiError.new(response)
        end

        return body
      end
  end
end
