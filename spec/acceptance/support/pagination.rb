module PaginationMethods
  # Check correct URI generation for pagination
  def should_have_pagination_uri(type, options)
    options = options.dup
    path = options.delete(:path) 
    uri = "\"#{type}\": \"#{host}#{path}?page=#{options[:page]}&per=#{options[:per]}"
    uri += "&type=#{options[:type]}" if options[:type]
    page.should have_content uri
  end

  # Check pagination existance on intex views
  def should_have_pagination(path)
    params = { page: Settings.pagination.page, per: Settings.pagination.per, path: path}
    should_have_pagination_uri('first', params)
    should_have_pagination_uri('prev', params)
    should_have_pagination_uri('next', params)
    should_have_pagination_uri('last', params)
  end
end

RSpec.configuration.include PaginationMethods, :type => :acceptance
