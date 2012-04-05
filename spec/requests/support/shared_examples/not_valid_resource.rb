shared_examples_for "not valid JSON" do |action, method|
  it "should get a not valid notification" do
    @params = "I'm not an Hash"
    eval(action)
    page.status_code.should == 422
    should_have_a_not_valid_resource code: "notifications.json.not_valid", error: "Not valid", method: method
    page.should have_content @params
  end
end

shared_examples_for "not valid params" do |action, method|
  it "should not create a resource" do
    @params = {}
    eval(action)
    page.status_code.should == 422
    should_have_a_not_valid_resource method: method
  end
end
