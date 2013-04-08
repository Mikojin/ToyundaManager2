

require $root+"Network/PacketFactory"
require $root+"Network/Packet"
require $root+"Tools/FileHelper"


# chargement des packets
Dir.chdir(File.dirname(__FILE__)) {
  Dir["Packet/*.rb"].each { |f|
    load f
  }
}
