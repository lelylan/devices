class FunctionProperty
  include Mongoid::Document
  include Resourceable

  field :value
  field :property_id, type: Moped::BSON::ObjectId

  attr_accessor :uri

  embedded_in :function

  before_create :set_property_id

  private

  def set_property_id
    self.property_id = find_id(uri)
  end
end
