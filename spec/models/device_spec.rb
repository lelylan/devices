require 'spec_helper'

describe Device do
  # presence
  it { should validate_presence_of(:created_from) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type_uri) }

  # mass assignment
  it { should_not allow_mass_assignment_of(:created_from) }

  # general stub
  before  { stub_get(Settings.type.uri).to_return(body: fixture('type.json') ) }

  
  # ------------------------
  # Create physical device
  # ------------------------
  describe "#create_physical_connection" do
    context "when valid" do
      before { @physical = {uri: Settings.physical.uri} }
      subject { Factory(:device_no_physical, physical: @physical).device_physical }
      it { should_not be_nil }
    end

    context "when not valid" do
      context "with no uri field" do
        before { @physical = {} }
        it "should get a not valid notification" do
          lambda{ 
            Factory(:device_no_physical, physical: @physical)
          }.should raise_error(Mongoid::Errors::Validations)
        end
      end

      context "when sent as Array" do
        before { @physical = [] }
        it "should get a not valid notification" do
          lambda{ 
            Factory(:device_no_physical, physical: @physical) 
          }.should raise_error(Mongoid::Errors::InvalidType)
        end
      end
    end
  end


  # --------------------------------
  # Syncronize with type structure
  # --------------------------------
  context "#synchronize_type" do
    before  { @device = Factory(:device_no_connections) }
    subject { @device }

    its(:device_properties) { should have(2).properties }

    context "Lelylan::Type.type" do
      before { @type = Lelylan::Type.type(Settings.type.uri) }

      it "should return a json representation" do
        @type[:name].should == "Dimmer"
      end

      context "#synchronize_properties" do
        before  { @device = Factory.build(:device_no_connections) }
        before  { @device.synchronize_properties(@type[:properties]); }
        subject { @device.device_properties }
        it { should have(2).properties }
      end
    end
  end


  # -------------------------------
  # Syncronize to physical device
  # -------------------------------
  context "#synchronize_device" do
    before { @properties = json_fixture('properties.json')[:properties] }

    context "with physical connection" do
      before  { stub_request(:put, Settings.physical.uri).with(body: {properties: @properties}) }
      before  { @device = Factory(:device) }
      before  { @device.synchronize_device(@properties, {}) }

      it "should change device property status" do
        @device.reload.device_properties[0][:value].should == "on"
      end

      it "should change device property intensity" do
        @device.reload.device_properties[1][:value].should == "100.0"
      end

      it "should update the physical device" do
        a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should have_been_made.once
      end
    end

    context "without physical connection" do
      before  { @device = Factory(:device_no_physical) }
      before  { @device.synchronize_device(@properties, {}) }

      it "should change device property status" do
        @device.reload.device_properties[0][:value].should == "on"
      end

      it "should change device property intensity" do
        @device.reload.device_properties[1][:value].should == "100.0"
      end
    end
  end


  # ----------------
  # Create history
  # ----------------

  context "#create_history" do
    before { @device = DeviceDecorator.decorate(Factory(:device_no_physical)) }
    before { DeviceDecorator.any_instance.stub(:uri).and_return(Settings.device.uri) }

    it "should create an history" do
      expect{ @device.create_history(Settings.user.another.uri) }.to change{ History.count }.by(1)
      history = History.last
      history.device_uri.should == @device.uri
      history.created_from.should == Settings.user.another.uri
      history.history_properties.should have(2).items
    end
  end

  
  # ----------------
  # Update pending
  # ----------------
  context "#update_pending" do
    before { DeviceDecorator.any_instance.stub(:uri).and_return(Settings.device.uri) }
    before { @params = json_fixture('properties.json') }

    # -----------------------------
    # With no physical connection
    # -----------------------------
    context "with no physical connection" do
      before { @device = DeviceDecorator.decorate(Factory(:device_no_physical)) }

      context "when update device properties" do
        before { @device.synchronize_device(@params[:properties], @params) }

        it "should not start pending" do
          @device.check_pending(@params)
          @device.pending.should be_false
        end
      end
    end

    # --------------------------
    # With physical connection
    # --------------------------
    context "with physical connection" do
      before { stub_request(:put, Settings.physical.uri) }
      before { @device = DeviceDecorator.decorate(Factory(:device)) }

      # ----------------
      # Call from user
      # ----------------
      context "when update properties" do
        before { @device.synchronize_device(@params[:properties], @params) }

        it "should start pending" do
          @device.check_pending(@params)
          @device.pending.should be_true
          @device.device_properties[0].pending.should == "on"
          @device.device_properties[1].pending.should == "100.0"
        end

        it "should not update physical device" do
          a_put(Settings.physical.uri).should have_been_made.once
        end
      end

      # --------------------
      # Call from physical
      # --------------------
      context "when :source is :physical" do
        before { @params[:source] = 'physical' }

        context "when update properties" do
          before { @device.synchronize_device(@params[:properties], @params) }

          it "should end pending" do 
            @device.synchronize_device(@params[:properties], @params)
            @device.check_pending(@params)
            @device.pending.should be_false
          end

          it "should not update physical device" do
            a_put(Settings.physical.uri).should_not have_been_made
          end
        end
      end

      # -------------------------------
      # Call with pending set to true
      # -------------------------------
      context "when :pending is :true" do
        before { @params[:pending] = 'true' }

        context "when update properties" do
          before { @device.synchronize_device(@params[:properties], @params) }

          it "should start/update pending" do
            @device.check_pending(@params)
            @device.pending.should be_true
            @device.device_properties[0].pending.should == "on"
            @device.device_properties[1].pending.should == "100.0"
          end

          it "should not update physical device" do
            a_put(Settings.physical.uri).should have_been_made.once
          end
        end
      end
    end
  end

end
