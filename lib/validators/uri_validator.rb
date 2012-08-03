class UriValidator < ActiveModel::EachValidator

  def initialize(options)
    options.reverse_merge!(:schemes => %w(http https))
    options.reverse_merge!(:message => 'is not a valid URL')
    super(options)
  end

  def validate_each(record, attribute, value)
    validate_uri(record, attribute, value) if value.kind_of? String
    value.each { |uri| validate_uri(record, attribute, uri) } if value.kind_of? Array
  end

  def validate_uri(record, attribute, value) 
    schemes = [*options.fetch(:schemes)].map(&:to_s)
    if URI::regexp(schemes).match(value)
      begin
        URI.parse(value)
      rescue URI::InvalidURIError
        record.errors.add(attribute, options.fetch(:message), value: value)
      end
    else
      record.errors.add(attribute, options.fetch(:message), value: value)
    end
  end
end

module ClassMethods
  # Validates whether the value of the specified attribute is valid url or an array of valid uris.
  #
  #   class Unicorn
  #     include ActiveModel::Validations
  #     attr_accessor :homepage, :ftpsite
  #     validates_url :homepage, :allow_blank => true
  #     validates_url :ftpsite, :schemes => ['ftp']
  #   end
  # Configuration options:
  # * <tt>:message</tt> - A custom error message (default is: 'is not a valid URL').
  # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
  # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
  # * <tt>:schemes</tt> - Array of URI schemes to validate against. (default is +['http', 'https']+)

  def validates_uri(*attr_names)
    validates_with UriValidator, _merge_attributes(attr_names)
  end
end
