module GoogleMaps

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
    def snap_to_roads(path, interpolate=false)

      if locations.kind_of?(Array) and locations.length == 2 and not locations[0].kind_of?(Array)
        locations = [locations]
      end

      path = _convert_path(path)

      params = {
        "path": path
      }

      params["interpolate"] = "true" if interpolate

      return get("/v1/snapToRoads", params,
                 base_url=ROADS_BASE_URL,
                 accepts_clientid=false,
                 extract_body=_roads_extract)["snappedPoints"]
    end

    # Returns the posted speed limit (in km/h) for given road segments.
    #
    # @param [String, Array<String>] place_ids The Place ID of the road segment. Place IDs are returned
    #         by the snap_to_roads function. You can pass up to 100 Place IDs.
    # @return Array of speed limits.
    def speed_limits(place_ids)
      params = GoogleMaps::Convert.as_list(place_ids).map { |place_id| ["placeId", place_id] }

      return get("/v1/speedLimits", params,
                 base_url=ROADS_BASE_URL,
                 accepts_clientid=false,
                 extract_body=_roads_extract)["speedLimits"]
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
    def snapped_speed_limits(path)

      if locations.kind_of?(Array) and locations.length == 2 and not locations[0].kind_of?(Array)
        locations = [locations]
      end

      path = _convert_path(path)

      params = {
        "path": path
      }

      return get("/v1/speedLimits", params,
                 base_url=ROADS_BASE_URL,
                 accepts_clientid=false,
                 extract_body=_roads_extract)
    end

    private
      def _convert_path(paths)
        paths = GoogleMaps::Convert.as_list(paths)
        return GoogleMaps::Convert.join_list("|", paths.map { |k| k.kind_of?(String) ? k : GoogleMaps::Convert.latlng(k) })
      end

      # Extracts a result from a Roads API HTTP response.
      def _roads_extract(resp)
        begin
          j = resp.json()
        ensure
          unless resp.status_code == 200
            raise googlemaps.exceptions.HTTPError(resp.status_code)
          end
          raise googlemaps.exceptions.ApiError("UNKNOWN_ERROR", "Received a malformed response.")
        end

        if j.has_key?("error")
          error = j["error"]
          status = error["status"]

          if status == "RESOURCE_EXHAUSTED"
            raise googlemaps.exceptions._RetriableRequest()
          end

          if error.has_key?("message")
            raise googlemaps.exceptions.ApiError(status, error["message"])
          else
            raise googlemaps.exceptions.ApiError(status)
          end
        end

        unless resp.status_code == 200:
          raise googlemaps.exceptions.HTTPError(resp.status_code)
        end

        return j
      end
  end
end
