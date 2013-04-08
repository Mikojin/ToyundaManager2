
require 'singleton'
require $root+"Tools/Logger"

module Tools

  # Class g�n�rique repr�sentant une factory.
  # g�n�re des instances de class sans param�tre en entr�e (class.new())
  class Factory
    include Singleton
    include Logger
    
    # initialise la factory en fonction des objets g�n�riques cr��s
    def initialize()
      @map = Hash.new
    end
    
    # renvoie la key de l'instance de la donn�e � stocker
    def getKey(pObjectClass)
      return pObjectClass.to_s
    end
    
    # ajoute une class dans la factory � partir d'une instance de celle-ci
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