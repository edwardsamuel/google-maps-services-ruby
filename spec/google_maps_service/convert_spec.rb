require 'spec_helper'
require 'date'

describe GoogleMapsService::Convert do
  describe '.latlng' do
    context 'with a lat/lng pair' do
      it 'should return comma-separated string' do
        expect(GoogleMapsService::Convert.latlng({lat: 1, lng: 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({latitude: 1, longitude: 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({"lat" => 1, "lng" => 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng({"latitude" => 1, "longitude" => 2})).to eq("1.000000,2.000000")
        expect(GoogleMapsService::Convert.latlng([1, 2])).to eq("1.000000,2.000000")
      end
    end

    context 'without a lat/lng pair' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.latlng(1) }.to raise_error ArgumentError
        expect { GoogleMapsService::Convert.latlng("test") }.to raise_error ArgumentError
      end
    end
  end

  context '.join_list' do
    context 'with a single value array' do
      it 'should return its value' do
        expect(GoogleMapsService::Convert.join_list("|", "asdf")).to eq("asdf")
      end
    end

    context 'with a multiple values array' do
      it 'should return separated value string' do
        expect(GoogleMapsService::Convert.join_list(",", ["1", "2", "A"])).to eq("1,2,A")
      end
    end

    context 'with an empty array' do
      it 'should return empty string' do
        expect(GoogleMapsService::Convert.join_list(",", [])).to eq("")
      end
    end
  end

  context '.as_list' do
    context 'with a single value' do
      it 'should return an array contains the value' do
        expect(GoogleMapsService::Convert.as_list(1)).to eq([1])
        expect(GoogleMapsService::Convert.as_list("string")).to eq(["string"])

        a_hash = {a: 1}
        expect(GoogleMapsService::Convert.as_list(a_hash)).to eq([a_hash])
      end
    end

    context 'with an array' do
      it 'should return the same array' do
        expect(GoogleMapsService::Convert.as_list([1, 2, 3])).to eq([1, 2, 3])
      end
    end
  end


  context '.time' do
    context 'with an integer' do
      it 'should return the integer as string' do
        expect(GoogleMapsService::Convert.time(1409810596)).to eq("1409810596")
      end
    end

    context 'with a Time' do
      it 'should return the epoch time as string' do
        t = Time.at(1409810596)
        expect(GoogleMapsService::Convert.time(t)).to eq("1409810596")
      end
    end

    context 'with a DateTime' do
      it 'should return the epoch time as string' do
        dt = Time.at(1409810596).to_datetime
        expect(GoogleMapsService::Convert.time(dt)).to eq("1409810596")
      end
    end
  end


  context '.components' do
    context 'with single hash entry' do
      it 'should return key:value pair string' do
        c = {country: "US"}
        expect(GoogleMapsService::Convert.components(c)).to eq("country:US")
      end
    end

    context 'with multiple hash entries' do
      it 'should return key:value pairs separated by "|"' do
        c = {country: "US", foo: 1}
        expect(GoogleMapsService::Convert.components(c)).to eq("country:US|foo:1")
      end
    end

    context 'with non-hash' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.components("test") }.to raise_error ArgumentError
        expect { GoogleMapsService::Convert.components(1) }.to raise_error ArgumentError
      end
    end
  end

  context '.bounds' do
    context 'with northeast and southwest hash' do
      it 'should return string representation of bounds' do
        ne = {lat: 1, lng: 2}
        sw = [3, 4]
        b = {northeast: ne, southwest: sw}
        expect(GoogleMapsService::Convert.bounds(b)).to eq("3.000000,4.000000|1.000000,2.000000")
        b = {"northeast" => ne, "southwest" => sw}
        expect(GoogleMapsService::Convert.bounds(b)).to eq("3.000000,4.000000|1.000000,2.000000")
      end
    end

    context 'with string' do
      it 'should raise ArgumentError' do
        expect { GoogleMapsService::Convert.bounds("test") }.to raise_error ArgumentError
      end
    end
  end

  context '.waypoint' do
    context 'with string' do
      it 'should return string representation of waypoint' do
        places = 'ABC'
        expect(GoogleMapsService::Convert.waypoint(places)).to eq('ABC')
      end
    end

    context 'with lat/lon pairs' do
      it 'should return string representation of waypoints' do
        path = {"latitude" => 1, "longitude" => 2}
        expect(GoogleMapsService::Convert.waypoint(path)).to eq('1.000000,2.000000')
      end
    end
  end

  context '.waypoints' do
    context 'with string' do
      it 'should return string representation of waypoints' do
        places = 'ABC'
        expect(GoogleMapsService::Convert.waypoints(places)).to eq('ABC')
      end
    end

    context 'with lat/lon pairs' do
      it 'should return string representation of waypoints' do
        path = {"latitude" => 1, "longitude" => 2}
        expect(GoogleMapsService::Convert.waypoints(path)).to eq('1.000000,2.000000')
      end
    end

    context 'with array of string' do
      it 'should return string representation of waypoints' do
        places = ['ABC', 'def']
        expect(GoogleMapsService::Convert.waypoints(places)).to eq('ABC|def')
      end
    end

    context 'with array of lat/lon pairs' do
      it 'should return string representation of waypoints' do
        path = [[1, 2], {lat: 3, lng: 4}]
        expect(GoogleMapsService::Convert.waypoints(path)).to eq('1.000000,2.000000|3.000000,4.000000')
      end
    end

    context 'with mixed array' do
      it 'should return string representation of waypoints' do
        path = [[1, 2], 'ABC', {lat: 3, lng: 4}, 'def']
        expect(GoogleMapsService::Convert.waypoints(path)).to eq('1.000000,2.000000|ABC|3.000000,4.000000|def')
      end
    end
  end
end