
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Column Selector GUI
# ==========================================================
# Description :
# Sub module for the Toyunda Manager GUI. Only contains
# callback for the Column selector (include in the ConfigManagerGUI)
# Uses methodes and attributs from the main class : 
# ToyundaManagerGUI
# ==========================================================

puts "require StyleEditorGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "gui/SubToyundaManagerGUI"
require $root+ "gui/Style"
require $root+ "helper/StyleService"

# ----------------------------------------------------------

puts "++ StyleEditorGUI"

module GUI

  class StyleEditorGUI < SubToyundaManagerGUI
    
    W_ENTRY_NEW_STYLE_NAME = 'entryNewStyleName'
    W_SELECT_STYLE = 'comboboxSelectStyle'
    #~ W_LABEL_STYLE_FONT = 'labelStyleFont'
    W_BUTTON_FONT = 'fontbuttonStyleFont'
    W_BUTTON_FOREGROUND = 'colorbuttonStyleForeground'
    W_BUTTON_BACKGROUND = 'colorbuttonStyleBackground'
    W_HIGHLIGHT_VALUE = 'spinbuttonStyleHighlight'
    
    attr_reader :styleManager, :model
    
    # =====================================
    # Initialize
    # =====================================
    
    # clear the config manager
    def clear()
    end
    
    # initialize the config manager
    def subInitialize()
      log("subInitialize") {
        iniStyleManager()
        iniStyleSelector()
        # set the current style as default
        selectCurrentStyle()
      }
    end

    # =====================================
    public
    # =====================================

    # callback for saving information about StyleEditorGUI
    def save()
      log("save"){
        # save the style manager
        fileName = @application.configManager.getStyleFileName()
        @styleService.save(fileName, @styleManager)
      }
    end
    
    # return the model iter for the given style name
    # return the default iter if the style name is incorrect
    def getIter(pStyleName)
      log("getIter : #{pStyleName}") {
        selectedIter = nil
        defaultIter = nil
        @model.each { |bModel, bPath, bIter|
          iterName = bIter[0]
          if iterName == pStyleName
            log("getIter : OK Found #{iterName}")
            selectedIter = bIter
          elsif iterName == StyleManager::DEFAULT
            log("getIter : OK Default #{iterName}")
            defaultIter = bIter
          else
            log("getIter : KO #{iterName}")
          end
        }
        return selectedIter if selectedIter
        return defaultIter if defaultIter
        log("getIter : style not found #{pStyleName}")
        return nil
      }
    end

    # get the style for the given name, default if the name is incorrect
    def getStyle(pStyleName)
      return @styleManager.default if pStyleName.nil?
      style = @styleManager[pStyleName]
      return style if style
      return @styleManager.default
    end

    # =====================================
    private
    # =====================================

    # initialize style manaegr
    def iniStyleManager()
      @styleService = StyleService.new()
      @styleManager = StyleManager.new()
      # load Style Manager
      fileName = @application.configManager.getStyleFileName()
      @styleService.load(fileName, @styleManager)
      # set the default style as current
      #~ setCurrentStyle()
    end

    # initialize style selector model
    def iniStyleSelector()
      log("iniStyleSelector") {
        #~ @glade[W_SELECT_STYLE] = Gtk::ComboBox.new(false)
        @model = Gtk::ListStore.new(String)
        @glade[W_SELECT_STYLE].model = @model
        @glade[W_SELECT_STYLE].text_column = 0
        updateStyleSelector()
      }
    end
    
    # update the style selector model
    def updateStyleSelector()
      log("updateStyleSelector") {
        @model.clear
        @styleManager.getNameList.each { |bStyleName|
          iter = @model.append()
          iter[0] = bStyleName
          log(bStyleName)
        }
      }
    end

    # add the given style name to the style manager
    # return false if this style name exists already
    def addStyle(pStyleName)
      return false if @styleManager.exist?(pStyleName)
      newStyle = Style.new(pStyleName)
      @styleManager << newStyle
      updateStyleSelector()
      selectCurrentStyle(pStyleName)
      return true
    end

    # set the current style to styleName and select it in the combobox
    def selectCurrentStyle(pStyleName=StyleManager::DEFAULT)
      log("selectCurrentStyle = "+pStyleName) {
        setCurrentStyle(pStyleName)
        selectedIter = getIter(@currentStyle.name)
        @noUpdate = true
        @glade[W_SELECT_STYLE].active_iter = selectedIter
        @noUpdate = false
      }
    end

    # set the current style and update display
    def setCurrentStyle(pStyleName=StyleManager::DEFAULT)
      log("setCurrentStyle") {
        newStyle = pStyleName
        if newStyle.nil? || @styleManager[newStyle].nil?
          log("Error New Current Style : "+(newStyle.nil? ? 'nil' : newStyle))
          newStyle = StyleManager::DEFAULT
        end
        log("New Current Style : "+newStyle)
        @currentStyle = @styleManager[newStyle]
        #~ @glade[W_LABEL_STYLE_FONT].font = @currentStyle.font
        @glade[W_BUTTON_FONT].font_name = @currentStyle.font
        @glade[W_BUTTON_FOREGROUND].color = @currentStyle.foreground
        @glade[W_BUTTON_BACKGROUND].color = @currentStyle.background
        @glade[W_HIGHLIGHT_VALUE].value = @currentStyle.highlightValue
      }
    end
    
    # =====================================
    # Callbacks
    # =====================================
    public
    
    def on_buttonAddStyle_clicked(*pArg)
      log("add style") {
        newStyleName = @glade[W_ENTRY_NEW_STYLE_NAME].text
        return if (newStyleName.nil?) or (newStyleName =~ /^\s*$/)
        log "Add Style : "+newStyleName
        unless addStyle(newStyleName)
          setError("Style", "Style '#{newStyleName}' already exists")
        end
      }
    end
    
    def on_buttonDeleteStyle_clicked(*pArg)
      log("Delete Style") {
        styleName = @glade[W_SELECT_STYLE].active_text
        ok = @styleManager.delete(styleName)
        if ok
          updateStyleSelector()
          selectCurrentStyle()
        else
          setError("Style", "Deleting style '#{styleName}' is forbidden")
        end
      }
    end
    
    def on_comboboxSelectStyle_changed(*pArg)
      return if @noUpdate
      log("style changed") {
        iter = @glade[W_SELECT_STYLE].active_iter
        if iter.nil?
          setCurrentStyle()
        else
          styleName = iter[0]
          log("active : "+styleName)
          setCurrentStyle(styleName)
        end
        #~ log active_item.class.to_s
        #~ log @glade[W_SELECT_STYLE].model.class.to_s
      }
    end
  
    def on_fontbuttonStyleFont_font_set(*pArg)
      #~ log "new font"
      @currentStyle.font = @glade[W_BUTTON_FONT].font_name
    end
  
    def on_colorbuttonStyleForeground_color_set(*pArg)
      #~ log "new foreground color"
      @currentStyle.foreground = @glade[W_BUTTON_FOREGROUND].color
    end
    
    def on_colorbuttonStyleBackground_color_set(*pArg)
      #~ log "new background color"
      @currentStyle.background = @glade[W_BUTTON_BACKGROUND].color
    end
  
    def on_spinbuttonStyleHighlight_changed(*pArg)
      #~ log "new highlight"
      @currentStyle.highlightValue = @glade[W_HIGHLIGHT_VALUE].value
    end
    
  end
end

puts "-- StyleEditorGUI"
