module GoogleMaps

  # Converts Ruby types to string representations suitable for Maps API server.
  module Convert
    module_function

    # Converts a lat/lon pair to a comma-separated string.
    #
    # @example
    #   >> GoogleMaps::Convert.latlng({"lat": -33.8674869, "lng": 151.2069902})
    #   => "-33.867487,151.206990"
    #
    # @param [Hash, Array] arg The lat/lon hash or array pair.
    #
    # @return [String] Comma-separated lat/lng.
    #
    # @raise [ArgumentError] When argument is not lat/lng hash or array.
    def latlng(arg)
      return "%f,%f" % normalize_lat_lng(arg)
    end

    # Take the various lat/lng representations and return a tuple.
    #
    # Accepts various representations:
    #
    # 1. Hash with two entries - +lat+ and +lng+
    # 2. Array or list - e.g. +[-33, 151]+
    #
    # @param [Hash, Array] arg The lat/lon hash or array pair.
    #
    # @return [Array] Pair of lat and lng array.
    def normalize_lat_lng(arg)
      if arg.kind_of?(Hash)
          if arg.has_key?(:lat) and arg.has_key?(:lng)
              return arg[:lat], arg[:lng]
          end
          if arg.has_key?(:latitude) and arg.has_key?(:longitude)
              return arg[:latitude], arg[:longitude]
          end
          if arg.has_key?("lat") and arg.has_key?("lng")
              return arg["lat"], arg["lng"]
          end
          if arg.has_key?("latitude") and arg.has_key?("longitude")
              return arg["latitude"], arg["longitude"]
          end
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
    #   >> GoogleMaps::Convert.time(datetime.now())
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
    #   >> GoogleMaps::Convert.components({"country": "US", "postal_code": "94043"})
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
    #   >> GoogleMaps::Convert.bounds(sydney_bounds)
    #   => '-34.169249,150.502229|-33.424598,151.342636'
    #
    # @param [Hash] arg The bounds.
    #
    # @return [String]
    def bounds(arg)
      if arg.kind_of?(Hash)
        if arg.has_key?("southwest") && arg.has_key?("northeast")
          return "#{latlng(arg["southwest"])}|#{latlng(arg["northeast"])}"
        elsif arg.has_key?(:southwest) && arg.has_key?(:northeast)
          return "#{latlng(arg[:southwest])}|#{latlng(arg[:northeast])}"
        end
      end

      raise ArgumentError, "Expected a bounds (southwest/northeast) Hash, but got #{arg.class}"
    end

    # Decodes a Polyline string into a list of lat/lng hash.
    #
    # See the developer docs for a detailed description of this encoding:
    # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    #
    # @param [String] polyline An encoded polyline
    #
    # @return [Array] Array of hash with lat/lng keys
    def decode_polyline(polyline)
      points = []
      index = lat = lng = 0

      while index < polyline.length
        result = 1
        shift = 0
        while true
          b = polyline[index].ord - 63 - 1
          index += 1
          result += b << shift
          shift += 5
          break if b < 0x1f
        end
        lat += (result & 1) != 0 ? (~result >> 1) : (result >> 1)

        result = 1
        shift = 0
        while true
          b = polyline[index].ord - 63 - 1
          index += 1
          result += b << shift
          shift += 5
          break if b < 0x1f
        end
        lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)

        points << {"lat" => lat * 1e-5, "lng" => lng * 1e-5}
      end

      points
    end

    # Encodes a list of points into a polyline string.
    #
    # See the developer docs for a detailed description of this encoding:
    # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    #
    # @param [Array<Hash>, Array<Array>] points A list of lat/lng pairs.
    #
    # @return [String]
    def encode_polyline(points)
      last_lat = last_lng = 0
      result = ""

      points.each do |point|
        ll = normalize_lat_lng(point)
        lat = (ll[0] * 1e5).round.to_i
        lng = (ll[1] * 1e5).round.to_i
        d_lat = lat - last_lat
        d_lng = lng - last_lng

        [d_lat, d_lng].each do |v|
          v = (v < 0) ? ~(v << 1) : (v << 1)
          while v >= 0x20
            result += ((0x20 | (v & 0x1f)) + 63).chr
            v >>= 5
          end
          result += (v + 63).chr
        end

        last_lat = lat
        last_lng = lng
      end

      result
    end

  end
end