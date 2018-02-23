class DocumentType
  include Mongoid::Document
  store_in collection: "document-type"
  field :id, type: String
  field :name, type: String
end
