
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Config Manager GUI
# ==========================================================
# Description :
# Sub module for the Toyunda Manager GUI. Only contains
# callback for the config
# Uses methodes and attributs from the main class : 
# ToyundaManagerGUI
# ==========================================================

puts "require ConfigManagerGUI"

# ----------------------------------------------------------
require $root+ "gui/GUI"
require $root+ "constants/CstsConfigManager"
require $root+ "gui/SubToyundaManagerGUI"
# ----------------------------------------------------------

puts "++ ConfigManagerGUI"

module GUI

  class ConfigManagerGUI < SubToyundaManagerGUI
    
    W_INI_PATH = 'entryIniPath'
    W_VIDEO_PATH = 'entryVideoPath'
    W_LYRICS_PATH = 'entryLyricsPath'
    W_PLAYLIST_FILE = 'entryPlaylistFile'
    W_PLAYLIST_BACKUP = 'entryPlaylistBackUp'
    W_LAUNCH_ON_GENERATE = 'checkLaunchOnGenerate'
    W_SAVE_ON_CLOSE = 'checkSaveOnClose'
    W_OS_SELECTOR = 'comboboxOSselector'
    W_MPLAYER_OPTION = 'entryMPlayerOption'
    W_FULL_SCREEN = 'checkFullScreen'

    
    # =====================================
    # Initialize
    # =====================================
    
    # clear the config manager
    def clear()
    end
    
    # initialize the config manager
    def subInitialize()
      log("subInitialize") {
        conf = @application.configManager
        setSaveOnClose(conf.is(CstsConfigManager::SAVE_ON_CLOSE))
        setLaunchOnGenerate(conf.isLaunchOnGenerate())
        setIniPath(conf.getIniFilePath())
        setPlaylistFile(conf.getPlaylistFileName())
        setPlaylistBackup(conf.getBackupFilePath())
        setVideoPath(conf.getVideoFilePath())
        setLyricsPath(conf.getLyricsFilePath())
        iniOSselector()
        updateFullScreen()
        updateOSselector()
        updateMPlayerOption()
        @iniDone = true
      }
    end

    # =====================================
    # Save on close
    # =====================================
    def setSaveOnClose(pValue)
      @glade[W_SAVE_ON_CLOSE].set_active(pValue)
     
    end
    
    def on_checkSaveOnClose_toggled(widget)
      @application.configManager[CstsConfigManager::SAVE_ON_CLOSE] =  @glade[W_SAVE_ON_CLOSE].active?
    end

    # =====================================
    # Launch on generate
    # =====================================
    def setLaunchOnGenerate(pValue)
      @glade[W_LAUNCH_ON_GENERATE].set_active(pValue)
    end
    
    def on_checkLaunchOnGenerate_toggled(widget)
      @application.configManager[CstsConfigManager::LAUNCH_ON_GENERATE] = @glade[W_LAUNCH_ON_GENERATE].active?
    end
    
    # =====================================
    # Ini Path
    # =====================================
    def checkIniPath()
      newPath = @glade[W_INI_PATH].text
      @application.configManager[CstsConfigManager::INI_FILE_PATH] = newPath
      unless File.exist?(newPath)        
        log("Ini File Path invalide = "+newPath)
        setError("Config", "Ini File Path invalide = "+newPath)
      else
        log("Ini File Path = "+newPath)
        setInfo("Config", "Ini File Path = "+newPath)
      end
      
    end
    
    def setIniPath(newPath)
      @glade[W_INI_PATH].text = newPath
      checkIniPath()
    end
    
    def on_buttonIniPath_clicked(widget)
      oldPath = @glade[W_INI_PATH].text
      unless File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectDirectoryDialog(getWindow(), "Select Ini file path", oldPath)
      setIniPath(newPath)
    end

    def on_entryIniPath_focus_out_event(widget, arg0)
      checkIniPath()
      false
    end
    
    # =====================================
    # Playlist File
    # =====================================
    def checkPlaylistFile()
      newPath = @glade[W_PLAYLIST_FILE].text
      @application.configManager[CstsConfigManager::PLAYLIST_FILE_NAME] = newPath
      unless File.exist?(newPath)        
        log("New Playlist File = "+newPath)
        setError("Config", "New Playlist File = "+newPath)
      else
        log("Playlist File  = "+newPath)
        setInfo("Config", "Playlist File = "+newPath)
      end      
    end
    
    def setPlaylistFile(newPath)
      @glade[W_PLAYLIST_FILE].text = newPath
      checkPlaylistFile()
    end
    
    def on_buttonPlaylistFile_clicked(widget)
      oldPath = @glade[W_PLAYLIST_FILE].text
      unless File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectFileDialog(getWindow(), "Select Playlist file", oldPath)
      setPlaylistFile(newPath)
    end

    def on_entryPlaylistFile_focus_out_event(widget, arg0)
      checkPlaylistFile()
      false
    end

    # =====================================
    # Playlist BackUp
    # =====================================
    def checkPlaylistBackup()
      newPath = @glade[W_PLAYLIST_BACKUP].text
      @application.configManager[CstsConfigManager::BACKUP_FILE_PATH] = newPath
      unless File.exist?(newPath)        
        log("Playlist Backup Path invalide = "+newPath)
        setError("Config", "Playlist Backup Path invalide = "+newPath)
      else
        log("Playlist Backup Path = "+newPath)
        setInfo("Config", "Playlist Backup Path = "+newPath)
      end      
    end
    
    def setPlaylistBackup(newPath)
      @glade[W_PLAYLIST_BACKUP].text = newPath
      checkPlaylistBackup()
    end
    
    def on_buttonPlaylistBackUp_clicked(widget)
      oldPath = @glade[W_PLAYLIST_BACKUP].text
      unless File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectDirectoryDialog(getWindow(), "Select Backup Playlist path", oldPath)
      setPlaylistBackup(newPath)
    end

    def on_entryPlaylistBackUp_focus_out_event(widget, arg0)
      checkPlaylistBackup()
      false
    end
    
    # =====================================
    # Video Path
    # =====================================
    def checkVideoPath()
      newPath = @glade[W_VIDEO_PATH].text
      @application.configManager[CstsConfigManager::VIDEO_FILE_PATH] = newPath
      unless File.exist?(newPath)        
        log("Video File Path invalide = "+newPath)
        setError("Config", "Video File Path invalide = "+newPath)
      else
        log("Video File Path = "+newPath)
        setInfo("Config", "Video File Path = "+newPath)
      end      
    end
    
    def setVideoPath(newPath)
      @glade[W_VIDEO_PATH].text = newPath
      checkVideoPath()
    end
    
    def on_buttonVideoPath_clicked(widget)
      oldPath = @glade[W_VIDEO_PATH].text
      unless File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectDirectoryDialog(getWindow(), "Select Video file path", oldPath)
      setVideoPath(newPath)
    end

    def on_entryVideoPath_focus_out_event(widget, arg0)
      checkVideoPath()
      false
    end
    
    # =====================================
    # Lyrics Path
    # =====================================
    def checkLyricsPath()
      newPath = @glade[W_LYRICS_PATH].text
      @application.configManager[CstsConfigManager::LYRICS_FILE_PATH] = newPath
      unless File.exist?(newPath)        
        log("Video File Path invalide = "+newPath)
        setError("Config", "Video File Path invalide = "+newPath)
      else
        log("Video File Path = "+newPath)
        setInfo("Config", "Video File Path = "+newPath)
      end      
    end
    
    def setLyricsPath(newPath)
      @glade[W_LYRICS_PATH].text = newPath
      checkLyricsPath()
    end
    
    def on_buttonLyricsPath_clicked(widget)
      oldPath = @glade[W_LYRICS_PATH].text
      unless File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectDirectoryDialog(getWindow(), "Select Lyrics file path", oldPath)
      setLyricsPath(newPath)
    end

    def on_entryLyricsPath_focus_out_event(widget, arg0)
      checkLyricsPath()
      false
    end

    
    # =====================================
    # Full Screen
    # =====================================
    
    def updateFullScreen()
      isFullScreen = @application.configManager.is(CstsConfigManager::FULL_SCREEN)
      if isFullScreen.nil?
        isFullScreen = false
        @application.configManager[CstsConfigManager::FULL_SCREEN] = isFullScreen
      end
      @glade[W_FULL_SCREEN].active = isFullScreen
    end
    
    def on_checkFullScreen_toggled(*pArg)
      @application.configManager[CstsConfigManager::FULL_SCREEN] = @glade[W_FULL_SCREEN].active?
    end

    # =====================================
    # OS selector
    # =====================================
    
    def iniOSselector()
      return if @iniDone
      @osSelect = [
        @application.configManager[CstsConfigManager::OS_WINDOWS_LBL], 
        @application.configManager[CstsConfigManager::OS_UNIX_LBL],
      ]
      @osSelect.each { |os_lbl|
        @glade[W_OS_SELECTOR].append_text(os_lbl)
      }
    end
    
    def updateOSselector()
      text = @application.configManager[CstsConfigManager::OS_SELECTED]
      if text.nil?
        text = @application.configManager[CstsConfigManager::OS_WINDOWS_LBL]
        @application.configManager[CstsConfigManager::OS_SELECTED] = text
      end
      @glade[W_OS_SELECTOR].active = @osSelect.index(text)
    end
    
    def on_comboboxOSselector_changed(*pArg)
      active_item = @glade[W_OS_SELECTOR].active
      @application.configManager[CstsConfigManager::OS_SELECTED] = @osSelect[active_item]
    end

    # =====================================
    # Mplayer location
    # =====================================
    def on_buttonSelectPlayer_clicked(*pArg)
      oldPath = @application.configManager[CstsConfigManager::MPLAYER_TOYUNDA_EXE]
      unless oldPath.nil? or File.exist?(oldPath)
        oldPath = nil
      end
      newPath = GUI::selectOpenFileDialog(getWindow(), "Select MPlayer-Toyunda", oldPath)
      newPath = "" if newPath.nil?
      if File.exist?(newPath)
        @application.configManager[CstsConfigManager::MPLAYER_TOYUNDA_EXE] = newPath
        setInfo("Config", "MPlayer-Toyunda = "+newPath)
      else
        setError("Config", "Invalid player = "+newPath)
      end      
    end


    # =====================================
    # Mplayer Option
    # =====================================
    def updateMPlayerOption()
      text = @application.configManager[CstsConfigManager::MPLAYER_OPTION]
      if text.nil?
        text = ''
        @application.configManager[CstsConfigManager::MPLAYER_OPTION] = text
      end
      @glade[W_MPLAYER_OPTION].text = text
    end
    
    def on_entryMPlayerOption_focus_out_event(*pArg)
      @application.configManager[CstsConfigManager::MPLAYER_OPTION] = @glade[W_MPLAYER_OPTION].text
      false
    end

  end
end

puts "-- ConfigManagerGUI"
