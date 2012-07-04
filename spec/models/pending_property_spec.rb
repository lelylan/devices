require 'spec_helper'

describe PendingProperty do
  it { should validate_presence_of :value }
  it { should validate_presence_of :old_value }

  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) } 
  
  describe "transitional_values" do
    before  { @values = [1, {key: 'value'}, ['1']] }
    before  { @resource = Factory(:pending_complete) }
    before  { @resource.pending_properties.first.update_attributes(transitional_values: @values) }
    subject { @resource.pending_properties.first.transitional_values }

    it { should have(3).itmes }
    it { subject[0].should == "1" }
    it { subject[1].should == {key: 'value'}.to_s }
    it { subject[2].should == ['1'].to_s }
  end
end
