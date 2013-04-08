
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2010/02/20 
# Last version : 2010/02/20 
# ==========================================================
# Server MIO
# ==========================================================
# Description :
# Enable communication with the remote control "MIO".
# The server can :
# - send the current filtered list.
# - read a list of title to update the selected list
# ==========================================================

puts "require ServerMIO"

# ----------------------------------------------------------
require $root+"Common"
require $root+"constants/CstsConfigManager"
require $root+"application/ClientManagerMIO"
require $root+"Tools/tools"
require $root+"Network/Network"

# ----------------------------------------------------------

puts "++ ServerMIO"

module Application

  module CstMIO
    PORT = 'ServerMIO.port'
  end
	
  # The Glade class that load the profile selector UI
  class ServerMIO
    include Tools::Logger
		
		# attr_reader :toyundaManager, :config
		attr_accessor :port
		
		def initialize(pToyundaManager)
			@toyundaManager = pToyundaManager
			config_file = CstsConfigManager::CONFIG_PATH+"configMIO.csv"
			# @toyundaManager.configManager[CstsConfigManager::MIO_LOGGER]
			@config = Tools::Config.new(config_file)
			Tools::Logger.configure(@config)
			log("MIO config file = "+config_file)
			@port = @config.to_i(CstMIO::PORT)
			@server = Network::Server.new()
		end
		
		def start()
			log("start MIO")
			@server.open('localhost', @port)
			@server.start() { |bId, bClientSocket|
				clientManager = ClientManagerMIO.new(@toyundaManager, bId, bClientSocket)
				clientManager.mainLoop()
			}
		end
		
		def stop()
			log("stop MIO")
			@server.close()
		end
		
		
  end
end
puts "-- ServerMIO"
