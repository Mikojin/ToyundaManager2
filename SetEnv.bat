@echo off

set OLD_PATH=%PATH%

set GTK_BASEPATH="C:\Program Files\ruby\lib\GTK"

set RUBY_PATH="C:\Program Files\ruby"

rem symbole euro for ruby
set INPUTRC=%RUBY_PATH%\bin\inputrc.euro

rem option for ruby
set RUBYOPT=-rubygems

rem for CAIRO
rem set CAIRO_PATH="C:\Program Files\ruby\lib\ruby\site_ruby\1.8\cairo"

rem lib for GTK
set LIB=%GTK_BASEPATH%\lib;%GTK_BASEPATH%\bin

rem include for GTK
set INCLUDE=%GTK_BASEPATH%\bin;%GTK_BASEPATH%\lib;%GTK_BASEPATH%\lib\GTK-2.0;%GTK_BASEPATH%\lib\GLIB-2.0;%GTK_BASEPATH%\lib\pango;%GTK_BASEPATH%\etc\pango;%GTK_BASEPATH%\INCLUDE\CAIRO;%GTK_BASEPATH%\INCLUDE\ATK-1.0;%GTK_BASEPATH%\lib\GTKGLEXT-1.0;%GTK_BASEPATH%\LIB\GTK-2.0\INCLUDE;%GTK_BASEPATH%\LIB\GLIB-2.0\INCLUDE;%GTK_BASEPATH%\LIB\GTKGLEXT-1.0\INCLUDE;%GTK_BASEPATH%\INCLUDE\LIBGLADE-2.0;%GTK_BASEPATH%\INCLUDE\LIBXML2;

rem path with ruby and gtk
set PATH=%RUBY_PATH%\bin;%GTK_BASEPATH%;%GTK_BASEPATH%\bin;%GTK_BASEPATH%\LIB;%OLD_PATH=%


@echo on
