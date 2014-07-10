class Site
  include Mongoid::Document
  include OpenWeather

  ### ffvl attributes
  field :ffvl_id
  field :name
  field :latitude
#  field :longitude
#  field :altitude
  field :type
  field :departement
  field :orientation, type: Array
  field :pratique
  field :site_id
  field :site_cp
  field :commune
  field :site_structure_name
  field :site_structure_url
  field :site_url
  field :description

  field :location, type: Array

  field :geo_near_distance

  index({ location: "2d"})

  def latitude
    location.last
  end

  def longitude
    location.first
  end

end
