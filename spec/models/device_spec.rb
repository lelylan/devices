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
      subject { FactoryGirl.create(:device_no_physical, physical: @physical).device_physical }
      it { should_not be_nil }
    end

    context "when not valid" do
      context "with no uri field" do
        before { @physical = {} }
        it "should get a not valid notification" do
          lambda{ 
            FactoryGirl.create(:device_no_physical, physical: @physical)
          }.should raise_error(Mongoid::Errors::Validations)
        end
      end

      context "when sent as Array" do
        before { @physical = [] }
        it "should get a not valid notification" do
          lambda{ 
            FactoryGirl.create(:device_no_physical, physical: @physical) 
          }.should raise_error(Mongoid::Errors::InvalidType)
        end
      end
    end
  end


  # --------------------------------
  # Syncronize with type structure
  # --------------------------------
  context "#synchronize_type" do
    before  { @device = FactoryGirl.create(:device_no_connections) }
    before  { @device.synchronize_type }

    it "should have 2 properties" do
      @device.device_properties.should have(2).items
    end

    context "Lelylan::Type.type" do
      before { @type = Lelylan::Type.type(Settings.type.uri) }

      it "should return a json representation" do
        @type[:name].should == "Dimmer"
      end

      context "#synchronize_properties" do
        before  { @device = FactoryGirl.build(:device_no_connections) }
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
      before  { @device = FactoryGirl.create(:device) }
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
      before  { @device = FactoryGirl.create(:device_no_physical) }
      before  { @device.synchronize_device(@properties, {}) }

      it "should change device property status" do
        @device.reload.device_properties[0][:value].should == "on"
      end

      it "should change device property intensity" do
        @device.reload.device_properties[1][:value].should == "100.0"
      end
      
      it "should not update the physical device" do
        a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should_not have_been_made
      end
    end

    context "with source: 'physical'" do
      before  { @device = FactoryGirl.create(:device_no_physical) }
      before  { @device.synchronize_device(@properties, {source: 'physical'}) }

      it "should not update the physical device" do
        a_put(Settings.physical.uri, false).with(body: {properties: @properties}).should_not have_been_made
      end
    end
  end


  # ----------------
  # Create history
  # ----------------

  context "#create_history" do
    before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device_no_physical)) }
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
      before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device_no_physical)) }

      context "when update device properties" do
        before { @device.synchronize_device(@params[:properties], @params) }

        it "should not be pending" do
          @device.pending.should be_false
        end
      end
    end

    # --------------------------
    # With physical connection
    # --------------------------
    context "with physical connection" do
      before { stub_request(:put, Settings.physical.uri) }
      before { @device = DeviceDecorator.decorate(FactoryGirl.create(:device)) }

      # -----------------------------
      # Create pending (from user)
      # -----------------------------
      context "when pending: 'start'" do
        before { @params[:pending] = 'start' }

        context "when update properties" do
          before { @device.synchronize_device(@params[:properties], @params) }

          it "should be pending" do
            @device.pending.should be_true
          end

          it "should update device properties" do
            @device.device_properties[0].value.should == "on"
            @device.device_properties[1].value.should == "100.0"
          end

          it "should have old property values as pending values" do
            @device.device_properties[0].pending.should == "off"
            @device.device_properties[1].pending.should == "0.0"
          end
        end
      end

      # --------------------------------
      # Update pending (from physical)
      # --------------------------------
      context "when pending: 'update'" do
        before { @params[:pending] = 'update' }
        before { @params[:properties][1][:value] = '75.0' }

        context "when update properties" do
          before { @device.synchronize_device(@params[:properties], @params) }

          it "should be pending" do
            @device.pending.should be_true
          end

          it "should not update property values" do
            @device.device_properties[0].value.should == "off"
            @device.device_properties[1].value.should == "0.0"
          end

          it "should update pending values" do
            @device.device_properties[0].pending.should == "on"
            @device.device_properties[1].pending.should == "75.0"
          end
        end
      end

      # -------------------------------
      # Close pending (from physical)
      # -------------------------------
      context "when pending: 'close'" do
        before { @params[:pending] = 'close' }

        context "when update properties" do
          before { @device.synchronize_device(@params[:properties], @params) }

          it "should not be pending" do
            @device.pending.should_not be_true
          end

          it "should update property values" do
            @device.device_properties[0].pending.should == "on"
            @device.device_properties[1].pending.should == "100.0"
          end

          it "should update pending values" do
            @device.device_properties[0].value.should == "on"
            @device.device_properties[1].value.should == "100.0"
          end
        end
      end
    end
  end

end
