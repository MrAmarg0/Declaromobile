class RealestateType
  include Mongoid::Document
  store_in collection: "realestate-type"
  field :id, type: String
  field :name, type: String
end
