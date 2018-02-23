class OfficeType
  include Mongoid::Document
  store_in collection: "office-type"
  field :id, type: String
  field :name, type: String
end
