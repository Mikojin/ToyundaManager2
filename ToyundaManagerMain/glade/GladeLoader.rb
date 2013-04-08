
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 2
# Create : 2007/05/10 
# Last version : 2012/02/25
# ==========================================================
# Glade Loader Module
# ==========================================================
# Description :
# Simplify the loading of glade file
# Require libglade2 to work.
# v2 : Switch to Gtk::Builder instead of Glade
# ==========================================================

puts "require GladeLoader"

# ----------------------------------------------------------
# require 'libglade2'
require 'gtk2'
require $root + 'gui/GUI'
# ----------------------------------------------------------

puts "++ GladeLoader"

module GladeLoader
  include GetText

  attr_reader :glade

  # =================================
  private
  # ---------------------------------
  # initialize glade
  def iniGlade(fileName)
    bindtextdomain(nil, nil, nil, "UTF-8")
#    @glade = GladeXML.new(fileName, nil, nil, nil, GladeXML::FILE) { |handler| 
    @glade = Gtk::Builder.new
    @glade.add_from_file(fileName)
	
    @glade.connect_signals { |handler|
      #log("handler "+handler.class.to_s+" : "+handler.to_s)
      newProc = nil
      begin
        newMethod = method(handler)
        newProc = nil
        if newMethod.arity == 0
          newProc = proc { 
            begin
              log(handler.to_s) {
                newMethod.call()
              }
            rescue Exception => e
              msgList = ["An error occured while executing method #{handler}",e.to_s]
              msgList.concat(e.backtrace)
              GUI::popupError(msgList)
            end
          }
        else
          newProc = proc { |*bArg|
            begin
              log(handler.to_s) {
                newMethod.call(*bArg)
              }
            rescue Exception => e
              msgList = ["An error occured while executing method #{handler}",e.to_s]
              msgList.concat(e.backtrace)
              GUI::popupError(msgList)
            end
          }
        end
        #~ newProc
      rescue NameError => excp
        log(excp.class.to_s+" >> "+excp.to_s)
        newProc = proc { |*bArg|
          GUI::popupError("binding missing for : #{handler}")
        }
        #~ newProc
      end
      newProc
    }
  end

  
end

puts "-- GladeLoader"

