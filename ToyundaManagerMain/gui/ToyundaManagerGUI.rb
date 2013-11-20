
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Toyunda Manager GUI
# ==========================================================
# Description :
# GUI For the toyunda manager main window.
# Require libglade2 to work.
# ==========================================================

puts "require ToyundaManagerGUI"

# ----------------------------------------------------------
require 'gtk2'
require $root+ "Common"
require $root+ "constants/CstsConfigManager"
require $root+ "gui/GUI"
require $root+ "glade/GladeLoader"
require $root+ "application/ToyundaManager"
require $root+ "gui/ProfileSelectorGUI"
require $root+ "gui/ConfigManagerGUI"
require $root+ "gui/ColumnSelectorGUI"
require $root+ "gui/StyleEditorGUI"
require $root+ "gui/PlaylistManagerGUI"
require $root+ "gui/FilterEditorGUI"
require $root+ "gui/MergeDataGUI"
require $root+ "gui/ListSelectorGUI"

# ----------------------------------------------------------

puts "++ ToyundaManagerGUI"

module GUI

  class ToyundaManagerGUI
    include Common
    include GladeLoader
    
    attr_reader :application

    
    # =================================
    # Constants
    # ---------------------------------
		GLADE_FILE = $root+"glade/ToyundaManager"
    W_WINDOW = "toyundaManager"
    W_TASK_C = "taskC"
    W_TASK_L = "taskL"
    W_TASK_R = "taskR"
    W_HPANE = "hpanedList"
    W_PLAYLIST_VP = "viewportPlaylist"
    W_PL_SELECTOR = "viewportSelectTitle"
    W_PL_CURRENT = "viewportCurrentPlaylist"
    W_VERTICAL_DISPLAY = "verticalDisplay"
    W_HORIZONTAL_DISPLAY = "horizontalDisplay"
    W_PROGRESS_BAR = "progressbar"
    W_ABOUT_DIALOG = "aboutdialog"


    # =================================
    public
    # ---------------------------------
    def initialize()
      log("initialize") {
        @application = Application::ToyundaManager.new()
				@application.gui = self
        iniGlade(GLADE_FILE)
        @plPane = @glade[W_HPANE]
      }
    end
    
    # start the GUI
    def start()
      log("start") {
        getProfileSelector().start()
      }
    end
    
    # lazy creation of the profile selector
    def getProfileSelector()
      unless @profileSelector
        @profileSelector = ProfileSelectorGUI.new(self, @application.getProfileSelector())
      end
      return @profileSelector
    end
    
    # callback for the profile change
    def callProfileChange()
      log("callProfileChange") {
        destroyProfileSelector()
        reload()
      }
    end
    
    def getConfigManagerGUI()
      return @configManagerGUI if @configManagerGUI
      @configManagerGUI = ConfigManagerGUI.new(self)
      @configManagerGUI.subInitialize()
      return @configManagerGUI
    end
    
    def getColumnSelectorGUI()
      return @columnSelectorGUI if @columnSelectorGUI
      @columnSelectorGUI = ColumnSelectorGUI.new(self)
      @columnSelectorGUI.subInitialize()
      return @columnSelectorGUI
    end

    def getStyleEditorGUI()
      return @styleEditorGUI if @styleEditorGUI
      @styleEditorGUI = StyleEditorGUI.new(self)
      @styleEditorGUI.subInitialize()
      return @styleEditorGUI
    end
    
    def getPlaylistManagerGUI()
      return @playlistManagerGUI if @playlistManagerGUI
      @playlistManagerGUI = PlaylistManagerGUI.new(self)
      @playlistManagerGUI.subInitialize()
      return @playlistManagerGUI
    end
    
    def getFilterEditorGUI()
      return @filterEditorGUI if @filterEditorGUI
      @filterEditorGUI = FilterEditorGUI.new(self)
      @filterEditorGUI.subInitialize()
      return @filterEditorGUI
    end

    def getMergeDataGUI()
      return @mergeDataGUI if @mergeDataGUI
      @mergeDataGUI = MergeDataGUI.new(self)
      @mergeDataGUI.subInitialize()
      return @mergeDataGUI
    end

    def reduce()
      @glade[W_WINDOW].iconify()
    end
    
    def restore()
      @glade[W_WINDOW].deiconify()
    end

    # =================================
    # Progress Bar
    # ---------------------------------

    def startProgressBar(pSize, pText = nil)
      @glade[W_PROGRESS_BAR].fraction = 0.0
      @glade[W_PROGRESS_BAR].text = pText if pText
      @glade[W_PROGRESS_BAR].visible = true
      @progressBarStep = (1.0/pSize.to_f).to_f
    end

    def stopProgressBar()
      @glade[W_PROGRESS_BAR].visible = false
      @glade[W_PROGRESS_BAR].fraction = 0.0
      @glade[W_PROGRESS_BAR].text = ""
    end

    def updateProgressBar(pText = nil)
      old = @glade[W_PROGRESS_BAR].fraction
      @progressBarStep = 0.1 unless @progressBarStep
      @glade[W_PROGRESS_BAR].fraction = old + @progressBarStep
      log("fraction #{@glade[W_PROGRESS_BAR].fraction}")
      @glade[W_PROGRESS_BAR].text = pText if pText
    end

    # =================================
    private
    # ---------------------------------
    
    # =================================
    # Utils
    # ---------------------------------

    def reload()
      log("Reload") {
        reloadData()
        reloadGUI()
        getMergeDataGUI().doMerge(@application.iniList, @application.csvList) { |bMerger|
          @application.mergeReloadedData(bMerger)
          getColumnSelectorGUI().addColumnList(bMerger.mainList.getColumns)
          getPlaylistManagerGUI().updateSelectTitleColumns()
          getPlaylistManagerGUI().updateModelSelector()
        }
      }
    end

    def reloadData()
      log("reload Data") {
        profile = @application.profile
        unless profile
          setError("Load", "No profile, can't reload")
          return
        end
        #~ startProgressBar(1.0/8.0, "profile")
        setInfo("Load", "Loading profile data for "+profile)
        setTaskR(profile)
        
        #~ updateProgressBar("start")
        # (re) initialisation de l'application
        @application.start()
      }
    end
    
    # reload the GUI
    def reloadGUI()
      log("reload GUI") {
        #~ updateProgressBar("config")
        reloadConfigManager()
        
        #~ updateProgressBar("style")
        reloadStyleEditor()
        
        #~ updateProgressBar("column")
        reloadColumnSelector()
        
        #~ updateProgressBar("filter")
        reloadFilterEditor()
        
        #~ updateProgressBar("data")
        reloadPlaylistManager()
        
        #~ updateProgressBar("last playlist")
        reloadLastPlaylist()
        
        #~ updateProgressBar("data")
				reloadPlaylistDisplay()
        
        #~ stopProgressBar()
      }
    end
    
    # create or reset configManagerGUI elements
    def reloadConfigManager()
      if @configManagerGUI
        @configManagerGUI.reset()
      else
        getConfigManagerGUI()
      end
    end
    
    # create or reset configManagerGUI elements
    def reloadPlaylistManager()
      if @playlistManagerGUI
        @playlistManagerGUI.reset()
      else
        getPlaylistManagerGUI()
      end
    end

    # create or reset styleEditorGUI elements
    def reloadStyleEditor()
      if @styleEditorGUI
        @styleEditorGUI.reset()
      else
        getStyleEditorGUI()
      end
    end
    
    # create or reset columnSelectorGUI elements
    def reloadColumnSelector()
      if @columnSelectorGUI
        @columnSelectorGUI.reset()
      else
        getColumnSelectorGUI()
      end
    end
    
    # create or reset filter editor gui elements
    def reloadFilterEditor()
      if @filterEditorGUI
        @filterEditorGUI.reset()
      else
        getFilterEditorGUI()
      end
    end

    # reload the playlist display 
		def reloadPlaylistDisplay()
      log("reloadPlaylistDisplay") {
        # set the display (vertical or horizontal)
        displayVertical = @application.configManager.is(CstsConfigManager::PLAYLIST_DISPLAY_VERTICAL)

        log("display Vertical ? "+displayVertical.to_s) unless displayVertical.nil?
        if displayVertical.nil? or displayVertical
          log("active vertical")
          @glade[W_VERTICAL_DISPLAY].active = true
          @glade[W_HORIZONTAL_DISPLAY].active = false
          on_verticalDisplay_activate(@glade[W_VERTICAL_DISPLAY])
        else
          log("active horizontal")
          @glade[W_VERTICAL_DISPLAY].active = false
          @glade[W_HORIZONTAL_DISPLAY].active = true
          on_horizontalDisplay_activate(@glade[W_HORIZONTAL_DISPLAY])
        end
        # set the position of the separator
        percent = @application.configManager.number(CstsConfigManager::PLAYLIST_SEPARATOR_POSITION)
        percent = 50 if percent == 0
        setPosition(percent)
      }
		end
		
		# reload last playlist
		def reloadLastPlaylist()
      currentPlaylist = @application.loadCurrentPlaylist()
      log("currentPlaylist.size = " + currentPlaylist.size.to_s)
      getPlaylistManagerGUI().pushCurrentPlaylist(currentPlaylist)
		end

    # destroy the profile selector
    def destroyProfileSelector()
      @profileSelector = nil
      @application.destroyProfileSelector()
    end
    
    # closing the GUI
    def close()
      if @application and @application.isSaveOnClose()
        save()
      end
    end
    
    # saving the GUI
    def save()
      log("save") {
        getPlaylistManagerGUI().save()
        getStyleEditorGUI().save()
        getColumnSelectorGUI().save()
        getFilterEditorGUI().save()
        getConfigManagerGUI().save()
        
        # save display position
        position = getPosition()
        @application.configManager[CstsConfigManager::PLAYLIST_SEPARATOR_POSITION] = position
        
        # save display type vertical / horizontal
        displayVertical = @glade[W_VERTICAL_DISPLAY].active?
        @application.configManager[CstsConfigManager::PLAYLIST_DISPLAY_VERTICAL] = displayVertical.to_s

        # finally saving application
        @application.save
      }
    end
    
    # get the position of the separator of the playlist display in percent
    def getPosition()
      log("getPosition") {
        position = @plPane.position
        vp = @glade[W_PLAYLIST_VP]
        width = vp.allocation.width
        height = vp.allocation.height
        percent = nil
        log("w x h = "+width.to_s+" x "+height.to_s)
        if @plPane.instance_of?(Gtk::HPaned)
          percent = 100 * position / width
          log("vertical position = "+position.to_s+" => "+percent.to_s+" %")
        else
          percent = 100 * position / height
          log("horizontal position = "+position.to_s+" => "+percent.to_s+" %")
        end
        return percent
      }
    end
    
    # set the display position according to the saved config
    def setPosition(pPercent)
      log("setPosition") {
        return if pPercent.nil?
        pPercent = pPercent.to_i
        vp = @glade[W_PLAYLIST_VP]
        width = vp.allocation.width
        height = vp.allocation.height
        position = nil
        log("w x h = "+width.to_s+" x "+height.to_s)
        if @plPane.instance_of?(Gtk::HPaned)
          position = pPercent * width / 100
          log("vertical position = "+pPercent.to_s+" % => "+position.to_s)
        else
          position = pPercent * height / 100
          log("horizontal position = "+pPercent.to_s+" % => "+position.to_s)
        end
        @plPane.position = position
      }
    end
     
    # =================================
    # Controle
    # ---------------------------------

    # escape the given message for markup formating
    def escapeMarkup(pMsg)
      # <    >    &
      # &lt; &gt;  &amp;
      msg = pMsg.gsub('&', '&amp;')
      msg = msg.gsub('>', '&gt;')
      msg = msg.gsub('<', '&lt;')
    end
    
    # set the givem message in the task bar with the give label
    def setTask(lbl, msg, color= INFO_COLOR)
      s = '<span foreground="'+color+'"><b>'+ escapeMarkup(msg) +'</b></span>'
      @glade[lbl].markup = s
    end

    def setTaskC(msg, color= INFO_COLOR)
      setTask(W_TASK_C, msg, color)
    end

    def setTaskL(msg, color= INFO_COLOR)
      setTask(W_TASK_L, msg, color)
    end

    def setTaskR(msg, color= PROFILE_COLOR)
      setTask(W_TASK_R, msg, color)
    end
    
    # =================================
    public
    # =================================
    
    def setInfo(type, msg)
      setTaskL(type)
      setTaskC(msg, MSG_COLOR)
    end

    def setError(type, msg)
      setTaskL(type)
      setTaskC(msg, ERROR_COLOR)
    end
    
    # return the main window of the GUI
    def getWindow()
      return @glade[W_WINDOW]
    end
    
    
    # =================================
    private
    # =================================
    
    # =================================
    # Handler
    # ---------------------------------

    # handle the saving of the application
    def on_itemSave_activate(widget)
      log("save") {
        setInfo("Save", "Saving Profile "+@application.profile)
        save()
      }
    end

    #~ def on_saveIdInIniFile_activate(pWidget)
      #~ log("save all id in INI") {
        #~ log("function removed")
        #~ @application.saveAllIni()
      #~ }
    #~ end

    # reload the ini files and profile
    def on_reload_activate(widget)
      reload()
    end

    # change the current profile, display the profile selector dialog
    def on_changeProfile_activate(widget)
     	getProfileSelector().start()
    end

    # export data into cev
    def on_exportData_activate(pWidget)
      lastExport = @application.configManager[CstsConfigManager::LAST_EXPORT_FILE_NAME]
      fileName = GUI::selectFileDialog(@glade[W_WINDOW], "Export to ?", lastExport, ["*.csv"])
      return if fileName.nil?
      @application.configManager[CstsConfigManager::LAST_EXPORT_FILE_NAME] = fileName
      log("export to "+fileName)
      @application.exportData(fileName)
    end
    
    # load data from a csv
    def on_importData_activate(pWidget)
      lastImport = @application.configManager[CstsConfigManager::LAST_IMPORT_FILE_NAME]
      fileName = GUI::selectOpenFileDialog(@glade[W_WINDOW], "Import from ?", lastImport, ["*.csv"])
      return if fileName.nil?
      @application.configManager[CstsConfigManager::LAST_IMPORT_FILE_NAME] = fileName
      log("Import from "+fileName)
      importedData = @application.getKaraokeListService().loadCSV(fileName)
      currentData = @application.listAll
      getMergeDataGUI().doMerge(currentData, importedData) { |bMerger|
        listSelector = ListSelectorGUI.new(getMergeDataGUI().getWindow())
        listSelector.setStyleManager(getStyleEditorGUI().styleManager)
        listSelector.setTitle('Select columns to be imported')
        listSelector.select(importedData.getColumns()) { |bColumnList, bSelectedList|
          @application.mergeData(bMerger, bSelectedList)
          getColumnSelectorGUI().addColumnList(bSelectedList)
          getPlaylistManagerGUI().updateSelectTitleColumns()
          getPlaylistManagerGUI().updateModelSelector()
        }
      }
    end

    def on_importConfig_activate(*pArg)
      lastImport = @application.configManager[CstsConfigManager::LAST_IMPORT_CONFIG_FILE_NAME]
      fileName = GUI::selectOpenFileDialog(@glade[W_WINDOW], "Import Config from ?", lastImport, ["*.ini"])
      return if fileName.nil?
      @application.configManager.importConfig(fileName)
      @application.configManager[CstsConfigManager::LAST_IMPORT_CONFIG_FILE_NAME] = fileName
      reload()
    end

    # exit the application, destroying the GUI
    def on_exit_activate(widget)
      getWindow().destroy()
    end
	
    # ---------------------------------
    def on_toyundaManager_delete_event(widget, arg0)
      log("on_toyundaManager_delete_event")
      false
    end

    # exit properly the application
    def on_toyundaManager_destroy(widget)
      log("closing application..."){
	      # closing GUI
	      close()
	      # closing application
	      # @application.close() if @application
	      Gtk.main_quit
    	}
    end

    # ---------------------------------
    # set the display of the playlist horizontal
    def on_horizontalDisplay_activate(widget)
      log("set Horizontal Display") {
        return unless @glade[W_HORIZONTAL_DISPLAY].active?
        vp = @glade[W_PLAYLIST_VP]
        position = getPosition()
        @plPane.remove(@glade[W_PL_SELECTOR])
        @plPane.remove(@glade[W_PL_CURRENT])
        vpane = Gtk::VPaned.new
        vpane.add1(@glade[W_PL_SELECTOR])
        vpane.add2(@glade[W_PL_CURRENT])
        vp.remove(@plPane)
        vp.add(vpane)
        @plPane = vpane
        @plPane.show
        setPosition(position)
      }
    end
    
    # set the display of the playlist vertical
    def on_verticalDisplay_activate(widget)
      log("set Vertical Display") {
        return unless @glade[W_VERTICAL_DISPLAY].active?
        vp = @glade[W_PLAYLIST_VP]
        position = getPosition()
        @plPane.remove(@glade[W_PL_SELECTOR])
        @plPane.remove(@glade[W_PL_CURRENT])
        vpane = Gtk::HPaned.new
        vpane.add1(@glade[W_PL_SELECTOR])
        vpane.add2(@glade[W_PL_CURRENT])
        vp.remove(@plPane)
        vp.add(vpane)
        @plPane = vpane
        @plPane.show
        setPosition(position)
      }
    end

    # update when changing tab
    def on_tabMain_switch_page(*args)
      log("Tab Changed") {
        getPlaylistManagerGUI().updateSelectTitleColumns()
      }
    end

    # ---------------------------
    # Menu Info (?)
    def on_about_activate(*pArg)
      GUI::popupInfo(["Toyunda Manager 2 v#{INFO_VERSION}", "by #{INFO_AUTHOR}"], getWindow())
    end

    # =================================
    # Config Manager GUI Handler
    # ---------------------------------
    
    def on_checkSaveOnClose_toggled(widget)
      getConfigManagerGUI().on_checkSaveOnClose_toggled(widget)
    end

    def on_buttonIniPath_clicked(widget)
      getConfigManagerGUI().on_buttonIniPath_clicked(widget)
    end

    def on_entryIniPath_focus_out_event(widget, arg0)
      return getConfigManagerGUI().on_entryIniPath_focus_out_event(widget, arg0)
    end

    def on_buttonPlaylistFile_clicked(widget)
      getConfigManagerGUI().on_buttonPlaylistFile_clicked(widget)
    end

    def on_entryPlaylistFile_focus_out_event(widget, arg0)
      return getConfigManagerGUI().on_entryPlaylistFile_focus_out_event(widget, arg0)
    end

    def on_buttonPlaylistBackUp_clicked(widget)
      getConfigManagerGUI().on_buttonPlaylistBackUp_clicked(widget)
    end

    def on_entryPlaylistBackUp_focus_out_event(widget, arg0)
      return getConfigManagerGUI().on_entryPlaylistBackUp_focus_out_event(widget, arg0)
    end

    def on_checkLaunchOnGenerate_toggled(widget)
      getConfigManagerGUI().on_checkLaunchOnGenerate_toggled(widget)
    end

    def on_buttonVideoPath_clicked(widget)
      getConfigManagerGUI().on_buttonVideoPath_clicked(widget)
    end

    def on_entryVideoPath_focus_out_event(widget, arg0)
      return getConfigManagerGUI().on_entryVideoPath_focus_out_event(widget, arg0)
    end

    def on_buttonLyricsPath_clicked(widget)
      getConfigManagerGUI().on_buttonLyricsPath_clicked(widget)
    end

    def on_entryLyricsPath_focus_out_event(widget, arg0)
      return getConfigManagerGUI().on_entryLyricsPath_focus_out_event(widget, arg0)
    end

    def on_checkFullScreen_toggled(*pArg)
      getConfigManagerGUI().on_checkFullScreen_toggled(*pArg)
    end

    def on_comboboxOSselector_changed(*pArg)
      getConfigManagerGUI().on_comboboxOSselector_changed(*pArg)
    end

    def on_buttonSelectPlayer_clicked(*pArg)
      getConfigManagerGUI().on_buttonSelectPlayer_clicked(*pArg)
    end

    def on_entryMPlayerOption_focus_out_event(*pArg)
      return getConfigManagerGUI().on_entryMPlayerOption_focus_out_event(*pArg)
    end

    # =================================
    # Playlist Manager GUI Handler
    # ---------------------------------

    # ---------------------------
    # Menu File
    
    def on_exportPlaylist_activate(pWidget)
      getPlaylistManagerGUI().on_exportPlaylist_activate(pWidget)
    end
    
    def on_importPlaylist_activate(pWidget)
      getPlaylistManagerGUI().on_importPlaylist_activate(pWidget)
    end

    # ---------------------------
    # Menu Edit
    
    def on_refreshList_activate(pWidget)
      getPlaylistManagerGUI().on_refreshList_activate(pWidget)
    end
    
    def on_updateFromIni_activate(pWidget)
      getPlaylistManagerGUI().on_updateFromIni_activate(pWidget)
    end

    def on_scanVideoInfo_activate(widget)
    	getPlaylistManagerGUI().on_scanVideoInfo_activate(widget)
    end
    
    #~ def on_scanRhythm_activate(pWidget)
      #~ getPlaylistManagerGUI().on_scanRhythm_activate(pWidget)
    #~ end
    
    #~ def on_checkId_activate(pWidget)
      #~ getPlaylistManagerGUI().on_checkId_activate(pWidget)
    #~ end
    
    def on_resetParameters_activate(widget)
      getPlaylistManagerGUI().on_resetParameters_activate(widget)
    end
    
    # ---------------------------
    # Menu Config
    
    def on_allowMultipleEntry_activate(pWidget)
      getPlaylistManagerGUI().on_allowMultipleEntry_activate(pWidget)
    end
    
    def on_shuffleOnGenerate_activate(pWidget)
      getPlaylistManagerGUI().on_shuffleOnGenerate_activate(pWidget)
    end
    
    # ---------------------------
    # Menu View

    def on_lineNumberSelectTitle_activate(pWidget)
      getPlaylistManagerGUI().on_lineNumberSelectTitle_activate(pWidget)
    end
    
    def on_lineNumberCurrentPlaylist_activate(pWidget)
      getPlaylistManagerGUI().on_lineNumberCurrentPlaylist_activate(pWidget)
    end

    # ---------------------------
    # Menu MIO
	
		def on_launchMIO_activate(pWidget)
			getPlaylistManagerGUI().on_launchMIO_activate(pWidget)
		end
	
    # ---------------------------
    # Action
    
    def on_entryQuickFilter_changed(widget)
      getPlaylistManagerGUI().on_entryQuickFilter_changed(widget)
    end
    
    def on_comboboxQuickSelectFilter_changed(pWidget)
      getPlaylistManagerGUI().on_comboboxQuickSelectFilter_changed(pWidget)
    end
    
		#~ def on_checkShuffleOnGenerate_toggled(widget)
      #~ getPlaylistManagerGUI().on_checkShuffleOnGenerate_toggled(widget)
		#~ end

    def on_buttonUnselect_clicked(widget)
      getPlaylistManagerGUI().on_buttonUnselect_clicked(widget)
    end

    def on_buttonPick_clicked(pWidget)
      getPlaylistManagerGUI().on_buttonPick_clicked(pWidget)
    end
    
    def on_buttonShuffle_clicked(widget)
      getPlaylistManagerGUI().on_buttonShuffle_clicked(widget)
    end
    
    def on_buttonGenerate_clicked(widget)
      getPlaylistManagerGUI().on_buttonGenerate_clicked(widget)
    end
    
    def on_buttonLaunch_clicked(pWidget)
      getPlaylistManagerGUI().on_buttonLaunch_clicked(pWidget)
    end
    
    # ---------------------------
    # View
    
    def on_listSelectTitle_row_activated(pWidget, pPath, pColumn)
      getPlaylistManagerGUI().on_listSelectTitle_row_activated(pWidget, pPath, pColumn)
    end
    
    def on_listCurrentPlaylist_row_activated(pWidget, pPath, pColumn)
    	getPlaylistManagerGUI().on_listCurrentPlaylist_row_activated(pWidget, pPath, pColumn)
    end
    
    def on_listCurrentPlaylist_drag_end(*pArg)
      getPlaylistManagerGUI().on_listCurrentPlaylist_drag_end(*pArg)
    end

    def on_listSelectTitle_cursor_changed(pWidget)
      getPlaylistManagerGUI().on_listSelectTitle_cursor_changed(pWidget)
    end
    
    def on_listCurrentPlaylist_cursor_changed(pWidget)
      getPlaylistManagerGUI().on_listCurrentPlaylist_cursor_changed(pWidget)
    end
    
    # ---------------------------
    # Context Menu

    def on_listSelectTitle_button_press_event(pWidget, pEvent)
      getPlaylistManagerGUI().on_listSelectTitle_button_press_event(pWidget, pEvent)
    end

    def on_listCurrentPlaylist_button_press_event(pWidget, pEvent)
      getPlaylistManagerGUI().on_listCurrentPlaylist_button_press_event(pWidget, pEvent)
    end

    def on_ctxLaunch_activate(pWidget)
      getPlaylistManagerGUI().on_ctxLaunch_activate(pWidget)
    end

    def on_ctxUpdateVideoLyrics_activate(pWidget)
      getPlaylistManagerGUI().on_ctxUpdateVideoLyrics_activate(pWidget)
    end
    
    def on_ctxScanVideo_activate(pWidget)
      getPlaylistManagerGUI().on_ctxScanVideo_activate(pWidget)
    end
    
    def on_ctxScanRythm_activate(pWidget)
      getPlaylistManagerGUI().on_ctxScanRythm_activate(pWidget)
    end


    # =================================
    # Style Editor GUI Handler
    # ---------------------------------

    def on_buttonAddStyle_clicked(*pArg)
      getStyleEditorGUI().on_buttonAddStyle_clicked(*pArg)
    end

    def on_buttonDeleteStyle_clicked(*pArg)
      getStyleEditorGUI().on_buttonDeleteStyle_clicked(*pArg)
    end

    def on_comboboxSelectStyle_changed(*pArg)
      getStyleEditorGUI().on_comboboxSelectStyle_changed(*pArg)
    end
  
    def on_fontbuttonStyleFont_font_set(*pArg)
      getStyleEditorGUI().on_fontbuttonStyleFont_font_set(*pArg)
    end
  
    def on_colorbuttonStyleForeground_color_set(*pArg)
      getStyleEditorGUI().on_colorbuttonStyleForeground_color_set(*pArg)
    end
    
    def on_colorbuttonStyleBackground_color_set(*pArg)
      getStyleEditorGUI().on_colorbuttonStyleBackground_color_set(*pArg)
    end
  
    def on_spinbuttonStyleHighlight_changed(*pArg)
      getStyleEditorGUI().on_spinbuttonStyleHighlight_changed(*pArg)
    end

    # =================================
    # Column Selector GUI Handler
    # ---------------------------------

    def on_treeviewColumnSelector_row_activated(pWidget, pPath, pColumn)
      getColumnSelectorGUI().on_treeviewColumnSelector_row_activated(pWidget, pPath, pColumn)
    end

    def on_treeviewColumnSelector_cursor_changed(pWidget)
      getColumnSelectorGUI().on_treeviewColumnSelector_cursor_changed(pWidget)
    end

    def on_treeviewColumnSelector_drag_end(pWidget, pArg1=nil, pArg2=nil, pArg3=nil)
      getColumnSelectorGUI().on_treeviewColumnSelector_drag_end(pWidget, pArg1, pArg2, pArg3)
    end
    
    def on_buttonAddColumn_clicked(pWidget)
      getColumnSelectorGUI().on_buttonAddColumn_clicked(pWidget)
    end
    
    def on_buttonDeleteColumn_clicked(pWidget)
      getColumnSelectorGUI().on_buttonDeleteColumn_clicked(pWidget)
    end

    def on_checkEditable_toggled(pWidget)
      getColumnSelectorGUI().on_checkEditable_toggled(pWidget)
    end
    
    def on_comboboxStyleDefault_changed(*pArg)
      getColumnSelectorGUI().on_comboboxStyleDefault_changed(*pArg)
    end

    def on_comboboxStyleSelected_changed(*pArg)
      getColumnSelectorGUI().on_comboboxStyleSelected_changed(*pArg)
    end

    
    # =================================
    # Filter Editor GUI Handler
    # ---------------------------------

    def on_comboboxSelectFilter_changed(*arg)
      getFilterEditorGUI().on_comboboxSelectFilter_changed(*arg)
    end

    def on_buttonNewFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonNewFilter_clicked(pWidget)
    end

    def on_buttonSaveFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonSaveFilter_clicked(pWidget)
    end

    def on_buttonDeleteFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonDeleteFilter_clicked(pWidget)
    end

    def on_buttonAddFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonAddFilter_clicked(pWidget)
    end

    def on_buttonAddChildrenFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonAddChildrenFilter_clicked(pWidget)
    end
    
    def on_buttonRemoveFilter_clicked(pWidget)
      getFilterEditorGUI().on_buttonRemoveFilter_clicked(pWidget)
    end

    def on_treeviewFilter_drag_end(*arg)
      getFilterEditorGUI().on_treeviewFilter_drag_end(*arg)
    end

    def on_treeviewFilter_cursor_changed(pWidget)
      getFilterEditorGUI().on_treeviewFilter_cursor_changed(pWidget)
    end

    def on_buttonExpandAll_clicked(pWidget)
      getFilterEditorGUI().on_buttonExpandAll_clicked(pWidget)
    end
    
    def on_buttonCollapseAll_clicked(pWidget)
      getFilterEditorGUI().on_buttonCollapseAll_clicked(pWidget)
    end

    # =================================
    # Merge Data GUI Handler
    # ---------------------------------

    def on_buttonAssociate_clicked(*pArg)
      getMergeDataGUI().on_buttonAssociate_clicked(*pArg)
    end
    
    def on_buttonUnssociate_clicked(*pArg)
      getMergeDataGUI().on_buttonUnssociate_clicked(*pArg)
    end

    def on_buttonAutoMerge_clicked(*pArg)
      getMergeDataGUI().on_buttonAutoMerge_clicked(*pArg)
    end
    
    def on_buttonUnassociateAll_clicked(*pArg)
      getMergeDataGUI().on_buttonUnassociateAll_clicked(*pArg)
    end
    
    def on_buttonShowAll_clicked(*pArg)
      getMergeDataGUI().on_buttonShowAll_clicked(*pArg)
    end

    def on_buttonHideAssociated_clicked(*pArg)
      getMergeDataGUI().on_buttonHideAssociated_clicked(*pArg)
    end
    
    def on_buttonMergeOk_clicked(*pArg)
      getMergeDataGUI().on_buttonMergeOk_clicked(*pArg)
    end
    
    def on_buttonMergeCancel_clicked(*pArg)
      getMergeDataGUI().on_buttonMergeCancel_clicked(*pArg)
    end

    def on_treeviewOrigin_cursor_changed(*pArg)
      getMergeDataGUI().on_treeviewOrigin_cursor_changed(*pArg)
    end
    
    def on_treeviewOrigin_row_activated(*pArg)
      getMergeDataGUI().on_treeviewOrigin_row_activated(*pArg)
    end
      
    def on_treeviewImport_cursor_changed(*pArg)
      getMergeDataGUI().on_treeviewImport_cursor_changed(*pArg)
    end

    def on_treeviewImport_row_activated(*pArg)
      getMergeDataGUI().on_treeviewImport_row_activated(*pArg)
    end

  end
end

puts "-- ToyundaManagerGUI"
