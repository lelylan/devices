shared_examples_for "protected resource" do
  context "when not logged in" do
    before { basic_auth_cleanup }
    scenario "is not authorized" do
      visit @uri
      should_not_be_authorized
    end
  end
end

shared_examples_for "rescued when not found" do
  context "with not existing resource" do
    scenario "is not found" do
      @resource.destroy
      visit @uri
      should_have_a_not_found_resource(@uri)
    end
  end

  context "with not owned resource" do
    scenario "is not found" do
      @uri = "/devices/#{@not_owned_resource.id.as_json}"
      visit @uri
      should_have_a_not_found_resource(@uri)
    end
  end

  context "with illegal id" do
    scenario "is not found" do
      @uri = "/devices/0"
      visit @uri
      should_have_a_not_found_resource(@uri)
    end
  end
end
