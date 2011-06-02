shared_examples_for "an array field" do |field, action|
  context "with not valid ##{field}" do
    context "when Hash" do
      before { params[field] = {} }
      scenario "get a not valid notification" do
        eval(action)
        should_have_a_not_valid_resource
        should_have_valid_json(page.body) 
        page.should have_content "but received a Hash"
      end
    end
    
    context "when String" do
      before { params[field] = "not_valid" }
      scenario "get a not valid notification" do
        eval(action)
        should_have_a_not_valid_resource
        should_have_valid_json(page.body)
        page.should have_content "but received a String"
      end
    end
  end
end
