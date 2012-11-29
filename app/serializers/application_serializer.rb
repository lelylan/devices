# Extension to let serializers to be cached based on
# {class name}/{instance id}-{instance updated at}/to-json
#
# This extension lets you create a fragment cache for all
# serialized json with an autoexpiring key. In fact if you
# update your resource, everything changes.
#
# Example.
#
#   DeviceSerializer < ApplicationSerializer
#     cached true

class ApplicationSerializer < ActiveModel::Serializer

  class_attribute :perform_caching

  class << self

    # Confugure the usage of the cache (or not)
    def cached(value = true)
      self.perform_caching = value
    end

  end

  # Cache entire JSON string
  def to_json(*args)
    if perform_caching?
      Rails.cache.fetch expand_cache_key(self.class.to_s.underscore, object.cache_key, 'to-json') do
        super
      end
    else
      super
    end
  end

  # Cache individual Hash objects before serialization
  # This also makes them available to associated serializers
  def serializable_hash
    if perform_caching?
      Rails.cache.fetch expand_cache_key([self.class.to_s.underscore, object.cache_key, 'serializable-hash']) do
        super
      end
    else
      super
    end
  end

  def perform_caching?
    rails_caching && perform_caching && Rails.cache && respond_to?(:cache_key)
  end

  def rails_caching
    Rails.application.config.action_controller.perform_caching
  end

  def expand_cache_key(*args)
    ActiveSupport::Cache.expand_cache_key(args)
  end
end
