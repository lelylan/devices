shared_examples_for 'a searchable resource' do |searchable|

  searchable.each do |key, value|

    describe "?#{key}=:#{key}" do

      let!(:result) { FactoryGirl.create factory, key => value, resource_owner_id: user.id }

      it 'returns the searched resource' do
        page.driver.get uri, key => value
        contains_resource result
        page.should_not have_content resource.id.to_s
      end
    end
  end
end

shared_examples_for 'a searchable resource on properties' do

  let!(:result) { FactoryGirl.create factory, resource_owner_id: user.id }

  context 'when filters the property uri' do

    let(:property_uri) { a_uri(result.properties.first, :property_id) }

    it 'returns the searched resource' do
      page.driver.get uri, property: property_uri
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end

  context 'when filters the property value' do

    before { result.properties.first.update_attributes(value: 'updated') }

    it 'returns the searched resource' do
      page.driver.get uri, value: 'updated'
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end

  context 'when filters the property physical' do

    before { result.properties.first.update_attributes(physical: 'updated') }

    it 'returns the searched resource' do
      page.driver.get uri, physical: 'updated'
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end

  context 'when filters the property uri and property value' do

    let(:property_uri) { a_uri(result.properties.first, :property_id) }
    before { result.properties.first.update_attributes(value: 'updated', physical: 'updated') }

    it 'returns the searched resource' do
      page.driver.get uri, property: property_uri, value: 'updated', physical: 'updated'
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end
end

shared_examples_for 'a searchable resource on timing' do |field|

  let(:value)   { Time.now - 3600 }
  let!(:result) { FactoryGirl.create factory, resource_owner_id: user.id }

  context '?from={Time.now-60}' do

    before     { resource.update_attributes(field => value) }
    let(:from) { Time.now - 60 }

    it 'returns the searched resource' do
      page.driver.get uri, from: from
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end

  context '?to={Time.now-60}' do

    before   { result.update_attributes(field => value) }
    let(:to) { Time.now - 60 }

    it 'returns the searched resource' do
      page.driver.get uri, to: to
      contains_resource result
      page.should_not have_content resource.id.to_s
    end
  end
end
