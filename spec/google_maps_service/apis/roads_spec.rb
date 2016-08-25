require 'spec_helper'

describe GoogleMapsService::Apis::Roads do
  include_context 'HTTP client'

  context '#snap_to_roads' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/snapToRoads/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"snappedPoints":["foo"]}')
    end

    context 'snap' do
      it 'should call Google Maps Web Service' do
        results = client.snap_to_roads([40.714728, -73.998672])
        expect(a_request(:get, 'https://roads.googleapis.com/v1/snapToRoads?path=40.714728%%2C-73.998672&key=%s' % api_key)).to have_been_made
      end
    end
  end

  context '#nearest_roads' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/nearestRoads/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"snappedPoints":["foo"]}')
    end

    context 'single point' do
      it 'should call Google Maps Web Service with single point' do
        results = client.nearest_roads([40.714728, -73.998672])
        expect(a_request(:get, 'https://roads.googleapis.com/v1/nearestRoads?points=40.714728%%2C-73.998672&key=%s' % api_key)).to have_been_made
      end
    end
  end

  context '#snapped_speed_limits' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":["foo"]}')
    end

    context 'path' do
      it 'should call Google Maps Web Service' do
        results = client.snapped_speed_limits([[1, 2],[3, 4]])
        expect(a_request(:get, "https://roads.googleapis.com/v1/speedLimits?path=1.000000%%2C2.000000|3.000000%%2C4.000000&key=%s" % api_key)).to have_been_made
      end
    end
  end

  context '#speed_limits' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":["foo"]}')
    end

    context 'speedlimits' do
      it 'should call Google Maps Web Service' do
        results = client.speed_limits("id1")
        expect(a_request(:get, "https://roads.googleapis.com/v1/speedLimits?placeId=id1&key=%s" % api_key)).to have_been_made
      end
    end

    context 'speedlimits multiple' do
      it 'should call Google Maps Web Service' do
        results = client.speed_limits(["id1", "id2", "id3"])
        expect(a_request(:get, 'https://roads.googleapis.com/v1/speedLimits?placeId=id1&placeId=id2&placeId=id3&key=%s' % api_key)).to have_been_made
      end
    end
  end

  # context 'with over query limit' do
  #   before(:example) do
  #     stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits\//)
  #       .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OVER_QUERY_LIMIT"}').then
  #       .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  #   end

  #   it 'should make request twice' do
  #     results = client.geocode(address: 'Sydney')
  #     expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=Sydney' % api_key)).to have_been_made.times(2)
  #   end
  # end

  context 'retriable with server error' do
    before(:example) do
      stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
        .to_return(:status => 500, body: 'Internal server error.').then
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":[]}')
    end

    it 'should make request twice' do
      results = client.speed_limits([])
      expect(a_request(:get, 'https://roads.googleapis.com/v1/speedLimits?key=%s' % api_key)).to have_been_made.times(2)
    end
  end

  context 'error handling' do
    context 'with client_id and client_secret' do
      let(:client) do
        GoogleMapsService::Client.new(client_id: 'asdf', client_secret: 'asdf')
      end

      it 'should raise ArgumentError' do
        expect { client.speed_limits("foo") }.to raise_error ArgumentError
      end
    end

    context 'with invalid format' do
      before(:example) do
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 200, body: 'Unknown format.')
      end

      it 'should raise GoogleMapsService::Error::ApiError' do
        expect { client.speed_limits([]) }.to raise_error GoogleMapsService::Error::ApiError
      end
    end

    context 'with invalid status code' do
      before(:example) do
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 400, headers: { 'Content-Type' => 'application/json' }, body: '{"speedLimits":[]}')
      end

      it 'should raise GoogleMapsService::Error::ApiError' do
        expect { client.speed_limits([]) }.to raise_error GoogleMapsService::Error::ApiError
      end
    end

    context 'with invalid argument' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 400,
    "message": "placeId value is malformed: aChIJqaknMTeuEmsRUYCD5Wd9ARM",
    "status": "INVALID_ARGUMENT"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 400, body: json)
      end

      it 'should raise GoogleMapsService::Error::InvalidRequestError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::InvalidRequestError
      end
    end

    context 'with invalid api key' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 400,
    "message": "The provided API key is invalid.",
    "status": "INVALID_ARGUMENT"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 400, body: json)
      end

      it 'should raise GoogleMapsService::Error::RequestDeniedError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::RequestDeniedError
      end
    end

    context 'with insufficient credential' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 403,
    "message": "The provided API key is invalid.",
    "status": "PERMISSION_DENIED"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 403, body: json)
      end

      it 'should raise GoogleMapsService::Error::RequestDeniedError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::RequestDeniedError
      end
    end

    context 'with over query limit' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 429,
    "message": "The request was throttled due to project QPS limit being reached.",
    "status": "RESOURCE_EXHAUSTED"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 429, body: json)
      end

      it 'should raise GoogleMapsService::Error::RateLimitError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::RateLimitError
      end
    end

    context 'with unhandled error with message' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 400,
    "message": "Unhandled general error.",
    "status": "BAD_REQUEST"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 400, body: json)
      end

      it 'should raise GoogleMapsService::Error::ApiError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::ApiError
      end
    end

    context 'with unhandled error with message' do
      before(:example) do
        json = <<EOF
{
  "error": {
    "code": 400,
    "status": "BAD_REQUEST"
  }
}
EOF
        stub_request(:get, /https:\/\/roads.googleapis.com\/v1\/speedLimits.*/)
          .to_return(:status => 400, body: json)
      end

      it 'should raise GoogleMapsService::Error::ApiError' do
        expect { client.speed_limits('aChIJqaknMTeuEmsRUYCD5Wd9ARM') }.to raise_error GoogleMapsService::Error::ApiError
      end
    end
  end
end