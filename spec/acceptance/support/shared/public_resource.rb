shared_examples_for "a public list of resources" do |action|
  context "with public resources" do
    before { basic_auth_cleanup }
    before { @uri = @uri + "/public" }
    scenario "view all public resources" do
      eval(action)
      should_have_category(@public_resource)
      should_have_category(@not_owned_public_resource)
      should_not_have_category(@resource)
      should_not_have_category(@not_owned_resource)
      should_have_pagination(@uri)
      should_have_valid_json(page.body)
      should_have_root_as('resources')
    end
  end
end

shared_examples_for "a public resource" do |action|
  context "when resource is public" do
    before { basic_auth_cleanup }

    context "when not logged in" do
      scenario "view resource" do
        eval(action)
        page.status_code.should == 200
        should_have_category(@not_owned_public_resource)
        should_have_valid_json(page.body)
      end
    end

    context "when logged in" do
      before { basic_auth(@user) } 
      scenario "view resource" do
        eval(action)
        page.status_code.should == 200
        should_have_category(@not_owned_public_resource)
        should_have_valid_json(page.body)
      end
    end
  end
end
