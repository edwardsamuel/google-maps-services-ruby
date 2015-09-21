module GoogleMapsService

  # Converts Ruby types to string representations suitable for Maps API server.
  module Convert
    module_function

    # Converts a lat/lon pair to a comma-separated string.
    #
    # @example
    #   >> GoogleMapsService::Convert.latlng({"lat": -33.8674869, "lng": 151.2069902})
    #   => "-33.867487,151.206990"
    #
    # @param [Hash, Array] arg The lat/lon hash or array pair.
    #
    # @return [String] Comma-separated lat/lng.
    #
    # @raise [ArgumentError] When argument is not lat/lng hash or array.
    def latlng(arg)
      return "%f,%f" % normalize_latlng(arg)
    end

    # Take the various lat/lng representations and return a tuple.
    #
    # Accepts various representations:
    #
    # 1. Hash with two entries - `lat` and `lng`
    # 2. Array or list - e.g. `[-33, 151]`
    #
    # @param [Hash, Array] arg The lat/lon hash or array pair.
    #
    # @return [Array] Pair of lat and lng array.
    def normalize_latlng(arg)
      if arg.kind_of?(Hash)
        lat = arg[:lat] || arg[:latitude] || arg["lat"] || arg["latitude"]
        lng = arg[:lng] || arg[:longitude] || arg["lng"] || arg["longitude"]
        return lat, lng
      elsif arg.kind_of?(Array)
        return arg[0], arg[1]
      end

      raise ArgumentError, "Expected a lat/lng Hash or Array, but got #{arg.class}"
    end

    # If arg is list-like, then joins it with sep.
    #
    # @param [String] sep Separator string.
    # @param [Array, String] arg Value to coerce into a list.
    #
    # @return [String]
    def join_list(sep, arg)
      return as_list(arg).join(sep)
    end

    # Coerces arg into a list. If arg is already list-like, returns arg.
    # Otherwise, returns a one-element list containing arg.
    #
    # @param [Object] arg
    #
    # @return [Array]
    def as_list(arg)
      if arg.kind_of?(Array)
          return arg
      end
      return [arg]
    end


    # Converts the value into a unix time (seconds since unix epoch).
    #
    # @example
    #   >> GoogleMapsService::Convert.time(datetime.now())
    #   => "1409810596"
    #
    # @param [Time, Date, DateTime, Integer] arg The time.
    #
    # @return [String] String representation of epoch time
    def time(arg)
      if arg.kind_of?(DateTime)
        arg = arg.to_time
      end
      return arg.to_i.to_s
    end

    # Converts a dict of components to the format expected by the Google Maps
    # server.
    #
    # @example
    #   >> GoogleMapsService::Convert.components({"country": "US", "postal_code": "94043"})
    #   => "country:US|postal_code:94043"
    #
    # @param [Hash] arg The component filter.
    #
    # @return [String]
    def components(arg)
      if arg.kind_of?(Hash)
        arg = arg.sort.map { |k, v| "#{k}:#{v}" }
        return arg.join("|")
      end

      raise ArgumentError, "Expected a Hash for components, but got #{arg.class}"
    end

    # Converts a lat/lon bounds to a comma- and pipe-separated string.
    #
    # Accepts two representations:
    #
    # 1. String: pipe-separated pair of comma-separated lat/lon pairs.
    # 2. Hash with two entries - "southwest" and "northeast". See {.latlng}
    # for information on how these can be represented.
    #
    # For example:
    #
    #   >> sydney_bounds = {
    #   ?>   "northeast": {
    #   ?>     "lat": -33.4245981,
    #   ?>     "lng": 151.3426361
    #   ?>   },
    #   ?>   "southwest": {
    #   ?>     "lat": -34.1692489,
    #   ?>     "lng": 150.502229
    #   ?>   }
    #   ?> }
    #   >> GoogleMapsService::Convert.bounds(sydney_bounds)
    #   => '-34.169249,150.502229|-33.424598,151.342636'
    #
    # @param [Hash] arg The bounds.
    #
    # @return [String]
    def bounds(arg)
      if arg.kind_of?(Hash)
        southwest = arg[:southwest] || arg["southwest"]
        northeast = arg[:northeast] || arg["northeast"]
        return "#{latlng(southwest)}|#{latlng(northeast)}"
      end

      raise ArgumentError, "Expected a bounds (southwest/northeast) Hash, but got #{arg.class}"
    end

    # Converts a waypoints to the format expected by the Google Maps server.
    #
    # Accept two representation of waypoint:
    #
    # 1. String: Name of place or comma-separated lat/lon pair.
    # 2. Hash/Array: Lat/lon pair.
    #
    # @param [Array, String, Hash] waypoint Path.
    #
    # @return [String]
    def waypoint(waypoint)
      if waypoint.kind_of?(String)
        return waypoint
      end
      return GoogleMapsService::Convert.latlng(waypoint)
    end

    # Converts an array of waypoints (path) to the format expected by the Google Maps
    # server.
    #
    # Accept two representation of waypoint:
    #
    # 1. String: Name of place or comma-separated lat/lon pair.
    # 2. Hash/Array: Lat/lon pair.
    #
    # @param [Array, String, Hash] waypoints Path.
    #
    # @return [String]
    def waypoints(waypoints)
      if waypoints.kind_of?(Array) and waypoints.length == 2 and waypoints[0].kind_of?(Numeric) and waypoints[1].kind_of?(Numeric)
        waypoints = [waypoints]
      end

      waypoints = as_list(waypoints)
      return join_list('|', waypoints.map { |k| waypoint(k) })
    end
  end
end