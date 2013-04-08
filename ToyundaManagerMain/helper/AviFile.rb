# ==========================================================
# Author : J, Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/13 
# Last version : 2007/10/16
# ==========================================================
# Avi Header Reader
# ==========================================================
# Description :
# read the header of an avi file in order to extract 
# informations.
# 
#
# DWORD = 32-bits [4 chars]
# WORD = 16-bits [2 chars]
# FOURCC = 4 character code/id to describe data type (DWORD)
# => http://www.webkinesia.com/games/videoformats.php
#
# * RIFF format description :
#   => 'RIFF' fileSize fileType listData
#     - DWORD 'RIFF' is the fourcc 'RIFF'
#     - DWORD fileSize = size of [type + listData]
#     - DWORD fileType FOURCC for the format of this RIFF file
#     - listData : consists of CHUNKs or LISTs, in any order 
# * CHUNK format description :
#   => chunkID chunkSize chunkData
#     - chunkID is a FOURCC that identifies the data contained in the chunk,
#     - chunkSize is a 4-byte value giving the size of data in chunkData not including padded values,
#     - chunkData is zero or more bytes of data, padded to nearest WORD boundary (mod 2). 
#
# * LIST format description :
#   => 'LIST' listSize listType listData
#     - 'LIST' is the literal FOURCC code 'LIST,
#     - listSize is 4-byte value, indicating the size of the list,
#     - listType is a FOURCC code specifying the list type,
#     - listData consists of chunks or lists, in any order 
#
# ==========================================================

puts "require AviFile"

# ==========================================================
require $root+ "Common"
# ==========================================================

puts "++ declaration AviFile"

class AviFile
  include Common

  attr_reader :filename, :period, :frames, :streams, :width, :height, :vids, :auds
  attr_reader :auds_fourcc, :scale, :rate, :length

  SIZE_MAX = 500_000_000
  SIZE_08 = 2**8
  SIZE_16 = 2**16
  SIZE_24 = 2**24
  
  KILO = 1024
  MEGA = KILO * KILO
  GIGA = KILO * MEGA
  
  @@codecs = {
    "3IV0" => "3IVX", "3IV1" => "3IVX", "3IV2" => "3IVX",
    "AASC" => "Autodesk", "AFLI" => "Autodesk", "AFLC" => "Autodesk",
    "AP41" => "Angelpotion",
    "CRAM" => "Video 1", "MSVC" => "Video 1",
    "DIV3" => "DivX 3 low-motion", "DIV4" => "DivX 3 fast-motion",
    "DIVX" => "DivX 4", "DX50" => "DivX 5",
    "MJPG" => "Motion JPEG",
    "MP41" => "Microsoft MPEG 4 V1", "MP42" => "Microsoft MPEG 4 V2",
    "MP43" => "Microsoft MPEG 4 V3",

    "CVID" => "Radius Cinepak", "HFYU" => "Huffyuv 2.1.1",
    "I420" => "Intel 4:2:0 Video V2.50", "IV32" => "Indeo 3.2",
    "IV41" => "Indeo 4.5", "IV50" => "Indeo 5.10",
    "IYUV" => "Intel IYUV", "M261" => "Microsoft H.261",
    "M263" => "Microsoft H.263", "MRLE" => "Microsoft RLE",
    "MSVC" => "Video 1", "VIFP" => "VFAPI Wrapper codec",
    "XVID" => "XviD MPEG-4"
  }

  @@audiocodecs = {
    "\x01\x00" => "PCM",
    "\x02\x00" => "ADPCM",
    "\x11\x00" => "IMA ADPCM",
    "\x06\x00" => "CCITT G.711",
    "\x07\x00" => "CCITT G.711",
    "\x31\x00" => "Microsoft GSM 6.10",
    "\x22\x00" => "TrueSpeech",
    "\x42\x00" => "Microsoft G.723.1",
    "\x60\01x" => "WMA / DivX Audio",
    "\x61\x01" => "WMA / DivX Audio",
    "\x30\x01" => "Sipro",
    "\x02\x04" => "Indeo audio",
    "\x55\x00" => "Fraunhofer MP3",
    "\x00\x20" => "AC3",
    "\x4F\x67" => "Ogg Vorbis"
  }

  # ==========================================================

  def initialize(filename)
    set_debug_lvl(10)
    log("file : "+filename) {
      file = File.open(filename)
      file.binmode
      begin
        @next_is_audio = false
        @filename = filename
        riff = read(file,4)                         # read RIFF header id
        if riff != "RIFF"
          # can't read if not a RIFF
          log("Not a RIFF file : "+riff)
          return
        end
        
        buffer = read(file,4)
        size = to_n(buffer)                         # Read the size
        
        avi = read(file,4)                          # read data ID
        if avi != "AVI "
          # can't read if not avi
          log("Not an AVI file : '"+riff+"' ("+size.to_s+") ["+buffer.to_s+"] '"+avi+"'")
          return
        end

        strSize = prettySize(size)
        # only the first list/chunk interest us
        log(riff+" ("+strSize+") '"+avi+"'") {
          read_list_or_chunk(file, size)            # read the main chunk
        }
      ensure
        log("closing file")
        file.close
      end
    }
  end

  # ==========================================================
  private
  # ==========================================================

  def prettySize(pSize)
    octet = pSize
    mega = octet / MEGA
    octet = octet - (mega * MEGA)
    kilo = octet / KILO
    octet = octet - (kilo * KILO)
    str = ''
    str += "#{mega}Mo, " if mega > 0
    str += "#{kilo}ko, " if kilo > 0
    str += "#{octet}"
    return str
  end

  # ----------------------------------------------------------
  # convert the given 4-byte (DWORD) value into a number
  def to_n(s)
    return 0 if s.nil?  #mikomi
    return s[0] + SIZE_08 * s[1] + SIZE_16 * s[2] + SIZE_24 * s[3]
  end

  # read pSize byte in the given file
  def read(pFile, pSize)
    #~ preOffset = pFile.pos
    buffer = pFile.read(pSize)
    #~ postOffset = pFile.pos
    #~ diff = (postOffset - preOffset)
    #~ if pSize != diff
      #~ log("*** READ ERROR : read="+pSize.to_s+" ; preOffset="+preOffset.to_s+" ; postOffset="+postOffset.to_s+" ; diff="+diff.to_s)
      #~ if buffer.nil?
        #~ log("*** Buffer nil")
      #~ else
        #~ buffer = buffer[0...pSize] if buffer..size > pSize
      #~ end
      #~ seek(pFile, preOffset+pSize, IO::SEEK_SET)
      #~ log("*** move : "+pFile.pos.to_s+" : "+buffer.class.to_s)
    #~ end
    return buffer
  end

  # if size is too big, we have to seek in several time
  def seek(file, size, pOption = IO::SEEK_CUR)
    newSize = size
    if(size > SIZE_MAX)
      log("===> BIG : "+size.to_s)
    end
    while newSize > SIZE_MAX
      file.seek(SIZE_MAX, pOption)
      newSize = newSize - SIZE_MAX
    end
    file.seek(newSize, pOption)
  end

  # ----------------------------------------------------------
  # read a listData element : list or chunk.
  # pTotalSize : maximum possible size for this chunk
  def read_list_or_chunk(file, pTotalSize)
    fourcc = read(file,4)
    size = to_n(read(file,4))
    sizeRead = 8
    log("size + "+sizeRead.to_s+" [ fourcc + size ]")
    
    if size > pTotalSize 
      log("*** error '"+fourcc+"' : "+size.to_s+" > "+pTotalSize.to_s)
      seek(file, pTotalSize - sizeRead)
      return pTotalSize
    end
    
    case fourcc
    when "LIST"
      sizeRead += parse_list(file, size)
    else
      sizeRead += parse_chunk(fourcc, file, size)
    end
    return sizeRead
  end

  # parse a LIST of listData
  def parse_list(file, size)
    id = read(file,4)
    sizeRead = 4
    log("'LIST' ("+size.to_s+") '"+id+"'") {
      log("size + "+sizeRead.to_s+" [ listId ]")
      while size > sizeRead
        sizeLeft = size - sizeRead
        sizeRead += read_list_or_chunk(file, sizeLeft)
        log("  size "+sizeRead.to_s+'/'+size.to_s)
      end
    }
    return sizeRead
  end

  # parse a chunk (size is padded to nearest upper WORD boundary)
  def parse_chunk(fourcc, file, size)
    chunkSize = size
    if (size % 2) == 1
      chunkSize += 1 
      log("true size : "+chunkSize.to_s)
    end
    log("'"+fourcc.to_s+"' ("+chunkSize.to_s+") ")
    case fourcc
      when "avih"
          read_header(file, chunkSize)
      when "strh"
          read_stream_header(file, chunkSize)
      when "strf"
          read_stream_format(file, chunkSize)
      when "JUNK"
        seek(file, chunkSize)
      else
        seek(file, chunkSize)
    end
    return chunkSize
  end

  # read header data
  # AVI Main Header doc :
  # => http://msdn2.microsoft.com/en-us/library/ms779632.aspx
  # => http://www.alexander-noe.com/video/documentation/avi.pdf
  #~ DWORD  dwMicroSecPerFrame;
  #~ DWORD  dwMaxBytesPerSec;
  #~ DWORD  dwPaddingGranularity;
  #~ DWORD  dwFlags;
  #~ DWORD  dwTotalFrames;
  #~ DWORD  dwInitialFrames;
  #~ DWORD  dwStreams;
  #~ DWORD  dwSuggestedBufferSize;
  #~ DWORD  dwWidth;
  #~ DWORD  dwHeight;
  #~ DWORD  dwReserved[4];
  def read_header(file, size)
    sizeRead = 0
    
    buffer = read(file,4)
    sizeRead += 4
    @period = to_n(buffer)
    
    buffer = read(file,12)
    sizeRead += 12
    
    buffer = read(file,4)
    sizeRead += 4
    @frames = to_n(buffer)
    
    buffer = read(file,4)
    sizeRead += 4

    buffer = read(file,4)
    sizeRead += 4
    @streams = to_n(buffer)
    
    buffer = read(file,4)
    sizeRead += 4

    buffer = read(file,4)
    sizeRead += 4
    @width = to_n(buffer)
    
    buffer = read(file,4)
    sizeRead += 4
    @height = to_n(buffer)
    
    sizeLeft = size - sizeRead
    #~ log("  left : "+sizeLeft.to_s+" = "+size.to_s+" - "+sizeRead.to_s)
    if sizeLeft > 0
      buffer = read(file,sizeLeft)
      #~ log("  unknown = '"+buffer.to_s+"'")
      #~ fullheader += buffer
    end
    #~ log("header : '"+fullheader.to_s+"'")
  end

  # read the stream header strh
  def read_stream_header(file, size)
    @next_is_audio = false
    sizeRead = 4
    case read(file,4)
      when "vids"
        sizeRead += read_video_header(file, size-4)
      when "auds"
        @next_is_audio = true
        sizeRead += read_audio_header(file, size-4)
    end
    sizeLeft = size - sizeRead
    seek(file, sizeLeft) if sizeLeft > 0
  end
  
  # read info from the video stream header
  def read_video_header(file, size)
    sizeRead = 0
    @vids = read(file,4)
    sizeRead += 4
    buffer = read(file, 8)
    sizeRead += 8
    @initial_frame = to_n(read(file,4))
    sizeRead += 4
    
    @scale = to_n(read(file,4))
    sizeRead += 4
    @rate = to_n(read(file,4))
    sizeRead += 4
    @length = to_n(read(file,4))
    sizeRead += 4

    return sizeRead
  end

  # read info from the audio stream header
  def read_audio_header(file, size)
    sizeRead = 0
    @auds_fourcc = read(file,4)
    sizeRead += 4
    return sizeRead
  end

  # read the steam format strf
  def read_stream_format(file, size)
    if (@next_is_audio)
      @auds = read(file, 2)
      seek(file, size - 2)
    else
      seek(file, size)
    end
  end

  # ==========================================================
  public
  # ==========================================================

  def fps
    return @fps if @fps
    unless @period
      @fps = nil 
    else
      @fps = 1_000_000_000.0 / @period
      @fps = @fps.round
      @fps = @fps / 1_000.0
    end
    return @fps
  end
  
  def duration
    return nil unless @frames and @period
    return @frames * @period / 1_000_000
  end

  def frequence
    return @frequence if @frequence
    unless @scale and @rate
      @frequence = nil
    else
      @frequence = (@rate.to_f * 1_000.0) / @scale.to_f
      @frequence = @frequence.round
      @frequence = @frequence / 1_000.0
    end
    return @frequence
  end

  def true_duration
    currentFps = self.fps
    return nil unless currentFps and @length
    return (@length / currentFps).to_i
  end

  def resolution
    return "#{@width}x#{@height}"
  end

  def codec
    codec = @@codecs[@vids.upcase]
    return codec if codec
    return @vids
  end

  def audio_codec
    codec = @@audiocodecs[@auds]
    return codec if codec
    return @auds.dump if @auds
    return @auds
  end

end

puts "-- declaration AviFile"
