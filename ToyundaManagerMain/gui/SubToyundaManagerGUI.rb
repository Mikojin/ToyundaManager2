
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Config Manager GUI
# ==========================================================
# Description :
# Generics Sub classes for the Toyunda Manager GUI. 
# every ToyundaManagerGUI dependant classes should inherit this class
# ==========================================================

puts "require SubToyundaManagerGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "Common"
# ----------------------------------------------------------

puts "++ SubToyundaManagerGUI"

module GUI

  class SubToyundaManagerGUI
    include Common
    
    # =====================================
    # Initialize
    # =====================================
    def initialize(pToyundaManagerGUI)
      # iniCommon()
      @application = pToyundaManagerGUI.application
      @glade = pToyundaManagerGUI.glade
      @toyundaManagerGUI = pToyundaManagerGUI
    end
    
    # reset the Sub GUI
    def reset()
      clear()
      subInitialize()
    end
    
    # clear the sub GUI
    def clear()
    end
    
    # save the configuration of this sub GUI, should be overridden
    def save()
    end
    
    # sub classe should override this methode to initialize themselves
    def subInitialize()
    end
    
    def setInfo(type, msg)
      @toyundaManagerGUI.setInfo(type, msg)
    end

    def setError(type, msg)
      @toyundaManagerGUI.setError(type, msg)
    end

    def getWindow()
      return @toyundaManagerGUI.getWindow()
    end
  end
end

puts "-- SubToyundaManagerGUI"

