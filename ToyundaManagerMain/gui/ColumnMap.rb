# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/10 
# Last version : 2007/10/10
# ==========================================================
# Table Column class
# ==========================================================
# Description :
# Class that describe a Column of a TreeView (Table)
# It's able to display elements of a list of map.
# each column display one element of a map
# ==========================================================

puts "require ColumnMap"

# ----------------------------------------------------------
require $root+ "gui/ColumnGeneric"
# ----------------------------------------------------------

puts "++ ColumnMap"

module GUI
  
  class ColumnMap < ColumnGeneric
    
    attr_reader :key
    
    def initialize(pKey, pTitle=nil)
      @key = pKey
      if pTitle.nil?
        super(pKey)
      else
        super(pTitle)
      end
    end
    
    #==============================
    protected
    #==============================
    
    # return the default display function
    # may be overriden
    def getDefaultDisplayFuncion()
      return proc { |bObject|
        s = ''
        if bObject
          begin
            v = bObject[@key]
            s = v.to_s if v
          rescue
            s = ''
          end
        end       
        s
      }
    end

    #~ def getDisplayString(pElement)
      #~ return '' if pElement.nil?
      #~ v = pElement[@key]
      #~ return '' if v.nil?
      #~ return v.to_s
    #~ end
    
  end

end

puts "-- ColumnMap"
