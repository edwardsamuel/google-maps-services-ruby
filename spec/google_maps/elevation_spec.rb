require 'spec_helper'

describe GoogleMapsService::Elevation do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/elevation\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  context 'elevation single' do
    it 'should call Google Maps Web Service' do
      results = client.elevation(locations: [40.714728, -73.998672])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/elevation/json?locations=40.714728%%2C-73.998672&key=%s' % api_key)).to have_been_made
    end
  end

  context 'elevation single list' do
    it 'should call Google Maps Web Service' do
      results = client.elevation(locations: [[40.714728, -73.998672]])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/elevation/json?locations=40.714728%%2C-73.998672&key=%s' % api_key)).to have_been_made
    end
  end

  context 'elevation multiple' do
    it 'should call Google Maps Web Service' do
      locations = [[40.714728, -73.998672], [-34.397, 150.644]]
      results = client.elevation(locations: locations)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/elevation/json?locations=40.714728%%2C-73.998672%%7C-34.397000%%2C150.644000&key=%s' % api_key)).to have_been_made
    end
  end

  context 'elevation along path single' do
    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/elevation\/.*/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"results": [], "status": "INVALID_REQUEST"}')
    end

    it 'should raise InvalidRequestError' do
      expect { client.elevation_along_path(path: [[40.714728, -73.998672]], samples: 5) }.to raise_error GoogleMapsService::Error::InvalidRequestError
    end
  end

  context 'elevation along path' do
    it 'should call Google Maps Web Service' do
      path = [[40.714728, -73.998672], [-34.397, 150.644]]

      results = client.elevation_along_path(path: path, samples: 5)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/elevation/json?path=40.714728%%2C-73.998672%%7C-34.397000%%2C150.644000&key=%s&samples=5' % api_key)).to have_been_made
    end
  end
end