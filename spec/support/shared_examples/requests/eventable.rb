shared_examples_for 'a registered event' do |action, error_params, resource, event|

  it 'creates a new event' do
    expect { eval(action) }.to change { Event.last.id }
  end

  describe 'when creates an event' do
    before  { eval(action) }
    subject { Event.last }

    its(:resource) { should == resource }
    its(:event)    { should == event }
  end

  describe 'with not valid params' do
    it 'does not create a new event' do
      params = error_params
      expect { eval(action) }.to_not change { Event.last.id } if error_params
    end
  end
end
