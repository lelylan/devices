shared_examples_for 'a filterable list' do

  let!(:result)      { FactoryGirl.create :device, resource_owner_id: user.id }
  # consumption specific (only used in the consumption test suite)
  let!(:consumption) { FactoryGirl.create :consumption, resource_owner_id: user.id, device: a_uri(result) }
  # consumption specific (only used in the consumption test suite)
  let!(:history)     { FactoryGirl.create :history, resource_owner_id: user.id, device: a_uri(result) }

  before { access_token.device_ids = [result.id]; access_token.save }
  before { page.driver.get(uri) }

  it { page.should have_content result.id.to_s }
end

shared_examples_for 'a filterable resource' do |action|

  let(:result) { FactoryGirl.create :device, resource_owner_id: user.id }
  before       { access_token.device_ids = [result.id]; access_token.save; }

  describe 'when gets the not accessible resource' do
    before    { eval(action) }
    it        { page.status_code.should == 404 }
  end

  # TODO this test is not real for privates, consumptions, properties and function update as it call the device URL
  describe 'when gets the accessible resource' do
    let(:uri) { "/devices/#{result.id}" }
    before    { eval(action) }
    it        { page.should have_content result.id.to_s }
  end
end
