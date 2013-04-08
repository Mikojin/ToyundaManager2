

# repr�sente un noeud d'un graph

module Tools

  class Node
    
    # identifiant du noeud
    attr_reader :id, :dataClass
    
    # donn�e associ� au noeud
    attr_accessor :data
    
    # cr�e un noeud d'id donn�
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
    
    # ajoute une branche Event==>Destination � ce noeud
    # pEvent : l'action d�clenchant l'aiguillage de cette branche
    # pDestination : le noeud suivant.
    def add(pEvent, pDestination)
      @map[pEvent] = pDestination
    end
    
    # execute l'action donn� sur chaque branche du noeud
    # pAction (bEvent, bDestination) : l'action execut� sur chaque branche
    #   - bEvent : l'evennement d�clenchant l'aiguillage
    #   - bDestination : la destination suivant l'aiguillage
    def each(&pAction)
      @map.each { |bEvent, bDestination|
        pAction.call(bEvent, bDestination)
      }
    end
    
    # renvoie le noeud suivant en fonction de l'event donn�
    def next(pEvent)
      return @map[pEvent]
    end
    
    def to_s
      return @id.to_s
    end
  end
  
end

