shared_examples_for 'a registered event' do |action, error_params|

  it 'creates a new event' do
    expect { eval(action) }.to change { Event.last.id }
  end

  describe 'with not valid params' do
    it 'does not create a new event' do
      params = error_params
      expect { eval(action) }.to_not change { Event.last.id } if error_params
    end
  end
end
