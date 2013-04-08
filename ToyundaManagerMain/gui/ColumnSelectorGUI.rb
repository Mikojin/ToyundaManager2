
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

puts "require ColumnSelectorGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "gui/SubToyundaManagerGUI"
require $root+ "constants/CstsKaraoke"
require $root+ "gui/ColumnMap"
# ----------------------------------------------------------

puts "++ ColumnSelectorGUI"

module GUI

  class ColumnSelectorGUI < SubToyundaManagerGUI
    
    W_VIEW_COLUMN_SELECTOR = 'treeviewColumnSelector'
    W_ENTRY_NEW_COLUMN = 'entryNewColumn'
    W_BUTTON_ADD = 'buttonAddColumn'
    W_BUTTON_DELETE = 'buttonDeleteColumn'
    W_CHECK_EDITABLE = 'checkEditable'
    W_LABEL_SELECTED_COLUMN = 'labelSelectedColumn'
    W_COMBO_STYLE_DEFAULT = 'comboboxStyleDefault'
    W_COMBO_STYLE_SELECTED = 'comboboxStyleSelected'
    
    attr_reader :sortColumnSelector
    
    # =====================================
    # Initialize
    # =====================================
    
    # clear the config manager
    def clear()
      getColumnSelectorView().columns.each { |bColumn|
        getColumnSelectorView().remove_column(bColumn)
      }
      @columnSelectorModel = nil
      @selectTitleColumns = nil
    end
    
    # initialize the config manager
    def subInitialize()
      log("subInitialize") {
        @changed = true
        @sortColumnSelector = [CstsKaraoke::K_FULL_TITLE]
        iniFunctions()
        iniColumnSelectorView()
        iniStyleCombobox()
      }
    end

    # =====================================
    public
    # =====================================

    # callback for saving information about ColumnSelectorGUI
    def save()
      log("save"){
        # save column order and display
        colOrder = Array.new()
        colDisplay = Array.new()
        colStyleDefault = Array.new()
        colStyleSelected = Array.new()
        
        # !!! TODO !!! The column list may not be up to date !!!
        getSelectTitleColumns().each { |bColumnMap|
          colOrder << bColumnMap.title
          colDisplay << bColumnMap.visible?.to_s
          colStyleDefault << bColumnMap.styleDefault.name
          colStyleSelected << bColumnMap.styleSelected.name
        }
        @application.configManager.setColumnOrder(colOrder)
        @application.configManager.setColumnDisplay(colDisplay)
        @application.configManager.setColumnStyleDefault(colStyleDefault)
        @application.configManager.setColumnStyleSelected(colStyleSelected)
        log("columnOrder = "+colOrder.join(", "))
        log("columnDisplay = "+colDisplay.join(", "))
        log("columnStyleDefault = "+colStyleDefault.join(", "))
        log("columnStyleSelected = "+colStyleSelected.join(", "))
        
        #~ # save the model into a file
        #~ fileName = @application.configManager.getColumnFileName()
        #~ File.open(fileName,'w') { |bFile|
          #~ Marshal.dump(getColumnSelectorModel(), bFile)
        #~ }
      }
    end

    # return an array of columns for the select title view
    def getSelectTitleColumns()
      log("getSelectTitleColumns") {
        return @selectTitleColumns if @selectTitleColumns
        iniSelectTitleColumns()
        return @selectTitleColumns
      }
    end
  
    # return the treeview for the column selector
    def getColumnSelectorView()
      return @glade[W_VIEW_COLUMN_SELECTOR]
    end

    # return the treeview for the column selector
    def getColumnSelectorModel()
      return @columnSelectorModel if @columnSelectorModel
      iniColumnSelectorModel()
      return @columnSelectorModel
    end

    # if the columns displayed have changed
    def changed?()
      return @changed
    end

    # valid the change
    def changeDone()
      @changed = false
    end

    # set the changed status
    def changed(pValue = true)
      unless @changed
        log "changed"
        @changed = pValue
        @selectTitleColumns = nil
      end
    end

    # update column from karaoke list
    def updateColumnsFromKaraokeList(pKaraokeList)
      #~ map = Hash.new
      #~ getSelectTitleColumns().each { |bColumnMap|
        #~ map[bColumnMap.title] = true
      #~ }
      #~ newList = Array.new
      #~ pKaraokeList.each { |bKaraoke|
        #~ bKaraoke.each { |bKey|
          #~ unless map.key?(bKey)
            #~ map[bKey] = true
            #~ newList << bKey
          #~ end
        #~ }
      #~ }
      columnList = pKaraokeList.getColumns
      doAddColumn(columnList)
    end
    
    # add all column from the given list if they don't already exist
    def addColumnList(pNameList)
      mapExist = Hash.new
      getSelectTitleColumns().each { |bColumnMap|
        mapExist[bColumnMap.title] = true
      }
      return unless pNameList
      pNameList.each { |bName|
        unless mapExist[bName]
          doAddColumn(bName)
        end
      }
    end


    # =====================================
    private
    # =====================================

    # initialize various functions
    def iniFunctions()
      # select function
      @selectedFunc = proc {	|bKaraoke|
      	karaoke = @toyundaManagerGUI.getPlaylistManagerGUI().currentPlaylist.getByIni(bKaraoke.ini)
      	!karaoke.nil?
      }
      
      # clicked function
      @clickedFunc = proc { |bColumnMap|
        @sortColumnSelector.delete(bColumnMap.key)
        @sortColumnSelector.insert(0, bColumnMap.key)
        log("sort : "+@sortColumnSelector.join(", "))
      }
      
      # edit function
      @editFunc = proc { |bColumnMap, bPath, bValue|
        model = @toyundaManagerGUI.getPlaylistManagerGUI().getModelSelector()
        row = model.get_iter(bPath)
        karaoke = row[0]
        bValue = nil	if bValue=~/^\s*$/
        karaoke[bColumnMap.key] = bValue
        log("New value : "+karaoke.to_s+"["+bColumnMap.key+"] = "+karaoke[bColumnMap.key].to_s+" ("+karaoke[bColumnMap.key].class.to_s+")")
      }
    end

    # initialize the view for the column selector
    def iniColumnSelectorView()
      log("iniColumnSelectorView") {
        view = getColumnSelectorView()
        view.model = getColumnSelectorModel()
        view.selection.mode = Gtk::SELECTION_BROWSE
        view.enable_search = false
        
        @viewColumn = ColumnGeneric.new("Name")
        selectFunc = proc { |bColumMap|
          bColumMap.visible?
        }
        @viewColumn.setSelectedFunc(selectFunc)
        @viewColumn.gtkColumn.clickable = false
        @viewColumn.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default
        @viewColumn.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected
        view.append_column(@viewColumn.gtkColumn)
      }
    end

    # initialize the model of ColumnMap for the select title view
    def iniColumnSelectorModel()
      log("iniColumnSelectorModel") {
        #~ @columnSelectorModel = createColumnSelectorModelFromFile()
        #~ return unless @columnSelectorModel.nil?
        @columnSelectorModel = createColumnSelectorModelFromConfig()
      }
    end
    
    # initialize the Style combobox
    def iniStyleCombobox()
      @glade[W_COMBO_STYLE_DEFAULT].model = @toyundaManagerGUI.getStyleEditorGUI().model
      @glade[W_COMBO_STYLE_DEFAULT].text_column = 0
      @glade[W_COMBO_STYLE_SELECTED].model = @toyundaManagerGUI.getStyleEditorGUI().model
      @glade[W_COMBO_STYLE_SELECTED].text_column = 0
    end
    
    # load model from config file
    def createColumnSelectorModelFromConfig()
      # create from config
      model = Gtk::ListStore.new(ColumnMap, String)
      i = 0
      colDisplay = @application.configManager.getColumnDisplay()
      colStyleDefault = @application.configManager.getColumnStyleDefault()
      colStyleSelected = @application.configManager.getColumnStyleSelected()
      defaultStyleName = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default.name
      selectedStyleName = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected.name
      @application.configManager.getColumnOrder().each { |bColumnName|
        column = createColumnMap(bColumnName)
        column.visible = (true.to_s == colDisplay[i])
        defaultStyle = defaultStyleName
        defaultStyle = colStyleDefault[i]  if i < colStyleDefault.size
        selectedStyle = selectedStyleName
        selectedStyle = colStyleSelected[i] if i < colStyleSelected.size
        column.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().getStyle(defaultStyle)
        column.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().getStyle(selectedStyle)
        addColumn(model, column)
        i += 1
      }
      return model
    end

    # create the model from the column file. return nil if no file
    def createColumnSelectorModelFromFile()
      fileName = @application.configManager.getColumnFileName()
      return nil unless File.exist?(fileName)
      model = nil
      begin
        File.open(fileName,'r') { |bFile|
          model = Marshal.load(bFile)
        }
      rescue
      end
      return model
    end

    # return the list of ColumnMap for the select title view
    def iniSelectTitleColumns()
      log("iniSelectTitleColumns") {
        @selectTitleColumns = Array.new
        getColumnSelectorModel().each { |bModel,bPath,bIter|
          columnMap = bIter[0]
          @selectTitleColumns << columnMap
        }
      }
    end

    # add the given column in the given model
    def addColumn(pModel, pColumn)
      row = pModel.append()
      row[0] = pColumn
      row[1] = pColumn.to_s
    end

    # create and configure a column
    def createColumnMap(pColumnName)
      column = ColumnMap.new(pColumnName)
      column.setSelectedFunc(@selectedFunc)
      column.setClickedFunc(@clickedFunc)
      column.setEditFunc(@editFunc)
      column.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default
      column.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected
      return column
    end

    # test if the given column name exists already
    def columnExist?(pColumnName)
      exist = false
      getSelectTitleColumns().each { |bColumnMap|
        if bColumnMap.title == pColumnName
          exist = true
        end
      }
      return exist
    end
    
    # set the selected column map
    def setSelectedColumn(pColumnMap)
      log("selected column = "+pColumnMap.to_s) {
        @selectedColumn = pColumnMap
        # column editable ?
        @glade[W_CHECK_EDITABLE].active = pColumnMap.editable?
        label = @glade[W_LABEL_SELECTED_COLUMN]
        label.text = pColumnMap.to_s
        GUI::setStyle(Gtk::STATE_NORMAL, label, pColumnMap.styleDefault)
        GUI::setStyle(Gtk::STATE_PRELIGHT, label, pColumnMap.styleSelected)
        @noUpdate = true
        @glade[W_COMBO_STYLE_DEFAULT].active_iter = @toyundaManagerGUI.getStyleEditorGUI().getIter(pColumnMap.styleDefault.name)
        @glade[W_COMBO_STYLE_SELECTED].active_iter = @toyundaManagerGUI.getStyleEditorGUI().getIter(pColumnMap.styleSelected.name)
        @noUpdate = false
      }
    end

    # add a column to the view
    def doAddColumn(pName)
      log("new Column : "+pName)
      column = createColumnMap(pName)
      addColumn(getColumnSelectorModel(), column)
      changed()
    end

    # =====================================
    # Callbacks
    # =====================================
    public
    
    # when activating a row : show / hide column
    def on_treeviewColumnSelector_row_activated(pWidget, pPath, pColumn)
      log("toggle visibility") {
        rowSelected = pWidget.model.get_iter(pPath)
        columnMap = rowSelected[0]
        columnMap.visible = !columnMap.visible?
        log(columnMap.to_s+" : set visible = "+columnMap.visible?.to_s)
        changed()
      }
    end
    
    # select a row in the column selector view : display column info
    def on_treeviewColumnSelector_cursor_changed(pWidget)
      selectedRow = getColumnSelectorView().selection.selected
      return unless selectedRow
      columnMap = selectedRow[0]
      setSelectedColumn(columnMap)
    end
    
    # when moving row in the selector
    def on_treeviewColumnSelector_drag_end(pWidget, pArg1=nil, pArg2=nil, pArg3=nil)
      changed()
    end

    # clic on Add Column button
    def on_buttonAddColumn_clicked(pWidget)
      name = @glade[W_ENTRY_NEW_COLUMN].text
      if (voidName= (name =~ /^\s*$/) or columnExist?(name))
          if voidName
            setError("Add", "Can't add column with void name")
          else
            setError("Add", "Column "+name+" is already in the list")
          end
        return 
      end
      doAddColumn(name)
    end
    
    # clic on Delete Column button
    def on_buttonDeleteColumn_clicked(pWidget)
      selectedRow = getColumnSelectorView().selection.selected
      return unless selectedRow
      column = selectedRow[0]
      if @application.configManager.isColumnDeletable(column.key)
        getColumnSelectorModel().remove(selectedRow)
        changed()
      else
        setError("Delete", "Deleting "+column.to_s+" is forbidden")
      end
    end
    
    # clic on Delete Column button
    def on_checkEditable_toggled(pWidget)
      log("toggle editable")
      selectedRow = getColumnSelectorView().selection.selected
      return unless selectedRow
      columnMap = selectedRow[0]
      columnMap.editable = @glade[W_CHECK_EDITABLE].active?
    end
    
    def on_comboboxStyleDefault_changed(*pArg)
      return if @noUpdate
      style = @glade[W_COMBO_STYLE_DEFAULT].active_text
      @selectedColumn.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().styleManager[style]
    end

    def on_comboboxStyleSelected_changed(*pArg)
      return if @noUpdate
      style = @glade[W_COMBO_STYLE_SELECTED].active_text
      @selectedColumn.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().styleManager[style]
    end
    
  end
end

puts "-- ColumnSelectorGUI"
