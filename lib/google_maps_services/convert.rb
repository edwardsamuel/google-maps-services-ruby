module GoogleMapsServices
  module Convert

    def self.latlng(arg)
      return "%f,%f" % normalize_lat_lng(arg)
    end

    def self.normalize_lat_lng(arg)
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

    def self.join_list(sep, arg)
      return as_list(arg).join(sep)
    end

    def self.as_list(arg)
      if arg.kind_of?(Array)
          return arg
      end
      return [arg]
    end

    def self.time(arg)
      if arg.kind_of?(DateTime)
        arg = arg.to_time
      end
      return arg.to_i.to_s
    end

    def self.components(arg)
      if arg.kind_of?(Hash)
        arg = arg.sort.map { |k, v| "#{k}:#{v}" }
        return arg.join("|")
      end

      raise ArgumentError, "Expected a Hash for components, but got #{arg.class}"
    end

    def self.bounds(arg)
      if arg.kind_of?(Hash)
        if arg.has_key?("southwest") && arg.has_key?("northeast")
          return "#{latlng(arg["southwest"])}|#{latlng(arg["northeast"])}"
        elsif arg.has_key?(:southwest) && arg.has_key?(:northeast)
          return "#{latlng(arg[:southwest])}|#{latlng(arg[:northeast])}"
        end
      end

      raise ArgumentError, "Expected a bounds (southwest/northeast) Hash, but got #{arg.class}"
    end

    def self.decode_polyline(polyline)
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

    def self.encode_polyline(points)
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