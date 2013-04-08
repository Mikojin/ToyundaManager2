
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Merge Data GUI
# ==========================================================
# Description :
# Sub module for the Toyunda Manager GUI. Only contains
# callback for the Merge Data GUI
# Manage the Merge data window. 
# The entry point is the method doMerge() that popup the window
# and initialize the source list and import list. This method
# takes a block parameters called once the merge is validate
# the block receive the mergeMap, newList and missingList
# ==========================================================

puts "require MergeDataGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "gui/SubToyundaManagerGUI"
require $root+ "gui/ColumnMap"
require $root+ "application/Karaoke"
require $root+ "application/Merger"
require $root+ "constants/CstsKaraoke"

# ----------------------------------------------------------

puts "++ MergeDataGUI"

module GUI

  class MergeDataGUI < SubToyundaManagerGUI
    
    W_WINDOW_MERGE_DATA = 'windowMergeData'
    W_LABEL_SELECTED_ORIG = 'labelSelectedOrigin'
    W_LABEL_SELECTED_ASSOCIATE = 'labelSelectedAssociate'
    W_LABEL_SELECTED_IMPORT = 'labelSelectedImport'
    W_LABEL_SELECTED_IMPORT_ASSOCIATE = 'labelSelectedImportAssociate'
    W_LABEL_ORIG = 'labelOrigin'
    W_LABEL_IMPORT = 'labelImport'
    W_VIEW_ORIGIN = 'treeviewOrigin'
    W_VIEW_IMPORT = 'treeviewImport'
    

    # =====================================
    # Initialize
    # =====================================
    
    # clear the config manager
    def clear()
      log("clear") {
        clearView(@glade[W_VIEW_ORIGIN])
        clearView(@glade[W_VIEW_IMPORT])
        @onMerge = nil
        @merger = nil
      }
    end
    
    # initialize the config manager
    def subInitialize()
      log("subInitialize") {
        #~ iniMap()
        defaultStyle = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default
        selectedStyle = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected
        GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_SELECTED_ORIG], defaultStyle)
        GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_SELECTED_ASSOCIATE], selectedStyle )
        GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_SELECTED_IMPORT], defaultStyle )
        GUI::setStyle(Gtk::STATE_NORMAL, @glade[W_LABEL_SELECTED_IMPORT_ASSOCIATE], selectedStyle )
        configureView(@glade[W_VIEW_ORIGIN])
        configureView(@glade[W_VIEW_IMPORT])
        iniColumnFunction()
      }
    end

    # =====================================
    public
    # =====================================

    # callback for saving information about StyleEditorGUI
    def save()
    end
    
    # display the Merge Data window and wait for its return
    # onMerge(mergedMap) => return a map associating pMainList with corresponding pImportList
    def doMerge(pMainList, pImportList, &onMerge)
      log("doMerge") {
        clear()
        @merger = Application::Merger.new(pMainList, pImportList)
        iniMap()
        # bind the action on validation
        @onMerge = onMerge
        
        if @merger.needMerge?
          fillView(@glade[W_VIEW_ORIGIN], @merger.getMainListUnassoc())
          fillView(@glade[W_VIEW_IMPORT], @merger.getImportListUnassoc())
          show()
        else
          log("Auto Merge OK") {
            @onMerge.call(@merger) if @onMerge
          }
          clear()
        end
      }
    end

    # return the merger
    def getMerger()
      return @merger
    end
    
    def getWindow()
      return @glade[W_WINDOW_MERGE_DATA]
    end
    
    # =====================================
    private
    # =====================================
    # =====================================
    # Display methods
    # =====================================

    # initialize global maps
    def iniMap()
      #~ @current = Hash.new()
      #~ @mapMainToImport = Hash.new()
      #~ @mapImportToMain = Hash.new()
      @mapAssociate = Hash.new()
      @mapAssociate[@glade[W_VIEW_ORIGIN]] = @merger.mapMainToImport
      @mapAssociate[@glade[W_VIEW_IMPORT]] = @merger.mapImportToMain
    end

    def iniColumnFunction()
      @selectFunc = Hash.new()
      views = [@glade[W_VIEW_ORIGIN], @glade[W_VIEW_IMPORT]]
      views.each { |bView|
        @selectFunc[bView] = proc { |bKaraoke|
          @mapAssociate[bView].key?(bKaraoke)
          #~ bKaraoke == @current[bView]
        }
      }
    end

    # show the merge window
    def show()
      @toyundaManagerGUI.reduce()
      @glade[W_WINDOW_MERGE_DATA].visible = true
    end
    
    # hide the merge window
    def hide()
      @glade[W_WINDOW_MERGE_DATA].visible = false
      @toyundaManagerGUI.restore()
    end
    
    # clear the given view
    def clearView(pView)
      clearModel(pView)
      clearColumn(pView)
    end
    
    # clear the model of the given view
    def clearModel(pView)
      if pView.model
        pView.model.clear
      else
        model = Gtk::ListStore.new(Application::Karaoke)
        model.set_sort_column_id(0, Gtk::SORT_ASCENDING)
        model.set_sort_func(0) { |bIter1, bIter2|
            karaoke1 = bIter1[0]
            karaoke2 = bIter2[0]
            karaoke1.ini <=> karaoke2.ini
          }
        pView.model = model
      end
    end

    # clear columns of the given view
    def clearColumn(pView)
      pView.columns.each { |bColumn|
        pView.remove_column(bColumn)
      }
    end
    
    # configure the given view
    def configureView(pView)
			pView.selection.mode = Gtk::SELECTION_SINGLE
			pView.headers_visible = true
			pView.enable_search = true
      pView.search_column = 0

      # search method
      pView.set_search_equal_func { |bModel, bColind, bKey, bIter|
        ok = true
        karaoke = bIter[0]
        iniName = karaoke.ini
        keys = bKey.split(/\s+/)
        # for each typed word
        keys.each { |bWord|
          reg = Regexp.new(Regexp.escape(bWord),Regexp::IGNORECASE)
          ok = (ok && (reg === iniName))
        }
        !ok
      }
    end
    
    # fill the given view with the given karaoke list
    # then set the column for each data in the karaokeList
    def fillView(pView, pKaraokeList)
      log("fillView") {
        columnMap = {CstsKaraoke::K_INI => CstsKaraoke::K_INI}
        columnList = [CstsKaraoke::K_INI]
        model = pView.model
        pKaraokeList.each { |bKaraoke|
          iter = model.append
          iter[0] = bKaraoke
          log("- #{bKaraoke}")
          bKaraoke.each { |bColumn, bValue|
            unless columnMap[bColumn]
              columnList << bColumn
              columnMap[bColumn] = bColumn
            end
          }
        }
        updateColumns(pView, columnList)
      }
    end
    
    # fill view with column list
    def updateColumns(pView, pColumnList)
      log("updateColumn") {
        clearColumn(pView)
        darker = 0
        pColumnList.each { |bColumnName|
          viewColumn = createColumn(bColumnName, pView)
          viewColumn.darker += darker
          darker = 1 - darker
        }
      }
    end

    def createColumn(pName, pView)
      log("- #{pName}")
      viewColumn = ColumnMap.new(pName)
      viewColumn.gtkColumn.clickable = false
      viewColumn.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default
      viewColumn.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected
      viewColumn.setSelectedFunc(@selectFunc[pView])
      pView.append_column(viewColumn.gtkColumn)
      return viewColumn
    end

    def getSelectedKaraoke(pView)
      rowSelected = pView.selection.selected
      return nil if rowSelected.nil?
      return rowSelected[0]
    end

    def redrawViews()
      @glade[W_VIEW_ORIGIN].queue_draw
      @glade[W_VIEW_IMPORT].queue_draw
    end

    # display information about the selected main karaoke (associated with ?)
    def updateInfo()
      selectedKaraokeMain = getSelectedKaraoke(@glade[W_VIEW_ORIGIN])
      karaokeImport = nil
      if selectedKaraokeMain
        @glade[W_LABEL_SELECTED_ORIG].text = selectedKaraokeMain.ini
        karaokeImport = @merger.mapMainToImport[selectedKaraokeMain]
      else
        @glade[W_LABEL_SELECTED_ORIG].text = ""
      end
      if karaokeImport
        @glade[W_LABEL_SELECTED_ASSOCIATE].text = karaokeImport.ini
      else
        @glade[W_LABEL_SELECTED_ASSOCIATE].text = ""
      end
      selectedKaraokeImport = getSelectedKaraoke(@glade[W_VIEW_IMPORT])
      karaokeMain = nil
      if selectedKaraokeImport
        @glade[W_LABEL_SELECTED_IMPORT].text = selectedKaraokeImport.ini
        karaokeMain = @merger.mapImportToMain[selectedKaraokeImport]
      else 
        @glade[W_LABEL_SELECTED_IMPORT].text = ""
      end
      if karaokeMain
        @glade[W_LABEL_SELECTED_IMPORT_ASSOCIATE].text = karaokeMain.ini
      else
        @glade[W_LABEL_SELECTED_IMPORT_ASSOCIATE].text = ""
      end
    end

    # associate the current selected karaoke
    def associateSelected()
      karaokeMain = getSelectedKaraoke(@glade[W_VIEW_ORIGIN])
      karaokeImport = getSelectedKaraoke(@glade[W_VIEW_IMPORT])
      if karaokeMain && karaokeImport
        # both are selected
        @merger.associate(karaokeMain, karaokeImport)
      elsif karaokeMain
        # only main selected
        @merger.unAssociateMain(karaokeMain)
      elsif karaokeImport
        # only import selected
        @merger.unAssociateImport(karaokeImport)
      else
        # no selection
      end
    end

    # unassociate the current selected karaoke
    def unAssociateSelected()
      karaokeMain = getSelectedKaraoke(@glade[W_VIEW_ORIGIN])
      karaokeImport = getSelectedKaraoke(@glade[W_VIEW_IMPORT])
      @merger.unAssociate(karaokeMain, karaokeImport)
    end
    
    # =====================================
    # Callbacks
    # =====================================
    public
    
    # -------------------------------------
    # Controle Button
    # -------------------------------------
    
    def on_buttonAssociate_clicked(*pArg)
      associateSelected()
      updateInfo()
      redrawViews()
    end
    
    def on_buttonUnssociate_clicked(*pArg)
      unAssociateSelected()
      updateInfo()
      redrawViews()
    end
    
    def on_buttonAutoMerge_clicked(*pArg)
      log("on_buttonAutoMerge_clicked") {
        @merger.autoMerge()
        updateInfo()
        redrawViews()
      }
    end
    
    def on_buttonUnassociateAll_clicked(*pArg)
      log("on_buttonUnassociateAll_clicked") {
        @merger.unassociateAll()
        updateInfo()
        redrawViews()
      }
    end
    
    def on_buttonShowAll_clicked(*pArg)
      log("on_buttonShowAll_clicked") {
        clearView(@glade[W_VIEW_ORIGIN])
        clearView(@glade[W_VIEW_IMPORT])
        fillView(@glade[W_VIEW_ORIGIN], @merger.mainList)
        fillView(@glade[W_VIEW_IMPORT], @merger.importList)
        updateInfo()
        redrawViews()
      }
     end

    def on_buttonHideAssociated_clicked(*pArg)
      log("on_buttonHideAssociated_clicked") {
        clearView(@glade[W_VIEW_ORIGIN])
        clearView(@glade[W_VIEW_IMPORT])
        fillView(@glade[W_VIEW_ORIGIN], @merger.getMainListUnassoc())
        fillView(@glade[W_VIEW_IMPORT], @merger.getImportListUnassoc())
        updateInfo()
        redrawViews()
      }
     end
    
    # -------------------------------------
    # Validation
    # -------------------------------------
    
    def on_buttonMergeOk_clicked(*pArg)
      log("Merge OK") {
        @onMerge.call(@merger) if @onMerge
      }
      clear()
      hide()
    end
    
    def on_buttonMergeCancel_clicked(*pArg)
      clear()
      hide()
    end
    
    # -------------------------------------
    # View
    # -------------------------------------
    
    def on_treeviewOrigin_cursor_changed(pView)
      updateInfo()
    end
    
    def on_treeviewOrigin_row_activated(pView, pPath, pColumn)
      associateSelected()
      updateInfo()
      redrawViews()
    end
    
    def on_treeviewImport_cursor_changed(pView)
      updateInfo()
    end
    
    def on_treeviewImport_row_activated(pView, pPath, pColumn)
      associateSelected()
      updateInfo()
      redrawViews()
    end

  end

end

puts "-- MergeDataGUI"
