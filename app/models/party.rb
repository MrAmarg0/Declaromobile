class Party
  include Mongoid::Document
  store_in collection: "party"
  field :id, type: String
  field :name, type: String
end
