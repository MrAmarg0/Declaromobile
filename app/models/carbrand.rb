class Carbrand
  include Mongoid::Document
  store_in collection: "carbrand"
  field :car_id, type: Integer
  field :name, type: String
  field :count, type: Integer
  field :average_price, type: Integer
  field :min_price, type: Integer
  field :max_price, type: Integer
  belongs_to :carbrand, foreign_key: "parent"
end
