
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/14 
# ==========================================================
# Config Manager
# ==========================================================
# Description :
# Manage the config part of the application
# ==========================================================

puts "require ConfigManager"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "constants/CstsConfigManager"
require $root+ "constants/CstsKaraoke"
require $root+ "helper/Property"
# ----------------------------------------------------------

puts "++ ConfigManager"

module Application
  
  class ConfigManager
    include Common
    include CstsConfigManager
    
    LIST_SEPARATOR = ";"
    OS_WINDOWS_DEFAULT_LBL = 'Windows'
    OS_UNIX_DEFALUT_LBL = 'Unix'
    SEPARATOR_WINDOWS_DEFAULT = '\\'
    SEPARATOR_UNIX_DEFAULT = '/'
    MPLAYER_TOYUNDA_EXE_DEFAUT = 'mplayer-toyunda'
    
    # default column order
    DEFAULT_COLUMN_ORDER = [ 
      #~ CstsKaraoke::K_ID,
      CstsKaraoke::K_LENGTH,
      CstsKaraoke::K_USE_FREQ,
      CstsKaraoke::K_USED,
      CstsKaraoke::K_LAST,
      CstsKaraoke::K_FULL_TITLE,
      CstsKaraoke::K_INI,
      CstsKaraoke::K_VIDEO,
      CstsKaraoke::K_LYRICS,
      CstsKaraoke::K_FPS,
      CstsKaraoke::K_FREQ,
      CstsKaraoke::K_WIDTH,
      CstsKaraoke::K_HEIGHT,
      CstsKaraoke::K_FOURCC,
      CstsKaraoke::K_VIDEO_CODEC,
      CstsKaraoke::K_AUDIO_CODEC,
    ]
    
    # default column and visibility
    DEFAULT_COLUMN = {
      #~ CstsKaraoke::K_ID => true,
      CstsKaraoke::K_LENGTH => true,
      CstsKaraoke::K_USE_FREQ => true,
      CstsKaraoke::K_USED => false,
      CstsKaraoke::K_LAST => true,
      CstsKaraoke::K_FULL_TITLE => true,
      CstsKaraoke::K_INI => false,
      CstsKaraoke::K_VIDEO => false,
      CstsKaraoke::K_LYRICS => false,
      CstsKaraoke::K_FPS => false,
      CstsKaraoke::K_FREQ => false,
      CstsKaraoke::K_WIDTH => false,
      CstsKaraoke::K_HEIGHT => false,
      CstsKaraoke::K_FOURCC => false,
      CstsKaraoke::K_VIDEO_CODEC => false,
      CstsKaraoke::K_AUDIO_CODEC => false,
    }
    
    # =================================
    public
    # ---------------------------------
    def initialize(pProfile)
      @profile = pProfile
      updateConfig_v1_2()
      loadConfig()
      configure()
    end
    
    # ---------------------------------
    def save()
      log("save") {
        prepareSave()
        saveConfig()
      }
    end
    
    # ---------------------------------
    def importConfig(pFile)
      log("import Config "+pFile)
      mapImported = Property::load(pFile)
      unless mapImported
        log("config file "+pFile+" not found")
        return false 
      end
      mapImported.each { |bKey, bValue|
        @map[bKey] = bValue
      }
    end
    
    # ---------------------------------
    # return the config value for pId
    def [](pId)
      return @map[pId]
    end
    
    # ---------------------------------
    # set the config value for pId
    def []=(pId, pValue)
      # return @map[pId] = pValue.to_i if isNumber(pValue)
      # return @map[pId] = (true.to_s == pValue.to_s) if isBoolean(pValue)
      return if pValue.nil?
      log("Config : "+pId+" = "+pValue.to_s)
      @map[pId] = pValue.to_s
    end


    # ---------------------------------
    
    # if we can delete this column
    def isColumnDeletable(pColumnKey)
      return !DEFAULT_COLUMN.include?(pColumnKey)
    end
    
    # return the column order
    def getColumnOrder()
      return @columnOrder if @columnOrder
      columnLine = @map[COLUMN_ORDER]
      if columnLine
        @columnOrder = columnLine.split(LIST_SEPARATOR)
      else
        @columnOrder = Array.new
      end
      updateColumnOrder()
      return @columnOrder
    end
    
    # set the column order
    def setColumnOrder(pOrder)
      @columnOrder = pOrder
    end
    
    # return the column displayed in the respective order
    def getColumnDisplay()
      return @columnDisplay if @columnDisplay
      columnLine = @map[COLUMN_DISPLAY]
      if columnLine
        @columnDisplay = columnLine.split(LIST_SEPARATOR)
      else
        @columnDisplay = Array.new
      end
      updateColumnDisplay()
      return @columnDisplay
    end
    
    # set the column display order
    def setColumnDisplay(pOrder)
      @columnDisplay = pOrder
    end

    def setColumnStyleDefault(pStyleDefault)
      @columnStyleDefault = pStyleDefault
    end
    
    def getColumnStyleDefault()
      return @columnStyleDefault if @columnStyleDefault
      columnLine = @map[COLUMN_STYLE_DEFAULT]
      if columnLine
        @columnStyleDefault = columnLine.split(LIST_SEPARATOR)
      else
        @columnStyleDefault = Array.new
      end
      return @columnStyleDefault
    end

    def setColumnStyleSelected(pStyle)
      @columnStyleSelected = pStyle
    end
    
    def getColumnStyleSelected()
      return @columnStyleSelected if @columnStyleSelected
      columnLine = @map[COLUMN_STYLE_SELECTED]
      if columnLine
        @columnStyleSelected = columnLine.split(LIST_SEPARATOR)
      else
        @columnStyleSelected = Array.new
      end
      return @columnStyleSelected
    end
    
    # ---------------------------------
    def getIniFilePath()
      return @map[INI_FILE_PATH]
    end

    # ---------------------------------
    def getVideoFilePath()
      return @map[VIDEO_FILE_PATH]
    end

    # ---------------------------------
    def getLyricsFilePath()
      return @map[LYRICS_FILE_PATH]
    end

    # ---------------------------------
    def getConfigFileName()
      return File.join(CONFIG_PATH, @profile, PROFILE_CONFIG_FILE)
    end

    # ---------------------------------
    def getPlaylistFileName()
      return @map[PLAYLIST_FILE_NAME]
    end
    
    # ---------------------------------
    def getBackupFilePath()
      return @map[BACKUP_FILE_PATH]
    end

    # ---------------------------------
    def getBackupFileName()
    	currentTime = Time.new
			dateString = currentTime.strftime("%Y-%m-%d--%H-%M-%S")
    	filepath = getBackupFilePath()
    	filename = PLAYLIST_BACKUP+'_'+@profile+'_'+dateString+PLAYLIST_EXT
      return File.join(filepath, filename)
    end
    
    # ---------------------------------
    def getResumeFileName()
    	currentTime = Time.new
			dateString = currentTime.strftime("%Y-%m-%d--%H-%M-%S")
    	filepath = getBackupFilePath()
    	filename = PLAYLIST_RESUME+'_'+@profile+'_'+dateString+PLAYLIST_EXT
      return File.join(filepath, filename)
    end
    
    # ---------------------------------
    def getDataFileName_v1()
      return File.join(CONFIG_PATH, @profile, @profile+DATA_SUFFIXE)
    end
    def getDataFileName()
      return File.join(CONFIG_PATH, @profile, PROFILE_DATA_FILE)
    end

    # ---------------------------------
    def getDataBackupFileName()
      backupNumber = number(BACKUP_DATA_NUMBER)
      fileName = File.join(CONFIG_PATH, @profile, backupNumber.to_s+'_'+PROFILE_DATA_FILE)
      backupNumber = (backupNumber + 1)  %  number(MAX_BACKUP_DATA_NUMBER)
      @map[BACKUP_DATA_NUMBER] = backupNumber
      return fileName
    end
    
    # ---------------------------------
    def getStyleFileName_v1()
      return File.join(CONFIG_PATH, @profile, @profile+STYLE_SUFFIXE)
    end
    def getStyleFileName()
      return File.join(CONFIG_PATH, @profile, PROFILE_STYLE_FILE)
    end

    # ---------------------------------
    #~ def getColumnFileName_v1()
      #~ return File.join(CONFIG_PATH, @profile, @profile+COLUMN_SUFFIXE)
    #~ end
    #~ def getColumnFileName()
      #~ return File.join(CONFIG_PATH, @profile, PROFILE_COLUMN_FILE)
    #~ end

    # ---------------------------------
    def getCurrentPlaylistFileName_v1()
      return File.join(CONFIG_PATH, @profile, @profile+CURRENT_PLAYLIST_SUFFIXE)
    end
    def getCurrentPlaylistFileName()
      return File.join(CONFIG_PATH, @profile, PROFILE_CURRENT_PLAYLIST_FILE)
    end
    
    # ---------------------------------
    def getFilterFileName_v1()
      return File.join(CONFIG_PATH, @profile, @profile+FILTER_SUFFIXE)
    end
    def getFilterFileName()
      return File.join(CONFIG_PATH, @profile, PROFILE_FILTER_FILE)
    end
    
    # ---------------------------------
    def isShuffleOnGenerate()      
      return is(SHUFFLE_ON_GENERATE)
    end

    def isLaunchOnGenerate()
      return is(LAUNCH_ON_GENERATE)
    end
    
    # ---------------------------------
    # return the file separator using the selected os
    def getFileSeparator()
      return @separator[@map[OS_SELECTED]]
    end

    # ---------------------------------
    # return the boolean value for the given key
    # return false if nil
    def is(pKey)
      bool = @map[pKey]
      return false if bool.nil?
      return (true.to_s == bool.to_s)
    end

    # return the number value for the given key, 0 if error
    def number(pKey)
      num = @map[pKey]
      return 0 if num.nil?
      begin
        return num.to_i
      rescue
        return 0
      end
    end


    # =================================
    private
    # ---------------------------------
    def getConfigFileName_v1()
      return File.join(CONFIG_PATH, @profile, @profile+CONFIG_SUFFIXE)
    end
    
    # ---------------------------------
    def loadConfig()
      log("loading profile "+getConfigFileName())
      @map = Property::load(getConfigFileName())
      unless @map
        log("config file "+getConfigFileName()+" not found")
        @map = Hash.new
      end
    end
    
    # ---------------------------------
    def saveConfig()
      log("saving profile "+getConfigFileName())
      Property::save(getConfigFileName(), @map)
    end
    
    # prepare data before saving
    def prepareSave()
      @map[COLUMN_ORDER] = getColumnOrder().join(LIST_SEPARATOR)
      @map[COLUMN_DISPLAY] = getColumnDisplay().join(LIST_SEPARATOR)
      @map[COLUMN_STYLE_DEFAULT] = getColumnStyleDefault().join(LIST_SEPARATOR)
      @map[COLUMN_STYLE_SELECTED] = getColumnStyleSelected().join(LIST_SEPARATOR)
    end

    # configure data after loading
    def configure()
      getColumnOrder()
      getColumnDisplay()
      defaultConfig()
    end
    
    # update the column order adding obligatory column
    def updateColumnOrder()
      DEFAULT_COLUMN_ORDER.each { |bColumn|
        @columnOrder << bColumn unless @columnOrder.include?(bColumn)
      }
      
    end

    # update column display adding obligatory column (invisible)
    def updateColumnDisplay()
        falseStr = false.to_s
        while @columnOrder.size > @columnDisplay.size
          column = @columnOrder[@columnDisplay.size() - 1]
          if DEFAULT_COLUMN.include?(column)
            @columnDisplay << DEFAULT_COLUMN[column].to_s 
          else
            @columnDisplay << falseStr
          end
        end
    end

    # initialize default value
    def defaultConfig()
      @map[OS_WINDOWS_LBL] = OS_WINDOWS_DEFAULT_LBL unless @map.key?(OS_WINDOWS_LBL)
      @map[OS_UNIX_LBL] = OS_UNIX_DEFALUT_LBL unless @map.key?(OS_UNIX_LBL)
      @map[SEPARATOR_WINDOWS] = SEPARATOR_WINDOWS_DEFAULT unless @map.key?(SEPARATOR_WINDOWS)
      @map[SEPARATOR_UNIX] = SEPARATOR_UNIX_DEFAULT unless @map.key?(SEPARATOR_UNIX)
      @separator = {
        @map[OS_WINDOWS_LBL] => @map[SEPARATOR_WINDOWS],
        @map[OS_UNIX_LBL] => @map[SEPARATOR_UNIX],
      }
      @map[MPLAYER_TOYUNDA_EXE] = MPLAYER_TOYUNDA_EXE_DEFAUT unless @map.key?(MPLAYER_TOYUNDA_EXE)
      @map[MAX_BACKUP_DATA_NUMBER] = 5 unless @map.key?(MAX_BACKUP_DATA_NUMBER)
	  @map[MIO_LOGGER] = 'config.csv' unless @map.key?(MIO_LOGGER)
    end

    # test if the given value is a number
    def isNumber(pValue)
    	begin
      	return pValue.to_s === pValue.to_i.to_s
      rescue Exception => pException
      	return false
    	end
    end
    
    # test if the given value is a boolean
    def isBoolean(pValue)
      return ((true.to_s == pValue.to_s) || false.to_s == pValue.to_s)
    end
    
    # rename old file to new file only if old exist and new doesn't
    def rename(pOld, pNew)
      return unless File.exist?(pOld)
      return if File.exist?(pNew)
      begin 
        log("renaming '#{pOld}' to '#{pNew}'")
        File.rename(pOld, pNew)
      rescue Exception => e
        log("Error while renaming '#{pOld}' to '#{pNew}'")
        log_exception(e)
      end
    end
    
    # Update old config file into new config file. since v1.2
    def updateConfig_v1_2()
      rename(getConfigFileName_v1(), getConfigFileName())
      rename(getDataFileName_v1(), getDataFileName())
      rename(getFilterFileName_v1(), getFilterFileName())
      rename(getStyleFileName_v1(), getStyleFileName())
      rename(getCurrentPlaylistFileName_v1(), getCurrentPlaylistFileName())
    end
    
  end
end

puts "-- ConfigManager"

