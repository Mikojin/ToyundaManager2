
# Classe permettant la communication client / serveur via un protocol utilisant les objets type Packet
# Elle représente un canal de communication entre 2 machines.
# =============================================================================

# =============================================================================
require $root+"Tools/Tools"
require $root+"Network/IniPacket"


# =============================================================================

module Network
  class Socket
    include Tools::Logger
    
    HEADER_SIZE = 2
    PACKET_HEADER = "CC"
    PACKET_ID = 0
    PACKET_SIZE = 1

    public
    attr_reader :isOpen, :socket
    
    def initialize(socket = nil)
      @socket = socket
      @isOpen = !socket.nil?
    end
    
    # lit un packet sur le socket
    def read()
      #~ log("read") {
        header = readHeader()
        return nil unless header
        #~ log "header = #{header.join(', ')}"
        id = header[PACKET_ID]
        size = header[PACKET_SIZE]
        data = readData(size)
        
        if data.nil? or data.size < size
          log "data manquante : #{id} #{size}"
          return nil
        end
        packet = PacketFactory.instance.create(id)
        packet.deserialize(data)
        return packet
      #~ }
    end
    
    # ecrit la liste de packet donné sur le socket
    def write(packetList)
      msg = ""
      packetList.each { |packet|
        packetStr = serialize(packet)
        msg += packetStr unless packetStr.nil?
      }
      return if msg.empty?
      @socket.write(msg) 
    end
    
    # flush the data waiting on the socket
    def flush()
      @socket.flush
    end
    
    # ferme le socket
    def close()
      @isOpen = false
      @socket.close()
    end
    
    #==============================================================
    private
    
    # lis une quantité de donné sur le reseau
    def readData(dataSize)
      begin
        return @socket.recv_nonblock(dataSize)
      rescue
        return nil
      end
    end
    
    # renvoie le header du packet lu sur le socket
    def readHeader()
      msg = readData(HEADER_SIZE)
      return nil if msg.nil? or msg.empty?

      header = msg.unpack(PACKET_HEADER)
      return header
    end
    
    # serialise le packet donné
    def serialize(pPacket)
      #~ log("serialize") {
        data = pPacket.serialize()
        return unless data
        id = pPacket.id()
        size = data.size()
        #~ log "id = #{id} ; size = #{size}"
        
        packetHeader = [
          id,
          size
        ].pack(PACKET_HEADER)
        
        return packetHeader + data
      #~ }
    end
    
  end

end