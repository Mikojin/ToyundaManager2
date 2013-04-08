
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2010/02/20 
# Last version : 2010/02/20 
# ==========================================================
# Client Manager MIO
# ==========================================================
# Description :
# Manage the server connection with the client.
# Handle the protocole.
# ==========================================================

puts "require ServerMIO"

# ----------------------------------------------------------
require 'fileutils'
require $root+"Common"
require $root+"Tools/tools"
require $root+"Network/Network"
require $root+ "constants/CstsKaraoke"

# ----------------------------------------------------------

puts "++ ServerMIO"

module Application

	module ProtocolMIO
		GET_DATABASE = 'GET_DATABASE'
		SEND_WISHLIST = 'SEND_WISHLIST'
		END_LIST = 'END_LIST'
		QUIT = 'QUIT'
  end
	
  # The Glade class that load the profile selector UI
  class ClientManagerMIO
    include Tools::Logger

		attr_reader :id, :socketClient
		
		def initialize(pToyundaManager, pId, pSocketClient)
			@id = pId
			@socketClient = pSocketClient
			@toyundaManager = pToyundaManager
		end
		
		def mainLoop()
			begin
				while command = @socketClient.socket.gets()
					command.chomp!
					log("#{@id} > command : "+command) {
						case command
						when ProtocolMIO::GET_DATABASE
							doSendDatabase()
						when ProtocolMIO::SEND_WISHLIST
							doGetWishlist()
						when ProtocolMIO::QUIT
							break;
						else
							log("#{@id} > command unknown")
						end
					}
				end
			ensure
				log("#{@id} > quit mainloop")
			end
		end
		
		# ====================
		private
		
		def doSendDatabase()
			log("#{@id} > send database") {
				pKaraokeList = @toyundaManager.getFilteredList()
				pKaraokeList.each { |bKaraoke|
					title = bKaraoke[CstsKaraoke::K_FULL_TITLE]
					log("#{@id} > sending : "+title)					
					@socketClient.socket.puts(title)
				}
				@socketClient.socket.puts(ProtocolMIO::END_LIST)
			}
		end
		
		def doGetWishlist()
			log("#{@id} > get wishlist") {
				wishlist = Array.new
				while true
					title = @socketClient.socket.gets()
					break unless title
					title.chomp!
					if ProtocolMIO::END_LIST == title
						log("#{@id} > end list")
						pushWishlist(wishlist)
						break
					else
						log("#{@id} > add : "+title)
						karaoke = @toyundaManager.getFilteredList().getByIni(title+'.ini')
						wishlist << karaoke if karaoke
					end
				end
			}
		end
		
		def pushWishlist(pWishlist)
			log("#{@id} > push wishlist") {
				@toyundaManager.gui.getPlaylistManagerGUI().pushCurrentPlaylist(pWishlist)
			}
		end
  end
end
puts "-- ServerMIO"
