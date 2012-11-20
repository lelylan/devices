shared_examples_for 'a physical event' do |service|

  describe 'when source param is set to physical' do

    let(:uri)   { "/devices/#{resource.id}/#{service}?source=physical" }
    before      { update }
    let(:event) { Event.last }

    it 'sets the event source field to physical' do
      event.source.should == 'physical'
    end
  end

  describe 'when X-Request-Source header is set to physical' do

    before      { page.driver.header 'X-Request-Source', 'physical' }
    before      { update }
    let(:event) { Event.last }

    it 'sets the event source field to physical' do
      event.source.should == 'physical'
    end
  end

  describe 'when the request has a physical access token' do

    before          { access_token.application_id = Defaults.phisical_application_id; access_token.save }
    let(:signature) { Signature.sign(params, resource.secret) }
    before          { update }
    let(:event)     { Event.last }

    it 'sets the event source field to physical' do
      event.source.should == 'physical'
    end
  end

  describe 'when the physical source is not set' do

    before          { update }
    let(:event)     { Event.last }

    it 'sets the event source field to lelylan' do
      event.source.should == 'lelylan'
    end
  end
end
