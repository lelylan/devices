require 'spec_helper'

describe Consumption do  
  it { should validate_presence_of(:uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  it { should validate_presence_of(:created_from) }
  it { should allow_value(Settings.validation.valid_uri).for(:created_from) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:created_from) }

  it { should allow_value('instantaneous').for(:type) }
  it { should allow_value('durational').for(:type) }

  it { should validate_presence_of(:consumption) }
  it { should allow_value('kwh').for(:unit) }
  it { should validate_presence_of(:occur_at) }

  context "#normalize_timings" do
    context "with all timing present" do
    end

    context "with #duration missing" do
    end

    context "with #end_at missing" do
    end

    context "with #occur_at missing" do
    end
  end
end
