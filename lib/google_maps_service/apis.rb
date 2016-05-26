require_relative './apis/directions'
require_relative './apis/distance_matrix'
require_relative './apis/elevation'
require_relative './apis/geocoding'
require_relative './apis/roads'
require_relative './apis/time_zone'

module GoogleMapsService
  # Collections of Google Maps Web Services
  module Apis
    # See {Directions#directions}.
    #
    # @return [Hash]
    def directions(origin, destination, options = {})
      @directions ||= Directions.new(self)
      @directions.directions(origin, destination, options)
    end

    # See {DistanceMatrix#distance_matrix}
    #
    # @return [Hash]
    def distance_matrix(origins, destinations, options = {})
      @distance_matrix ||= DistanceMatrix.new(self)
      @distance_matrix.distance_matrix(origins, destinations, options)
    end

    # See {Elevation#elevation}
    #
    # @return [Hash]
    def elevation(locations)
      @elevation ||= Elevation.new(self)
      @elevation.elevation(locations)
    end

    # See {Elevation#elevation_along_path}
    #
    # @return [Hash]
    def elevation_along_path(path, samples)
      @elevation ||= Elevation.new(self)
      @elevation.elevation_along_path(path, samples)
    end

    # See {Geocoding#geocode}
    #
    # @return [Hash]
    def geocode(address, options = {})
      @geocoding ||= Geocoding.new(self)
      @geocoding.geocode(address, options)
    end

    # See {Geocoding#reverse_geocode}
    #
    # @return [Hash]
    def reverse_geocode(latlng, options = {})
      @geocoding ||= Geocoding.new(self)
      @geocoding.reverse_geocode(latlng, options)
    end

    # See {Roads#snap_to_roads}
    #
    # @return [Hash]
    def snap_to_roads(path, options = {})
      @roads ||= Roads.new(self)
      @roads.snap_to_roads(path, options)
    end

    # See {Roads#speed_limits}
    #
    # @return [Hash]
    def speed_limits(place_ids)
      @roads ||= Roads.new(self)
      @roads.speed_limits(place_ids)
    end

    # See {Roads#snapped_speed_limits}
    #
    # @return [Hash]
    def snapped_speed_limits(path)
      @roads ||= Roads.new(self)
      @roads.snapped_speed_limits(path)
    end

    # See {TimeZone#timezone}
    #
    # @return [Hash]
    def timezone(location, options = {})
      @time_zone ||= TimeZone.new(self)
      @time_zone.timezone(location, options)
    end
  end
end
