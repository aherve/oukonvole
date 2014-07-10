d = Date.new(2014,7,15)
Site.where(type: "Décollage").where(pratique: /D/).lazy.select{|s| s.flyable_at(d)}.each{|s|
  ap "#{s.name} - #{s.commune} (#{s.departement})"
  #puts s.id
  ap s.flyable_details(d) 
  puts ""
}
