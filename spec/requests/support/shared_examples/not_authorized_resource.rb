shared_examples_for "not authorized resource" do |action|
  context "when not logged in" do
    before { basic_auth_cleanup }

    it "is not authorized" do
      eval(action)
      should_have_valid_json
      should_have_not_authorized_resource @uri
    end
  end
end
