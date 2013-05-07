require 'spec_helper'

describe DeviceProperty do

  its(:pending)  { should == false }
  its(:accepted) { should be_nil }

  it { should validate_presence_of :property_id }

  # Here we do not use the connection shared example.
  #
  # The reason is that this connection is way more complex than the others and we
  # need special test cases that are covered in the device_spec test suite.
end
