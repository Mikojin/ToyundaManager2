
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/13 
# Last version : 2007/05/14
# ==========================================================
# Karaoke service class
# ==========================================================
# Description :
# Load Karaoke information from ini files and profile info
# ==========================================================

puts "require KaraokeService"

# ----------------------------------------------------------
require 'csv'
require $root+ "Common"
require $root+ "constants/CstsKaraoke"
require $root+ "application/Karaoke"
require $root+ "helper/AviService"
# ----------------------------------------------------------

puts "++ KaraokeService"

class KaraokeService
  include Common
  include CstsKaraoke
  
  INI_EXTENSION = '.ini'
  INI_VIDEO = 'AVINAME'
  INI_LYRICS = 'FILE'
  #~ INI_ID = 'TMID'
  FULL_SCREEN = '-fs'
  
  REGEXP_ENTRY = /^(.*?)\s*=\s*(.*)/

  def initialize()
    set_debug_lvl(5)
  end

  # ============================================================
	public
  # ============================================================
  
  def getAviService()
    @aviService = AviService.new unless @aviService
    return @aviService
  end
  
  # ---------------------------------
  # Create a karaoke from a liste of columns and a list of values
  def createKaraoke(listColumn,listValue)
    karaoke = Application::Karaoke.new
  	log("create karaoke") {
      listValue.each_index { |i|
        v = listValue[i]
        k = listColumn[i]
        if v.nil?
          log(" ++ "+k+" = nil")
        else
          log(" ++ "+k+" = "+v)
        end
        if v and k
          karaoke[k] = v
        end
      }
    }
    # karaoke.update()
    return karaoke
  end
  
  # ---------------------------------
  # update the given old karaoke with data from the given new one  of the given column list
  # if the column list is nil, then all data of the new karaoke are injected in the old one.
  # if the column list is empty, the old karaoke remain as he is.
  # return the old karaoke with updated values
  def updateKaraoke(pOldKaraoke, pNewKaraoke, pColumnList=nil)
    
    # if pColumnList is nil : every key of the new karaoke are used.
    pColumnList = pNewKaraoke.getColumns() if pColumnList.nil?
    pColumnList.delete(K_INI)
    
    #~ oldIni = pOldKaraoke.ini
  	pColumnList.each { |bColumn|
      #~ unless bColumn == K_INI
      newValue = pNewKaraoke[bColumn]
      # the old value is replaced, even if the new value is nil
      pOldKaraoke[bColumn] = newValue
      #~ end
  	}
    #~ pOldKaraoke.ini = oldIni
  	return pOldKaraoke
	end
  
  # ---------------------------------
  # update the given karaoke with data read from the ini file
  def updateKaraokeFromIni(pFilePath, pKaraoke)
    log("update from ini : "+pKaraoke.to_s)
		fileName = File.join(pFilePath, pKaraoke[K_INI])
    pKaraoke[K_FULL_TITLE] = File.basename(fileName, INI_EXTENSION)
    File.open(fileName,'r') { |bFile|
      bFile.each_line { |bLine|
        bLine.chomp!
        k,v = getKeyValue(bLine)
        if k and v
          case k
          when INI_VIDEO
            pKaraoke[K_VIDEO] = v
          when INI_LYRICS
            pKaraoke[K_LYRICS] = v
          #~ when INI_ID
            #~ pKaraoke[K_ID] = v
          end
        end
      }
    }
    return pKaraoke
	end

  # ---------------------------------
  # Load a karaoke from an ini file.
  def parseIniFull(pFilePath, pFileName)
    fileName = File.join(pFilePath, pFileName)
    log('parsing ini file '+fileName)
    return nil unless File.exist?(fileName)
    karaoke = Application::Karaoke.new
    karaoke[K_INI] = File.basename(fileName)
    karaoke[K_FULL_TITLE] = File.basename(fileName, INI_EXTENSION)
    File.open(fileName,'r') { |bFile|
      bFile.each_line { |bLine|
        bLine.chomp!
        k,v = getKeyValue(bLine)
        if k and v
          case k
          when INI_VIDEO
            karaoke[K_VIDEO] = v
          when INI_LYRICS
            karaoke[K_LYRICS] = v
          #~ when INI_ID
            #~ karaoke[K_ID] = v
          end
        end
      }
    }
    return karaoke
  end
  

  #~ # ---------------------------------
  #~ # save a karaoke in a ini file. (add only the id parameter)
  #~ def saveIniFull(pFilePath, pKaraoke)
		#~ forig = Array.new
		#~ fileName = File.join(pFilePath, pKaraoke[K_INI])
		#~ File.open(fileName,"r") { |f|
			#~ f.each { |bLine|
				#~ bLine.chomp!
				#~ forig << bLine unless isTMID(bLine)
			#~ }
		#~ }
		#~ forig << INI_ID+"="+pKaraoke[K_ID].to_s
		#~ File.open(fileName,"w") { |f|
			#~ forig.each { |line|
				#~ f.puts line
			#~ }
		#~ }
  #~ end

  # ---------------------------------
  # only parse the ini file name
  def parseIni(pFilePath, pFileName)
		fileName = File.join(pFilePath, pFileName)
    log('read Ini Name : '+fileName)
    return nil unless File.exist?(fileName)
    karaoke = Application::Karaoke.new
    karaoke[K_INI] = pFileName
    karaoke[K_FULL_TITLE] = File.basename(fileName, INI_EXTENSION)
    return karaoke
  end
  
  # ---------------------------------
  # update information from the given karaoke
  def updateVideoInfo(pKaraoke, pVideoFilePath)
    log("updateVideoInfo : "+pKaraoke.to_s) {
      unless pVideoFilePath and pKaraoke[K_VIDEO]
        log("Missing video file or path")
        return false
      end
      video = File.join(pVideoFilePath, pKaraoke[K_VIDEO])
      log("video = "+video.to_s)
      aviFile = getAviService().getAviFile(video)
      if aviFile.nil?
        pKaraoke[K_LENGTH] = nil
        pKaraoke[K_FPS] = nil
        pKaraoke[K_WIDTH] = nil
        pKaraoke[K_HEIGHT] = nil
        pKaraoke[K_FOURCC] = nil
        pKaraoke[K_VIDEO_CODEC] = nil
        pKaraoke[K_AUDIO_CODEC] = nil
        return false
      end
      getAviService().logInfo(aviFile)
      #~ log("length = "+length.to_s)
      pKaraoke[K_LENGTH] = aviFile.duration
      pKaraoke[K_FPS] = aviFile.fps
      pKaraoke[K_FREQ] = aviFile.frequence
      pKaraoke[K_WIDTH] = aviFile.width
      pKaraoke[K_HEIGHT] = aviFile.height
      pKaraoke[K_FOURCC] = aviFile.vids
      pKaraoke[K_VIDEO_CODEC] = aviFile.codec
      pKaraoke[K_AUDIO_CODEC] = aviFile.audio_codec
      return true
    }
  end
      #~ log "frames = "+aviFile.frames.to_s
      #~ log "period = "+aviFile.period.to_s
      #~ log "duration = "+aviFile.duration.to_s+" s"
      #~ log "fps = "+aviFile.fps.to_s
      #~ log "streams = "+aviFile.streams.to_s
      #~ log "width = "+aviFile.width.to_s+" px"
      #~ log "height = "+aviFile.height.to_s+" px"
      #~ log "resolution = "+aviFile.resolution.to_s
      #~ log "video_codec = "+aviFile.codec.to_s
      #~ log "scale = "+aviFile.scale.to_s
      #~ log "rate = "+aviFile.rate.to_s
      #~ log "length = "+aviFile.length.to_s
      #~ log "frequence = "+aviFile.frequence.to_s+" f/s"
      #~ log "true_duration = "+aviFile.true_duration.to_s
      #~ log "audio_codec = "+aviFile.audio_codec.to_s
      #~ log "audio_fourcc = "+aviFile.auds_fourcc.to_s

  
  # launch the given karaoke using the given video and lyrics path
  def launch(pKaraoke, pPlayer, pVideoPath, pLyricsPath, pSeparator, pFullScreen, pOption = nil)
    log("launch : "+pKaraoke.to_s) {
      video = pVideoPath + pSeparator + pKaraoke[K_VIDEO]
      lyrics = pLyricsPath + pSeparator + pKaraoke[K_LYRICS] if pKaraoke[K_LYRICS]
      option = ''
      option += FULL_SCREEN if pFullScreen
      option += ' '+pOption unless pOption.nil?
      return launchMplayer(pPlayer, video, lyrics, option)
    }
  end

  # launch the given video with the given subs and options
  def launchMplayer(pPlayer, pVideo, pSub, pOption = nil)
    if pVideo.nil?
      log("missing video") if pVideo.nil?
      return true
    end
    begin
      pOption = '' if pOption.nil?
      cmd = pPlayer
      cmd += " -sub \"#{pSub}\"" if pSub
      cmd += " \"#{pVideo}\" #{pOption}"
      log "$ #{cmd}"
      ret = system(cmd)
      log(ret.to_s) unless ret.nil?
      if ret.nil?
        log("Execution Error")
        return false
      else
        return ret
      end
    rescue
      log $!
      return false
    end
  end


  # ============================================================
  private
  # ============================================================

  #~ ESCAPE_PATTERN = /\'/
  #~ REPLACE = '\\\''

  #~ # return the given string with simple quote ' escaped
  #~ def escape(pString)
    #~ return nil unless pString
    #~ return pString
    #~ log("  orig = "+pString)
    #~ str = pString.gsub(ESCAPE_PATTERN) { |bMatch|
      #~ log(bMatch+" => "+REPLACE)
      #~ REPLACE
    #~ }
    #~ log("escape = "+str)
    #~ return str
  #~ end

  #~ # ---------------------------------
  #~ # check the validy of the availability of the values in the given karaoke
  #~ def check(karaoke)
    #~ ok = true
    #~ missing = Hash.new
    #~ unless karaoke[K_INI]
      #~ ok = false
      #~ missing[K_INI] = 'Ini file name' 
    #~ end
    #~ unless karaoke[K_VIDEO]
      #~ ok = false
      #~ missing[K_VIDEO] = 'Video file name' 
    #~ end
    #~ unless karaoke[K_LYRICS]
      #~ ok = false
      #~ missing[K_LYRICS] = 'Lyrics file name' 
    #~ end
    #~ unless karaoke[K_ID]
      #~ ok = false
      #~ missing[K_ID] = 'Lyrics file name' 
    #~ end
    #~ return ok, missing
  #~ end
  
  # ---------------------------------
  # parse the given line and return the key and value from it
  # format : key=value
  def getKeyValue(pLine)
    m = pLine.match(REGEXP_ENTRY)
    return nil if m.nil?
    return m[1].upcase, m[2]
  end

  #~ # ---------------------------------
	#~ # test if the given line define the id of the karaoke
  #~ def isTMID(pLine)
  	 #~ k,v = getKeyValue(pLine)
  	 #~ return (k and v and (k === INI_ID))
  #~ end

end

puts "-- KaraokeService"

