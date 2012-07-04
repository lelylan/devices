shared_examples_for "a default resource" do |action, connection = ""|
  context "when is the default status" do
    before { @resource = Factory(:is_setting_intensity, default: 'true') }
    before { @uri = "/statuses/#{@resource.id.as_json}#{connection}" }
    scenario "get a protected notification" do
      eval(action)
      should_have_a_not_valid_resource
      page.should have_content 'Protected resource'
      should_have_valid_json(page.body)
    end
  end
end

