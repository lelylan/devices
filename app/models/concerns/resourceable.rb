require 'addressable/uri'

module Resourceable
  extend ActiveSupport::Concern

  # Returns a list of ids from a list of uris
  def find_ids(uris)
    uris.map { |uri| find_id(uri) }
  end

  # Returns an id from a uri
  def find_id(uri)
    Addressable::URI.parse(uri).basename
  end
end
