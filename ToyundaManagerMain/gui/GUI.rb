
# ==========================================================
# Author : Mikomi
# ==========================================================
# Version : 1.0
# Create : 2007/05/17 
# Last version : 2007/05/17
# ==========================================================
# Generique GUI module 
# ==========================================================
# Description :
# Generique GUI module
# Contains lots of helper
# ==========================================================



puts "require  GUI"

# ----------------------------------------------------------
require 'gtk2'
require 'pango'

# ----------------------------------------------------------

puts "++  GUI"


module GUI
  
  # set the given style to the given widget for the given state
  def GUI::setStyle(pState, pWidget, pStyle)
    pWidget.modify_font(Pango::FontDescription.new(pStyle.font))
    pWidget.modify_fg(pState, pStyle.foreground)
    pWidget.modify_bg(pState, pStyle.background)
  end

  # Popup Dialog box for file or directory select
  def GUI::selectFileDirectoryDialog(parent, msg, action, fname=nil, filterPatternList=[])
    dialog = Gtk::FileChooserDialog.new(msg, parent, action, nil,
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
      [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
    dialog.select_filename(fname) unless fname == nil
    filter = GUI::getFileFilter(filterPatternList)
    dialog.add_filter(filter) if filter
    dialog.add_filter(GUI::getFileFilter(["*"]))
    if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
      fname = dialog.filename
    else
      fname = nil
    end
    dialog.destroy
    return fname
  end

  def GUI::getFileFilter(pFilterPatternList)
    return nil if pFilterPatternList.nil? or pFilterPatternList.size < 1
    filter = Gtk::FileFilter.new
    filter.name = pFilterPatternList.join(";")
    pFilterPatternList.each { |bFilterPattern|
      filter.add_pattern(bFilterPattern)
    }
    return filter
  end

  # Popup Dialog box for file select
  def GUI::selectFileDialog(parent, msg, fname=nil, pFilter=nil)
    return selectFileDirectoryDialog(parent, msg, Gtk::FileChooser::ACTION_SAVE, fname, pFilter)
  end

  # Popup Dialog box for file select
  def GUI::selectOpenFileDialog(parent, msg, fname=nil, pFilter=nil)
    return selectFileDirectoryDialog(parent, msg, Gtk::FileChooser::ACTION_OPEN, fname, pFilter)
  end

  # Popup Dialog box for directory select
  def GUI::selectDirectoryDialog(parent, msg, fname=nil, pFilter=nil)
    return selectFileDirectoryDialog(parent, msg, Gtk::FileChooser::ACTION_SELECT_FOLDER, fname, pFilter)
  end
  
  # Popup Dialog box for font select
  def GUI::selectFontDialog(oldFontName)
    fd = Gtk::FontSelectionDialog.new("Select Font")
    fd.font_name = oldFontName
    newFontName = oldFontName
    fd.run { |resp|
      case resp
      when Gtk::Dialog::RESPONSE_OK
        newFontName = fd.font_name
      end
    }
    fd.destroy
    return newFontName
  end
  
  # Popup Dialog box for Color select
  def GUI::selectColorDialog(oldColor)
    fd = Gtk::ColorSelectionDialog.new("Select Font Color")
    fd.colorsel.current_color = oldColor
    newColor = oldColor
    fd.run { |resp|
      case resp
      when Gtk::Dialog::RESPONSE_OK
        newColor = fd.colorsel.current_color
      end
    }
    fd.destroy
    return newColor
  end

  def GUI::popupGeneric(pMsgList, pType, pParent = nil)
    msg = ""
    pMsgList.each { |bMsg|
      msg += bMsg + "\n"
    }
    popup = Gtk::MessageDialog.new(
      pParent, 
      Gtk::Dialog::DESTROY_WITH_PARENT, 
			pType, 
      Gtk::MessageDialog::BUTTONS_CLOSE,
      msg)
    popup.run
    popup.destroy
  end
  
  def GUI::popupInfo(pMsgList, pParent = nil)
    popupGeneric(pMsgList, Gtk::MessageDialog::INFO, pParent)
  end
  
  def GUI::popupError(pMsgList, pParent = nil)
    popupGeneric(pMsgList, Gtk::MessageDialog::ERROR, pParent)
  end
  
end

puts "--  GUI"

