
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/14 
# Last version : 2007/05/14
# ==========================================================
# Karaoke
# ==========================================================
# Description :
# Model for the Merger object
# ==========================================================

puts "require Merger"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "application/KaraokeList"
# ----------------------------------------------------------

puts "++ Merger"

module Application
  
  class Merger
    include Common
    
    attr_reader :mapMainToImport, :mapImportToMain
    attr_reader :mainList, :importList
    
    # =================================
    public
    # ---------------------------------
    def initialize(pMainList, pImportList)
      @mainList = pMainList
      @importList = pImportList
      @mapMainToImport = Hash.new()
      @mapImportToMain = Hash.new()
      set_debug_lvl(15)
    end
    
    # clear this merger
    def clear()
      @mapMainToImport.clear
      @mapImportToMain.clear
      @mainList = nil
      @importList = nil
    end
    
    # try an auto merge, if there is no unmatched data, then false
    def needMerge?()
      return false if @mainList.nil? or @importList.nil?
      autoMerge()
      mergeNeeded = ((@mainList.size != @importList.size) or (@mainList.size != @mapMainToImport.size))
      return mergeNeeded
    end
    
    # do an automatique merge of the given KaraokeList
    def autoMerge()
      return if @mainList.nil? or @importList.nil?
      @mainList.each { |bMainKaraoke|
        importKaraoke = @importList.getByIni(bMainKaraoke.ini)
        if importKaraoke
          associate(bMainKaraoke, importKaraoke)
        end
      }
    end

    # clear the association map
    def unassociateAll()
      @mapMainToImport.clear
      @mapImportToMain.clear
    end

    # return a new karaoke list of mainList without associated karaoke
    def getMainListUnassoc()
      unassocList = KaraokeList.new
      @mainList.each { |bMainKaraoke|
        importKaraoke = @mapMainToImport[bMainKaraoke]
        unassocList << bMainKaraoke if importKaraoke.nil?
      }
      return unassocList
    end

    # return a new karaoke list of importList without associated karaoke
    def getImportListUnassoc()
      unassocList = KaraokeList.new
      @importList.each { |bImportKaraoke|
        mainKaraoke = @mapImportToMain[bImportKaraoke]
        unassocList << bImportKaraoke if mainKaraoke.nil?
      }
      return unassocList
    end
    
    # associate together the given karaokes
    def associate(pKaraokeMain, pKaraokeImport)
      log("Associate") {
        unAssociate(pKaraokeMain, pKaraokeImport)
        @mapMainToImport[pKaraokeMain] = pKaraokeImport
        @mapImportToMain[pKaraokeImport] = pKaraokeMain
        log("Associate : #{pKaraokeMain} => #{pKaraokeImport}")
      }
    end

    # unassociate the given 2 karaokes
    def unAssociate(pKaraokeMain, pKaraokeImport)
      log("unAssociate") {
        
        oldKaraokeMain = @mapImportToMain[pKaraokeImport]
        if oldKaraokeMain
          log("remove old Main to Import : #{oldKaraokeMain} => #{pKaraokeImport}") 
          @mapMainToImport.delete(oldKaraokeMain)
        end
        oldKaraokeImport = @mapMainToImport[pKaraokeMain]
        if oldKaraokeImport
          log("remove old Import to Main : #{oldKaraokeImport} => #{pKaraokeMain}") 
          @mapImportToMain.delete(oldKaraokeImport)
        end
        
        @mapMainToImport.delete(pKaraokeMain)
        @mapImportToMain.delete(pKaraokeImport)
      }
    end

    # unAssociate using main entry
    def unAssociateMain(pKaraokeMain)
      karaokeImport = @mapMainToImport[pKaraokeMain]
      return if karaokeImport.nil?
      unAssociate(pKaraokeMain, karaokeImport)
    end
    # unAssociate using import entry
    def unAssociateImport(pKaraokeImport)
      karaokeMain = @mapImportToMain[pKaraokeImport]
      return if karaokeMain.nil?
      unAssociate(karaokeMain, pKaraokeImport)
    end

    # For debug. Log the type and str values of the given pArg list
    def logArgs(pMsg, pArg)
      log("#{pMsg} args") {
        pArg.each { |bArg|
          log(bArg.class.to_s+" => #{bArg}")
        }
      }
    end
    
    def logMap(pMap, pMsg="Map")
      log(pMsg) {
        pMap.each { |bKey, bValue|
          log("** #{bKey}")
          log("=> #{bValue}")
        }
      }
    end
  end
end

puts "-- Merger"
