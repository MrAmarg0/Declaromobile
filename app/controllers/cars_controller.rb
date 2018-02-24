class CarsController < ActionController::Base
  def index
    @cars = Carbrand.order_by(:count => 'desc').limit(9)
    render 'cars/index'
  end

  def show
    @car = Carbrand.where("car_id": params[:id]).first
    @image_name = @car["parent"]["name"] + " " + @car["name"]
    @image_name = @image_name.downcase.gsub(' ', '_') + ".png"
    @image_path = "app/assets/images/" + @image_name
    unless File.exist?(@image_path)
      @image_name = "unknown_car.jpg"
    end
    @chart_data = {
        "0 - 100000" =>  0,
        "100000 - 200000" => 0,
        "200000 - 300000" => 0,
        "300000 - 400000" => 0,
        "400000 - 500000" => 0,
        "500000 - 1000000" => 0,
        ">1000000" =>  0
    }
    Declaration.where("vehicles" => {"$elemMatch" => {"brand.id" => @car.car_id}}, "main.year" => {"$gte" => 2016}).each do |declaration|
      incomes = Declaration.get_total_incomes(declaration).to_i
      next if incomes == 0
      if (0..100000).member?(incomes)
          @chart_data["0 - 100000"] += 1
      elsif (100000..200000).member?(incomes)
          @chart_data["100000 - 200000"] += 1
      elsif (200000..300000).member?(incomes)
          @chart_data["200000 - 300000"] += 1
      elsif (300000..400000).member?(incomes)
          @chart_data["300000 - 400000"] += 1
      elsif (400000..500000).member?(incomes)
          @chart_data["400000 - 500000"] += 1
      elsif (500000..1000000).member?(incomes)
          @chart_data["500000 - 1000000"] += 1
      elsif incomes > 1000000
          @chart_data[">1000000"] += 1
      else
        puts "ERROR with " + Declaration["main"]["person"]["name"]
      end
    end
    @poor_owner = Declaration.get_min_incoming_car_owner(@car)
    @poor_income = Declaration.get_total_incomes(@poor_owner).to_i
    @poor_year = @poor_owner["main.year"]
    @rich_owner = Declaration.get_max_incoming_car_owner(@car)
    @rich_income = Declaration.get_total_incomes(@rich_owner).to_i
    @rich_year = @rich_owner["main.year"]
    @average_price = @car["average_price"]
    @min_price = @car["min_price"]
    @max_price = @car["max_price"]
  end
  def redflag
    render json: Declaration.where("red_flag": true).any_of
  end
end