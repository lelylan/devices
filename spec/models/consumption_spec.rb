require 'spec_helper'

<<<<<<< HEAD
describe Consumption do
  # presence
  it { should validate_presence_of(:created_from) }
  it { should validate_presence_of(:device_uri) }
  it { should validate_presence_of(:value) }
 
  # uri
  it { should allow_value(Settings.validation.uri.valid).for(:created_from) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:created_from) }
  it { should allow_value(Settings.validation.uri.valid).for(:device_uri) }
  it { should_not allow_value(Settings.validation.uri.not_valid).for(:device_uri) }

  # allowed values
  it { should allow_value('instantaneous').for(:type) }
  it { should allow_value('durational').for(:type) }
  it { should_not allow_value('not_allowed').for(:type) }

  # presence
  it { should validate_presence_of(:occur_at) }

  # defaults
  its(:unit) { should == 'kwh' }

  # mass assignment
  it { should_not allow_mass_assignment_of(:created_from) } 



  context "#normalize_timings" do
    context "with durational consumption" do
      before { @correct = FactoryGirl.create(:consumption_durational) }

      context "with all timing values" do
        before { @consumption = FactoryGirl.create(:consumption_durational) }

        it "should not change timings" do
=======
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
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
          @consumption.occur_at.should == @correct.occur_at
          @consumption.end_at.should == @correct.end_at
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #duration missing" do
<<<<<<< HEAD
        before { @consumption = FactoryGirl.create(:consumption_durational, duration: nil) }

        it "should calculate duration field" do
=======
        before { @consumption = Factory.build(:durational_consumption, duration: nil) }
        before { @consumption.save! }
        it "calculates duration field" do
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
          @consumption.duration.should == @correct.duration
        end
      end

      context "with #end_at missing" do
<<<<<<< HEAD
        before { @consumption = FactoryGirl.create(:consumption_durational, end_at: nil) }

        it "should calculate end_at field" do
=======
        before { @consumption = Factory.build(:durational_consumption, end_at: nil) }
        before { @consumption.save! }
        it "calculates end_at field" do
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
          @consumption.end_at.should == @correct.end_at
        end
      end

      context "with #occur_at missing" do
<<<<<<< HEAD
        before { @consumption = FactoryGirl.create(:consumption_durational, occur_at: nil) }

        it "should calculate occur_at field" do
=======
        before { @consumption = Factory.build(:durational_consumption, occur_at: nil) }
        before { @consumption.save! }
        it "calculates occur_at field" do
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
          @consumption.occur_at.should == @correct.occur_at
        end
      end

<<<<<<< HEAD
      context "with two missing timing values" do
        before { @consumption = FactoryGirl.build(:consumption_durational, occur_at: nil, duration: nil) }

        it "should raise error" do
          expect { @consumption.save! }.to raise_error
=======
      context "with two timings missing" do
        before { @consumption = Factory.build(:durational_consumption, occur_at: nil, duration: nil) }
        it "raise error" do
          lambda{ @consumption.save! }.should raise_error
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
        end
      end
    end

<<<<<<< HEAD

    context "with instantaneous consumption" do
      before  { @consumption = FactoryGirl.create(:consumption) }

      it "should not not populate durational params" do
=======
    context "with instantaneous consumption" do
      before  { @consumption = Factory(:consumption) }
      it "is not called" do
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
        @consumption.end_at.should be_nil
        @consumption.duration.should be_nil
      end
    end
  end
end
