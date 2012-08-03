module SharedMacros
  def has_valid_json
    expect { JSON.parse(page.source) }.to_not raise_error
  end
end

RSpec.configuration.include SharedMacros
