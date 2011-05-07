require 'spec_helper'

describe PendingProperty do
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:old_value) }
 
  it { should allow_value(Settings.validation.valid_uri).for(:property_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:property_uri) } 
end
