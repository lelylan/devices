require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "DevicesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { basic_auth(@user) } 

  before { Device.destroy_all }
  before { History.destroy_all }
  before { 5.times { |n| Factory(:device, name: "Resource #{n}") } }
  let(:path) { '/devices' }
  let(:connection) { 'histories' }
  let(:resource) { Device.last }


  describe "pagination" do

    describe "redirection" do
      context "with no params" do
        before { visit path }
        it { current_url.should match /page=1&per=25/ }
      end

      context "with page parmas" do
        before { visit "#{path}?page=2" }
        it { current_url.should match /page=2&per=25/ }
      end

      context "with per params" do
        before { visit "#{path}?per=1" }
        it { current_url.should match /page=1&per=1/ }
      end

      context "with per set to 'all'" do
        before { visit "#{path}?per=all" }
        it { current_url.should match /page=1&per=5/ }
      end
    end

    context "navigation links" do
      let(:params) { {path: path, page: 1, per: 2} }
      context "when in first page" do
        before { visit "#{path}?page=1&per=2" }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 2})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "when in page 2" do
        before { visit "#{path}?page=2&per=2" }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 3})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "when in last page" do
        before { visit "#{path}?page=3&per=2" }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('prev', params.merge({page: 2})) }
        it { should_have_pagination_uri('next', params.merge({page: 3})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "with extra params" do
        before { params.merge!(type: 'instantaneous') }
        before { visit "#{path}?page=1&per=2&type=instantaneous" }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 2})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end

      context "with extra params and no pagination" do
        before { params.merge!(type: 'instantaneous') }
        before { visit "#{path}?type=instantaneous" }
        it { should_have_pagination_uri('first', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('next', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('last', params.merge({page: 1, per: 25})) }
      end

      context "with an URI" do
        before { @uri = 'http://www.example.com/resource' }
        before { params.merge!(type: @uri) }
        before { visit "#{path}?type=#{@uri}" }
        it { should_have_pagination_uri('first', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('next', params.merge({page: 1, per: 25})) }
        it { should_have_pagination_uri('last', params.merge({page: 1, per: 25})) }
      end

      context "when accessing a connected resource" do
        before { path = "#{path}/#{resource.id.as_json}/#{connection}" }
        before { params.merge!(path: path) }
        before { visit "#{path}?page=1&per=2" }
        it { should_have_pagination_uri('first', params.merge({page: 1})) }
        it { should_have_pagination_uri('prev', params.merge({page: 1})) }
        it { should_have_pagination_uri('next', params.merge({page: 2})) }
        it { should_have_pagination_uri('last', params.merge({page: 3})) }
      end
    end
  end
end
