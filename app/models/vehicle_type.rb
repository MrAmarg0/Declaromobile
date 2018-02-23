class VehicleType
  include Mongoid::Document
  store_in collection: "vehicle-type"
  field :id, type: String
  field :name, type: String
end
