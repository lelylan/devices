# Not authorized requests
shared_examples_for "protected resource" do |action|
  context "when not logged in" do
    before { basic_auth_cleanup }
    scenario "is not authorized" do
      eval(action)
      should_not_be_authorized
    end
  end
end

# Not found resources
shared_examples_for "rescued when not found" do |action, controller, extra = ""|
  context "with not existing resource" do
    scenario "get a not found notification" do
      @resource.destroy
      eval(action)
      should_have_a_not_found_resource(@uri)
    end
  end

  context "with not owned resource" do
    scenario "get a not found notification" do
      @uri = "/#{controller}/#{@not_owned_resource.id.as_json}#{extra}"
      eval(action)
      should_have_a_not_found_resource(@uri)
    end
  end

  context "with illegal id" do
    scenario "get a not found notification" do
      @uri = "/#{controller}/0#{extra}"
      eval(action)
      should_have_a_not_found_resource(@uri)
    end
  end
end
