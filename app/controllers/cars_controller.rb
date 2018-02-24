class CarsController < ActionController::Base
  def index
    @cars = Carbrand.order_by(:count => 'desc').limit(10)
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
    Declaration.where("vehicles" => {"$elemMatch" => {"brand.id" => @car.car_id}}).each do |declaration|
      incomes = Declaration.get_total_incomes(declaration)
      next if incomes == 0
      case incomes
        when 0..100000
          @chart_data["0 - 100000"] += 1
        when 100000..200000
          @chart_data["100000 - 200000"] += 1
        when 200000..300000
          @chart_data["200000 - 300000"] += 1
        when 300000..400000
          @chart_data["300000 - 400000"] += 1
        when 400000..500000
          @chart_data["400000 - 500000"] += 1
        when 500000..1000000
          @chart_data["500000 - 1000000"] += 1
        when incomes > 1000000
          @chart_data[">1000000"] += 1
        else
          puts "Error charting"
      end
    end
  end

end