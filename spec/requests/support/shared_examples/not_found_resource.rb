shared_examples_for "a rescued 404 resource" do |action, controller|
  context "with not existing resource" do
    scenario "get a not found notification" do
      @resource.destroy
      eval(action)
      should_have_valid_json
      should_have_not_found_resource(@uri)
    end
  end

  #context "with not owned resource" do
    #scenario "get a not found notification" do
      #@uri = "/#{controller}/#{@not_owned_resource.id.as_json}#{connection}"
      #eval(action)
      #should_have_a_not_found_resource(@uri)
      #should_have_valid_json(page.body)
    #end
  #end

  #context "with illegal id" do
    #scenario "get a not found notification" do
      #@uri = "/#{controller}/0#{connection}"
      #eval(action)
      #should_have_a_not_found_resource(@uri)
      #should_have_valid_json(page.body)
    #end
  #end
end

#shared_examples_for "a rescued 404 connection" do |action, controller, connection|
  #context "with not existing resource" do
    #scenario "get a not found notification" do
      #@connection.destroy
      #eval(action)
      #should_have_a_not_found_connection(@uri)
      #should_have_valid_json(page.body)
    #end
  #end

  #context "with not owned resource" do
    #scenario "get a not found notification" do
      #@uri = "/#{controller}/#{@resource.id.as_json}#{connection}?uri=#{@not_owned_connection.uri}"
      #eval(action)
      #should_have_a_not_found_connection(@uri)
      #should_have_valid_json(page.body)
    #end
  #end
#end
