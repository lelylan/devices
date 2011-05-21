Settings.add_source!("#{Rails.root}/config/settings/test.yml")
Settings.reload!

FactoryGirl.define do

  # Base pending resource without connected properties
  factory :pending do
    uri Settings.pending.uri
    device_uri Settings.device.uri
    function_uri Settings.functions.set_intensity.uri
    function_name Settings.functions.set_intensity.name
  end

  # Open pending. Both connected properties are open
  factory :pending_complete, parent: :pending do |p|
    p.pending_properties {[
      Factory.build(:pending_property_intensity),
      Factory.build(:pending_property_status)
    ]}
  end
  
  # Open pending. One connected property is one and one is closed.
  # The intensity property connection is open and the status property connection is open
  factory :half_pending, parent: :pending do |p|
    p.pending_properties {[
      Factory.build(:pending_property_intensity),
      Factory.build(:pending_property_status_closed)
    ]}
  end

  # Closed pending. Both connected properties are closed
  factory :closed_pending, parent: :pending_complete do |p|
    uri Settings.pending_closed.uri
    pending_status false
    p.pending_properties {[
      Factory.build(:pending_property_intensity_closed),
      Factory.build(:pending_property_status_closed)
    ]}
  end

  # Not owned pending resource
  factory :not_owned_pending, parent: :pending_complete do |p|
    device_uri Settings.another_device.uri
  end

  # ------------
  # Connections
  # ------------

  # Open connected intensity
  factory :pending_property_intensity, class: :pending_property do
    uri Settings.properties.intensity.uri
    value Settings.properties.intensity.new_value
    old_value Settings.properties.intensity.default_value
    pending_status true
  end

  # Open pending status
  factory :pending_property_status, class: :pending_property do
    uri Settings.properties.status.uri
    value Settings.properties.status.new_value
    old_value Settings.properties.status.default_value
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
