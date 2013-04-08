
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Toyunda Manager
# ==========================================================
# Description :
# Toyunda Manager Main Application class.
# ==========================================================

puts "require ToyundaManager"

# ----------------------------------------------------------
require 'fileutils'
require $root+ "Common"
require $root+ "constants/CstsConfigManager"
require $root+ "application/ConfigManager"
require $root+ "application/ContextRules"
require $root+ "application/ServerMIO"
require $root+ "helper/KaraokeService"
require $root+ "helper/KaraokeListService"
require $root+ "helper/UpdateRulesService"
require $root+ "helper/FilterService"
# ----------------------------------------------------------

puts "++ ToyundaManager"

module Application

  # The Glade class that load the profile selector UI
  class ToyundaManager
    include Common
    attr_reader :profile, :configManager, :customFilterCatalog
    attr_reader :listAll, :iniList, :csvList, :needMerge
    # attr_accessor :profileSelector, :karaokeListService, :karaokeService
		# attr_accessor :serverMIO
		attr_accessor :gui
    attr_accessor :threads
    
    # =================================
    public
    # ---------------------------------
    # Constructor
    def initialize()
      @threads = Array.new()
    end
    
    def start()
      log("start") {
        loadData()
        loadCustomFilterCatalog()
        selectFilter(@configManager[CstsConfigManager::CURRENT_FILTER])
      }
    end
    
    # ---------------------------------------------------
    
    def getProfileSelector()
      unless @profileSelector 
        @profileSelector = ProfileSelector.new(self)
      end
      return @profileSelector
    end

    def getKaraokeListService()
      unless @karaokeListService
        @karaokeListService = KaraokeListService.new(getKaraokeService())
      end
      return @karaokeListService
    end

    def getKaraokeService()
      unless @karaokeService
        @karaokeService = KaraokeService.new()
      end
      return @karaokeService
    end

    def getUpdateRulesService()
      unless @updateRulesService
        @updateRulesService = UpdateRulesService.new()
      end
      return @updateRulesService
    end

    def getFilterService()
      unless @filterService
        @filterService = FilterService.new()
      end
      return @filterService
    end

    # ---------------------------------------------------
	
    # load the given profile from the config directory
    def loadProfile(pProfile)
      log("Loading profile "+pProfile+" ...")
      @profile = pProfile
      @configManager = ConfigManager.new(pProfile)
    end
    
    # destroy the profile selector
    def destroyProfileSelector()
      @profileSelector = nil
    end

		# save the application
    def save()
      log("save") {
        saveData()
        saveCustomFilterCatalog()
        @configManager.save()
      }
    end
    
    # close the application, saving if necessary
    def close()
      return unless @configManager
      if isSaveOnClose()
        save()
      end
    end
    
    # save the current playlist
    def saveCurrentPlaylist(pCurrentPlaylist)
      currentPlaylistFileName = @configManager.getCurrentPlaylistFileName()
      getKaraokeListService().savePlaylist(currentPlaylistFileName, pCurrentPlaylist)
    end

		# load the last playlist
    def loadCurrentPlaylist()
      currentPlaylistFileName = @configManager.getCurrentPlaylistFileName()
      return loadPlaylist(currentPlaylistFileName)
    end
    
    # save given playlist in the given playlist file
    def savePlaylist(pPlaylistFile, pCurrentPlaylist)
      getKaraokeListService().savePlaylist(pPlaylistFile, pCurrentPlaylist)
    end
    
    # load given playlist file
    def loadPlaylist(pPlaylistFile)
      currentPlaylist = getKaraokeListService().loadPlaylist(pPlaylistFile, @listAll)
      return currentPlaylist
    end
    
    # ---------------------------------
    # return the current filter for the main list
    def getFilter()
      return @filter
    end
    
    # set the current filter for the main list
    def setFilter(pFilter)
      @filter = pFilter
      clearFilteredList()
      #~ @filterChanged = true
    end

    # select the given filter
    def selectFilter(pFilterName)
      if pFilterName.nil?
        @configManager[CstsConfigManager::CURRENT_FILTER] = pFilterName
        setFilter(nil)
        return
      end
      log("filter selected : "+pFilterName)
      @configManager[CstsConfigManager::CURRENT_FILTER] = pFilterName
      customFilter = @customFilterCatalog[pFilterName]
      setFilter(customFilter)
    end
    
    # return the index of the selected filter
    def getActiveFilterIndex()
      return @customFilterCatalog.getFilterIndex(@configManager[CstsConfigManager::CURRENT_FILTER])
    end

    # return the karaoke list filtered by the current filter
    def getFilteredList()
      log("getFilteredList") {
        if @filteredList.nil?
           #~ or @configManager.filterChanged?
          log("filtering...")
          @filteredList = getKaraokeListService().filter(@listAll, getFilter())
          #~ @configManager.filterChanged = false
        end
        return @filteredList
      }
    end
    
    # force refresh on the next getFilteredList
    def clearFilteredList()
      @filteredList = nil
    end
    
    # generate a playlist and save it with a backup
    def generatePlaylist(pCurrentPlaylist)
      playlistFilename = @configManager.getPlaylistFileName()
      getKaraokeListService().savePlaylist(playlistFilename, pCurrentPlaylist)      
      saveBackupPlaylist(pCurrentPlaylist)
      updateData(pCurrentPlaylist)
    end

    # save the given playlist as bakcup
    def saveBackupPlaylist(pPlaylist)
      filename = @configManager.getBackupFileName()
      getKaraokeListService().savePlaylist(filename, pPlaylist)
      return filename
    end

    # save the given playlist as resume
    def saveResumePlaylist(pPlaylist)
      filename = @configManager.getResumeFileName()
      getKaraokeListService().savePlaylist(filename, pPlaylist)
      return filename
    end
    
    # update data using the given playlist
    def updateData(pPlaylist)
      log("update data") {
        context = createContextRules(pPlaylist)
        getUpdateRulesService().applyUpdateRules(context)
        saveContext(context)
      }
    end

    # reset parameters of the global list
    def resetParameters()
      context = createContextRules()
      getUpdateRulesService().resetUpdateRules(context)      
	  saveContext(context)
    end

    # test if we should save on exiting application
    def isSaveOnClose()
      return false unless @configManager
      return @configManager.is(CstsConfigManager::SAVE_ON_CLOSE)
    end

    # save all id in the INI file
    def saveAllIni()
      iniFilePath = @configManager.getIniFilePath()
      getKaraokeListService().saveAllIni(@listAll,iniFilePath)
    end
    
    # export data to the given file name
    def exportData(pFileName)
      columnList = @configManager.getColumnOrder()
      getKaraokeListService(pFileName, @listAll, columnList)
    end
    
    #~ def importData(pFileName)
      #~ filePath = @configManager.getIniFilePath()
      #~ karaokeList = getKaraokeListService().loadData(pFileName, filePath)
      #~ self.listAll = karaokeList
    #~ end
    
    def listAll=(pList)
      @listAll = pList
      log("new ListAll : #{@listAll.size}")
      @filteredList = nil
    end
    
    # merged reloaded data (update from ini for new data
    def mergeReloadedData(pMerger)
      log("Merge reloaded Data") {
        iniFilePath = @configManager.getIniFilePath()
        mergedMap = pMerger.mapMainToImport
        #~ updating Main Data with Imported Data
        pMerger.mainList.each { |bNewKaraoke|
          bImportKaraoke = mergedMap[bNewKaraoke]
          if bImportKaraoke 
            log("* updating : #{bNewKaraoke}")
            log("* from : #{bImportKaraoke}")
            getKaraokeService().updateKaraoke(bNewKaraoke, bImportKaraoke)
          else
            log("* updating from ini : #{bNewKaraoke}")
            getKaraokeService().updateKaraokeFromIni(iniFilePath, bNewKaraoke)
          end
        }
        self.listAll = pMerger.mainList
      }
    end
    
    # merge the data within the given merger using the given columns
    def mergeData(pMerger, pColumns = nil)
      log("Merge Data") {
        mergedMap = pMerger.mapMainToImport
        pMerger.mainList.each { |bNewKaraoke|
          bImportKaraoke = mergedMap[bNewKaraoke]
          if bImportKaraoke 
            log("* updating : #{bNewKaraoke}")
            log("* from : #{bImportKaraoke}")
            getKaraokeService().updateKaraoke(bNewKaraoke, bImportKaraoke, pColumns)
          end
          #~ log("add : #{bNewKaraoke}")
          #~ listAll << bNewKaraoke
        }
        self.listAll = pMerger.mainList
      }
    end
    
    # ---------------------------------------------------
		# MIO
    # ---------------------------------------------------
	
		# return the server MIO
		def getServerMIO()
				unless @serverMIO
					@serverMIO = ServerMIO.new(self)
				end
				return @serverMIO
		end
		
		def startMIO()
			getServerMIO().start()
		end
		
		def stopMIO()
			getServerMIO().stop()
		end
	
    # =================================
    private
    # ---------------------------------
    
    def copyFile(pFrom, pTo)
      return unless File.exist?(pFrom)
      begin
        if File.exist?(pTo)
          log("deleting '#{pTo}'")
          FileUtils::remove([pTo])
        end
        log("copying '#{pFrom}' to '#{pTo}'")
        FileUtils::copy(pFrom, pTo)
      rescue Exception => e
        log("Error while copying '#{pFrom}' to '#{pTo}'")
        log_exception(e)
      end
    end
	
    # save the data for the current profiles
    def saveData()
      dataFile = @configManager.getDataFileName()
      dataBackupFile = @configManager.getDataBackupFileName()
      columnList = @configManager.getColumnOrder()
      log("saving data in "+dataFile)
      getKaraokeListService().saveData(dataFile, @listAll, columnList)
      copyFile(dataFile, dataBackupFile)
      #~ getKaraokeListService().saveData(dataBackupFile, @listAll, columnList)
    end

		# load data for the current profile, including karaokelist
    def loadData()
			log("loading data") {
        dataFile = @configManager.getDataFileName()
        filePath = @configManager.getIniFilePath()
        
        #~ karaokeList = getKaraokeListService().loadData(dataFile, filePath)
        #~ @listAll = karaokeList
        #~ karaokeList, newList, oldList = getKaraokeListService().loadDataNoMerge(dataFile, filePath)
        #~ self.listAll = karaokeList
        
        @iniList = getKaraokeListService().loadIni(filePath)
        @csvList = getKaraokeListService().loadCSV(dataFile)
        # default list is ini list
        self.listAll = @iniList
        #~ log("listAll : #{karaokeList.size} karaokes")
        log("iniList : #{@iniList.size} karaokes")
        log("csvList : #{@csvList.size} karaokes")
        #~ @needMerge = (@iniList.size > 0) or (@csvList.size > 0)
      }
    end

    # save custom filter catalog
    def saveCustomFilterCatalog()
      filterFileName = @configManager.getFilterFileName()
      getFilterService().saveCustomFilterCatalog(@customFilterCatalog, filterFileName)
    end
    
    # load custom filter catalog
    def loadCustomFilterCatalog()
      filterFileName = @configManager.getFilterFileName()
      @customFilterCatalog = getFilterService().loadCustomFilterCatalog(filterFileName)
    end
    
    # return a new context for the rules
    def createContextRules(pPlaylist = nil)
      log("create Context Rules") {
        context = ContextRules.new
        context.globalList = @listAll
        context.totalUsedTitle = @configManager.number(CstsConfigManager::TOTAL_USED_TITLE)
        unless pPlaylist.nil?
          log("playlist not nil")
          context.playlist = pPlaylist
        end
        return context
      }
    end

    # save context into the config manager
    def saveContext(pContext)
      @configManager[CstsConfigManager::TOTAL_USED_TITLE] = pContext.totalUsedTitle
    end

  end
end
puts "-- ToyundaManager"
