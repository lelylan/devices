shared_examples_for "protected resource" do |action|
  context "when not logged in" do
    before { basic_auth_cleanup }
    scenario "is not authorized" do
      eval(action)
      should_not_be_authorized
      should_have_valid_json(page.body)
    end
  end
end
