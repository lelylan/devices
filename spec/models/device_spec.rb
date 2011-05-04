require 'spec_helper'

describe Device do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }
  it { should validate_presence_of(:type_name) }

  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:created_from) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:created_from) }
  it { should allow_value(Settings.validation.valid_uri).for(:type_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:type_uri) }

  it { should_not allow_mass_assignment_of(:uri) }
  it { should_not allow_mass_assignment_of(:created_from) }
  it { should_not allow_mass_assignment_of(:type_uri) }
  it { should_not allow_mass_assignment_of(:type_name) }
end
