
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
# Model for the Karaoke object
# ==========================================================

puts "require Karaoke"

# ----------------------------------------------------------
require $root+ "Common.rb"
require $root+ "constants/CstsKaraoke"
# ----------------------------------------------------------

puts "++ Karaoke"

module Application
  
  class Karaoke
    include Common
    include CstsKaraoke
    
    attr_accessor :map
    
    # =================================
    public
    # ---------------------------------
    def initialize()
      @map = Hash.new
    end
    
    # ---------------------------------
    # return the config value for pId
    def [](pId)
      return @map[pId]
    end
    
    # ---------------------------------
    # return the config value for pId
    def []=(pKey, pValue)
      if isNumber(pValue)
        @map[pKey] = pValue.to_i
      else
        @map[pKey] = pValue
      end
    end

		# set the ini property
		def ini=(pIni)
			@map[K_INI] = @ini
		end

    # return the ini property
    def ini
      return @map[K_INI]
    end

		#~ # set the id property
		#~ def id=(pNewId)
      #~ if pNewId.nil?
        #~ @map[K_ID] = nil
      #~ elsif pNewId.to_s =~ /^\s*$/
        #~ @map[K_ID] = nil
      #~ else
        #~ id = pNewId.to_i
        #~ @map[K_ID] = id
      #~ end
		#~ end

    #~ # return the id property
    #~ def id
      #~ return @map[K_ID]
    #~ end

		# set the length property
		def length=(pValue)
			value = pValue.to_i
			@map[K_LENGTH] = value
		end

    # return the length property
    def length
      return @map[K_LENGTH]
    end
    
    # ---------------------------------
    # execute the given action with each key and value of this karaoke
    def each(&action)
			@map.each{ |bKey, bValue|
		 		action.call(bKey, bValue)
		 	}
		end
    
    # ---------------------------------
    # return the config value for pId 
    def getValues(listColumn)
      values = Array.new
      listColumn.each { |column|
        values << @map[column]
      }
      return values
    end
    
    # ---------------------------------
    # return column for this karaoke
    def getColumns()
      return @map.keys
    end
    
    # ---------------------------------
    # default string conversion
    def to_s()
      return @map[K_FULL_TITLE].to_s
    	#~ id = @map[K_ID]
    	#~ id = "X" if id.nil?
      #~ return "["+id.to_s+"] "+@map[K_FULL_TITLE].to_s
    end
    
    # =================================
    private
    # ---------------------------------

    # test if the given value is a number
    def isNumber(pValue)
      return false if pValue.nil?
      return pValue.to_s === pValue.to_i.to_s
    end

  end
end

puts "-- Karaoke"
