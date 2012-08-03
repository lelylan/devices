shared_examples_for 'a boolean' do

  let (:booleans) { [true, false] }
  before          { booleans.push nil if accepts_nil }

  it { booleans.each { |value| should allow_value(value).for(field) } }

  it 'transforms strings to corresponding true value' do
    resource[field] = 'true'
    resource[field].should == true
  end

  it 'transforms strings to corresponding true value' do
    resource[field] = 'false'
    resource[field].should == false
  end

  it 'sets false any string different from a boolean string value' do
    resource[field] = 'string'
    resource[field].should == false
  end
end
