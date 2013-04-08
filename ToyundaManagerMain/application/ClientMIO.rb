
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
require $root+"Tools/tools"
require $root+"Network/Network"

# ----------------------------------------------------------

puts "++ ClientMIO"

module Application

  module CstMIO
    PORT = 'ServerMIO.port'
  end

	module ProtocolMIO
		GET_DATABASE = 'GET_DATABASE'
		SEND_WISHLIST = 'SEND_WISHLIST'
		END_LIST = 'END_LIST'
		QUIT = 'QUIT'
  end

	
  # The Glade class that load the profile selector UI
  class ClientMIO
    include Tools::Logger
		
		# attr_reader :toyundaManager, :config
		attr_accessor :port
		
		def initialize()
			config_file = "clientMIO.csv"
			@config = Tools::Config.new(config_file)
			Tools::Logger.configure(@config)
			log("MIO config file = "+config_file)
			@port = @config.to_i(CstMIO::PORT)
			@client = Network::Client.new()
		end
		
		def startDatabase()
			log("connect to server MIO")
			@client.connect("localhost", @port)
			sleep(2)
			log("get database") {
				doGetDatabase()
			}
			@client.socket.puts(ProtocolMIO::QUIT)
			@client.close
		end
		def startWishlist()
			log("connect to server MIO")
			@client.connect("localhost", @port)
			sleep(2)
			log("send wishlist") {
				doSendWishlist()
			}
			@client.socket.puts(ProtocolMIO::QUIT)
			@client.close
		end
		
		# ====================
		private
		
		def doGetDatabase()
			@client.socket.puts(ProtocolMIO::GET_DATABASE)
			@database = Array.new
			log("begin get database loop")
			while true 
					break unless @client.isOpen()
					title = @client.socket.gets()
					break unless title
					title.chomp!
					if ProtocolMIO::END_LIST == title
						log("end list")
						break
					else
						log("add : "+title)
						@database << title
					end
			end
		end
		
		def doSendWishlist()
			@client.socket.puts(ProtocolMIO::SEND_WISHLIST)
			wishlist = getWishlist()
			wishlist.each { |bTitle|
				log("send : "+bTitle)
				@client.socket.puts(bTitle)
			}
			@client.socket.puts(ProtocolMIO::END_LIST)
		end
		
		def getWishlist()
			map = Hash.new
			wishlist = Array.new
			log("build wishlist") {
				10.times {
					r = nil
					begin
						r = rand(@database.size)
					end while map[r]
					title = @database[r]
					log("pick : #{title}")
					map[r] = title
					wishlist << title
				}
			}
			wishlist
		end
  end
end
puts "-- ClientMIO"


client = Application::ClientMIO.new
client.startDatabase()
sleep(10)
client.startWishlist()
