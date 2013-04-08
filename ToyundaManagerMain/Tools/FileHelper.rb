
# contient des méthodes permettant le chargement et/ou 
# la sauvegarde de données standards à partir de fichier csv

require 'csv'

module Tools

  class FileHelper
    SEPARATOR = ';'

    #===============================================================
    # Global
    #===============================================================
    
    def self.loadFolder(pFolder)
      Dir[pFolder+"/*.rb"].each { |f|
        puts "load : #{f}"
        load f
      }
    end
    
    # remplace tout les \ par des / dans la string donnée
    def self.toSlash(pString)
      return nil if pString.nil?
      return pString.split('\\').join('/')
    end
    
    # verifie la lisibilité du fichier donné
    def self.checkFileRead(pFileName)
      unless pFileName
        raise "file unreadable : nil file name"
      end
      unless File.exist?(pFileName)
        raise "file unreadable : invalid file name : #{pFileName}"
      end
      unless File.readable?(pFileName)
        raise "file unreadable : #{pFileName}"
      end
    end

    # verifie l'écrivabilité du fichier donné
    def self.checkFileWrite(pFileName)
      unless pFileName
        raise "file unwritable : nil file name"
      end
      filename = FileHelper.toSlash(pFileName)
      dirname = File.dirname(filename)
      if dirname and not File.directory?(dirname)
        raise "file unwritable : invalid path : #{dirname}"
      end
      if File.exist?(pFileName) and not File.writable?(pFileName)
        raise "file unwritable : #{pFileName}"
      end
    end
    
    #===============================================================
    # CSV Read
    #===============================================================

    # effectue l'action donnée sur chacune des lignes du csv donné
    # - pCsvFile : le chemin du fichier csv à parcourir
    # - &pAction(bRow) : l'action appelée sur chacune des lignes du csv
    #   - bRow : liste de string représentant une ligne du csv
    def self.csvRead(pCsvFile, &pAction)
      FileHelper.checkFileRead(pCsvFile)
      CSV.open(pCsvFile, 'r', SEPARATOR) { |bRow|
        pAction.call(bRow)
      }
    end

    # renvoie une liste de liste représentant le csv donné
    def self.csvToListList(pCsvFile)
      resultList = Array.new
      FileHelper.csvRead(pCsvFile) { |bRow|
        resultList << bRow
      }
      return resultList
    end
    
    # Execute l'action donnée sur chaque map représentant les lignes du csv donné
    # la premiere ligne du csv est considéré comme l'entête des colonnes (clef des maps)
    # pAction(bMap) : executé sur chaque ligne
    #   - bMap : map représentant la ligne en court de traitement
    def self.csvEachMap(pCsvFile, &pAction)
      header = nil
      FileHelper.csvRead(pCsvFile) { |bRow|
        if header.nil?
          header = bRow 
        else
          map = Hash.new
          header.each_index { |i|
            k = header[i]
            v = bRow[i]
            map[k] = v
          }
          pAction.call(map)
        end
      }
    end

    # charge un fichier csv et renvoie une liste de map.
    # la premiere ligne du csv est considéré comme l'entête des colonnes (clef des maps)
    # Si un block action(bMap)=>object est passé en parametre, alors renvoie une liste de object
    # ou bMap est la map représentant la ligne en court de traitement
    def self.csvToListMap(pCsvFile)
      header = nil
      resultList = Array.new
      FileHelper.csvRead(pCsvFile) { |bRow|
        if header.nil?
          header = bRow 
        else
          map = Hash.new
          header.each_index { |i|
            k = header[i]
            v = bRow[i]
            map[k] = v
          }
          if block_given?
            object = yield map
            resultList << object
          else
            resultList << map
          end
        end
      }
      return resultList
    end
    
    # charge un fichier csv dans une map de map
    # la premiere ligne du csv détermine les clef des colonnes
    # la colonne d'index pKeyIndex détermine la clef de chaque ligne
    # Si un block action(bMap)=>object est passé en parametre, alors renvoie une map de object
    # ou bMap est la map représentant la ligne en court de traitement
    def self.csvToMapMap(pCsvFile, pKeyIndex = 0)
      #~ puts 'FileHelper.csvToMapMap'
      header = key = nil
      key = pKeyIndex if pKeyIndex.is_a? String
      resultMap = Hash.new
      FileHelper.csvRead(pCsvFile) { |bRow|
        if header.nil?
          header = bRow
          #~ puts "header : #{header.join(' | ')}"
          key = header[pKeyIndex] if key.nil?
          #~ puts "id key : #{key}"
        else
          map = Hash.new
          #~ puts ">>"
          header.each_index { |i|
            k = header[i]
            v = bRow[i]
            map[k] = v
            #~ puts "  ++ #{k} = #{v}"
          }
          mapKey = map[key]
          if block_given?
            object = yield map
            resultMap[mapKey] = object
          else
            resultMap[mapKey] = map
          end
          #~ puts "<< #{mapKey}"
        end
      }
      return resultMap
    end
    
    #===============================================================
    # CSV Write
    #===============================================================

    # effectue l'action sur le csv donné
    def self.csvWrite(pCsvFile, &pAction)
      FileHelper.checkFileWrite(pCsvFile)
      CSV.open(pCsvFile, 'w', SEPARATOR) { |bWriter|
        pAction.call(bWriter)
      }
    end

    # Enregistre la map donnée dans le fichier csv donné
    # pCsvFile : le nom du fichier Csv à sauvegarder
    # pListMap : la liste de map contenant les données à sauvegarder
    # pColumnList : la liste des colonnes à sauvegarder. 
    #   Si nil alors on prend les colonnes de la première ligne comme base.
    def self.listMapToCsv(pCsvFile, pListMap, pColumnList = nil)
      return false if pListMap.nil? or pListMap.empty?
      FileHelper.csvWrite(pCsvFile) { |bWriter|
        pColumnList = pListMap[0].keys.sort if pColumnList.nil?
        bWriter << pColumnList
        pListMap.each { |bRow|
          values = Array.new
          pColumnList.each { |bKey|
            values << bRow[bKey]
          }
          bWriter << values
        }
      }
      return true
    end
    
    # Enregistre la map donnée dans le fichier csv donné
    # pCsvFile : le nom du fichier Csv à sauvegarder
    # pMapMap : la liste de map contenant les données à sauvegarder
    # pColumnList : la liste des colonnes à sauvegarder. 
    #   Si nil alors on prend les colonnes de la première ligne comme base.
    def self.mapMapToCsv(pCsvFile, pMapMap, pColumnList = nil)
      return false if pMapMap.nil? or pMapMap.empty?
      FileHelper.csvWrite(pCsvFile) { |bWriter|
        bWriter << pColumnList if pColumnList
        pMapMap.keys.sort.each { |bLineKey|
          row = pMapMap[bLineKey]
          if pColumnList.nil?
            pColumnList = row.keys.sort 
            bWriter << pColumnList
          end
          values = Array.new
          pColumnList.each { |bKey|
            values << row[bKey]
          }
          bWriter << values
        }
      }
      return true
    end
    
  end
end

  
