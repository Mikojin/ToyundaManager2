
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Filter Editor GUI
# ==========================================================
# Description :
# Filter Editor : edit the selected filter.
# ==========================================================

puts "require FilterEditorGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "gui/SubToyundaManagerGUI"
require $root+ "filter/Filter"
require $root+ "filter/FilterCatalog"
require $root+ "filter/CustomFilterCatalog"

# ----------------------------------------------------------

puts "++ FilterEditorGUI"

module GUI

  class FilterEditorGUI < SubToyundaManagerGUI

    W_COMBOBOX_SELECT_FILTER = 'comboboxSelectFilter'
    W_VIEW_FILTER = 'treeviewFilter'
    
    COLOR_BG = Gdk::Color.parse('#FFFFFF')
    COLOR_BG_ERROR = Gdk::Color.parse('#FFC0C0')
    
    attr_reader :modelSelectFilter, :customFilterCatalog
    
    # =====================================
    # Initialize
    # =====================================
    
    # clear the config manager
    def clear()
    end
    
    # initialize the config manager
    def subInitialize()
      log("subInitialize") {
        log("ini model filter catalog column")
        @modelFilterCatalog = Gtk::ListStore.new(String)
        fillModel(@modelFilterCatalog, FilterCatalog.instance.getList())
        
        @currentFilter = createFilter()

        iniSelectFilter()
        refreshSelectFilter()
        iniFilterView()
        refreshFilterView()
      }
    end

    # =====================================
    public
    # =====================================
    
    # callback for saving information about PlaylistManagerGUI
    def save()
      #~ log("save"){
      #~ }
    end
    
    # return the model for the custom filter catalog
    def getModelCustomFilterCatalog()
      log("get ModelCustomFilterCatalog")
      return @modelSelectFilter
    end

    # =====================================
    private
    # =====================================

    # create and return a new filter
    def createFilter()
      filterName = nil
      iter = @modelFilterCatalog.iter_first()
      filterName = iter[0] unless iter.nil?
      newFilter = Filter.new(filterName)
      return newFilter
    end

    # fill the given model with the given list
    def fillModel(pModel, pList)
      log("fill model") {
        pList.each { |bElement|
          iter = pModel.append()
          iter[0] = bElement
          log("add : "+bElement.to_s)
        }
      }
    end

    # clear the column of the given view
    def clearColumn(pView)
      pView.columns.each { |bColumn|
        pView.remove_column(bColumn)
      }
    end
    
    # create and add a new filter under the given parent (TreeIter)
    # The filter is added to the children of the parent filter.
    # It is also added to the model
    def addNewFilter(pIterParent)
      filterElement = pIterParent[0]
      newFilter = createFilter()
      filterElement << newFilter
      addFilterInModel(pIterParent, newFilter)
    end
    
    # update the current filter using the current model filter
    def updateCurrentFilter()
      log("update Current Filter") {
        rootIter = @modelFilter.iter_first
        updateFilterIter(rootIter)
      }
    end
    
    # update the filter and children of the given TreeIter
    def updateFilterIter(pIter)
      filter = pIter[0]
      filter.clear_children()
      for i in 0...pIter.n_children
        childIter = pIter.nth_child(i)
        childFilter = childIter[0]
        filter << childFilter
        updateFilterIter(childIter)
      end
    end
    
    #--------------------------------------------------------
    # return the gtk component for the select filter combobox
    def getSelectFilterCombobox()
      return @glade[W_COMBOBOX_SELECT_FILTER]
    end

    # return the Filter object linked to the selected custom filter or nil
    def getSelectedCustomFilter()
      iter = getSelectFilterCombobox().active_iter()
      return nil if iter.nil?
      customFilterName = iter[0]
      return nil if customFilterName.nil?
      customFilter = @application.customFilterCatalog[customFilterName]
      return customFilter
    end

    # initialize the select filter combobox
    def iniSelectFilter()
      @modelSelectFilter = Gtk::ListStore.new(String)
      getSelectFilterCombobox().model = @modelSelectFilter
      getSelectFilterCombobox().text_column = 0
    end

    def refreshSelectFilter()
      @modelSelectFilter.clear
      fillModel(@modelSelectFilter, @application.customFilterCatalog.getList())
    end

    #--------------------------------------------------------
    # return the gtk componant for the filter treeview
    def getFilterView()
      return @glade[W_VIEW_FILTER]
    end

    # initialize the filter treeview
    def iniFilterView()
      log("iniFilterView") {
        clearColumn(getFilterView())
        @modelFilter = Gtk::TreeStore.new(Filter)
        getFilterView().model = @modelFilter
        getFilterView().selection.mode = Gtk::SELECTION_BROWSE
        
        log("append column")
        getFilterView().append_column(createColumnPath())
        getFilterView().append_column(filterColumn = createColumnFilter())
        getFilterView().append_column(createColumnKey())
        getFilterView().append_column(createColumnValue())
        getFilterView().expander_column=filterColumn
      }
    end
    
    # refresh the filter tree view
    def refreshFilterView()
      log("refresh Filter View") {
        @modelFilter.clear()
        addFilterInModel(nil, @currentFilter)
        getFilterView().expand_all()
      }
    end
    
    # add the given filter under the given parent
    def addFilterInModel(pParent, pFilter)
      name = nil
      if pFilter.nil?
        name = "nilFilter"
      else
        name = pFilter.filter
        name = "nilFilterName" if name.nil?
      end
      log("add Filter : "+name) {
        iter = @modelFilter.append(pParent)
        iter[0] = pFilter
        pFilter.each_children { |bChildFilter|
          addFilterInModel(iter, bChildFilter)
        }
      }
    end

    #--------------------------------------------------------

    # initialize the column "Path" of the Create Filter View
    def createColumnPath()
      log("iniColumnPath") {
        log("ini renderer path column")
        renderer = Gtk::CellRendererText.new()
        renderer.editable = false

        log("ini path column")
        column = Gtk::TreeViewColumn.new("Path", renderer)
        column.resizable = true
        column.set_cell_data_func(renderer) { |bColumn, bRenderer, bModel, bIter|
          path = bIter.path
          bRenderer.text = path.to_s
        }
        return column
      }
    end


    # initialize the column "Filter" of the Create Filter View
    def createColumnFilter()
      log("iniColumnFilter") {
        log("ini renderer filter column")
        rendererFilter = Gtk::CellRendererCombo.new()
        rendererFilter.model = @modelFilterCatalog
        rendererFilter.text_column = 0
        rendererFilter.has_entry = false
        rendererFilter.editable = true
        rendererFilter.signal_connect("edited") { |bRenderer, bPath, bValue|
          iter = @modelFilter.get_iter(bPath)
          filterElement = iter[0]
          filterElement.filter = bValue
        }

        log("ini filter column")
        columnFilter = Gtk::TreeViewColumn.new("Filter", rendererFilter)
        columnFilter.resizable = true
        columnFilter.set_cell_data_func(rendererFilter) { |bColumn, bRenderer, bModel, bIter|
          filterElement = bIter[0]
          filterName = filterElement.filter
          filterName = '' if filterName.nil?
          #~ bRenderer.text = "["+bIter.path.to_s+"] "+filterName
          bRenderer.text = filterName
          if filterElement.isChildrenOK()
            bRenderer.background_gdk = COLOR_BG
          else
            bRenderer.background_gdk = COLOR_BG_ERROR
          end
        }
        return columnFilter
      }
    end
    
    # initialize the column "Filter" of the Create Filter View
    def createColumnKey()
      log("iniColumnKey") {
        log("ini renderer key column")
        renderer = Gtk::CellRendererCombo.new()
        renderer.model = @toyundaManagerGUI.getColumnSelectorGUI().getColumnSelectorModel()
        renderer.text_column = 1
        renderer.has_entry = false
        renderer.editable = true
        renderer.signal_connect("edited") { |bRenderer, bPath, bValue|
          iter = @modelFilter.get_iter(bPath)
          filterElement = iter[0]
          filterElement.key = bValue
        }

        log("ini key column")
        column = Gtk::TreeViewColumn.new("Key", renderer)
        column.resizable = true
        column.set_cell_data_func(renderer) { |bColumn, bRenderer, bModel, bIter|
          filterElement = bIter[0]
          key = filterElement.key
          key = '' if key.nil?
          bRenderer.text = ' '+key
          if filterElement.isKeyOK()
            bRenderer.background_gdk = COLOR_BG
          else
            bRenderer.background_gdk = COLOR_BG_ERROR
          end
        }
        return column
      }
    end

    # initialize the column "Filter" of the Create Filter View
    def createColumnValue()
      log("iniColumnKey") {
        log("ini renderer value column")
        renderer = Gtk::CellRendererText.new()
        renderer.editable = true
        renderer.signal_connect("edited") { |bRenderer, bPath, bValue|
          iter = @modelFilter.get_iter(bPath)
          filterElement = iter[0]
          bValue = nil if bValue =~ /^\s*$/
          filterElement.value = bValue
        }

        log("ini value column")
        column = Gtk::TreeViewColumn.new("Value", renderer)
        column.resizable = true
        column.set_cell_data_func(renderer) { |bColumn, bRenderer, bModel, bIter|
          filterElement = bIter[0]
          bRenderer.text = filterElement.value.to_s
          if filterElement.isValueOK()
            bRenderer.background_gdk = COLOR_BG
          else
            bRenderer.background_gdk = COLOR_BG_ERROR
          end
        }
        return column
      }
    end
    #--------------------------------------------------------

    # =====================================
    # Callbacks
    # =====================================
    public
    
    def on_comboboxSelectFilter_changed(*arg)
      log("on_comboboxSelectFilter_changed") {
        filter = getSelectedCustomFilter()
        return unless filter
        log("current filter : "+@currentFilter.object_id.to_s)
        log("filter : "+filter.object_id.to_s)
        @currentFilter = filter.duplicate()
        log("new current filter : "+@currentFilter.object_id.to_s)
        refreshFilterView()
      }
    end
    
    def on_buttonNewFilter_clicked(pWidget)
      log("on_buttonNewFilter_clicked") {
        @currentFilter = createFilter()
        refreshFilterView()
        begin
          getSelectFilterCombobox().text = nil
        rescue
          log("Error")
        end
      }
    end

    def on_buttonSaveFilter_clicked(pWidget)
      log("on_buttonSaveFilter_clicked") {
        filterName = getSelectFilterCombobox().active_text
        updateCurrentFilter()
        log("current filter : "+@currentFilter.object_id.to_s)
        filter = @currentFilter.duplicate()
        log("duplicate filter : "+filter.object_id.to_s)
        @application.customFilterCatalog[filterName] = filter
        refreshSelectFilter()
      }
    end

    def on_buttonDeleteFilter_clicked(pWidget)
      log("on_buttonDeleteFilter_clicked") {
        filterName = getSelectFilterCombobox().active_text
        @application.customFilterCatalog.remove(filterName)
        getSelectFilterCombobox().active = -1
        refreshSelectFilter()
      }
    end

    def on_buttonAddFilter_clicked(pWidget)
      log("on_buttonAddFilter_clicked") {
        rowSelected = getFilterView().selection.selected
        return if rowSelected.nil?
        parent = rowSelected.parent
        return if parent.nil?
        addNewFilter(parent)
        getFilterView().columns_autosize
      }
    end

    def on_buttonAddChildrenFilter_clicked(pWidget)
      log("on_buttonAddChildrenFilter_clicked") {
        rowSelected = getFilterView().selection.selected
        return if rowSelected.nil?
        getFilterView().expand_row(rowSelected.path, false)
        addNewFilter(rowSelected)
      }
    end
    
    def on_buttonRemoveFilter_clicked(pWidget)
      log("on_buttonRemoveFilter_clicked") {
        rowSelected = getFilterView().selection.selected
        return if rowSelected.nil?
        filter = rowSelected[0]
        parentRow = rowSelected.parent
        if parentRow.nil?
          setError('Filter','Root filter cannot be removed')
          return
        end
        parentFilter = parentRow[0]
        parentFilter.remove(filter)
        @modelFilter.remove(rowSelected)
        setInfo('Filter', 'Deleted : '+filter.to_s)
      }
    end
    
    def on_treeviewFilter_drag_end(*arg)
      log("on_treeviewFilter_drag_end") {
        updateCurrentFilter()
      }
    end
    
    def on_treeviewFilter_cursor_changed(pWidget)
      selection = getFilterView().selection
      return if selection.nil?
      rowSelected = selection.selected
      filter = rowSelected[0]
      setInfo('Filter', filter.to_s)
    end
    
    def on_buttonExpandAll_clicked(pWidget)
      getFilterView().expand_all()
    end
    
    def on_buttonCollapseAll_clicked(pWidget)
      getFilterView().collapse_all()
    end

  end
end

puts "-- FilterEditorGUI"
