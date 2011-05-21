require 'spec_helper'

describe Consumption do  
  it { should validate_presence_of(:uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:uri) }

  it { should validate_presence_of(:created_from) }
  it { should allow_value(Settings.validation.valid_uri).for(:created_from) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:created_from) }

  it { should validate_presence_of(:device_uri) }
  it { should allow_value(Settings.validation.valid_uri).for(:device_uri) }
  it { should_not allow_value(Settings.validation.not_valid_uri).for(:device_uri) }

  it { should allow_value('instantaneous').for(:type) }
  it { should allow_value('durational').for(:type) }

  it { should validate_presence_of(:value) }
  it { should allow_value('kwh').for(:unit) }
  it { should validate_presence_of(:occur_at) }

  context "#normalize_timings" do
    context "with durational consumption" do
      before { @correct = Factory(:durational_consumption) }

      context "with all timing present" do
        before { @consumption = Factory(:durational_consumption) }
        before { @consumption.save! }
        it "does not change timings" do
          @consumption.occur_at.should == @correct.occur_at
          @consumption.end_at.should == @correct.end_at
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #duration missing" do
        before { @consumption = Factory.build(:durational_consumption, duration: nil) }
        before { @consumption.save! }
        it "calculates duration field" do
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #end_at missing" do
        before { @consumption = Factory.build(:durational_consumption, end_at: nil) }
        before { @consumption.save! }
        it "calculates end_at field" do
          @consumption.end_at.should == @correct.end_at
        end
      end

      context "with #occur_at missing" do
        before { @consumption = Factory.build(:durational_consumption, occur_at: nil) }
        before { @consumption.save! }
        it "calculates occur_at field" do
          @consumption.occur_at.should == @correct.occur_at
        end
      end

      context "with two timings missing" do
        before { @consumption = Factory.build(:durational_consumption, occur_at: nil, duration: nil) }
        it "raise error" do
          lambda{ @consumption.save! }.should raise_error
        end
      end
    end

    context "with instantaneous consumption" do
      before  { @consumption = Factory(:consumption) }
      it "is not called" do
        @consumption.end_at.should be_nil
        @consumption.duration.should be_nil
      end
    end
  end
end
