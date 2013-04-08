
# contient des m�thodes permettant le chargement et/ou 
# la sauvegarde de donn�es standards � partir de fichier csv

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
    
    # remplace tout les \ par des / dans la string donn�e
    def self.toSlash(pString)
      return nil if pString.nil?
      return pString.split('\\').join('/')
    end
    
    # verifie la lisibilit� du fichier donn�
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

    # verifie l'�crivabilit� du fichier donn�
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

    # effectue l'action donn�e sur chacune des lignes du csv donn�
    # - pCsvFile : le chemin du fichier csv � parcourir
    # - &pAction(bRow) : l'action appel�e sur chacune des lignes du csv
    #   - bRow : liste de string repr�sentant une ligne du csv
    def self.csvRead(pCsvFile, &pAction)
      FileHelper.checkFileRead(pCsvFile)
      CSV.open(pCsvFile, 'r', SEPARATOR) { |bRow|
        pAction.call(bRow)
      }
    end

    # renvoie une liste de liste repr�sentant le csv donn�
    def self.csvToListList(pCsvFile)
      resultList = Array.new
      FileHelper.csvRead(pCsvFile) { |bRow|
        resultList << bRow
      }
      return resultList
    end
    
    # Execute l'action donn�e sur chaque map repr�sentant les lignes du csv donn�
    # la premiere ligne du csv est consid�r� comme l'ent�te des colonnes (clef des maps)
    # pAction(bMap) : execut� sur chaque ligne
    #   - bMap : map repr�sentant la ligne en court de traitement
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
    # la premiere ligne du csv est consid�r� comme l'ent�te des colonnes (clef des maps)
    # Si un block action(bMap)=>object est pass� en parametre, alors renvoie une liste de object
    # ou bMap est la map repr�sentant la ligne en court de traitement
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
    # la premiere ligne du csv d�termine les clef des colonnes
    # la colonne d'index pKeyIndex d�termine la clef de chaque ligne
    # Si un block action(bMap)=>object est pass� en parametre, alors renvoie une map de object
    # ou bMap est la map repr�sentant la ligne en court de traitement
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

    # effectue l'action sur le csv donn�
    def self.csvWrite(pCsvFile, &pAction)
      FileHelper.checkFileWrite(pCsvFile)
      CSV.open(pCsvFile, 'w', SEPARATOR) { |bWriter|
        pAction.call(bWriter)
      }
    end

    # Enregistre la map donn�e dans le fichier csv donn�
    # pCsvFile : le nom du fichier Csv � sauvegarder
    # pListMap : la liste de map contenant les donn�es � sauvegarder
    # pColumnList : la liste des colonnes � sauvegarder. 
    #   Si nil alors on prend les colonnes de la premi�re ligne comme base.
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
    
    # Enregistre la map donn�e dans le fichier csv donn�
    # pCsvFile : le nom du fichier Csv � sauvegarder
    # pMapMap : la liste de map contenant les donn�es � sauvegarder
    # pColumnList : la liste des colonnes � sauvegarder. 
    #   Si nil alors on prend les colonnes de la premi�re ligne comme base.
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

  
