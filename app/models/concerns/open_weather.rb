require 'faraday'
module OpenWeather
  extend ActiveSupport::Concern

  class OpenWeatherQuery
    class << self
      def daily_forecast(params)
        Faraday.new('http://api.openweathermap.org/data/2.5/forecast/daily') do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          faraday.params["appid"] = OPENWEATHER_API_KEY
          faraday.params["units"] = "metric"
          faraday.params["cnt"] = 7
          faraday.params["mode"] = 'json'

          params.each_pair do |k,v|
            faraday.params[k] = v
          end
        end
      end
    end
  end

  included do 

    def weather
      Rails.cache.fetch("siteWeather|#{id}", expires_in: 3.hours ) do 
        JSON.parse(
          OpenWeatherQuery.daily_forecast(lat: latitude, lon: longitude).get.body
        )
      end
    end

    #{{{ heading_in_degrees
    def heading_in_degrees
      orientation.map do |o|
        if o.downcase == "n"
          0
        elsif o.downcase == "nne"
          22.5
        elsif o.downcase == "ne"
          45
        elsif o.downcase == "ene"
          67.5
        elsif o.downcase == "e"
          90
        elsif o.downcase == "ese"
          112.5
        elsif o.downcase == "se"
          135
        elsif o.downcase == "sse"
          157.5
        elsif o.downcase == "s"
          180
        elsif o.downcase == "sso" or o.downcase == "ssw"
          202.5
        elsif o.downcase == "so" or o.downcase == "sw"
          225
        elsif o.downcase == "oso" or o.downcase == "wsw"
          247.5
        elsif o.downcase == "o" or o.downcase == "w"
          270
        elsif o.downcase == "ono" or o.downcase == "wnw"
          292.5
        elsif o.downcase == "no" or o.downcase == "nw"
          315
        elsif o.downcase == "nno" or o.downcase == "nnw"
          337.5
        else
          nil
        end
      end
    end
    #}}}

    def weather_at(date_or_time=self.class.default_date)
      weather["list"].sort_by{|h| (h["dt"] - date_or_time.to_time.to_i).abs}.first
    end

    def flyable_at(date_or_time=self.class.default_date,max_wind_velocity=self.class.default_speed)
      heading_in_degrees.select do |deg|
        flyable_deco(date_or_time,deg,max_wind_velocity)
      end.any?
    end

    def flyable_details(date_or_time=self.class.default_date,max_speed = self.class.default_speed)
      orientation.zip(heading_in_degrees).map do |o,deg|
        {o => {
          face: face(date_or_time,deg),
          travers_in_kmh: (travers(date_or_time,deg) * 3.6).to_f.round,
          wind_speed_in_kmh: (force(date_or_time) * 3.6).to_f.round,
          wind_orientation_in_deg: (wind_at(date_or_time)[:deg]).to_f.round,
          rain_in_mm: rain(date_or_time).to_f.round(1),
        }
        }
      end.reduce(&:merge)
    end

    def travers(date_or_time, deco_angle_deg)
      wind = wind_at(date_or_time)
      (Math.sin( (deco_angle_deg - wind[:deg]).to_f*Math::PI/180.0) * wind[:speed]).abs
    end

    def face(date_or_time,deco_angle_deg)
      wind = wind_at(date_or_time)
      Math.cos((deco_angle_deg - wind[:deg]).to_f*Math::PI/180.0 ) > 0
    end

    def force(date_or_time)
      wind_at(date_or_time)[:speed]
    end

    def rain(date_or_time)
      weather_at(date_or_time)["rain"]
    end

    private

    def flyable_deco(date_or_time,deco_angle_deg,max_wind_velocity)
      [
        travers(date_or_time,deco_angle_deg) <= 5.0/3.6, # 5km/h de travers max
        face(date_or_time,deco_angle_deg),
        force(date_or_time) <= max_wind_velocity,
        rain(date_or_time).to_f <= 1.4 # 1.4mm of rain
      ].reduce(:&)
    end

    def wind_at(date_or_time)
      {
        deg:  (weather_at(date_or_time)["deg"] ) % 360,
        speed:  weather_at(date_or_time)["speed"],
      }
    end

  end

  module ClassMethods

    def default_speed
      35/3.6
    end

    def default_date
      Time.now
    end

  end

end
