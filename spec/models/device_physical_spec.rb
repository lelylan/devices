require 'spec_helper'

describe DevicePhysical do
<<<<<<< HEAD
  # presence
  it { should validate_presence_of(:uri) }

  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:uri) }
=======
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
