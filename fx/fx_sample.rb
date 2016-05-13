require 'fox16'

include Fox

class FxSample

end

def launch
  theApp = FXApp.new

  theMainWindow = FXMainWindow.new(theApp, "Hello")
  FXButton.new(theMainWindow, "Hello, World!")
  theApp.create

  theMainWindow.show
  theApp.run

end

launch
