require_relative './apis/directions'
require_relative './apis/distance_matrix'
require_relative './apis/elevation'
require_relative './apis/geocoding'
require_relative './apis/roads'
require_relative './apis/time_zone'

module GoogleMapsService
  # Collections of Google Maps Web Services
  module Apis
    def directions(origin, destination, options = {})
      @directions ||= Directions.new(self)
      @directions.directions(origin, destination, options)
    end

    def distance_matrix(origins, destinations, options = {})
      @distance_matrix ||= DistanceMatrix.new(self)
      @distance_matrix.distance_matrix(origins, destinations, options)
    end

    def elevation(locations)
      @elevation ||= Elevation.new(self)
      @elevation.elevation(locations)
    end

    def elevation_along_path(path, samples)
      @elevation ||= Elevation.new(self)
      @elevation.elevation_along_path(path, samples)
    end

    def geocode(address, options = {})
      @geocoding ||= Geocoding.new(self)
      @geocoding.geocode(address, options)
    end

    def reverse_geocode(latlng, options = {})
      @geocoding ||= Geocoding.new(self)
      @geocoding.reverse_geocode(latlng, options)
    end

    def snap_to_roads(path, options = {})
      @roads ||= Roads.new(self)
      @roads.snap_to_roads(path, options)
    end

    def speed_limits(place_ids)
      @roads ||= Roads.new(self)
      @roads.speed_limits(place_ids)
    end

    def snapped_speed_limits(path)
      @roads ||= Roads.new(self)
      @roads.snapped_speed_limits(path)
    end

    def timezone(location, options = {})
      @time_zone ||= TimeZone.new(self)
      @time_zone.timezone(location, options)
    end
  end
end
