
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 0.1
# Create : 2007/05/10 
# Last version : 2007/05/11 
# ==========================================================
# Profile Selector
# ==========================================================
# Description :
# Profile Selector Main Application class.
# ==========================================================

puts "require ProfileSelector"

# ----------------------------------------------------------
require 'digest/md5'
require $root+ "Common"
require $root+ "helper/Property"
require $root+ "constants/CstsConfigManager"
# ----------------------------------------------------------

puts "++ ProfileSelector"

module Application

  # The Glade class that load the profile selector UI
  class ProfileSelector
    include Common
    
    attr_accessor :main
    attr_reader :profileList, :profile

    PROFILE_FILE = CstsConfigManager::CONFIG_PATH+'profile.ini'

    puts "PROFILE_FILE = "+PROFILE_FILE

    # =================================
    public
    # ---------------------------------
    # Constructor
    def initialize(pMain = nil)
      log("initialize") {
        unless File.directory?(CstsConfigManager::CONFIG_PATH)
          log("mkdir "+CstsConfigManager::CONFIG_PATH)
          Dir.mkdir(CstsConfigManager::CONFIG_PATH)
        end
        @main = pMain
        @profile = nil
        load()
      }
    end
	
    # ---------------------------------
    # Add a new profile to the profile liste
    def addProfile(pLogin, pPassword)
      if @profileMap.key?(pLogin)
        return false, 'The profile '+pLogin+' already exists'
      end
      @profileMap[pLogin] =  encode(pPassword)
      @profileList << pLogin
      @profileList.sort!
      createProfileDir(pLogin)
      return true, 'Profile '+pLogin+' has been added'
    end

    # ---------------------------------
    # try to authentify for the given login and password
    def authenticate(pLogin, pPassword)
      @profile = nil
      unless @profileMap.key?(pLogin)
        return false, 'Unknown profile '+pLogin
      end
      encodedPassword = encode(pPassword)
      goodPassword = @profileMap[pLogin]
      # puts pPassword + " >> "+encodedPassword+"-"
      # puts "profile password = "+goodPassword+"-"
      if encodedPassword != goodPassword
        return false, 'Wrong password for '+pLogin+', try again'
      end
      @profile = pLogin
      return true, 'Loading profile ' + pLogin + '...'
    end

    # ---------------------------------
    def loadProfile()
      if @profile and @main
        createProfileDir(@profile)
        @main.loadProfile(@profile)
      end
    end
    
    # ---------------------------------
    def save()
      Property::save(PROFILE_FILE, @profileMap)
    end
	
    # ---------------------------------
    def load()
      @profileList = Array.new
      @profileMap = Property::load(PROFILE_FILE) { |bKey, bValue|
        @profileList << bKey        
      }
      unless @profileMap
        @profileMap = Hash.new
      end
      @profileList.sort!
    end

    # ---------------------------------
    def to_s
      s = ''
      @profileList.each { |bProfile|
        s += '  - '+bProfile+"\n"
      }
      return s
    end

    # =================================
    private
    # ---------------------------------
	
    # create the directory for the given profile
    def createProfileDir(pProfile)
      profileDir = File.join(CstsConfigManager::CONFIG_PATH,pProfile)
      unless File.directory?(profileDir)
        log("mkdir "+profileDir)
        Dir.mkdir(profileDir)
      end
    end
  
    # ---------------------------------
    # initialize profile list
    def iniProfileList()
      @profileMap.each { |bProfile, bPassword|
        @profileList << bProfile
      }			
    end
	
    # ---------------------------------
    # encode the given password
    def encode(pPassword)
      encoded = Digest::MD5.hexdigest(pPassword)
      # puts pPassword + " >> " + encoded
      return encoded
    end

    # ---------------------------------
    # Add admin account if necessary
    def addAdmin()
      # TODO
    end
	
  end
end

puts "-- ProfileSelector"

