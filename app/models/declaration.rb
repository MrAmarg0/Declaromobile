class Declaration
  require 'carbrand'
  require 'net/http'
  require 'json'
  include Mongoid::Document
  store_in collection: "declarations"
  field :main, type: Hash
  field :incomes, type: Array
  field :real_estates, type: Array
  field :savings, type: Array
  field :stocks, type: Array
  field :bonds, type: Array
  field :red_flag, type: :boolean
  field :spendings, type: Array

  has_many :carbrands, foreign_key: "vehicles"

  def self.get_by_vehicle_name(name)
    self.where("vehicles.brand.name" => name)
  end

  def self.update_carbrand_stat
    Carbrand.where({"parent" => {"$ne" => "null"}}).any_of.update_all({:count => 0})
    Carbrand.where({"parent" => {"$ne" => "null"}}).each do |car|
      new_car_count = Declaration.where("vehicles" => {"$elemMatch" => {"brand.id" => car.car_id}}).count
      puts car.name + " " + car.car_id.to_s + " " + new_car_count.to_s
      car.update_attribute(:count, new_car_count)
    end
  end

  def self.set_average_price(car)
    return if (car.parent.nil?)
    url = URI.parse("http://crwl.ru/api/rest/latest/get_average_price/?api_key=" + "b3673fe2447f95ae806bb4a2bd46d953" + "&brand=" + car["parent"]["name"] + "&model=" + car.name + "&year=2015")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    result = JSON(res.body)
    puts result
    unless (res.nil?)
      car.update_attribute(:average_price, result["average_price"])
      car.update_attribute(:max_price, result["max_price"])
      car.update_attribute(:min_price, result["min_price"])
    end
  end

  def self.get_all_price

  end

  def self.get_vehicles_price(declaration)
    total_price = 0
    return if declaration["vehicles"] == nil
    declaration["vehicles"].each do |vehicle|
      next if vehicle["brand"] == nil
      price = Carbrand.where("car_id": vehicle["brand"]["id"]).first["average_price"]
      next unless price.is_a? Integer
      total_price += price
    end
    total_price
  end

  def self.get_overprice_vehicles
    Declaration.where("main.year" => {"$gt" => 2015}).each do |declaration|
      vehicle_prices = get_vehicles_price(declaration)
      total_money = get_total_money(declaration)
      current_year = declaration["main.year"];
      previous_declaration = Declaration.where("main.person.name": declaration["main"]["person"]["name"]).where("main.year": current_year - 1)
      unless (previous_declaration.empty?)
        prev_decl = previous_declaration.first
        previous_total_money = get_total_money(prev_decl)
        previous_vehicle_prices = get_vehicles_price(prev_decl)
        if (vehicle_prices > previous_vehicle_prices)
          vehicle_diff = vehicle_prices - previous_vehicle_prices
          if (vehicle_diff > total_money && (prev_decl["real_estates"] == declaration["real_estates"] || prev_decl["real_estates"].count < declaration["real_estates"].count))
            puts declaration["main.person.name"]
            puts declaration["main.year"]
            declaration.update_attribute(:red_flag, true)
          end
        end
      end
    end
  end

  def self.get_total_money(declaration)
    total_savings = get_total_savings(declaration)
    total_incomes = get_total_incomes(declaration)
    return total_incomes + total_savings
  end

  def self.get_total_incomes(declaration)
    total_incomes = 0
    return total_incomes if declaration["incomes"].nil?
    declaration["incomes"].each do |income|
      total_incomes += income["size"]
    end
    total_incomes
  end

  def self.get_total_savings(declaration)
    total_savings = 0
    declaration["savings"].each do |saving|
      save = saving.gsub(/[^0-9,]/, "").to_i
      total_savings += save
    end
    total_savings
  end

  def self.get_min_incoming_car_owner(car)
    min_income = 9999999999999
    owner = nil
    Declaration.where("vehicles" => {"$elemMatch" => {"brand.id" => car.car_id}}, "main.year" => {"$gte" => 2016}).each do |dec|
      total_incomes = get_total_money(dec)
      next if total_incomes == 0
      if (total_incomes < min_income)
        min_income = total_incomes
        owner = dec
      end
    end
    owner
  end

  def self.get_max_incoming_car_owner(car)
    min_income = 0
    owner = nil
    Declaration.where("vehicles" => {"$elemMatch" => {"brand.id" => car.car_id}}, "main.year" => {"$gte" => 2016}).each do |dec|
      total_incomes = get_total_incomes(dec)
      if (total_incomes > min_income)
        min_income = total_incomes
        owner = dec
      end
    end
    owner
  end
end
