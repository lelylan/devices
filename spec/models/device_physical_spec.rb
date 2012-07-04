require 'spec_helper'

describe DevicePhysical do
  # presence
  it { should validate_presence_of(:uri) }

  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:uri) }
end
