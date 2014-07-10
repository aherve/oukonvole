Site.delete_all

File.open('./db/sites.csv').each_line do |l|
  ll = l.chomp.split(";").map(&:strip)
  s = Site.new(
  :ffvl_id              => ll[0],
  :name                 => ll[1],
  :latitude             => ll[2],
  :longitude            => ll[3],
  :altitude             => ll[4],
  :type                 => ll[5],
  :departement          => ll[6],
  :orientation          => ll[7].split(","),
  :pratique             => ll[8],
  :site_id              => ll[9],
  :site_cp              => ll[10],
  :commune              => ll[11],
  :site_structure_name  => ll[12],
  :site_structure_url   => ll[13],
  :site_url             => ll[14],
  :description          => ll[15],
  )
  puts s.name if s.save
end
