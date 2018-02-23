class CarsController < ActionController::Base

  def index
    @cars = Carbrand.order_by(:count => 'desc').limit(10)
    render 'cars/index'
  end

end