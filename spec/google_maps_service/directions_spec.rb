require 'spec_helper'

describe GoogleMapsService::Directions do
  include_context 'HTTP client'

  before(:example) do
    stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/directions\/.*/)
      .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"OK","results":[]}')
  end

  context 'simple directions' do
    it 'should call Google Maps Web Service' do
      # Simplest directions request. Driving directions by default.
      routes = client.directions('Sydney', 'Melbourne')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Sydney&destination=Melbourne&key=%s' %
                          api_key)).to have_been_made
    end
  end

  context 'complex request' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Sydney', 'Melbourne',
                                     mode: 'bicycling',
                                     avoid: ['highways', 'tolls', 'ferries'],
                                     units: 'metric',
                                     region: 'au')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Sydney&avoid=highways%%7Ctolls%%7Cferries&destination=Melbourne&mode=bicycling&key=%s&units=metric&region=au' %
                          api_key)).to have_been_made
    end
  end

  context 'transit with departure time' do
    it 'should call Google Maps Web Service' do
      now = Time.now
      routes = client.directions('Sydney Town Hall', 'Parramatta, NSW',
                                     mode: 'transit',
                                     departure_time: now)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Sydney+Town+Hall&key=%s&destination=Parramatta%%2C+NSW&mode=transit&departure_time=%d' %
                          [api_key, now.to_i])).to have_been_made
    end
  end

  context 'transit with arrival time' do
    it 'should call Google Maps Web Service' do
      an_hour_before_now = Time.now - (1.0/24)
      routes = client.directions('Sydney Town Hall', 'Parramatta, NSW',
                                     mode: 'transit',
                                     arrival_time: an_hour_before_now)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Sydney+Town+Hall&arrival_time=%d&destination=Parramatta%%2C+NSW&mode=transit&key=%s' %
                          [an_hour_before_now.to_i, api_key])).to have_been_made
    end
  end

  context 'transit with departure and arrival time' do
    it 'should raise ArgumentError' do
      expect {
        now = Time.now
        an_hour_from_now = Time.now + (1.0/24)
        routes = client.directions('Sydney Town Hall', 'Parramatta, NSW',
                                       mode: 'transit',
                                       departure_time: now,
                                       arrival_time: an_hour_from_now)
      }.to raise_error ArgumentError
    end
  end

  context 'crazy travel mode' do
    it 'should throw ArgumentError' do
      expect { client.directions('48 Pirrama Road, Pyrmont, NSW', 'Sydney Town Hall',
                                mode: 'crawling') }.to raise_error ArgumentError
    end
  end

  context 'travel mode round trip' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Town Hall, Sydney', 'Parramatta, NSW',
                                     mode: 'bicycling')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Town+Hall%%2C+Sydney&destination=Parramatta%%2C+NSW&mode=bicycling&key=%s' % api_key)).to have_been_made
    end
  end

  context 'brooklyn to queens by transit' do
    it 'should call Google Maps Web Service' do
      now = Time.now
      routes = client.directions('Brooklyn', 'Queens',
                                     mode: 'transit',
                                     departure_time: now)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Brooklyn&key=%s&destination=Queens&mode=transit&departure_time=%d' % [api_key, now.to_i])).to have_been_made
    end
  end

  context 'boston to concord via charlestown and lexington' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Boston, MA', 'Concord, MA',
                                     waypoints: ['Charlestown, MA', 'Lexington, MA'])
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Boston%%2C+MA&destination=Concord%%2C+MA&waypoints=Charlestown%%2C+MA%%7CLexington%%2C+MA&key=%s' % api_key)).to have_been_made
    end
  end

  context 'adelaide wine tour' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Adelaide, SA', 'Adelaide, SA',
                                     waypoints: ['Barossa Valley, SA',
                                                'Clare, SA',
                                                'Connawarra, SA',
                                                'McLaren Vale, SA'],
                                     optimize_waypoints: true)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Adelaide%%2C+SA&destination=Adelaide%%2C+SA&waypoints=optimize%%3Atrue%%7CBarossa+Valley%%2C+SA%%7CClare%%2C+SA%%7CConnawarra%%2C+SA%%7CMcLaren+Vale%%2C+SA&key=%s' % api_key)).to have_been_made
    end
  end

  context 'toledo to madrid in spain' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Toledo', 'Madrid',
                                     region: 'es')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Toledo&region=es&destination=Madrid&key=%s' %
                          api_key)).to have_been_made
    end
  end

  context 'zero results returns response' do
    before(:example) do
      stub_request(:get, /https:\/\/maps.googleapis.com\/maps\/api\/directions\/.*/)
        .to_return(:status => 200, headers: { 'Content-Type' => 'application/json' }, body: '{"status":"ZERO_RESULTS","routes":[]}')
    end

    it 'should call Google Maps Web Service' do
      routes = client.directions('Toledo', 'Madrid')
      expect(routes.length).to eq(0)
    end
  end

  context 'language parameter' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Toledo', 'Madrid',
                                     region: 'es',
                                     language: 'es')
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Toledo&region=es&destination=Madrid&key=%s&language=es' % api_key)).to have_been_made
    end
  end

  context 'alternatives' do
    it 'should call Google Maps Web Service' do
      routes = client.directions('Sydney Town Hall', 'Parramatta Town Hall',
                                     alternatives: true)
      expect(a_request(:get, 'https://maps.googleapis.com/maps/api/directions/json?origin=Sydney+Town+Hall&destination=Parramatta+Town+Hall&alternatives=true&key=%s' % api_key)).to have_been_made
    end
  end
end