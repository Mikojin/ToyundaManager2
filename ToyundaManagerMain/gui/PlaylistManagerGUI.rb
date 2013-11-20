
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Playlist Manager GUI
# ==========================================================
# Description :
# Sub module for the Toyunda Manager GUI. Only contains
# callback for the Playlist
# Uses methodes and attributs from the main class : 
# ToyundaManagerGUI
# ==========================================================

puts "require PlaylistManagerGUI"

# ----------------------------------------------------------
require $root+ "constants/CstsConfigManager"
require $root+ "constants/CstsKaraoke"
require $root+ "constants/CstsFilter"
require $root+ "gui/GUI"
require $root+ "gui/SubToyundaManagerGUI"
require $root+ "gui/ColumnMap"
require $root+ "application/KaraokeList"
require $root+ "filter/Filter"
# ----------------------------------------------------------

puts "++ PlaylistManagerGUI"

module GUI

  class PlaylistManagerGUI < SubToyundaManagerGUI

    # =====================================
    public 
    # =====================================

    W_WINDOW = "toyundaManager"
    W_LAUNCH_ON_GENERATE = 'checkLaunchOnGenerate'
    W_CHECK_SHUFFLE_ON_GENERATE = 'checkShuffleOnGenerate'
    W_SHUFFLE_ON_GENERATE = 'shuffleOnGenerate'
    W_VIEW_SELECT_TITLE = 'listSelectTitle'
    W_VIEW_CURRENT_PLAYLIST = 'listCurrentPlaylist'
    W_LABEL_NB_TITLES = 'nbTitles'
    W_LABEL_TOTAL_TIME = 'totalTime'
    W_QUICK_FILTER = 'entryQuickFilter'
    W_ALLOW_MULTIPLE_ENTRY = 'allowMultipleEntry'
    W_MENU_CTX_SELECT_TITLE = 'menuCtxSelectTitle'
    W_CHECK_LINE_NUMBER_CURRENT_PLAYLIST = 'lineNumberCurrentPlaylist'
    W_CHECK_LINE_NUMBER_SELECT_TITLE = 'lineNumberSelectTitle'
    W_QUICK_SELECT_FILTER = 'comboboxQuickSelectFilter'
    
    attr_reader :currentPlaylist
    
    # =====================================
    # Initialize
    # =====================================

    # clear the Playlist Manager
    def clear()
      clearColumn(getViewSelectTitle())
      clearColumn(getViewCurrentPlaylist())
    end

    # initialize Playlist Manager
    def subInitialize()
      log("subInitialize") {
        return if @application.profile.nil?
 	    	@currentPlaylist = Application::KaraokeList.new unless @currentPlaylist
        @displayedList =  Application::KaraokeList.new unless @displayedList
 	    	iniFilter()
        iniAllowMultipleEntry()
        iniShuffleOnGenerate()
        iniLineNumberSelectTitle()
        iniLineNumberCurrentPlaylist()
        iniModelSelector()
        iniModelCurrent()
        iniQuickSelectFilter()
        # iniSelectTitleColumns()
        iniCurrentPlaylistColumns()
        iniViewSelector(getViewSelectTitle(), getSelectTitleColumns())
        iniViewSelector(getViewCurrentPlaylist(), @currentPlaylistColumns)
        updateModelSelector()
        fillModelCurrent()
      }
    end
    
    # =====================================
    # Public Methods
    # =====================================
    
    # callback for saving information about PlaylistManagerGUI
    def save()
      log("save"){
        @application.saveCurrentPlaylist(@currentPlaylist) if @currentPlaylist
      }
    end
    
    # set the current playlist
    def pushCurrentPlaylist(pCurrentPlaylist)
      log("pushCurrentPlaylist") {
        fillModelCurrent(pCurrentPlaylist)
        updateInfoCurrentPlaylist()
      }
    end

    # clear the current playlist
    def clearCurrentPlaylist()
      if @modelCurrent
        @modelCurrent.clear
        @currentPlaylist.clear
      end
    end

    # return the select title view
    def getViewSelectTitle()
      view = @glade[W_VIEW_SELECT_TITLE]
      # log "getViewSelectTitle : " + view.class.to_s
      return view
    end

    # return the current playlist view
    def getViewCurrentPlaylist()
      view = @glade[W_VIEW_CURRENT_PLAYLIST]
      # log "getViewCurrentPlaylist : " + view.class.to_s
      return view
    end
    
    def isShuffleOnGenerate?()
      return @glade[W_SHUFFLE_ON_GENERATE].active?
    end
    
    def isLaunchOnGenerate?()
      return @glade[W_LAUNCH_ON_GENERATE].active?
    end
    
    def isAllowMultipleEntry?()
      return @glade[W_ALLOW_MULTIPLE_ENTRY].active?
    end
	 
    # update columns of the select title view
    def updateSelectTitleColumns()
      return unless @toyundaManagerGUI.getColumnSelectorGUI().changed?
      log("updateSelectTitleColumns"){
        view = getViewSelectTitle()
        clearColumn(view)
        iniViewColumns(view, getSelectTitleColumns())
        @toyundaManagerGUI.getColumnSelectorGUI().changeDone()
      }
    end
    
    # return the selector model
    def getModelSelector()
      return @modelSelector
    end

    # update the model selector using the quick filter and the filtered playlist
    def updateModelSelector()
      log("updateModelSelector") {
        @modelSelector.clear()
        fillModelSelector(@application.getFilteredList())
      }
    end

    # =====================================
    private 
    # =====================================

    def iniFilter()
      log("Quick Filter") {
        @quickFilter = Filter.new(CstsFilter::F_CONTAINS, CstsKaraoke::K_INI)
      }
    end

    def iniQuickSelectFilter()
      quickSelectFilter = @glade[W_QUICK_SELECT_FILTER]
      quickSelectFilter.model = @toyundaManagerGUI.getFilterEditorGUI().getModelCustomFilterCatalog()
      quickSelectFilter.text_column = 0
      index = @application.getActiveFilterIndex()
      index = -1 if index.nil?
      @glade[W_QUICK_SELECT_FILTER].active = index
    end

    # initialize allow multiple entry check button
    def iniAllowMultipleEntry()
      allowed = @application.configManager.is(CstsConfigManager::ALLOW_MULTIPLE_ENTRY)
      @glade[W_ALLOW_MULTIPLE_ENTRY].active = allowed
    end

		# initialize the shuffle on generate check box
		def iniShuffleOnGenerate()
			shuffleOnGenerate = @application.configManager.is(CstsConfigManager::SHUFFLE_ON_GENERATE)
			@glade[W_SHUFFLE_ON_GENERATE].active = shuffleOnGenerate
		end

    # initialize line number display for select title
    def iniLineNumberSelectTitle()
      displayed = @application.configManager.is(CstsConfigManager::LINE_NUMBER_SELECT_TITLE)
      @glade[W_CHECK_LINE_NUMBER_SELECT_TITLE].active = displayed
      getLineNumberColumn(getViewSelectTitle()).visible = displayed
    end

    # initialize line number display for select title
    def iniLineNumberCurrentPlaylist()
      displayed = @application.configManager.is(CstsConfigManager::LINE_NUMBER_CURRENT_PLAYLIST)
      @glade[W_CHECK_LINE_NUMBER_CURRENT_PLAYLIST].active = displayed
      getLineNumberColumn(getViewCurrentPlaylist()).visible = displayed
    end

    # return the list of ColumnMap for the current playlist view
    def iniCurrentPlaylistColumns()
      column = ColumnMap.new(CstsKaraoke::K_FULL_TITLE)
      column.styleDefault = @toyundaManagerGUI.getStyleEditorGUI().styleManager.default
      column.styleSelected = @toyundaManagerGUI.getStyleEditorGUI().styleManager.selected

      @currentPlaylistColumns = [
        column
      ]
    end
    
    # return the list of ColumnMap for the select title view
    def getSelectTitleColumns()
      @toyundaManagerGUI.getColumnSelectorGUI.getSelectTitleColumns()
    end
    
    # initialize the view for the karaoke selector
    def iniViewSelector(pView, pDisplayedColumn)
      
      iniViewColumns(pView, pDisplayedColumn)
      
			pView.selection.mode = Gtk::SELECTION_BROWSE
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
			pView.columns_autosize
    end

    # initialize columns for the given view with the given column list
    def iniViewColumns(pView, pDisplayedColumn)
      darker = 0
      pView.append_column(getLineNumberColumn(pView))
			pDisplayedColumn.each { |bColumnMap|
        if bColumnMap.visible?
          bColumnMap.darker(darker)
          pView.append_column(bColumnMap.gtkColumn)
          darker = 1 - darker
        end
      }
    end
    
    def getLineNumberColumn(pView)
      return @lineNumberColumn[pView] if @lineNumberColumn
      @lineNumberColumn = Hash.new
      [getViewSelectTitle(), getViewCurrentPlaylist()].each { |bView|
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new('#',renderer)
        column.resizable = true
        # @gtkColumn.reorderable = true
        column.clickable = false
        column.set_cell_data_func(renderer) { |bColumn, bRenderer, bModel, bRow|
          path = bRow.path
          bRenderer.text = path.to_s
        }
        @lineNumberColumn[bView] = column
      }
      return @lineNumberColumn[pView]
    end

    # initialize the data model for the karaoke selector
    def iniModelSelector()
      log("ini model selector") {
        if @modelSelector
          log("clear")
          @modelSelector.clear
        else
          log("create")
          @modelSelector = Gtk::ListStore.new(Application::Karaoke)
          @modelSelector.set_sort_column_id(0, Gtk::SORT_ASCENDING)
          @modelSelector.set_sort_func(0) { |bIter1, bIter2|
            karaoke1 = bIter1[0]
            karaoke2 = bIter2[0]
            ret, i = 0, 0
            sortColumnSelector = @toyundaManagerGUI.getColumnSelectorGUI().sortColumnSelector
            while (ret == 0 and i < sortColumnSelector.size)
              column = sortColumnSelector[i]
              v1 = karaoke1[column]
              v2 = karaoke2[column]
              if v1.nil? and v2.nil?
                ret = 0
              elsif v1.nil?
                ret = -1
              elsif v2.nil?
                ret = 1
              else
                ret = ( v1 <=> v2 )
              end
              i += 1
            end
            ret
          }
          getViewSelectTitle().model = @modelSelector
        end
      }
    end

    # initialize the data model for the current playlist    
    def iniModelCurrent()
      if @modelCurrent
        clearCurrentPlaylist()
      else
        @modelCurrent = Gtk::ListStore.new(Application::Karaoke)
        getViewCurrentPlaylist().model = @modelCurrent
      end
    end

    # fill the model for the karaoke selector with the given list
    def fillModelSelector(pKaraokeList = nil)
      log("fillModelSelector") {
        @displayedList.clear
        pKaraokeList.each { |bKaraoke|
          if @quickFilter.validate(bKaraoke)
            #~ log("+ "+bKaraoke.to_s)
            iter = @modelSelector.append()
            iter[0] = bKaraoke
            @displayedList << bKaraoke
          #~ else
            #~ log("- "+bKaraoke.to_s)
          end
        }
        getViewSelectTitle().columns_autosize
      }
    end
    
    # fill the model for the karaoke selector with the given list
    def fillModelCurrent(pKaraokeList = nil)
    	return if pKaraokeList.nil?
      pKaraokeList.each { |bKaraoke|
        iter = @modelCurrent.append()
        iter[0] = bKaraoke
        @currentPlaylist << bKaraoke
      }
    	getViewCurrentPlaylist().columns_autosize
    end
    
    # removes all column of the given view
    def clearColumn(pView)
      pView.columns.each { |bColumn|
        pView.remove_column(bColumn)
      }
    end
    
		# force an update on the current playlist
    def updateCurrentPlaylist()
    	@currentPlaylist.clear
      @modelCurrent.each { |bModel,bPath,bIter|
        karaoke = bIter[0]
        @currentPlaylist << karaoke
      }
      return @currentPlaylist
  	end
    
    # create and return displayed list in the select title view
    def getDisplayedList()
      return @displayedList
    end
    
    # add the given karaoke in the current playlist
    def addCurrentPlaylist(pKaraoke)
      rowCurrent = @modelCurrent.append
      rowCurrent[0] = pKaraoke
      @currentPlaylist << pKaraoke
      getViewCurrentPlaylist().scroll_to_cell(rowCurrent.path,nil, false, 0, 0)
      updateInfoCurrentPlaylist()
  	end
  	
  	# remove the element at the given path from the current playlist
  	def removeCurrentPlaylist(pPath)
  		log("remove from current playlist") {
	    	# get the position in the playlist
	    	position = pPath.indices[0]
	    	rowCurrent = @modelCurrent.get_iter(pPath)
	    	
	    	log("on_listCurrentPlaylist_row_activated ==> "+rowCurrent[0].to_s)
	    	@modelCurrent.remove(rowCurrent)
	    	# log("current size = "+@currentPlaylist.size.to_s)
	    	@currentPlaylist.delete_at(position)
	    	# log("current size ==> "+@currentPlaylist.size.to_s)
	      updateInfoCurrentPlaylist()
	    }
  	end

    def removeKaraokeFromPlaylist(pKaraoke)
  		log("remove karaoke from current playlist") {
        log("karaoke : "+pKaraoke.to_s)
        removeList = Array.new
        # creating reference of rows to remove
        @modelCurrent.each { |bModel, bPath, bIter|
          karaoke = bIter[0]
          if karaoke.ini == pKaraoke.ini
            log("remove : "+karaoke.to_s)
            removeList << Gtk::TreeRowReference.new(bModel,bPath)
          end
        }
        
        # removing rows from the reference list
        removeList.each { |bRef|
          path = bRef.path
          removeCurrentPlaylist(path)
        }
      }
    end

    # launch the given playlist in a background thread
    # the playlist can't be modified
    def launchPlaylistBackground(pPlaylist, pUpdate = true)
      videoPath = @application.configManager.getVideoFilePath()
      lyricsPath = @application.configManager.getLyricsFilePath()
      separator = @application.configManager.getFileSeparator()
      isFullScreen = @application.configManager.is(CstsConfigManager::FULL_SCREEN)
      player = @application.configManager[CstsConfigManager::MPLAYER_TOYUNDA_EXE]
      option = @application.configManager[CstsConfigManager::MPLAYER_OPTION]
      playlist = pPlaylist.getCopyList()
      @application.saveBackupPlaylist(playlist) if pUpdate
      Thread.new(@application) { |bApplication|
        @toyundaManagerGUI.reduce()
        played = @application.getKaraokeListService().launch(playlist, player, videoPath, lyricsPath, separator, isFullScreen, option) { |bKaraoke|
          setInfo("Playing",bKaraoke.to_s)
        }
        bApplication.updateData(played) if pUpdate
        # if all karaoke had not been played
        remainSize = playlist.size - played.size 
        if remainSize > 0 
          log("played "+played.size.to_s+"/"+playlist.size.to_s)
          # get the remaining title
          remain = playlist[played.size, remainSize]
          log("remaining : "+remain.size.to_s+" titles")
          # saving resume file
          filename = @application.saveResumePlaylist(remain)
          log("resume saved : "+filename.to_s)
          setError("Resume",filename.to_s)
        end
        @toyundaManagerGUI.restore()
      }
    end

    # called when we should update information about the current playlist
    def updateInfoCurrentPlaylist()
      log("updateInfoCurrentPlaylist") {
        log("number of title : "+@currentPlaylist.size.to_s)
        @glade[W_LABEL_NB_TITLES].text = @currentPlaylist.size.to_s
        
        totalLength = @application.getKaraokeListService().getTotalLengthMinute(@currentPlaylist)
        @glade[W_LABEL_TOTAL_TIME].text = totalLength.to_s
      }
    end
    
    # return the current selected karaoke or nil
    def getSelectedKaraoke(view = nil)
      view = getViewSelectTitle() if view.nil?
      rowSelected = view.selection.selected
      return nil if rowSelected.nil?
      karaoke = rowSelected[0]
      return karaoke
    end

    # return the current selected filter
    def getSelectedFilter()
      iter = @glade[W_QUICK_SELECT_FILTER].active_iter()
      if iter.nil?
        log("no active filter")
        return nil
      else
        customFilterName = iter[0]
        return customFilterName
      end
    end

    def redrawViews()
      @glade[W_VIEW_SELECT_TITLE].queue_draw
      @glade[W_VIEW_CURRENT_PLAYLIST].queue_draw
    end

    # =====================================
    public
    # =====================================
    # =====================================
    # Callback
    # =====================================

    # ---------------------------
    # Menu File
    # ---------------------------

    # export playlist
    def on_exportPlaylist_activate(pWidget)
      log("export playlist") {
        lastExport = @application.configManager[CstsConfigManager::LAST_EXPORT_PLAYLIST_FILE_NAME]
        fileName = GUI::selectFileDialog(@glade[W_WINDOW], "Export to ?", lastExport)
        return if fileName.nil?
        @application.configManager[CstsConfigManager::LAST_EXPORT_PLAYLIST_FILE_NAME] = fileName
        log("Import from "+fileName)
        currentPlaylist = @currentPlaylist
        @application.savePlaylist(fileName, currentPlaylist)
      }
    end
    
    # import playlist
    def on_importPlaylist_activate(pWidget)
      log("import playlist") {
        lastImport = @application.configManager[CstsConfigManager::LAST_IMPORT_PLAYLIST_FILE_NAME]
        fileName = GUI::selectOpenFileDialog(@glade[W_WINDOW], "Import from ?", lastImport)
        return if fileName.nil?
        @application.configManager[CstsConfigManager::LAST_IMPORT_PLAYLIST_FILE_NAME] = fileName
        log("Import from "+fileName)
        currentPlaylist = @application.loadPlaylist(fileName)
        pushCurrentPlaylist(currentPlaylist)
      }
    end

    # ---------------------------
    # Menu Edit
    # ---------------------------

    # refresh the filtered list displayed in the select title view
    def on_refreshList_activate(pWidget)
      log("refresh select title") {
        @application.clearFilteredList()
        customFilterName = getSelectedFilter()
        @application.selectFilter(customFilterName)
        updateModelSelector()
      }
    end
    
    # update karaoke list from ini
    def on_updateFromIni_activate(pWidget)
      log("Update from INI") {
        filePath = @application.configManager.getIniFilePath()
        Thread.new(getDisplayedList()) { |bList|
          @application.getKaraokeListService().updateKaraokeListFromIni(filePath, bList)
        }
      }
    end

    # clic on the menu button scan Length 
    def on_scanVideoInfo_activate(widget)
    	log("Updating video Info") {
        setInfo("Updating","Updating video Info")
        videoFilePath = @application.configManager.getVideoFilePath()
        scanlist = getDisplayedList().getCopyList()
        total = scanlist.size.to_s
        error = 0
        Thread.new() {
          i = 0
          @toyundaManagerGUI.startProgressBar(scanlist.size, "#{i}/#{total}")
          scanlist.each { |bKaraoke|
            i += 1
            setInfo("Scan "+i.to_s+"/"+total, bKaraoke.ini)
            ret = @application.getKaraokeService().updateVideoInfo(bKaraoke, videoFilePath)
            @toyundaManagerGUI.updateProgressBar("#{i}/#{total}")
            error += 1 unless ret
          }          
          setInfo("Scan "+i.to_s+"/"+total, "Finish with "+error.to_s+" error")
          @toyundaManagerGUI.stopProgressBar()
          redrawViews()
        }
      }
    end
    
    def on_scanRhythm_activate(pWidget)
      log("scan rhythm")
      setError("TODO", 'Scan for rhythm not implemented')
    end
    
    #~ def on_checkId_activate(pWidget)
      #~ log("check id") {
        #~ iniFilePath = @application.configManager.getIniFilePath()
        #~ error = @application.getKaraokeListService().checkIniFile(iniFilePath)
        #~ if error.empty?
          #~ setInfo("Check Id","No duplicate Id")
        #~ else
          #~ setError("Check Id","Duplicate Id found !")
        #~ end
      #~ }
    #~ end
    
    # clic on the menu button Reset Parameters
    def on_resetParameters_activate(widget)
      log("Reset Parameters") {
        @application.resetParameters()
        redrawViews()
      }
    end

    # ---------------------------
    # Menu Config
    # ---------------------------
    
    # toggle allow multiple entry.
    # when multiple entry is on, we can add the same karaoke in the playlist.
    # when off, selecting the same karaoke will remove it from the play list
    def on_allowMultipleEntry_activate(pWidget)
      @application.configManager[CstsConfigManager::ALLOW_MULTIPLE_ENTRY] = pWidget.active?
    end
    
    # menu shuffle on generate
    def on_shuffleOnGenerate_activate(pWidget)
			@application.configManager[CstsConfigManager::SHUFFLE_ON_GENERATE] = isShuffleOnGenerate?
    end

    # ---------------------------
    # Menu View
    # ---------------------------

    # display line number for select title
    def on_lineNumberSelectTitle_activate(pWidget)
      @application.configManager[CstsConfigManager::LINE_NUMBER_SELECT_TITLE] = pWidget.active?
      getLineNumberColumn(getViewSelectTitle()).visible = pWidget.active?
    end
    
    # display line number for current playlist
    def on_lineNumberCurrentPlaylist_activate(pWidget)
      @application.configManager[CstsConfigManager::LINE_NUMBER_CURRENT_PLAYLIST] = pWidget.active?
      getLineNumberColumn(getViewCurrentPlaylist()).visible = pWidget.active?
    end

    # ---------------------------
    # Menu MIO
    # ---------------------------
    
		def on_launchMIO_activate(pWidget)
			if pWidget.active?
				@application.startMIO()
			else
				@application.stopMIO()
			end
		end
	
    # ---------------------------
    # Actions
    # ---------------------------
    
    # modification in the entry "Quick Filter"
    def on_entryQuickFilter_changed(widget)
      @quickFilter.value = @glade[W_QUICK_FILTER].text
      log("Quick Filter : "+@quickFilter.value) {
        updateModelSelector()
      }
    end
    
    # select new custom filter
    def on_comboboxQuickSelectFilter_changed(pWidget)
      log("Quick Select Filter") {
        customFilterName = getSelectedFilter()
        @application.selectFilter(customFilterName)
        updateModelSelector()
      }
    end

    # clic on the button "Unselect"
    def on_buttonUnselect_clicked(widget)
      clearCurrentPlaylist()
      updateInfoCurrentPlaylist()
      redrawViews()
    end

    # Randomly pick 1 music in the current view
    def on_buttonPick_clicked(pWidget)
      log('pick'){
        copyList = getDisplayedList().getCopyList()
        unless isAllowMultipleEntry?() or @currentPlaylist.nil?
          @currentPlaylist.each { |bKaraoke|
            copyList.delete(bKaraoke)
          }
        end
        karaoke = @application.getKaraokeListService().pick(copyList)
        addCurrentPlaylist(karaoke) unless karaoke.nil?
        redrawViews()
      }
    end

    # clic on the Shuffle! button
    def on_buttonShuffle_clicked(widget)
      log("Shuffle playlist") {
        setInfo("Run","Shuffle playlist")
        shuffledPlaylist = @application.getKaraokeListService().shuffle(@currentPlaylist)
        clearCurrentPlaylist()
        fillModelCurrent(shuffledPlaylist)
      }
    end
    
    # clic on the generate button
    def on_buttonGenerate_clicked(widget)
      log("Generate playlist") {
        setInfo("Run","Generate playlist")
        updateCurrentPlaylist()
        playlist = @currentPlaylist
        if @application.configManager.isShuffleOnGenerate()
            playlist = @application.getKaraokeListService().shuffle(playlist)
        end
        @application.generatePlaylist(playlist)
        if isLaunchOnGenerate?
          log("launching Toyunda Player")
          setInfo("Run","Launching Toyunda Player")
          launchPlaylistBackground(playlist, false)
        end
        redrawViews()
      }
    end
    
    # launch the current playlist
    def on_buttonLaunch_clicked(pWidget)
      log("Launch") {
        @application.saveBackupPlaylist(@currentPlaylist)
        launchPlaylistBackground(@currentPlaylist)
      }
    end

    # ---------------------------
    # View
    # ---------------------------
    
    # double-clic a row of the Title Selector
    def on_listSelectTitle_row_activated(pWidget, pPath, pColumn)
      rowSelected = pWidget.model.get_iter(pPath)
      karaoke = rowSelected[0]
      if @currentPlaylist.getByIni(karaoke.ini).nil?
        addCurrentPlaylist(karaoke)
      elsif isAllowMultipleEntry?()
        addCurrentPlaylist(karaoke)
      else
        removeKaraokeFromPlaylist(karaoke)
      end
    end
    
    # double-clic a row of the Current Playlist table
    def on_listCurrentPlaylist_row_activated(pWidget, pPath, pColumn)
    	removeCurrentPlaylist(pPath)
      redrawViews()
    end

    # selection of a row in the listSelectTitle view
    def on_listSelectTitle_cursor_changed(pWidget)
      rowSelected = getViewSelectTitle().selection.selected
      return if rowSelected.nil?
      karaoke = rowSelected[0]
      setInfo("Select",karaoke.ini.to_s)
    end
    
    # selection of a row in the listSelectTitle view
    def on_listCurrentPlaylist_cursor_changed(pWidget)
      rowSelected = getViewCurrentPlaylist().selection.selected
      karaoke = rowSelected[0]
      setInfo("Select",karaoke.ini.to_s)
    end
    
    def on_listCurrentPlaylist_drag_end(*pArg)
      updateCurrentPlaylist()
    end
    
    # ---------------------------
    # Select title context menu
    # ---------------------------
    
    # right clic on the select title view
    def on_listSelectTitle_button_press_event(pWidget, pEvent)
			if pEvent.kind_of? Gdk::EventButton and pEvent.button == 3
        #~ log("event : "+pEvent.x.to_s+" x "+pEvent.y.to_s)
        # select current row
        @popupView = getViewSelectTitle()
				select = @popupView.selection
				return if select.nil?
        path,column,*other = @popupView.get_path_at_pos(pEvent.x, pEvent.y)
				return if path.nil?
        select.select_path(path)
        # display popup menu
        @glade[W_MENU_CTX_SELECT_TITLE].popup(nil, nil, pEvent.button, pEvent.time)
			end
    end
    
    def on_listCurrentPlaylist_button_press_event(pWidget, pEvent)
			if pEvent.kind_of? Gdk::EventButton and pEvent.button == 3
        #~ log("event : "+pEvent.x.to_s+" x "+pEvent.y.to_s)
        # select current row
        @popupView = getViewCurrentPlaylist()
				select = @popupView.selection
				return if select.nil?
        path,column,*other = @popupView.get_path_at_pos(pEvent.x, pEvent.y)
        return if path.nil?
				select.select_path(path)
        # display popup menu
        @glade[W_MENU_CTX_SELECT_TITLE].popup(nil, nil, pEvent.button, pEvent.time)
			end
    end
    
    # launch selected karaoke
    def on_ctxLaunch_activate(pWidget)
      karaoke = getSelectedKaraoke(@popupView)
      return if karaoke.nil?
      player = @application.configManager[CstsConfigManager::MPLAYER_TOYUNDA_EXE]
      videoPath = @application.configManager.getVideoFilePath()
      lyricsPath = @application.configManager.getLyricsFilePath()
      separator = @application.configManager.getFileSeparator()
      isFullScreen = @application.configManager.is(CstsConfigManager::FULL_SCREEN)
      option = @application.configManager[CstsConfigManager::MPLAYER_OPTION]
      log("Launch : "+karaoke.to_s) {
        setInfo("Launch", "Launching "+karaoke.ini.to_s)
        Thread.new(karaoke) { |bKaraoke|
          @application.getKaraokeService().launch(bKaraoke, player, videoPath, lyricsPath, separator, isFullScreen, option)
        }
      }
    end
    
    # parse ini of the selected karaoke to get video and lyrics info
    def on_ctxUpdateVideoLyrics_activate(pWidget)
      karaoke = getSelectedKaraoke(@popupView)
      return if karaoke.nil?
      filePath = @application.configManager.getIniFilePath()
      log("update : "+karaoke.to_s) {
        @application.getKaraokeService().updateKaraokeFromIni(filePath, karaoke)
      }
    end
    
    # scan for length of the selected karaoke
    def on_ctxScanVideo_activate(pWidget)
      karaoke = getSelectedKaraoke(@popupView)
      return if karaoke.nil?
      videoPath = @application.configManager.getVideoFilePath()
      log("Scan Length : "+karaoke.to_s) {
        @application.getKaraokeService().updateVideoInfo(karaoke, videoPath)
        setInfo("Scan Video", '['+karaoke[CstsKaraoke::K_LENGTH].to_s+'s] '+karaoke.ini)
      }
    end
    
    # scan for rythm of the selected karaoke
    def on_ctxScanRythm_activate(pWidget)
      log("scan rhythm")
      setError("TODO", 'Scan for rhythm not implemented')
      karaoke = getSelectedKaraoke(@popupView)
      return if karaoke.nil?
      log('column : '+karaoke.to_s){
        karaoke.getColumns().each { |bKey|
          v = karaoke[bKey]
          v = 'nil' if v.nil?
          log(bKey.to_s+' = '+v.to_s)
        }
      }
    end
    
  end
  
end

puts "-- PlaylistManagerGUI"
