require 'spec_helper'

describe DeviceProperty do
<<<<<<< HEAD
  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:uri) }
=======
  it { should validate_presence_of(:name) }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }
  it { should allow_value(true).for(:pending) }
  it { should allow_value(false).for(:pending) }
  it { should_not allow_value('example').for(:pending) }
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
