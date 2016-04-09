module GoogleMapsService
  # Converts Ruby types to string representations suitable for Maps API server.
  module Convert
    module_function

    # Converts a lat/lon pair to a comma-separated string.
    #
    # @example
    #   >> GoogleMapsService::Convert.latlng(
    #        { lat: -33.8674869, lng: 151.2069902}
    #      )
    #   => "-33.867487,151.206990"
    #
    # @param [Hash, Array] arg The lat/lon hash or array pair.
    #
    # @return [String] Comma-separated lat/lng.
    #
    # @raise [ArgumentError] When argument is not lat/lng hash or array.
    def latlng(arg)
      lat, lng = normalize_latlng(arg)
      format('%.6f,%.6f', lat, lng)
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
      if arg.is_a?(Hash)
        lat = find_by_priority(arg, :lat, :latitude, 'lat', 'latitude')
        lng = find_by_priority(arg, :lng, :longitude, 'lng', 'longitude')
        return [lat, lng]
      elsif arg.is_a?(Array)
        return arg[0..1]
      end

      raise ArgumentError,
            "Expected a lat/lng Hash or Array, but got #{arg.class}"
    end

    # Find non-nil value in a Hash if any from keys those are ordered
    # by priority
    #
    # @param [Array] keys Hash keys order by priority
    #
    # @return [String] Non-nil Hash value if any
    def find_by_priority(hash, *keys)
      hash[keys.detect { |k| hash[k] }]
    end

    # If arg is list-like, then joins it with `|`.
    #
    # @param [Array, String] arg Value to coerce into a list.
    #
    # @return [String]
    def join_list(arg)
      as_list(arg).join('|')
    end

    # Coerces arg into a list. If arg is already list-like, returns arg.
    # Otherwise, returns a one-element list containing arg.
    #
    # @param [Object] arg
    #
    # @return [Array]
    def as_list(arg)
      return arg if arg.is_a?(Array)
      [arg]
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
      arg = arg.to_time if arg.is_a?(DateTime)
      arg.to_i.to_s
    end

    # Converts a dict of components to the format expected by the Google Maps
    # server.
    #
    # @example
    #   >> GoogleMapsService::Convert.components(
    #        { 'country': 'US', 'postal_code': '94043' }
    #      )
    #   => "country:US|postal_code:94043"
    #
    # @param [Hash] arg The component filter.
    #
    # @return [String]
    def components(arg)
      return arg.sort.map { |k, v| "#{k}:#{v}" }.join('|') if arg.is_a?(Hash)
      raise ArgumentError,
            "Expected a Hash for components, but got #{arg.class}"
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
    #   ?>   'northeast': {
    #   ?>     'lat': -33.4245981,
    #   ?>     'lng': 151.3426361
    #   ?>   },
    #   ?>   'southwest': {
    #   ?>     'lat': -34.1692489,
    #   ?>     'lng': 150.502229
    #   ?>   }
    #   ?> }
    #   >> GoogleMapsService::Convert.bounds(sydney_bounds)
    #   => "-34.169249,150.502229|-33.424598,151.342636"
    #
    # @param [Hash] arg The bounds.
    #
    # @return [String]
    def bounds(arg)
      if arg.is_a?(Hash)
        southwest = arg[:southwest] || arg['southwest']
        northeast = arg[:northeast] || arg['northeast']
        return "#{latlng(southwest)}|#{latlng(northeast)}"
      end

      raise ArgumentError,
            "Expected a bounds (southwest/northeast) Hash, but got #{arg.class}"
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
      return waypoint if waypoint.is_a?(String)
      GoogleMapsService::Convert.latlng(waypoint)
    end

    # Converts an array of waypoints (path) to the format expected by
    # Google Maps server.
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
      if waypoints.is_a?(Array) && waypoints.length == 2 &&
         waypoints[0].is_a?(Numeric) && waypoints[1].is_a?(Numeric)
        waypoints = [waypoints]
      end
      join_list(as_list(waypoints).map { |k| waypoint(k) })
    end
  end
end
