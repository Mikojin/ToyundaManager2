# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/10 
# Last version : 2007/10/10
# ==========================================================
# Table Column Generic class
# ==========================================================
# Description :
# Class that describe a Column of a TreeView (Table)
# It's able to display generic elements calling to_s 
# method on each element.
# It's associated to a title name and a style
# optional functions can be added when edit, clic or active 
# element
# ==========================================================

puts "require ColumnGeneric"

# ----------------------------------------------------------
require 'gtk2'
require $root+ "gui/GUI"
require $root+ "gui/Style"
require $root+ "Common"
# ----------------------------------------------------------

puts "++ ColumnGeneric"

module GUI
  
  class ColumnGeneric
    include Common
    
    #~ DEFAULT_SELECTED_COLOR_BACKGROUND = "#FFE0E0"

    #~ STYLE_DEFAULT = Style.new("Default")
    #~ STYLE_SELECTED = Style.new("Selected", nil, nil, DEFAULT_SELECTED_COLOR_BACKGROUND)
    DEFAULT = 'DEFAULT'
    SELECTED = 'SELECTED'
    
    attr_reader :gtkColumn, :title, :style
    
    def initialize(pTitle)
      @title = pTitle
      @darker = 0
      @visible = true
      @displayFunction = getDefaultDisplayFuncion()
      iniRenderer()
      iniGtkColumn()
      @style = {  
      #~ DEFAULT => STYLE_DEFAULT, SELECTED => STYLE_SELECTED
      }
    end
    
    # this column is visible ?
    def visible?()
      return @gtkColumn.visible?
    end
    
    # set the visible property
    def visible=(bVisible)
      @gtkColumn.visible=bVisible
    end
    
    # this column is editable ?
    def editable?()
      return @renderer.editable?
    end
    
    # set the editable property
    def editable=(pEditable)
      @renderer.editable = pEditable
    end
    
    # get the default style for this column
    def styleDefault()
    	return @style[DEFAULT]
    end
    
    # set the default style for this column
    def styleDefault=(pStyle)
    	return if pStyle.nil?
      @style[DEFAULT] = pStyle
    end
    
    # get the default style for this column
    def styleSelected()
    	return @style[SELECTED]
    end
    
    # set the default style for this column
    def styleSelected=(pStyle)
    	return if pStyle.nil?
      @style[SELECTED] = pStyle
    end
    
		# set the selected function.
		# def: boolean selectedFunction(currentElement)
		def setSelectedFunc(pSelectedFunc)
			@selectedFunction = pSelectedFunc 
		end
    
    # set the clicked function
    # def: void clickedFunction(ColumnMap)
    def setClickedFunc(pClickedFunc)
      @clickedFunction = pClickedFunc
    end
    
    # set the edit function
    # def: void editFunction(ColumnMap,Path,Value)
    def setEditFunc(pFunc)
      @editFunction = pFunc
    end

    # set the display function
    # def: String displayFunction(currentElement)
    def setDisplayFunc(pFunc)
      @displayFunction = pFunc
    end

    # darken the background
    def darker(pValue = 1)
     	@darker = pValue
    end

    alias :darker= :darker

    # the title of this column
    def to_s()
      return @title
    end
    
    # hide / show this column
    def toggleDisplay()
      @gtkColumn.visible = !@gtkColumn.visible?
    end
    
    #==============================
    protected
    #==============================
    
    # return the default display function
    def getDefaultDisplayFuncion()
      return proc { |bObject|
        s = ''
        s = bObject.to_s if bObject
        s
      }
    end
    
    #~ # return the string to display the given element
    #~ #should be overriden
    #~ def getDisplayString(pElement)

      #~ return '' if pElement.nil?
      #~ return pElement.to_s
    #~ end
    
    #==============================
    private
    #==============================
    
    
    # initialize the render for this column
    def iniRenderer()
      @renderer = Gtk::CellRendererText.new
      
   		@renderer.signal_connect("edited") { |bRenderer, bPath, bValue|
        if @editFunction
          @editFunction.call(self, bPath, bValue)
        end
      }
    end
    
    # initialize the GTK Column for this column
    def iniGtkColumn()
      @gtkColumn = Gtk::TreeViewColumn.new(@title,@renderer)
      @gtkColumn.resizable = true
      # @gtkColumn.reorderable = true
      @gtkColumn.clickable = true
      @gtkColumn.sort_column_id = 0
      @gtkColumn.signal_connect("clicked") { |bColumn|
        @clickedFunction.call(self) unless @clickedFunction.nil?
      }
      @gtkColumn.set_cell_data_func(@renderer) { |bColumn, bRenderer, bModel, bRow|
      	element = bRow[0]
        applyStyle(bRenderer, element)
				bRenderer.text = @displayFunction.call(element)
			}
    end


    # apply the given style on the given renderer
    def applyStyle(pRenderer, pElement)
      style = nil
      if @selectedFunction != nil and @selectedFunction.call(pElement)
        style = @style[SELECTED]
      else
        style = @style[DEFAULT]
      end
      return unless style
      pRenderer.font = style.font
      pRenderer.foreground_gdk = style.foreground
      pRenderer.background_gdk = ColumnGeneric._darker(style.background, style.highlightValue * @darker)
    end

    
    #=============================================================
    # static methods
    #=============================================================
    
    # min between 2 values
    def ColumnGeneric._min(a,b)
      return a if a <= b
      return b
    end

    # max between 2 values
    def ColumnGeneric._max(a,b)
      return a if a >= b
      return b
    end

    # darken the given color with the given amount and return a new Gdk color
    def ColumnGeneric._darker(color, v=-4000)
      a = color.to_a
      0.upto(2) { |i|
        a[i] = ColumnGeneric._max(ColumnGeneric._min(a[i]+v,65535),0)
      }
      return Gdk::Color.new(*a)
    end

    
  end

end

puts "-- ColumnGeneric"
