require 'spec_helper'

describe Device do
  it { should allow_value(SETTINGS[:validation][:valid_uri]).for(:uri) }
  it { should_not allow_value(SETTINGS[:validation][:not_valid_uri]).for(:uri) }

  it { should allow_value(SETTINGS[:validation][:valid_uri]).for(:created_from) }
  it { should_not allow_value(SETTINGS[:validation][:not_valid_uri]).for(:created_from) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:type_uri) }
  it { should allow_value(SETTINGS[:validation][:valid_uri]).for(:type_uri) }
  it { should_not allow_value(SETTINGS[:validation][:not_valid_uri]).for(:type_uri) }

  it { should validate_presence_of(:type_name) }
end
