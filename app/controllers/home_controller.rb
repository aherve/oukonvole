class HomeController < ApplicationController
  def index
    @latitude = params["latitude"].to_f 
    @longitude = params["longitude"].to_f 
    @max = (params["max_number_of_sites"] || 5).to_i

    @only_flyable = params["only_flyable"] || false

    @date = (params["date"] || Date.today).to_date
    @max_wind = (params["max_wind"] || 35).to_f
    @max_wind_ms = @max_wind/3.6

    @sites = Site.where(type: "Décollage").geo_near([@latitude,@longitude]).spherical.select{|s| s.flyable_at(@date,@max_wind_ms)}.take(@max)

    #@debug = params
  end
end
