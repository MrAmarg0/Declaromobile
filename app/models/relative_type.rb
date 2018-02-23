class RelativeType
  include Mongoid::Document
  store_in collection: "relative-type"
  field :id, type: String
  field :name, type: String
end
