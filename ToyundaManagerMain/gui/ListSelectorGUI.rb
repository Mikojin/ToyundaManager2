
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 1.0
# Create : 2007/05/10 
# Last version : 2007/05/13 
# ==========================================================
# List Selector GUI
# ==========================================================
# Description :
# GUI for selecting multiple elements from a list
# Require libglade2 to work.
# ==========================================================

puts "require ListSelectorGUI"

# ----------------------------------------------------------
require 'gtk2'

require $root+ "gui/GUI"
require $root+ "Common"
require $root+ "glade/GladeLoader"
require $root+ "gui/Style"
require $root+ "gui/ColumnGeneric"

# ----------------------------------------------------------

puts "++ ListSelectorGUI"

module GUI

  # The Glade class that load the profile selector UI
  class ListSelectorGUI
    include Common
    include GladeLoader

    # =================================
    # Constants
    # ---------------------------------
    GLADE_FILE = $root + "glade/ListSelector"
    W_WINDOW = "windowSelector"
    W_VIEW = "treeviewSelector"
    W_LABEL_SELECTED = "labelLegendSelected"
    W_LABEL_DEFAULT = "labelLegendDefault"
    W_TITLE = "labelTitle"
    
    TITLE_PREFIXE = '<span size="13000" foreground="#C00000"><b>'
    TITLE_SUFFIXE = '</b></span>'
    
    # =================================
    public
    # ---------------------------------
    # constructor
    # pParent : parent window widget for this ListSelector
    def initialize(pParent=nil)
      log("initialize") {
        iniGlade(GLADE_FILE)
        @mapSelected = Hash.new
        iniFunc()
        iniWindow(pParent)
        iniModel()
        iniView()      
      }
    end

    # popup this ListSelector for the given List
    # action onSelection(pListIn, pSelectedList) will be called on validation
    def select(pList, &onSelection)
      @onSelection = onSelection
      @list = pList
      @mapSelected.clear
      prepareView()
      show()
    end

    def setTitle(pTitle)
      @glade[W_TITLE].markup = TITLE_PREFIXE+pTitle+TITLE_SUFFIXE
    end

    # action(pListObj)=>String : action used to display object from the list
    def setDisplayFunc(&action)
      @displayFunc = action
    end
    
    def setStyleManager(pStyleManager)
      @styleManager = pStyleManager
    end
  
    # =================================
    private
    # ---------------------------------

    def show()
      GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_DEFAULT], @styleManager.default)
      GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_SELECTED], @styleManager.selected)
      window = @glade[W_WINDOW]
      window.modal = true
      window.show_all
    end

    def close()
      window = @glade[W_WINDOW]
      window.hide_all()
      window.transient_for = nil
      window.modal = false
      window.destroy()
    end

    # ==================================
    # initialisation
    # ---------------------------------

    # initialize the window
    def iniWindow(pParent = nil)
      window = @glade[W_WINDOW]
      window.transient_for = pParent
      window.modal = false
      window.hide_all()
    end
    
    # initialize the display default function
    def iniFunc()
      @displayFunc = proc { |bObject|
        s = ''
        s = bObject.to_s if bObject
        s
      }
      @selectFunc = proc { |bObject|
        @mapSelected.key?(bObject)
      }
    end
    
    # initiliaze the model
    def iniModel()
      view = @glade[W_VIEW]
      model = Gtk::ListStore.new(Application::Karaoke)
      model.set_sort_column_id(0, Gtk::SORT_ASCENDING)
      model.set_sort_func(0) { |bIter1, bIter2|
          obj1 = @displayFunc.call(bIter1[0])
          obj2 = @displayFunc.call(bIter2[0])
          obj1 <=> obj2
        }
      view.model = model
    end
    
    # initialize the view
    def iniView()
      view = @glade[W_VIEW]
			view.selection.mode = Gtk::SELECTION_SINGLE
			view.headers_visible = false
			view.enable_search = true
      view.search_column = 0

      # search method
      view.set_search_equal_func { |bModel, bColind, bKey, bIter|
        ok = true
        searchString = @displayFunc.call(bIter[0])
        keys = bKey.split(/\s+/)
        # for each typed word
        keys.each { |bWord|
          reg = Regexp.new(Regexp.escape(bWord),Regexp::IGNORECASE)
          ok = (ok && (reg === searchString))
        }
        !ok
      }
    end
    
    # =================================
    # controle
    # ---------------------------------

    # prepare the view for the current list
    def prepareView()
      
      view = @glade[W_VIEW]
      view.columns.each { |bColumn|
        view.remove_column(bColumn)
      }
      createColumn( "Item", view)
      
      model = view.model
      return if model.nil?
      model.clear
      return if @list.nil?
      @list.each { |bObj|
        iter = model.append
        iter[0] = bObj
      }
    end

    def getStyleManager()
      unless @styleManager
        @styleManager = StyleManager.new()
      end
      return @styleManager
    end

    def createColumn(pName, pView)
      viewColumn = ColumnGeneric.new(pName)
      viewColumn.gtkColumn.clickable = false
      viewColumn.styleDefault = getStyleManager().default
      viewColumn.styleSelected = getStyleManager().selected
      viewColumn.setDisplayFunc(@displayFunc)
      viewColumn.setSelectedFunc(@selectFunc)
      pView.append_column(viewColumn.gtkColumn)
      return viewColumn
    end

    def toggleSelection(pObject)
      if @mapSelected.key?(pObject)
        @mapSelected.delete(pObject)
      else
        @mapSelected[pObject] = pObject
      end
    end

    # =================================
    # Handler
    # ---------------------------------

    public

    def on_treeviewSelector_cursor_changed(*pArg)
      
    end

    def on_treeviewSelector_row_activated(*pArg)
      rowSelected = @glade[W_VIEW].selection.selected
      return if rowSelected.nil?
      objectSelected = rowSelected[0]
      toggleSelection(objectSelected)
      @glade[W_VIEW].queue_draw
    end

    def on_buttonSelectAll_clicked(*pArg)
      @list.each { |bObj|
        @mapSelected[bObj] = bObj
      }
      @glade[W_VIEW].queue_draw
    end
    
    def on_buttonUnselectAll_clicked(*pArg)
      @mapSelected.clear
      @glade[W_VIEW].queue_draw
    end


    def on_buttonCancel_clicked(*pArg)
      close()
    end

    def on_buttonOk_clicked(*pArg)
      log("Select OK") {
        @onSelection.call(@list, @mapSelected.keys) if @onSelection
      }
      close()
    end
    
  end

end

puts "-- ProfileSelectorGUI"
