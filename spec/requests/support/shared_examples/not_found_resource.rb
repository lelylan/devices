shared_examples_for "a rescued 404 resource" do |action, controller|
  context "with not existing resource" do
    scenario "get a not found notification" do
      @resource.destroy
      eval(action)
      should_have_valid_json
      should_have_not_found_resource uri: @uri
    end
  end

  context "with resource not owned" do
    scenario "get a not found notification" do
      @uri = "/#{controller}/#{@resource_not_owned.id.as_json}"
      eval(action)
      should_have_valid_json
      should_have_not_found_resource uri: @uri
    end
  end

  context "with illegal id" do
    scenario "get a not found notification" do
      @uri = "/#{controller}/0"
      eval(action)
      should_have_valid_json
      should_have_not_found_resource uri: @uri
    end
  end
end
