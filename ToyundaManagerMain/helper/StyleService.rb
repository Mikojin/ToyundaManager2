
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/11/13 
# Last version : 2007/11/13
# ==========================================================
# Filter service class
# ==========================================================
# Description :
# Load / Save filter
# ==========================================================

puts "require StyleService"

# ----------------------------------------------------------
require 'csv'
require $root+ "Common"
require $root+ "gui/Style"

# ----------------------------------------------------------

puts "++ StyleService"

class StyleService
  include Common
  
  CSV_SEPARATOR = ";"
  COLOR_SEPARATOR = "|"

  NAME = "name"
  FONT = "font"
  FOREGROUND = "foreground"
  BACKGROUND = "background"
  HIGHLIGHT = "highlight"

  # ============================================================
	public
  # ============================================================
  
  def initialize()
    set_debug_lvl(7)
  end
  
  # save the given style manager into the given file
  def save(pFilename, pStyleManager)
		pListColumn = getStyleColumn()
  	return if pListColumn.nil?
    log("save columns : "+pListColumn.join(", "))
    CSV.open(pFilename, 'w', CSV_SEPARATOR) { |writer|
    	writer << pListColumn
      pStyleManager.each { |bName, bStyle|
        styleMap = styleToMap(bStyle)
        writer << getValues(styleMap, pListColumn)
      }
    }
  end

  # load the given file into the given file manager or create a new one
  def load(pFileName, pStyleManager = nil)
    log('loading Style from '+pFileName)
    styleManager = pStyleManager
    styleManager = createStyleManager() if styleManager.nil?
    unless File.exist?(pFileName)
    	log("Style file not found : "+pFileName)
    	return styleManager 
    end
    listColumn = nil
    CSV.open(pFileName, 'r', CSV_SEPARATOR) { |bRow|
    	if listColumn.nil?
    		listColumn = bRow 
    	else
      	style = createStyle(listColumn, bRow)
        styleManager << style
      end
    }
    return styleManager
  end
  
  # ============================================================
	private
  # ============================================================

  #create a style manager
  def createStyleManager()
    return GUI::StyleManager.new
  end

  # create a style using the given column list and value list
  def createStyle(pListColumn, pListValue)
    map = {}
    pListValue.each_index { |i|
      v = pListValue[i]
      k = pListColumn[i]
      if v and k
        map[k] = v
      else
        log "error creating style : k= #{k} ; v= #{v}"
      end
    }
    return mapToStyle(map)
  end

  # get the style columns
  def getStyleColumn()
    return @styleColumn if @styleColumn
    @styleColumn = [NAME, FONT, FOREGROUND,BACKGROUND, HIGHLIGHT]
  end

  # get values of the given map ordered by pListColumn keys,
  def getValues(pMap, pListColumn)
    arr = []
    pListColumn.each { |bName|
      arr << pMap[bName]
    }
    return arr
  end

  # convert a style to a map
  def styleToMap(pStyle)
    map = {
      NAME => pStyle.name,
      FONT => pStyle.font.to_s,
      FOREGROUND => pStyle.foreground.to_a.join(COLOR_SEPARATOR),
      BACKGROUND => pStyle.background.to_a.join(COLOR_SEPARATOR),
      HIGHLIGHT => pStyle.highlightValue.to_s
    }
    return map
  end

  # convert a map to a style
  def mapToStyle(pMap)
    name = pMap[NAME]
    font = pMap[FONT]
    foreground = pMap[FOREGROUND].split(COLOR_SEPARATOR).map! { |v| v.to_i}
    background = pMap[BACKGROUND].split(COLOR_SEPARATOR).map! { |v| v.to_i}
    highlight = pMap[HIGHLIGHT]
    return GUI::Style.new(name, font, foreground, background, highlight)
  end

  
end

puts "-- StyleService"
