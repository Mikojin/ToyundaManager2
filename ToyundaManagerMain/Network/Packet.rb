
require $root+"Network/PacketFactory"

require $root+"Tools/Tools"

# Représente un Packet envoyer par le reseau

# =================================================================================================
module Network

  class Packet
    include Tools::Logger
    
    private
    ID_RAW = 0
    F_RAW = "a*"

    public
    attr_accessor :data
    
    def initialize()
      @data = nil
    end
    
    def deserialize(dataStr)
      @data = dataStr.unpack(self.format())
    end
    
    def serialize()
      return nil if @data.nil?
      return @data.pack(self.format())
    end
    
    # a deriver
    def format
      return F_RAW
    end
    
    # a deriver
    def id
      return ID_RAW
    end

    # a deriver
    def self._format
      return F_RAW
    end
    
    # a deriver
    def self._id
      return ID_RAW
    end


  end
  
  PacketFactory.add(Packet)

=begin




  # =================================================================================================
  class PacketNewPlayer < Packet
    FORMAT = "C"
    def initialize(orig, id = nil)
      super(orig, NEW_PLAYER, FORMAT)
      return if id.nil?
      @data = [id]
    end
  end

  # =================================================================================================
  class PacketPlayer < Packet
    def initialize(orig, id, format)
      super(orig, id, format)
    end
  end

  # =================================================================================================
  class PacketPlayerState < PacketPlayer
    F_STATE = "f*"
    def initialize(orig, player = nil)
      super(orig, STATE, F_STATE)
      return if player.nil?
      @data = [
        player.cframe.translation[0],
        player.cframe.translation[1],
        player.cframe.translation[2],
        player.vectVitesse[0],
        player.vectVitesse[1],
        player.vectVitesse[2],
        player.angle,
        player.vitesseRotation,
      ]
    end
  end

  # =================================================================================================
  class PacketPlayerAction < PacketPlayer
    F_ACTION = "C*"
    def initialize(orig, player = nil)
      super(orig, ACTION, F_ACTION)
      return if player.nil?
      @data = player.actionListToSend
    end
  end
=end

end