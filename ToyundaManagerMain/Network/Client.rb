
# Represente une connexion de type Client se connectant à un Serveur
# =============================================================================

# =============================================================================
require $root+"Tools/Tools"
require $root+"Network/Socket"

# =============================================================================

module Network
  class Client < Socket
    include Tools::Logger
    
    public
    
    def initialize()
      super()
    end

    # ouvre une connexion avec le serveur donné
    # pHost : l'adresse du serveur
    # pPort : le port sur lequel se fait la connexion
    # return : true si la connexion est ouvert
    def connect(pHost, pPort)
      begin
        @socket = TCPSocket.new(pHost, pPort)
        @isOpen = true
        return true
      rescue Errno::EBADF => err
        return false
      end
    end
    
    
  end

end