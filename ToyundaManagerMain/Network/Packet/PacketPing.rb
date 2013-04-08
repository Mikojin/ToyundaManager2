
require $root+"Network/PacketFactory"
require $root+"Network/Packet"

module Network

  # =================================================================================================
  class PacketPing < Packet
    ID_PING = 1
    F_PING = "f*"
    
    # t doit être un floatant ou un liste de floatant
    def initialize(t = nil)
      super()
      return if t.nil?
      if t.kind_of?(Array)
        @data = t
      else
        @data = [t]
      end
    end
    def format()
      F_PING
    end
    def id()
      ID_PING
    end
    
    def self._format()
      F_PING
    end
    def self._id()
      ID_PING
    end

  end

  PacketFactory.add(PacketPing)


end