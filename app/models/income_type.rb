class IncomeType
  include Mongoid::Document
  store_in collection: "income-type"
  field :id, type: String
  field :name, type: String
end
