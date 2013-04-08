
# repr�sente un chronometre pouvant �tre d�marr�, arr�t�, mis en pause

module Tools

  class Chrono

    attr_reader :startTime, :pauseTime, :isPaused
    
    def initialize()
      @paused = 0.0
      @isPaused = false
      start()
    end

    # lance/r�initialise le comptage
    def start()
      @startTime = Time.now
    end

    # renvoie la valeur (float) du chrono
    def get()
      if @isPaused
        return (@pauseTime.to_f - @startTime.to_f - @paused)
      else
        return (Time.now.to_f - @startTime.to_f - @paused)
      end
    end
    
    # renvoie la dur�e total depuis le start sans prendre en compte les pauses
    def getTotal()
      return (Time.now.to_f - @startTime.to_f)
    end
    
    # renvoie la dur�e en float depuis la mise en pause, 0 si le chrono n'est pas en pause
    def getPause()
      return 0.0 unless @isPaused
      return (Time.now.to_f - @pauseTime.to_f)
    end
    
    # met en pause le comptage
    def pause()
      @isPaused = true
      @pauseTime = Time.now
    end

    # reprend le compte
    def resume()
      @isPaused = false
      @paused += (Time.now.to_f - @pauseTime.to_f)
    end

    # bascule la pause et la reprise du chrono
    def toggle()
      if @isPaused
        resume()
      else
        pause()
      end
    end

    # renvoie la valeur actuelle du chrono en string
    def to_s()
      getStr()
    end

    # renvoie la valeur actuelle du chrono en string
    def getStr()
      return Chrono.toString(get())
    end

    # renvoie le lancement du chrono en string
    def startStr()
      return Chrono.toString(@startTime)
    end

    # converti en string la date donn�e (�criture en seconde)
    def self.toString(pDate)
      return "%08.3f" %  pDate.to_f
    end

    
  end

end