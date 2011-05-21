require 'spec_helper'

describe DeviceStatus do
  it { should validate_presence_of(:name) }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }
end
