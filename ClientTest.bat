call SetEnv.bat

%RUBY_PATH%\bin\ruby ClientTest.rb

@echo off
set PATH=%OLD_PATH%

@echo on

pause