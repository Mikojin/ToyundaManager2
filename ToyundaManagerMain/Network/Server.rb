
# Classe permettant la communication client / serveur via un protocol utilisant les objets type Packet
# Elle représente un canal de communication entre 2 machines.
# =============================================================================

# =============================================================================
require $root+"Tools/Tools"
require $root+"Network/Socket"

# =============================================================================

module Network
  class Server 
    include Tools::Logger
    
    attr_reader :producer, :threadServer, :threadClientList, :socketClientList
    
    public
    
    def initialize(pMax = 10, pInter = 1)
      super()
      iniProducer(pMax, pInter)
    end

    # ouvre le serveur sur le port donné
    def open(pHost, pPort)
      @socket = TCPServer.new(pHost, pPort)
      @isOpen = true
    end
    
    # test si le serveur est ouvert
    def isOpen()
      return @isOpen
    end
    
    # demarre la bufferisation des connexion
		# &clientCallback(id, socket) : la fonction callback à appeler pour chaque client.
    def start(&clientCallback)
			log("server start")
			@producer.start()
			@clientCallback = clientCallback
			@threadServer = Thread.new(self) { |bServer|
				serverManager(bServer)
			}
    end
    
    # ferme le serveur
    def close()
      @producer.stop()
      @isOpen = false
      @socket.close()
			@threadServer.join
      # fermeture de tous les sockets dans le buffer
      until @producer.isEmpty
        socket = @producer.get
        begin 
          socket.close()
        rescue
        end
      end
    end
    

    private
    
    # accept une connexion d'un client
    # renvoi nil s'il n'y a pas de connexion
    def accept()
      network = nil
      begin
        network = @socket.accept_nonblock
      rescue Errno::EWOULDBLOCK => err
        return nil
      end
      return network
    end

    # initialise le producteur permettant de gerer les connexions en attente
    def iniProducer(pMax=10, pInterval=1)
      @producer = Tools::Producer.new(pMax, pInterval) {
				client = nil
        network = accept()
        if network
          client = Network::Socket.new(network)
          log "nouvelle connexion"
        #~ else
          #~ log "pas de connexion"
        end
        client
      }
    end

	# gestion du serveur
	# pServer : le server à gérer (self)
	def serverManager(pServer)
		id = 0
		threadClientList = Array.new
		socketClientList = Array.new
		while pServer.isOpen()
		  socketClient = pServer.producer.get
		  if socketClient
				log "creation de la callback. id : #{id}"
				threadClient = Thread.new(socketClient) { |bSocketClient|
					socketClientList << bSocketClient
					@clientCallback.call(id, bSocketClient)
				}
				threadClientList << threadClient
				id += 1
		  end
		  sleep(1)
		end
		socketClientList.each { |bSocketClient|
			begin
				bSocketClient.close()
			rescue
			end
		}
		threadClientList.each { |thr|
		  thr.join
		}
	end
	
  end

end