
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/13 
# Last version : 2007/05/14
# ==========================================================
# Karaoke List service class
# ==========================================================
# Description :
# Load Karaoke information from ini files and profile info
# ==========================================================

puts "require KaraokeListService"

# ----------------------------------------------------------
require 'csv'
require $root+ "Common"
require $root+ "helper/KaraokeService"
require $root+ "application/KaraokeList.rb"
require $root+ "application/Karaoke.rb"
# ----------------------------------------------------------

puts "++ KaraokeListService"

class KaraokeListService
  include Common
  
  SEPARATOR = ';'
  REGEXP_INI = /\.ini$/

  # ============================================================
	public
  # ============================================================
  
  def initialize(pKaraokeService)
    # iniCommon()
    @karaokeService = pKaraokeService
  end
  
  def createKaraokeList()
    return Application::KaraokeList.new
  end
  
  # ---------------------------------
  # load karaoke list from the given csv file and column list
  def loadCSV(fileName)
    log('loading data from '+fileName)
    karaokeList = createKaraokeList()
    unless File.exist?(fileName)
    	log("data file not found : "+fileName)
    	return karaokeList
    end
    listColumn = nil
    CSV.open(fileName, 'r', SEPARATOR) { |row|
    	if listColumn.nil?
    		listColumn = row 
        karaokeList.columns = listColumn
    	else
      	karaoke = @karaokeService.createKaraoke(listColumn, row)
        karaokeList << karaoke
      end
    }
    return karaokeList
  end

  # ---------------------------------
  # Load ini file name from the given path
  # return karaoke list with partially loaded karaoke
  def loadIni(filePath)
    karaokeList = createKaraokeList()
    if filePath.nil?
      return karaokeList
    end
    unless File.exist?(filePath)
      return karaokeList
      # raise "No directory or no ini files in : "+filePath
    end
    log('loadIni >> loading Ini directory '+filePath)
    Dir.open(filePath) { |bDir|
      bDir.each { |bFile|
        unless bFile =~ REGEXP_INI
          next
        end
        karaoke = @karaokeService.parseIni( filePath,bFile)
        if karaoke.nil?
          log('loadIni >> karaoke nil')
        else
        	  karaokeList << karaoke
        end
      }
    }
    return karaokeList
  end

  # ---------------------------------
  # Update the given karaokeList from the ini file
  # return the given karaokeList updated.
  def updateKaraokeListFromIni(pFilePath, pKaraokeList)
    log('update Karaoke List From Ini in '+pFilePath) {
      unless File.exist?(pFilePath)
        log("No directory or no ini files in : "+pFilePath)
        return pKaraokeList
      end
      pKaraokeList.each { |bKaraoke|
        @karaokeService.updateKaraokeFromIni(pFilePath, bKaraoke)
      }
      return pKaraokeList
    }
  end

  # ---------------------------------
	# Load the data from the given file and update it with the given path.
  # this method doesn't write nor use id from ini files
  # return 
  # - karaokeList : ini file with matching karaoke
  # - newList : ini File list without matching karaoke
  # - oldList : karaoke list without matching ini File
  # the final mereg will be done manually by the user
	#~ def loadDataNoMerge(pDataFile, pIniFilePath)
    #~ log("loadDataNoMerge") {
      #~ karaokeListCsv = loadCSV(pDataFile)
      #~ karaokeListIni = loadIni(pIniFilePath)
       
      #~ if karaokeListCsv.nil?
        #~ # can't load data
        #~ if pIniFilePath.nil?
          #~ return createKaraokeList()
        #~ end
        #~ log("load from ini path"){
          #~ # no old data, we must parse all the ini and update the karaokeList
          #~ log("file not found, load from path : "+pIniFilePath)
          #~ # load ini file, video and lyrics path
          #~ updateKaraokeListFromIni(pIniFilePath, karaokeListIni)
        #~ }
        #~ return karaokeListIni
      #~ end
      
      #~ log("checking for differences...")
      #~ # check differences between csv datas and ini files
      #~ karaokeList, newList, oldList = checkByIni(karaokeListCsv, karaokeListIni)
      
      #~ # we need to update the new karaoke
      #~ updateKaraokeListFromIni(pIniFilePath, newList)

      #~ return karaokeList, newList, oldList
    #~ }
	#~ end
  
  #~ # ---------------------------------
	#~ # Load the data from the given file and update it with the given path
	#~ # check for new ini in the given path, and try to match new data with missing one
	#~ # (in the case of renamed ini files)
	#~ def loadData(pDataFile, pIniFilePath)
    #~ log("loadData") {
      #~ karaokeListCsv = loadCSV(pDataFile)
      #~ karaokeListIni = loadIni(pIniFilePath)
       
      #~ if karaokeListCsv.nil?
        #~ # can't load data
        #~ if pIniFilePath.nil?
          #~ return createKaraokeList()
        #~ end
        #~ log("load from ini path"){
          #~ # no old data, we must parse all the ini and update the karaokeList
          #~ log("file not found, load from path : "+pIniFilePath)
          #~ updateKaraokeListFromIni(pIniFilePath, karaokeListIni)
          #~ # save Id for the new entry.
          #~ newList = karaokeListIni.updateId()
          #~ newList.each { |bKaraoke|
            #~ log("++ "+bKaraoke.to_s)
            #~ @karaokeService.saveIniFull(pIniFilePath, bKaraoke)
          #~ }
        #~ }
        #~ return karaokeListIni
      #~ end
      
      #~ log("checking for differences...")
      #~ # check differences between csv datas and ini files
      #~ okList, newList, missingList = checkByIni(karaokeListCsv, karaokeListIni)
      
      #~ log("loading data for new entry...")
      #~ # we need to update the new karaoke to get their id if the file has been renamed.
      #~ updateKaraokeListFromIni(pIniFilePath, newList)
      
      #~ log("checking for renamed files...")
      #~ # for each new file with existing id, we look for its older data in the missing list
      #~ # and update the data from the ini and remove it from missing list.
      #~ updatedListIni = Array.new
      #~ newList.each { |bNewKaraoke|
        #~ idKaraoke = bNewKaraoke.id
        #~ unless idKaraoke.nil?
          #~ oldKaraoke = missingList.getById(idKaraoke)
          #~ unless oldKaraoke.nil?
            #~ log("rename : "+oldKaraoke.ini+" >> "+bNewKaraoke.ini)
            #~ oldKaraoke = @karaokeService.updateKaraoke(oldKaraoke, bNewKaraoke)
            #~ missingList.remove(oldKaraoke)
            #~ updatedListIni << bNewKaraoke
          #~ else
            #~ # check for existing id : duplication ?
            #~ duplicate = karaokeListCsv.getById(idKaraoke)
            #~ unless duplicate.nil?
              #~ log("duplicate") {
                #~ bNewKaraoke.id = nil
                #~ log("keep : "+duplicate.to_s)
                #~ log("reset : "+bNewKaraoke.to_s)
              #~ }
            #~ end
          #~ end
        #~ end
      #~ }
      
      #~ log("updating renamed files...") {
        #~ # remove the updated list from the new
        #~ updatedListIni.each { |bKaraoke|
          #~ newList.remove(bKaraoke)
          #~ log("== "+bKaraoke.to_s)
        #~ }
      #~ }
      
      #~ # add newList in the actual dataList
      #~ newList.each { |bKaraoke|
        #~ karaokeListCsv << bKaraoke
      #~ }
      #~ # update the List Id.
      #~ newList = karaokeListCsv.updateId()
      
      #~ saveAllIni(newList, pIniFilePath)
      
      #~ log("Listing missing entry...") {
        #~ # remove the missing entry from the actual datalist
        #~ missingList.each { |bKaraoke|
          #~ log("-- "+bKaraoke.to_s)
          #~ karaokeListCsv.remove(bKaraoke)
        #~ }
      #~ }
      #~ return karaokeListCsv
    #~ }
	#~ end
	
  # ---------------------------------
	# save the given karaokelist in the given filename
	def saveData(pFilename, pKaraokeList, pListColumn = nil)
		saveCSV(pFilename, pKaraokeList, pListColumn)
	end

  # load the given playlist (full path filename) then create a karaokeList
  # by retrieving karaokes from the given list by ini name, missing values or removed
  def loadPlaylist(pFileName, bKaraokeListReference)
    log('loadPlaylist : '+pFileName) {
      karaokeList = createKaraokeList()
      unless File.exist?(pFileName)
        log("playlist file not found : "+pFileName)
        return karaokeList 
      end
      File.open(pFileName,'r') { |bFile|
        bFile.each_line { |bLine|
          iniKaraoke = bLine.chomp
          karaoke = bKaraokeListReference.getByIni(iniKaraoke)
          unless karaoke.nil?
            log(karaoke.to_s)
            karaokeList << karaoke
          end
        }
      }
      return karaokeList
    }
  end

  # save id for all ini file in the given karaoke list
  #~ def saveAllIni(pKaraokeList, pIniFilePath)
    #~ log("saving ID in Ini file") {
      #~ pKaraokeList.each { |bKaraoke|
        #~ log("++ "+bKaraoke.to_s)
        #~ @karaokeService.saveIniFull(pIniFilePath, bKaraoke)
      #~ }
    #~ }
  #~ end

  # save the given karaokeList in the given file (full path and name)
  def savePlaylist(pFileName, pKaraokeList)
    log("save playlist "+pFileName) {
      File.open(pFileName,'w') { |bFile|
        pKaraokeList.each { |bKaraoke|
          bFile.puts(bKaraoke.ini)
        }
      }
    }
  end

  # return a new list with shuffled elements of the given one
  # the original liste isn't alterate
  def shuffle(pKaraokeList)
    log("shuffle") {
      shuffledKaraoke = createKaraokeList()
      # copyList = createKaraokeList()
      #~ copyList = Array.new
      #~ pKaraokeList.each { |bKaraoke|
        #~ copyList << bKaraoke
      #~ }
      
      copyList = pKaraokeList.getCopyList()
      
      while copyList.size > 0
        index = rand(copyList.size)
        karaoke = copyList[index]
        shuffledKaraoke << karaoke
        copyList.delete_at(index)
      end
      return shuffledKaraoke
    }
  end
  
  # randomly pick 1 karaoke in the given list
  def pick(pKaraokeList)
    return nil if pKaraokeList.nil? or pKaraokeList.size < 1
    index = rand(pKaraokeList.size)
    karaoke = pKaraokeList[index]
  end
  
  # return a new list where each element of the given list are validate
  # by the given filter
  def filter(pKaraokeList, pFilter)
    log("Filter List") {
      filteredList = createKaraokeList()
      pKaraokeList.each { |bKaraoke|
        if pFilter.nil? or pFilter.validate(bKaraoke)
          #~ log("++ "+bKaraoke.to_s)
          filteredList << bKaraoke
        #~ else
          #~ log("-- "+bKaraoke.to_s)
        end
      }
      return filteredList
    }
  end

  # update information of all the video of the given list
  def updateVideoInfo(pKaraokeList, pVideoFilePath)
    log("updateVideoInfo") {
      error = 0
      pKaraokeList.each { |bKaraoke|
        ret = @karaokeService.updateVideoInfo(bKaraoke, pVideoFilePath)
        error += 1 unless ret
      }
      return error
    }
  end

  # compute the total length of the given karaoke list
  def getTotalLengthMinute(pKaraokeList)
    log("getTotalLengthMinute") {
      totalLength = 0
      pKaraokeList.each { |bKaraoke|
        length = bKaraoke.length
        length = 90 if length.nil? or length < 0
        totalLength = totalLength + length
      }
      totalLengthMin = totalLength / 60
      log("Total length = "+totalLength.to_s+" s ==> "+totalLengthMin.to_s+" min")
      return totalLengthMin
    }
  end

  # launch the given karaoke list
  def launch(pKaraokeList, pPlayer, pVideoPath, pLyricsPath, pSeparator, pFullScreen, pOption = '')
    played = createKaraokeList()
    begin
      pKaraokeList.each { |bKaraoke|
        if block_given?
          yield bKaraoke
        end
        ret = @karaokeService.launch(bKaraoke, pPlayer, pVideoPath, pLyricsPath, pSeparator, pFullScreen, pOption)
        break unless ret
        played << bKaraoke
      }
    rescue Exception => err
      log_exception(err)
    end
    return played
  end
  
  # ---------------------------------
  # load each ini file from the given path and parse each data
  # return [false, error message] if there is problems
  # return [true, karaokeList, newList, errorList] if no problems
  def checkIniFile(pFilePath)
    log('check ini : '+pFilePath) {
      error = []
      unless File.exist?(pFilePath)
        return false, "Path doesn't exist : "+pFilePath
      end
      karaokeList = createKaraokeList()
      Dir.open(pFilePath) { |bDir|
        bDir.each { |bFile|
          unless bFile =~ REGEXP_INI
            next
          end
          karaoke = @karaokeService.parseIniFull( pFilePath, bFile)
          if karaoke.nil?
            log('loadIni >> karaoke nil')
          else
              #~ if karaoke.id
                #~ temp = karaokeList.getById(karaoke.id)
                #~ if temp
                  #~ error << [temp,karaoke]
                  #~ log("duplicate id"){
                    #~ log('1- '+temp.to_s)
                    #~ log('2- '+karaoke.to_s)
                  #~ }
                #~ end
              #~ end
              karaokeList << karaoke
          end
        }
      }
      return error
    }
  end

  # ============================================================
	private  
  # ============================================================

  # ---------------------------------
  # save karaoke list into a csv file
  def saveCSV(pFilename, pKaraokeList, pListColumn = nil)
		unless pListColumn
      pKaraokeList.columns = nil
      pListColumn = pKaraokeList.getColumns() 
    end
  	return if pListColumn.nil?
    log("saveCSV columns : "+pListColumn.join(", "))
    CSV.open(pFilename, 'w', SEPARATOR) { |writer|
    	writer << pListColumn
      pKaraokeList.sort!
      pKaraokeList.each { |bKaraoke|
        writer << bKaraoke.getValues(pListColumn)
      }
    }
  end

  # ---------------------------------
	# compare by Ini pOld and pNew KaraokeList
	# return newList, missingList.
	# newList : karaoke in new, not in old.
	# missingList : in old not in new.
	def checkByIni(pOld, pNew)
		# looking for new ini
		okList = createKaraokeList()
    newList = createKaraokeList()
    log("new list :")
		pNew.each { |bKaraoke|
			oldKaraoke = pOld.getByIni(bKaraoke.ini)
			
			if oldKaraoke.nil?
				log("++ Ini : "+bKaraoke.ini)
				newList << bKaraoke
			end
		}

		# looking for missing ini
		missingList = createKaraokeList()
    log("missing list :")
		pOld.each { |bKaraoke|
			newKaraoke = pNew.getByIni(bKaraoke.ini)
			
			if newKaraoke.nil?
				log("-- Ini : "+bKaraoke.ini)
				missingList << bKaraoke
      else
        okList << bKaraoke
			end
		}
		
		return okList, newList, missingList
	end

  # ---------------------------------
  # load each ini file from the given path and parse each data
  # return [false, error message] if there is problems
  # return [true, karaokeList, newList, errorList] if no problems
  #~ def loadIniFull(filePath)
    #~ log('loadIniFull >> loading Ini directory '+filePath)
    #~ unless File.exist?(filePath)
      #~ return false, "No directory or no ini files in : "+filepath
    #~ end
    #~ karaokeList = createKaraokeList()
    #~ newList = createKaraokeList()
    #~ errorList = createKaraokeList()
    #~ Dir.open(filePath) { |bDir|
      #~ bDir.each { |bFile|
        #~ unless bFile =~ REGEXP_INI
          #~ next
        #~ end
        #~ karaoke = @karaokeService.parseIniFull( filePath, bFile)
        #~ ok, missing = @karaokeService.check(karaoke)
        #~ if ok
          #~ karaokeList << karaoke
        #~ else
          #~ if missing[Application::Karaoke::K_ID] and missing.size == 1
            #~ newList << karaoke
          #~ else
            #~ errorList << karaoke
          #~ end
        #~ end
      #~ }
    #~ }
    #~ return true, karaokeList, newList, errorList
  #~ end


end

puts "-- KaraokeListService"
