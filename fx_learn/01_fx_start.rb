require 'fox16'

include Fox

class FxSample

end

def the_button theMainWindow, theApp
  # http://www.fxruby.org/doc/ch03s03.html
  # object creation
  theButton = FXButton.new(theMainWindow, "Exit Button!")
  theButton.connect(SEL_COMMAND) { |sender, selector, data| exit }

  # for the tooltip message thing.. neat..
  theButton.tipText = "Push Me!"
  FXToolTip.new(theApp) # just need to do this before the run mainloop


  # for images on elements
  # iconFile = File.open("pbr.jpg", "rb")
  # iconFile = File.open("./assets/ruby.jpg", "rb")
  # theButton.icon = FXJPGIcon.new(theApp, iconFile.read) # not working for some reason!
  iconFile = File.open("./assets/ruby.png", "rb")
  theButton.icon = FXPNGIcon.new(theApp, iconFile.read)
  iconFile.close
  theButton.iconPosition = ICON_ABOVE_TEXT # for position.. need to explore other options

  # theButton.icon.options = IMAGE_ALPHAGUESS
  # theButton.icon.options = IMAGE_ALPHACOLOR
  theButton.icon.options = IMAGE_ALPHAGUESS | IMAGE_ALPHACOLOR
  # theButton.icon.options = IMAGE_ALPHACOLOR | IMAGE_ALPHAGUESS

end

def launch
  # creates the server app
  theApp = FXApp.new

  # builds the content
  theMainWindow = FXMainWindow.new(theApp, "Hello")

  the_button theMainWindow, theApp

  # actually creates the app objects to serve
  theApp.create
  theMainWindow.show # needs special instr to display the main thread
  theApp.run # and finally runs the main thread

end

launch
