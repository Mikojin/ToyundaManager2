
# Classe permettant de g�rer la configuration d'une application

require $root+"Tools/FileHelper"


module Tools

  class Config
    
    ID = 'id'
    VALUE = 'value'
    COMMENT = 'comment'
    TYPE = 'type'
    SEPARATOR = '|'
    
    def initialize(pConfigFile = nil)
      return if pConfigFile.nil?
      @filename = pConfigFile
      load()
    end
    
    # charge le fichier de config donn�
    def load(pConfigFile = nil)
      pConfigFile = @filename if pConfigFile.nil?
      #~ puts 'Config.load'
      @map = FileHelper.csvToMapMap(pConfigFile, ID)
      @changed = false
    end
    
    # sauvegarde la config actuelle dans le fichier donn�
    def save(pConfigFile = nil)
      if pConfigFile.nil? || pConfigFile == @filename
        if @changed
          pConfigFile = @filename
          FileHelper.mapMapToCsv(pConfigFile, @map, [ID,VALUE,COMMENT])
          @changed = false
        end
      else
        FileHelper.mapMapToCsv(pConfigFile, @map, [ID,VALUE,COMMENT])
      end
    end
    
    # afficher la config
    def print()
      @map.each { |bKey, bValue|
        if bValue
          puts "#{bKey} ; #{bValue[VALUE]} ; #{bValue[COMMENT]}"
        else
          puts "#{bKey} ; nil"
        end
      }
    end
    
    # renvoie ou cr�e une ligne de config pour la clef donn�e
    def row(pKey)
      row = @map[pKey]
      if row.nil?
        row = Hash.new
        row[ID] = pKey
      end
      return row
    end
    
    # renvoie la valeur associ� � la clef donn�e
    def [](pKey)
      row = @map[pKey]
      return nil if row.nil?
      return row[VALUE]
    end
    
    alias :get :[]
    
    # affecte la valeur pour la clef donn�e
    # la valeur est forcement une string
    def []=(pKey, pValue)
      row = row(pKey)
      row[VALUE] = pValue.to_s
      @changed = true
    end
    
    alias :set :[]=
    
    # renvoie le commentaire associ� � la clef donn�
    def comment(pKey)
      row = @map[pKey]
      return nil if row.nil?
      return row[COMMENT]
    end
    
    # affecte la commentaire pour la clef donn�e
    def comment=(pKey, pComment)
      row = row(pKey)
      row[COMMENT] = pComment
    end
    
    # renvoie le type de la propri�t�
    def type(pKey)
      row = @map[pKey]
      return nil if row.nil?
      return row[TYPE]
    end
    
    # affecte le type pour la clef donn�e
    def comment=(pKey, pType)
      row = row(pKey)
      row[TYPE] = pType
    end
    
    # renvoie la valeur en boolean
    def to_b(pKey)
      value = get(pKey)
      return nil if value.nil?
      return (true.to_s == value)
    end
    
    # renvoie la valeur en entier
    def to_i(pKey)
      value = get(pKey)
      return nil if value.nil?
      return value.to_i 
    end
    
    # renvoie la valeur en float
    def to_f(pKey)
      value = get(pKey)
      return nil if value.nil?
      return value.to_f
    end
    
    # renvoie la valeur en tableau d'�l�ment (s�par� par SEPARATOR)
    def to_a(pKey)
      value = get(pKey)
      return nil if value.nil?
      return value.split(SEPARATOR)
    end
    
    # affecte le tableau � la clef donn�e en le convertissant en string
    def from_a(pKey, pArray)
      return if pArray.nil
      value = pArray.join(SEPARATOR)
      set(pKey, value)
    end
    
  end
end