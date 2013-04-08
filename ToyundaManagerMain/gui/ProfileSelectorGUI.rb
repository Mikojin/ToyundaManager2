
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 1.0
# Create : 2007/05/10 
# Last version : 2007/05/13 
# ==========================================================
# Profile Selector GUI 
# ==========================================================
# Description :
# GUI for the Toyunda Manager Profile Selector :
# - Select your profile.
# - enter your password.
# - Launch Toyunda Manager for your profile.
# Require libglade2 to work.
# ==========================================================

puts "require ProfileSelectorGUI"

# ----------------------------------------------------------
require 'gtk2'

require $root+ "Common"
require $root+ "glade/GladeLoader"
require $root+ "application/ProfileSelector"

# ----------------------------------------------------------

puts "++ ProfileSelectorGUI"

module GUI

  # The Glade class that load the profile selector UI
  class ProfileSelectorGUI
    include Common
    include GladeLoader

    attr_reader :application	
    attr :listStore
	
    # =================================
    # Constants
    # ---------------------------------
    GLADE_FILE = $root+"glade/ProfileSelector.ui"
    W_WINDOW = "profileSelector"
    W_PROFILE_COMBO = "comboboxProfile"
    W_PROFILE = "entryLogin"
    W_PASSWORD = "entryPassword"
    W_INFO = "labelInfo"
    
    # =================================
    public
    # ---------------------------------
    # constructor
    def initialize(pParent=nil, pApplication = nil)
      log("initialize") {
        @parent = pParent
        @application = pApplication
        unless @application
          @application = Application::ProfileSelector.new()
        end
      }
    end

    def start()
      log("start") {
        iniGlade(GLADE_FILE)
        iniComboBox()
        window = getWindow()
        window.transient_for = @parent.getWindow()      
        window.modal = true
        window.show_all
      }
    end

    def hide()
      window = getWindow()
      window.hide_all()
      window.transient_for = nil
      window.modal = false
      #@application.save()
    end
	
    # =================================
    private
    # ---------------------------------
    # initialize the combobox content
    def iniComboBox()
      updateListStore
      @glade[W_PROFILE_COMBO].model = @listStore
    end

    # ---------------------------------
    # update the content the profile list
    def updateListStore()
      if @listStore == nil
        @listStore = Gtk::ListStore.new(String)
      end
      @listStore.clear()
      @application.profileList.each { |bProfile|
        iter = @listStore.append()
        iter[0] = bProfile
      }      
    end
    
    def returnProfile()
      log("returnProfile") {
        @application.loadProfile()
        @parent.callProfileChange()
        @glade[W_WINDOW].destroy
        @glade = nil
      }
    end
    
    # =================================
    # Controle
    # ---------------------------------

    def getWindow()
      return @glade[W_WINDOW]
    end
    
    # ---------------------------------
    # get the selected profile in the combobox, nil if empty
    def getSelectedProfile()
      iter = @glade[W_PROFILE_COMBO].active_iter
      return nil unless iter
      return iter[0]
    end
    
    # ---------------------------------
    # get the profile, nil if empty or not correct
    def getProfile()
      profile = @glade[W_PROFILE].text
      unless profile =~ /^\S+$/
        return nil
      end
      return profile
    end
    
    # ---------------------------------
    # set the profile
    def setProfile(pProfile)
      @glade[W_PROFILE].text = pProfile
    end
    
    # ---------------------------------
    # get the password, nil if empty or not correct
    def getPassword()
      password = @glade[W_PASSWORD].text
      unless password =~ /^\S+$/
        return nil
      end
      return password
    end
    
    # ---------------------------------
    # get the password, nil if empty or not correct
    def clearPassword()
      @glade[W_PASSWORD].text = ''
    end

    # ---------------------------------
    # set the info texte
    def setInfo(msg, color=INFO_COLOR)
      s = '<span foreground="'+color+'"><b>'+ msg +'</b></span>'
      #      log("setInfo >> "+s)
      @glade[W_INFO].markup = s
    end

    # ---------------------------------
    def getLoginAndPassword()
      profile = getProfile()
      unless profile
        setInfo("Enter a valide login", ERROR_COLOR)
        return false
      end
      password = getPassword()
      unless password
        setInfo("Enter a valide password", ERROR_COLOR)
        return false
      end
      return true, profile, password
    end
    
    def doCheckAndAuthenticate()
      # check profile / password
      ok, profile, password = getLoginAndPassword()
      unless ok
        return
      end
      ok, msg = @application.authenticate(profile, password)
      if ok
        setInfo(msg)
        returnProfile()
      else
        # authenticate failed
        setInfo(msg, ERROR_COLOR)
      end
    end
    
    # =================================
    # Handler
    # ---------------------------------
    def on_buttonCreate_clicked(widget)
      #      log("on_buttonCreate_clicked")
      ok, profile, password = getLoginAndPassword()
      unless ok
        return
      end
      ok, msg = @application.addProfile(profile, password)
      if ok
        setInfo(msg)
        updateListStore()
      else
        setInfo(msg, ERROR_COLOR)
      end
    end

    # ---------------------------------
    def on_comboboxProfile_changed(widget)
      #      log("on_comboboxProfile_changed")
      selectedProfile = getSelectedProfile()
      unless selectedProfile
        return
      end
      setProfile(selectedProfile)
      clearPassword()
    end
    
    # ---------------------------------
    def on_entryLogin_focus_out_event(widget, event)
      #      log("on_entryLogin_editing_done")
      profile = getProfile()
      combo = @glade[W_PROFILE_COMBO]
      combo.active = -1
      @listStore.each { |model, path, iter|
        if iter[0] == profile
          combo.active_iter = iter
        end
      }
      false
    end
    
    # ---------------------------------
    # click on the button OK 
    def on_buttonOk_clicked(widget)
      #      log("on_buttonOk_clicked")
      doCheckAndAuthenticate()
    end
	
    # ---------------------------------
    # press enter on the password entry
	 def on_entryPassword_activate(widget)
      doCheckAndAuthenticate()
	 end
	 
    # ---------------------------------
    def on_delete_event(widget, arg0)
      #      log("closing")
      false
    end

    # ---------------------------------
    def on_destroy(widget)
      #      log("exit")
      @application.save()
    end
    
  end

end

puts "-- ProfileSelectorGUI"
