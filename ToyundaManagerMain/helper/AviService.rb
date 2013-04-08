
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/10/10 
# Last version : 2007/10/11 
# ==========================================================
# Avi Service
# ==========================================================
# Description :
# Can retrieve information of an avi file
# ==========================================================

puts "require AviService"

# ----------------------------------------------------------
require $root+ "Common"
require $root+ "helper/AviFile"
# ----------------------------------------------------------

puts "++ AviService"

class AviService
	include Common

  def initialize()
    log("initialize")
  end

	# create and return the AviFile object for the given avi file name
	# return nil if an error occurs
	def getAviFile(fname)
		begin
      unless File.exist?(fname)
        log("file not found : "+fname)
        return nil 
      end
			avi = AviFile.new(fname)
		rescue Exception => err
      log("error in avi file "+fname) {
        log_exception(err)
      }
			return nil
		end
	end

	# open the given avi file and return the duration of the video in seconds
	# return -1 if an error occurs
	def getDuration(fname)
		avi = getAviFile(fname)
    return nil if avi.nil?
		return avi.duration 
	end	

	# display information from the givel AviFile object
	def logInfo(aviFile)
		log("filename = "+aviFile.filename.to_s) {
      log "frames = "+aviFile.frames.to_s
      log "period = "+aviFile.period.to_s
      log "duration = "+aviFile.duration.to_s+" s"
      log "fps = "+aviFile.fps.to_s
      log "streams = "+aviFile.streams.to_s
      log "width = "+aviFile.width.to_s+" px"
      log "height = "+aviFile.height.to_s+" px"
      log "resolution = "+aviFile.resolution.to_s
      log "video_fourcc = "+aviFile.vids.to_s
      log "video_codec = "+aviFile.codec.to_s
      log "scale = "+aviFile.scale.to_s
      log "rate = "+aviFile.rate.to_s
      log "length = "+aviFile.length.to_s
      log "frequence = "+aviFile.frequence.to_s+" f/s"
      log "true_duration = "+aviFile.true_duration.to_s
      log "audio_codec = "+aviFile.audio_codec.to_s
      log "audio_fourcc = "+aviFile.auds_fourcc.to_s
    }
	end

	# display information from the given Avi File name
	def logInfoFromFile(fname)
		a = getAviFile(fname)
		if a.nil?
			log "Error loading file : "+fname
    else
      logInfo(a)
		end
	end
	
	# display information for all the avi file name contained in the given list
	def logInfoListAvi(pListeVideo)
		pListeVideo.each { |bVideo|
			log "======================================"
			logInfoFromFile(bVideo)
			log "======================================"
		}
	end

end

puts "-- AviService"

