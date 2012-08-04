require 'spec_helper'

describe DeviceProperty do

  it { should validate_presence_of :property_id }

  # Here we do not use the connection shared example. The reaso is that this connection
  # is way more complex than the others and we need additional special cases that are 
  # covered in the device_spec test suite.
end
