
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Context for rules of an update
# ==========================================================
# Description :
# Contain data needed to evaluate rules for an update
# ==========================================================

puts "require ContextRules"

# ----------------------------------------------------------
require $root+ "Common"
# ----------------------------------------------------------

puts "++ ContextRules"

module Application

  class ContextRules
    include Common
    attr_accessor :globalList, :playlist, :currentKaraoke
    attr_writer :totalUsedTitle
    
    # =================================
    public
    # ---------------------------------
    # Constructor
    def initialize()
    end

    # get the total used title
    def totalUsedTitle
      if @totalUsedTitle.nil?
        @totalUsedTitle = 0
      end
      return @totalUsedTitle
    end

    # get the value of the current karaoke for the given key
    def [](pKey)
      return nil if @currentKaraoke.nil?
      return @currentKaraoke[pKey]
    end

    def []=(pKey, pValue)
      return if @currentKaraoke.nil?
      @currentKaraoke[pKey] = pValue
    end
    
    # call the given action on each element of the global list
    def each(&pAction)
      @globalList.each { |bKaraoke|
        @currentKaraoke = bKaraoke
        pAction.call(self)
      }
    end
    
    def isPlaylist?()
      return false if @currentKaraoke.nil?
      return @playlist.contains(@currentKaraoke)
    end
    
  end
end
puts "-- ContextRules"
