require 'spec_helper'

describe Consumption do
  # presence
  it { should validate_presence_of(:created_from) }
  it { should validate_presence_of(:device_uri) }
  it { should validate_presence_of(:value) }

  #uri
  it { should allow_value(Settings.validation.uri.valid).for(:created_from) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:created_from) }
  it { should allow_value(Settings.validation.uri.valid).for(:device_uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:device_uri) }

  # allowed values
  it { should allow_value('instantaneous').for(:type) }
  it { should allow_value('durational').for(:type) }
  it { should allow_value('KWH').for(:unit) }
  it { should validate_presence_of(:occur_at) }

  # mass assignment
  it { should_not allow_mass_assignment_of(:created_from) } 



  context "#normalize_timings" do
    context "with durational consumption" do
      before { @correct = Factory(:consumption_durational) }

      context "with all timing values" do
        before { @consumption = Factory.build(:consumption_durational) }
        before { @consumption.save! }
        it "should not change timings" do
          @consumption.occur_at.should == @correct.occur_at
          @consumption.end_at.should == @correct.end_at
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #duration missing" do
        before { @consumption = Factory.build(:consumption_durational, duration: nil) }
        before { @consumption.save! }
        it "should calculate duration field" do
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #end_at missing" do
        before { @consumption = Factory.build(:consumption_durational, end_at: nil) }
        before { @consumption.save! }
        it "should calculate end_at field" do
          @consumption.end_at.should == @correct.end_at
        end
      end

      context "with #occur_at missing" do
        before { @consumption = Factory.build(:consumption_durational, occur_at: nil) }
        before { @consumption.save! }
        it "should calculate occur_at field" do
          @consumption.occur_at.should == @correct.occur_at
        end
      end

      context "with two missing timing values" do
        before { @consumption = Factory.build(:consumption_durational, occur_at: nil, duration: nil) }
        it "should raise error" do
          expect { @consumption.save! }.to raise_error
        end
      end
    end


    context "with instantaneous consumption" do
      before  { @consumption = Factory(:consumption) }
      it "should not not populate durational params" do
        @consumption.end_at.should be_nil
        @consumption.duration.should be_nil
      end
    end
  end
end
