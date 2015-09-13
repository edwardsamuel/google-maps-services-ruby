require 'spec_helper'

describe GoogleMaps::Geocoding do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/geocode\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  context 'simple geocode' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'Sydney')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=Sydney' % api_key)).to have_been_made
    end
  end

  context 'reverse geocode' do
    it 'should call Google Maps Web Service' do
      results = client.reverse_geocode(latlng: [-33.8674869, 151.2069902])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?latlng=-33.867487%%2C151.206990&key=%s' % api_key)).to have_been_made
    end
  end

  context 'geocoding the googleplex' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: '1600 Amphitheatre Parkway, Mountain View, CA')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=1600+Amphitheatre+Parkway%%2C+Mountain+View%%2C+CA' % api_key)).to have_been_made
    end
  end

  context 'geocode with bounds' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'Winnetka', bounds: {southwest: [34.172684, -118.604794], northeast: [34.236144, -118.500938]})
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?bounds=34.172684%%2C-118.604794%%7C34.236144%%2C-118.500938&key=%s&address=Winnetka' % api_key)).to have_been_made
    end
  end

  context 'geocode with region biasing' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'Toledo', region: 'es')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?region=es&key=%s&address=Toledo' % api_key)).to have_been_made
    end
  end

  context 'geocode with component filter' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'santa cruz', components: {country: 'ES'})
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&components=country%%3AES&address=santa+cruz' % api_key)).to have_been_made
    end
  end

  context 'geocode with multiple component filters' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'Torun', components: {administrative_area: 'TX', country: 'US'})
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&components=administrative_area%%3ATX%%7Ccountry%%3AUS&address=Torun' % api_key)).to have_been_made
    end
  end

  context 'geocode with just components' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(components: {route: 'Annegatan', administrative_area: 'Helsinki', country: 'Finland'})
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&components=administrative_area%%3AHelsinki%%7Ccountry%%3AFinland%%7Croute%%3AAnnegatan' % api_key)).to have_been_made
    end
  end

  context 'simple reverse geocode' do
    it 'should call Google Maps Web Service' do
      results = client.reverse_geocode(latlng: [40.714224, -73.961452])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224%%2C-73.961452&key=%s' % api_key)).to have_been_made
    end
  end

  context 'reverse geocode restricted by type' do
    it 'should call Google Maps Web Service' do
      results = client.reverse_geocode(latlng: [40.714224, -73.961452], location_type: 'ROOFTOP', result_type: 'street_address')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224%%2C-73.961452&result_type=street_address&key=%s&location_type=ROOFTOP' % api_key)).to have_been_made
    end
  end

  context 'reverse geocode multiple location types' do
    it 'should call Google Maps Web Service' do
      results = client.reverse_geocode(latlng: [40.714224, -73.961452], location_type: ['ROOFTOP', 'RANGE_INTERPOLATED'], result_type: 'street_address')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224%%2C-73.961452&result_type=street_address&key=%s&location_type=ROOFTOP%%7CRANGE_INTERPOLATED' % api_key)).to have_been_made
    end
  end

  context 'reverse geocode multiple result types' do
    it 'should call Google Maps Web Service' do
      results = client.reverse_geocode(latlng: [40.714224, -73.961452], location_type: 'ROOFTOP', result_type: ['street_address', 'route'])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224%%2C-73.961452&result_type=street_address%%7Croute&key=%s&location_type=ROOFTOP' % api_key)).to have_been_made
    end
  end

  context 'partial match' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(address: 'Pirrama Pyrmont')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=Pirrama+Pyrmont' % api_key)).to have_been_made
    end
  end

  context 'utf results' do
    it 'should call Google Maps Web Service' do
      results = client.geocode(components: {postal_code: '96766'})
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&components=postal_code%%3A96766' % api_key)).to have_been_made
    end
  end

  context 'utf8 request' do
    it 'should call Google Maps Web Service' do
      client.geocode(address: "\u4e2d\u56fd".encode('utf-8')) # China
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/geocode/json?key=%s&address=%s' % [api_key, '%E4%B8%AD%E5%9B%BD'])).to have_been_made
    end
  end
end