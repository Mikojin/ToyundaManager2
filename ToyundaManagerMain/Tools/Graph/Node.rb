

# représente un noeud d'un graph

module Tools

  class Node
    
    # identifiant du noeud
    attr_reader :id, :dataClass
    
    # donnée associé au noeud
    attr_accessor :data
    
    # crée un noeud d'id donné
    def initialize(pId)
      @id = pId
      @map = Hash.new
    end
    
    def dataClass=(pClassName)
      if pClassName.is_a? String
        @dataClass = eval(pClassName)
      elsif pClassName.is_a? Class
        @dataClass = pClassName
      end
    end
    
    # ajoute une branche Event==>Destination à ce noeud
    # pEvent : l'action déclenchant l'aiguillage de cette branche
    # pDestination : le noeud suivant.
    def add(pEvent, pDestination)
      @map[pEvent] = pDestination
    end
    
    # execute l'action donné sur chaque branche du noeud
    # pAction (bEvent, bDestination) : l'action executé sur chaque branche
    #   - bEvent : l'evennement déclenchant l'aiguillage
    #   - bDestination : la destination suivant l'aiguillage
    def each(&pAction)
      @map.each { |bEvent, bDestination|
        pAction.call(bEvent, bDestination)
      }
    end
    
    # renvoie le noeud suivant en fonction de l'event donné
    def next(pEvent)
      return @map[pEvent]
    end
    
    def to_s
      return @id.to_s
    end
  end
  
end

