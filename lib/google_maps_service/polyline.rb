require 'google_maps_service/convert'

module GoogleMapsService

  # Encoder/decoder for [Google Encoded Polyline](https://developers.google.com/maps/documentation/utilities/polylinealgorithm).
  module Polyline
    module_function

    # Decodes a Polyline string into a list of lat/lng hash.
    #
    # See the developer docs for a detailed description of this encoding:
    # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    #
    # @example
    #   encoded_path = '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
    #   path = GoogleMapsService::Polyline.decode(encoded_path)
    #   #=> [{:lat=>38.5, :lng=>-120.2}, {:lat=>40.7, :lng=>-120.95}, {:lat=>43.252, :lng=>-126.45300000000002}]
    #
    # @param [String] polyline An encoded polyline
    #
    # @return [Array] Array of hash with lat/lng keys
    def decode(polyline)
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

        points << {lat: lat * 1e-5, lng: lng * 1e-5}
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
    def encode(points)
      last_lat = last_lng = 0
      result = ""

      points.each do |point|
        ll = GoogleMapsService::Convert.normalize_latlng(point)
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