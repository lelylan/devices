require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { basic_auth(@user) } 
  before { Device.destroy_all }
  let(:resource) { 'devices' }


  describe "pagination" do
    before { 5.times { |n| Factory(:device, name: "Device #{n}") } }

    context "redirect" do
      context "with no params" do
        before { visit 'devices' }
        it { current_url.should match /page=1&per=25/ }
      end

      context "with page parmas" do
        before { visit 'devices?page=2' }
        it { current_url.should match /page=2&per=25/ }
      end

      context "with per params" do
        before { visit 'devices?per=1' }
        it { current_url.should match /page=1&per=1/ }
      end

      context "with per set to 'all'" do
        before { visit 'devices?per=all' }
        it { current_url.should match /page=1&per=5/ }
      end
    end

    context "navigation links" do
      let(:params) { {resource: resource, per: 2} }
      context "when in first page" do
        before { visit resource + '?page=1&per=2' }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('previous', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 2})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "when in page 2" do
        before { visit 'devices?page=2&per=2' }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('previous', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 3})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "when in last page" do
        before { visit 'devices?page=3&per=2' }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('previous', params.merge({page: 2})) }
        it { should_have_pagination_uri('next', params.merge({page: 3})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "with extra params" do
        before { visit 'devices?page=3&per=2&type=instantaneous' }
        before { params.merge!(type: 'instantaneous') }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('previous', params.merge({page: 2})) }
        it { should_have_pagination_uri('next', params.merge({page: 3})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end
    end
  end
end
