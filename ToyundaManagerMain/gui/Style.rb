# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/10 
# Last version : 2007/10/10
# ==========================================================
# Style and Style Manager class
# ==========================================================
# Description :
# A Style define the font, color background and foreground
# for an element, cell or label of the application
# A Manager let you set and get style easyly
# ==========================================================

puts "require Style"

# ----------------------------------------------------------
require 'gtk2'
require $root+ "gui/GUI"
require $root+ "Common"
# ----------------------------------------------------------

puts "++ Style"


module GUI
  
  class Style
    include Common
    
    DEFAULT_HL_VALUE = -4000
    DEFAULT_COLOR_FOREGROUND = "#000000"
    DEFAULT_COLOR_BACKGROUND = "#F0F0FF"
    DEFAULT_FONT = "normal"
    
    NAME = "name"
    FONT = "font"
    FOREGROUND = "foreground"
    BACKGROUND = "background"
    HIGHLIGHT = "highlight"

    
    attr_reader :map
    #~ :selectedBackground,
    def initialize(pName, pFont=nil, pForeground=nil, pBackground=nil, pHLValue=nil)
      set_debug_lvl(25)
      @map = {
        NAME => pName
      }
      self.font = pFont
      self.foreground = pForeground
      self.background = pBackground
      self.highlightValue = pHLValue
    end
    
    def name
      return @map[NAME]
    end
    
    #~ def name=(pName)
      #~ @map[NAME] = pName
    #~ end
    
    def font
      return @map[FONT]
    end
    
    # set the given font for this style, if nil, then set the default font
    def font=(pFont = nil)
      if pFont
        @map[FONT] = pFont
      else
        @map[FONT] = DEFAULT_FONT
      end      
    end

    def foreground
      return @map[FOREGROUND]
    end
    
    # set the foreground color with the given color (#RRGGBB)
    def foreground=(pForeground)
      @map[FOREGROUND] = getColor(pForeground, DEFAULT_COLOR_FOREGROUND)
    end

    def background
      return @map[BACKGROUND]
    end

    # set the background color with the given color (#RRGGBB)
    def background=(pBackground)
      @map[BACKGROUND] = getColor(pBackground, DEFAULT_COLOR_BACKGROUND)
    end

    def highlightValue
      return @map[HIGHLIGHT]
    end
    
    # set the highlight value of his style
    def highlightValue=(pHLValue = nil)
      if pHLValue
        @map[HIGHLIGHT] = pHLValue.to_i
      else
        @map[HIGHLIGHT] = DEFAULT_HL_VALUE
      end      
    end
  
    # replace this style's data by those of the given style
    def replace(pStyle)
      pStyle.map.each { |k, v|
        @map[k] = v
      }
    end
    
    # get the color, parse or convert it before
    def getColor(pColor, pDefault)
      log("set color : #{pColor.class}") {
        begin
          if pColor.class == String 
            log("string : #{pColor}")
            return Gdk::Color.parse(pColor)
          elsif pColor.class == Array
            log("Array : #{pColor.join(', ')}")
            return Gdk::Color.new(*pColor)
          elsif pColor.class == Gdk::Color
            log("Color : #{pColor.to_a.join(', ')}")
            return pColor
          else
            log("default")
            return Gdk::Color.parse(pDefault)
          end
        rescue Exception => except
          log("error => default : #{pDefault}")
          logException(except)
          return Gdk::Color.parse(pDefault)
        end
      }
    end

    def to_s()
      return @name
    end

  end
  
  # ==========================================================
  # ==========================================================

  # style manager
  class StyleManager
    include Common
    DEFAULT = "Default"
    SELECTED = "Selected"
    DEFAULT_SELECTED_COLOR_BACKGROUND = "#FFE0E0"
    FORBIDDEN_DELETE = {DEFAULT => true, SELECTED => true}
    
    attr_reader :default, :selected
    
    def initialize()
      @map = {}
      @default = Style.new(DEFAULT)
      @selected = Style.new(SELECTED, nil, nil, DEFAULT_SELECTED_COLOR_BACKGROUND)
      clear()
    end
  
    def clear()
      @map.clear()
      add(@default)
      add(@selected)
    end

    # add or replace a style to the style manager
    def add(pStyle)
      unless @map.include?(pStyle.name)
        log "adding #{pStyle.name}"
        @map[pStyle.name] = pStyle
      else
        log "updating #{pStyle.name}"
        style = @map[pStyle.name]
        style.replace(pStyle)
      end
    end
    
    alias :<< :add
    
    def [](pName)
      #~ unless @map.include?(pStyle.name)
      return @map[pName]
      #~ style = @map[pName]
      #~ return style if style
      #~ log("style unknown : "+pName)
      #~ return @map[DEFAULT]
    end
    
    def exist?(pName)
      return true if @map[pName]
      return false
    end
    
    def delete(pName)
      return false if FORBIDDEN_DELETE.include?(pName)
      @map.delete(pName) 
      return true
    end
    
    def getNameList()
      return @map.keys.sort
    end
    
    def each(&action)
      @map.each { |bK, bV|
        action.call(bK, bV)
      }
    end
    
  end
  
end

puts "-- Style"

