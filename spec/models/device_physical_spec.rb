require 'spec_helper'

describe DevicePhysical do

  it { should validate_presence_of :uri }

  it { Settings.uris.valid.each     { |uri| should allow_value(uri).for(:uri) } }
  it { Settings.uris.not_valid.each { |uri| should_not allow_value(uri).for(:uri) } }
end
