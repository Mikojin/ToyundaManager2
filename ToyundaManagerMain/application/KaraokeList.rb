
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/14 
# Last version : 2007/05/14
# ==========================================================
# Karaoke
# ==========================================================
# Description :
# Model for the Karaoke List object
# ==========================================================

puts "require KaraokeList"

# ----------------------------------------------------------
require $root+ "Common"
# ----------------------------------------------------------

puts "++ KaraokeList"

module Application
  
  class KaraokeList
    include Common
    
    attr_writer :columns
    
    # =================================
    public
    # ---------------------------------
    def initialize()
      @list = Array.new
      @mapIni = Hash.new
      #~ @mapId = Hash.new
      #~ @idMax = -1
    end
    
    # ---------------------------------
    # return the ieme element
    def [](pIndex)
      return @list[pIndex]
    end
    
    # ---------------------------------
    # return the karaoke with the given pIni as key 
    def getByIni(pIni)
    	return @mapIni[pIni]
  	end
    
    #~ # ---------------------------------
    #~ # return the karaoke with the given id pIdKaraoke as key 
    #~ def getById(pIdKaraoke)
    	#~ return @mapId[pIdKaraoke]
  	#~ end

    # ---------------------------------
    # add a karaoke to the list
    def <<(pKaraoke)
    	iniKaraoke = pKaraoke.ini
    	@mapIni[iniKaraoke] = pKaraoke
    	
    	#~ idKaraoke = pKaraoke.id
    	#~ unless idKaraoke.nil?
    		#~ @idMax = idKaraoke if @idMax < idKaraoke
    		#~ @mapId[idKaraoke] = pKaraoke
    	#~ end
      return @list << pKaraoke
    end
    
    # ---------------------------------
    # test if this list contains the given karaoke 
		def contains(pKaraoke)
      return false if pKaraoke.nil?
      karaoke = getByIni(pKaraoke.ini)
      return !karaoke.nil?
    end

    #~ # ---------------------------------
    #~ # update the Id in this list.
    #~ # karaoke without id will be given an id from idMax
    #~ # return the list of karaoke with new id
		#~ def updateId()
			#~ log("updating id") {
        #~ newList = Array.new
        #~ @list.each { |bKaraoke|
          #~ if bKaraoke.id.nil?
            #~ @idMax = @idMax + 1
            #~ bKaraoke.id = @idMax
            #~ log(bKaraoke.to_s)
            #~ @mapId[@idMax] = bKaraoke
            #~ newList << bKaraoke
          #~ end
        #~ }
        #~ return newList
      #~ }
		#~ end

    # ---------------------------------
    # return columns for the first karaoke
    def getColumns()
      return @columns if @columns
      if @list and @list.size > 0
        columnMap = Hash.new
        @columns = Array.new
        @list.each { |bKaraoke|
          bKaraoke.getColumns().each { |bColumn|
            unless columnMap.key?(bColumn)
              @columns << bColumn
              columnMap[bColumn] = bColumn
            end
          }
        }
      end
      return @columns
    end

		# return the size of this karaokeList
		def size()
	 		return @list.size
	 	end

    def sort!(pColumn = nil)
      @list.sort! { |e1, e2|
        dif = nil
        if pColumn
          dif = (e1[pColumn] <=> e2[pColumn])
        else
          dif = (e1.ini <=> e2.ini)
        end
        dif
      }
    end

		# execute the given action for each karaoke of this list
		def each(&action)
			@list.each{ |bKaraoke|
		 		action.call(bKaraoke)
		 	}
		end
    
    # execute the given action for each ini and karaoke of this list
    def eachIni(&action)
			@mapIni.each{ |bIni, bKaraoke|
		 		action.call(bIni, bKaraoke)
		 	}
		end
    
    # return an Array copy of the list in this karaokeList 
    def getCopyList()
      copyList = Array.new
      copyList.replace(@list)
      return copyList
    end
    
    # return a copy of this karaokeList
    def getCopy()
      copyKaraokeList = KaraokeList.new()
      self.each { |bKaraoke|
        copyKaraokeList << bKaraoke
      }
      return copyKaraokeList
    end
    
    # remove the given karaoke from this list
    # remove all duplicate value of this karaoke
    def remove(pKaraoke)
    	@list.delete(pKaraoke)
    	#~ @mapId.delete(pKaraoke.id)
    	@mapIni.delete(pKaraoke.ini)
  	end
    
    # remove all element in the given list
    def removeAll(karaokeList)
      return if karaokeList.nil?
      karaokeList.each { |bKaraoke|
        remove(bKaraoke)
      }
    end
    
    # remove the karaoke at the given index position
    # don't remove duplicate values
    def delete_at(pIndex)
  		karaoke = @list.delete_at(pIndex)
  		unless @list.include?(karaoke)
    		#~ @mapId.delete(karaoke.id)
	  		@mapIni.delete(karaoke.ini)
  		end
  	end
    
    # clear the content of this list
    def clear()
    	@list.clear
    	#~ @mapId.clear
    	@mapIni.clear
  	end
    
    # =================================
    private
    # ---------------------------------

  end
end

puts "-- KaraokeList"
