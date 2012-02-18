Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do

  # Pending resource open.
  # The device status and intensity are pending.
  factory :pending do 
    uri Settings.pending.uri
    device_uri Settings.device.uri
    pending_properties {[
      Factory.build(:pending_property_status),
      Factory.build(:pending_property_intensity)
    ]}
  end

  # Pending resource open on intensity property.
  factory :pending_intensity, parent: :pending do
    pending_properties {[
      Factory.build(:pending_property_intensity),
      Factory.build(:pending_property_status_closed)
    ]}
  end

  # Pending resource closed.
  factory :pending_closed, parent: :pending do
    pending_properties {[
      Factory.build(:pending_property_intensity_closed),
      Factory.build(:pending_property_status_closed)
    ]}
  end

  # Not owned pending resource
  factory :pending_not_owned, parent: :pending do
    device_uri Settings.device.uri + '-another'
  end


  # -------------
  # Connections
  # -------------

  # Open connected intensity
  factory :pending_property_intensity, class: :pending_property do
    uri Settings.properties.intensity.uri
    value '20.0'
    old_value '0.0'
    pending_status true
  end

  # Open pending status
  factory :pending_property_status, class: :pending_property do
    uri Settings.properties.status.uri
    value 'off'
    old_value 'off'
    pending_status true
  end

  # Closed pending intensity
  factory :pending_property_intensity_closed, parent: :pending_property_intensity do
    pending_status false
  end

  # Closed pending property
  factory :pending_property_status_closed, parent: :pending_property_status do
    pending_status false
  end
end
