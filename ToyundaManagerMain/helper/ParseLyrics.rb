
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/10/11 
# ==========================================================
# Parse Lyrics Utilities
# ==========================================================
# Description :
# Parse toyunda lyrics files to retrieve syllabe and 
# timing information
# ==========================================================

module ParseLyrics

  #====================================

  class SyllabeFrm

    attr_reader :deb, :fin
    attr_writer :deb, :fin
	
    def initialize(pDeb, pFin)
      @deb = pDeb.to_i
      @fin = pFin.to_i
    end

  end

  #====================================

  class FrameList
    attr_reader :frameList
	
    def initialize
      @frameList = Array.new
    end
	
    def add(pDeb, pFin)
      @frameList << SyllabeFrm.new(pDeb, pFin)
    end

    def sort!
      frameList.sort! { |bSyl1, bSyl2|
        bSyl1.deb <=> bSyl2.deb
      }
    end

  end

  #====================================

  class ParseLyr

    attr_reader :frameList

    # initilisation
    def initialize
    end
	
    # parse un fichier toyunda
    def parseFile(pFile)
      puts ""
      puts "================================"
      puts "** " + pFile + " **"
      puts "================================"
      #puts "Begin Parsing"
      @frameList = FrameList.new
      File.open(pFile) { |bFile|
        bFile.each_line { |bLine|
          parseLine(bLine)
        }
      }
      #puts "================================"
      #puts "End Parsing"
      #puts "================================"
      #puts "Sorting"
      @frameList.sort!
      #puts "================================"
    end

    # parse une ligne de fichier toyunda	
    def parseLine(pLine)
      if (pLine =~ /^\s*\{([01-9]+)\}\s*\{([01-9]+)\}[\| ]*ÿ.*/ )
        lDeb = $1
        lFin = $2
        #puts "debut = " + lDeb.to_s + " ; fin = "+lFin.to_s
        @frameList.add(lDeb, lFin)
      end
    end

    # calcule l'ecart moyen au dessus et au dessous de la limite
    def computeEcart(pLimiteChain, pLimiteLength)
      @sommeChain = [0, 0, 0, 0]
      @sommeLength = [0, 0, 0, 0]
      puts "================================"
      puts "Compute Ecart"
      puts "================================"
		
      lLastSyl = SyllabeFrm.new(0,0)
      @frameList.frameList.each { |bSyl|
        #puts "========="
        #puts "* ecart chain"
        ecart = bSyl.deb - lLastSyl.fin
        addEcart(ecart, pLimiteChain, @sommeChain)
        #puts "========="
        #puts "* ecart Length"
        ecart = bSyl.fin - bSyl.deb
        addEcart(ecart, pLimiteLength, @sommeLength)
        lLastSyl = bSyl
      }
      @ecartChainMin = @ecartChainMax = @ecartLengthMin = @ecartLengthMax = 0
		
      unless (@sommeChain[1].to_f == 0)
        @ecartChainMin = @sommeChain[0].to_f / @sommeChain[1].to_f
        puts "ecartChainMin = " + @sommeChain[0].to_s + " / " + @sommeChain[1].to_s + " = " + @ecartChainMin.to_s
      end
      unless (@sommeChain[3].to_f == 0)
        @ecartChainMax = @sommeChain[2].to_f / @sommeChain[3].to_f
        puts "ecartChainMax = " + @sommeChain[2].to_s + " / " + @sommeChain[3].to_s + " = " + @ecartChainMax.to_s
      end
      unless (@sommeLength[1].to_f == 0)
        @ecartLengthMin = @sommeLength[0].to_f / @sommeLength[1].to_f
        puts "ecartLengthMin = " + @sommeLength[0].to_s + " / " + @sommeLength[1].to_s + " = " + @ecartLengthMin.to_s
      end
      unless (@sommeLength[3].to_f == 0)
        @ecartLengthMax = @sommeLength[2].to_f / @sommeLength[3].to_f
        puts "ecartLengthMax = " + @sommeLength[2].to_s + " / " + @sommeLength[3].to_s + " = " + @ecartLengthMax.to_s
      end
      puts "================================"
    end
	
	
    def addEcart(pEcart, pLimite, pSomme)
      if (pEcart < pLimite)
        pSomme[0] += pEcart
        pSomme[1] += 1
        #puts "add min : " + pEcart.to_s + " ; nb = " + pSomme[1].to_s
      else
        pSomme[2] += pEcart
        pSomme[3] += 1
        #puts "add max : " + pEcart.to_s + " ; nb = " + pSomme[3].to_s
      end
      #puts "ecart = " + pEcart.to_s + " ; Limite = " + pLimite.to_s + " ; somme = " + pSomme.join(" ; ")
    end
	
    def computeRythm(pLimiteChain, pLimiteLength, pFps=23.976 )
      computeEcart(pLimiteChain, pLimiteLength)
      @rythmChainMin = (@ecartChainMin.to_f * 1000.to_f ) / pFps.to_f
      @rythmChainMax = (@ecartChainMax.to_f * 1000.to_f ) / pFps.to_f
      @rythmLengthMin = (@ecartLengthMin.to_f * 1000.to_f ) / pFps.to_f
      @rythmLengthMax = (@ecartLengthMax.to_f * 1000.to_f ) / pFps.to_f
      ponderation(50, 0, 70, 0)
    end

    def ponderation(pCoefCMin, pCoefCMax, pCoefLMin, pCoefLMax)
      @rythm = 0
      @rythm += pCoefCMin * @rythmChainMin
      @rythm += pCoefCMax * @rythmChainMax
      @rythm += pCoefLMin * @rythmLengthMin
      @rythm += pCoefLMax * @rythmLengthMax
      @rythm = @rythm.to_f / (pCoefCMax + pCoefCMin + pCoefLMax + pCoefLMin).to_f
      printRythm
    end

    def printRythm
      puts "================================"
      puts "Rythm = "+@rythm.to_i.to_s
      puts "================================"
      puts "rythmChainMin = "+@rythmChainMin.to_i.to_s
      puts "rythmChainMax = "+@rythmChainMax.to_i.to_s
      puts "rythmLengthMin = "+@rythmLengthMin.to_i.to_s
      puts "rythmLengthMax = "+@rythmLengthMax.to_i.to_s
      puts "================================"
    end

  end

  #====================================

  def ParseLyrics::doParse(pFile, pFps, pCoefLimiteChain, pCoefLimiteLength)
    lParser = ParseLyr.new
    lParser.parseFile(pFile)
    lLimiteChain = (pFps.to_f * pCoefLimiteChain.to_f).to_i
    lLimiteLength = (pFps.to_f * pCoefLimiteLength.to_f).to_i
    lParser.computeRythm(lLimiteChain, lLimiteLength, pFps)
  end

end

if __FILE__ == $0
  #====================================
  directory = 'D:\\work\\ToyundaPlaylistManager\\Toyunda Playlist Manager [current]\\IniFiles\\Lyrics\\'
  filename = 'Shinkon Gattai Godannar [NCOP1] - Akira Kushida - Shinkon Gattai Godannar!!.toy.txt'
  doParse(directory+filename, 23.976, 1, 3)

  filename = 'Shinkon Gattai Godannar [ED] Akira Kushida + Mitsuko Horie - Sangou no Hitsugi.toy.txt'
  doParse(directory+filename, 24, 1, 3)


  filename = 'Ah! My Goddess AMV - Shining Collection.toy.txt'
  doParse(directory+filename, 29.97, 1, 3)
end
