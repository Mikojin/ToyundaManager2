
# représente un un graph de noeud lié par des actions.
# Un graph permet de déterminer le noeud suivant en fonction du noeud courrant et d'une action
# Il permet aussi de représenter des états

require $root+"Tools/Logger"
require $root+"Tools/Graph/Node"
require $root+"Tools/XMLFile"
require $root+"Tools/FileHelper"

module Tools

  class Graph
    include Logger
    
    attr_reader :currentNode

    # -------------------------------------------------
    # Initialisation
    # -------------------------------------------------

    # crée un graph avec un historique de parcour de taille donnée
    def initialize(pHistoSize = 10)
      @nodeMap = Hash.new
      @histo = Array.new
      @histoSize = pHistoSize
    end

    # -------------------------------------------------
    # accés, création
    # -------------------------------------------------

    # ajoute le noeud donné au graphe
    # pNode : le noeud à ajouter
    # return : true si le noeud est ajouter, false sinon
    def add(pNode)
      return false if @nodeMap.key?(pNode.id)
      @nodeMap[pNode.id] = pNode
      return true
    end
    
    alias :<< :add

    # crée un nouveau noeud dans le graph. Si l'id existe déjà le noeud correspondant est renvoyé
    # pId : l'id du nouveau noeud
    # return : le nouveau noeud crée, ou le noeud d'Id donné
    def createNode(pId)
      node = @nodeMap[pId]
      return node if node
      node = Node.new(pId)
      @nodeMap[pId] = node
      return node
    end
    
    # renvoie le noeud d'id donné
    # return : le noeud d'id donné, nil sinon
    def get(pId)
      return @nodeMap[pId]
    end
    
    alias :[] :get
    
    
    # execute l'action donné sur chaque noeuds du graphe
    # pAction (bNode) : l'action executé sur chaque noeud
    #   - bNode : le noeud sur lequel on execute l'action
    def each(&pAction)
      @nodeMap.each { |bId, bNode|
        pAction.call(bNode)
      }
    end

    # -------------------------------------------------
    # parcourt
    # -------------------------------------------------

    # défini le noeud courrant à partir de son identifiant
    def setCurrentNode(pId)
      historize()
      @currentNode = get(pId)
    end
    
    # déplace le noeud courrant en fonction de l'event donnée
    # pEvent : l'event provoquant le déplacement
    # return : le nouveau noeud courrant.
    # - nil : si le noeud courrant vaut nil
    # - currentNode : si l'action n'a pas de destination
    def move(pEvent)
      return nil if @currentNode.nil?
      newPosition = @currentNode.next(pEvent)
      historize()
      @currentNode = newPosition
      return @currentNode
    end
    alias :next :move
    
    # defait le dernier déplacement et renvoie le noeud l'ancien "noeud courrant"
    # ne fait rien s'il n'y a rien dans l'historique
    def undoMove()
      return @currentNode if @histo.empty?
      @currentNode = @histo.shift
      return @currentNode
    end


    # -------------------------------------------------
    # persistance
    # -------------------------------------------------
    
    def print()
      self.each { |bNode|
        log("Node : #{bNode.id}") {
          bNode.each { |bEvent, bDestination|
            log "Branche : #{bEvent} ==> #{bDestination.id}"
          }
        }
      }
    end
    
    GRAPH = 'Graph'
    HISTO_SIZE = 'HistoSize'
    NODES = 'Nodes'
    NODE_ID = 'NodeId'
    ID = 'Id'
    BRANCHS = 'Branchs'
    BRANCH = 'Branch'
    NODE = 'Node'
    EVENT = 'Event'
    DESTINATION = 'Destination'
    
    # sauvegarde l'arbre du noeud donné dans le fichier pFileName
    def save2(pFileName)
      xml = XMLFile.new()
      xml.openw(pFileName) { |bXml|
        bXml.tag(GRAPH, {HISTO_SIZE => @histoSize.to_s}) {
          bXml.tag(NODES) {
            @nodeMap.keys.sort.each { |bKey|
              bXml.tag(NODE_ID, {ID => bKey})
            }
          }
          bXml.tag(BRANCHS) {
            @nodeMap.keys.sort.each { |bKey|
              node = get(bKey)
              bXml.tag(NODE, {ID => bKey}) {
                node.each { |bEvent, bDest|
                  bXml.tag(BRANCH, { EVENT => bEvent, DESTINATION => bDest})
                }
              }
            }
          }
        }
      }
    end
    
    def load2(pFileName)
      xml = XMLFile.new()
      tag = nil
      xml.openr(pFileName) { |bXml|
        tag = bXml.readTag()
      }
      tag.print()
    end
    
    CSV_NODE_ID = 'nodeId'
    CSV_DEST = 'destination'
    CSV_EVENT = 'event'
    
    def save(pFileName)
      FileHelper.csvWrite(pFileName) { |bWriter|
        bWriter << [CSV_NODE_ID, CSV_DEST, CSV_EVENT]
        self.each { |bNode|
          bNode.each { |bEvent, bDestination|
            bWriter << [bNode.id, bDestination.id, bEvent]
          }
        }
      }
    end
    
    def load(pFileName)
      FileHelper.csvEachMap(pFileName) { |bRow|
        #~ log "#{bRow[CSV_NODE_ID]} ==> #{bRow[CSV_EVENT]} ==> #{bRow[CSV_DEST]}"
        nodeSrc = createNode(bRow[CSV_NODE_ID])
        if @currentNode.nil?
          log "new current node : #{bRow[CSV_NODE_ID]}"
          setCurrentNode(bRow[CSV_NODE_ID]) 
        end
        nodeDest = createNode(bRow[CSV_DEST])
        nodeSrc.add(bRow[CSV_EVENT], nodeDest)
      }
      #~ log "current node : #{@currentNode}"
      #~ print()
    end
    
    #==============================================================
    private
    
    # historise le noeud courrant
    def historize()
      @histo.unshift(@currentNode) if @currentNode
      @histo.pop if @histo.size > @histoSize
    end
    
    
  end
end
