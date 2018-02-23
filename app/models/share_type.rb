class ShareType
  include Mongoid::Document
  store_in collection: "share-type"
  field :id, type: String
  field :name, type: String
end
