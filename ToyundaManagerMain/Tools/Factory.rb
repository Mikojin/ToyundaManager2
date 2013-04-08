
require 'singleton'
require $root+"Tools/Logger"

module Tools

  # Class générique représentant une factory.
  # génère des instances de class sans paramètre en entrée (class.new())
  class Factory
    include Singleton
    include Logger
    
    # initialise la factory en fonction des objets génériques créés
    def initialize()
      @map = Hash.new
    end
    
    # renvoie la key de l'instance de la donnée à stocker
    def getKey(pObjectClass)
      return pObjectClass.to_s
    end
    
    # ajoute une class dans la factory à partir d'une instance de celle-ci
    def <<(pObjectClass)
      @map[getKey(pObjectClass)] = pObjectClass
    end
    
    # methode factory
    def create(pKey)
      objectClass = @map[pKey]
      return objectClass.new if objectClass
      log "create(#{pKey}) : unknown class key"
      return nil
    end

    # affiche le contenu de la factory, pour le debug
    def printContent()
      log(self.class.to_s+" content") {
        @map.each { |bKey, bClass|
          log bKey.to_s+" ==> "+bClass.to_s
        }
      }
    end

  end
end