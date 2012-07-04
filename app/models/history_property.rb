class HistoryProperty
  include Mongoid::Document
  include Mongoid::Timestamps

  field :uri
  field :value

  embedded_in :histoy
<<<<<<< HEAD

  validates :uri, presence: true, url: true
=======
  
  validates :uri, presence: true, url: true
  validates :value, presence:true
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
