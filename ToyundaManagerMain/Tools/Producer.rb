
# class g�n�rique representant un "producer"
# permet de bufferiser des donn�es dans une thread independante
# Gere les locks pour qu'un consumer puisse lire les donn�es du buffer

require 'thread'
require $root+"Tools/Logger"

module Tools

  class Producer
    include Logger
    
    # cr�e un Producer pouvant mettre en buffer des donn�es pour chaque intervalle
    # pSize : la taille du buffer
    # pInterval : l'interval de temps (en seconde) entre chaque mise en buffer
    # pAction : l'action renvoyant un �l�ment � mettre en buffer (producer)
    def initialize(pSize, pInterval, &pAction)
      @bufferMaxSize = pSize
      @pollingInterval = pInterval
      @buffer = Array.new
      @mutex = Mutex.new
      @producer = pAction
    end
    
    def start()
      return if @continue
      #~ log "Start"
      @continue = true
      @thread = Thread.new(self) { |bProducer|
        data = nil
        while @continue
          if data.nil?
            data = bProducer.produce() 
          end
          if data and bufferize(data)
            #~ log "bufferize : #{data}"
            data = nil
          end
          sleep(@pollingInterval)
        end
      }
    end
    
    def stop()
      #~ log "Stop"
      @continue = false
    end
    
    # consume un �l�ment du buffer
    def consume()
      data = nil
      @mutex.synchronize {
        data = @buffer.shift
      }
      return data
    end
    alias :get :consume
    
    # ajoute la donn�e dans le buffer retourne false si la donn�e n'est pas buffuriser
    def bufferize(pData)
      ok = false
      @mutex.synchronize {
        unless isFull()
          @buffer << pData unless pData.nil?
          ok = true
        end
      }
      return ok
    end
    
    alias :put :bufferize

    # =============================
    # Getter
    
    # test si le buffer est plein
    def isFull()
      return @buffer.size >= @bufferMaxSize
    end
 
    # test si le buffer est vide
    def isEmpty()
      return @buffer.size == 0
    end
    
    def size()
      return @buffer.size
    end
    
    # =============================
    # Setter

    def setBufferMaxSize(pMaxSize)
      @bufferMaxSize = pMaxSize
    end
    
    def setPollingInterval(pPollingInterval)
      @pollingInterval = pPollingInterval
    end
    
    def setProducer(&pAction)
      @producer = pAction
    end

     #====================================================
    protected
    
    # produit une donn�e � buffuriser
    def produce()
      if @producer
        return @producer.call()
      end
      return nil
    end
   
  end

end