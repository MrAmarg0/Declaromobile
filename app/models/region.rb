class Region
  include Mongoid::Document
  store_in collection: "region"
  field :id, type: String
  field :name, type: String
end
