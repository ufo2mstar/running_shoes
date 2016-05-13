require 'fox16'
# require 'customer'
# customer.rb

Customer = Struct.new("Customer", :name, :address, :zip)

$customers = []
$customers << Customer.new("Reed Richards", "123 Maple, Central City, NY", 010111)
$customers << Customer.new("Sue Storm", "123 Maple, Anytown, NC", 12345)
$customers << Customer.new("Benjamin J. Grimm", "123 Maple, Anytown, NC", 12345)
$customers << Customer.new("Johnny Storm", "123 Maple, Anytown, NC", 12345)


include Fox

class ClipMainWindow < FXMainWindow
  def initialize(anApp)
    # Initialize base class first
    super(anApp, "Clipboard Example", :opts => DECOR_ALL, :width => 400, :height => 300)


    # Horizontal frame contains buttons
    buttons = FXHorizontalFrame.new(self, LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)

    # Cut and paste buttons
    copyButton = FXButton.new(buttons, "Copy")
    pasteButton = FXButton.new(buttons, "Pasteeeeeeeeee")


    # Place the list in a sunken frame
    sunkenFrame = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_SUNKEN|FRAME_THICK, :padding => 10)

    # Customer list
    customerList = FXList.new(sunkenFrame, :opts => LIST_BROWSESELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
    $customers.each do |customer|
      customerList.appendItem(customer.name, nil, customer)
    end

    # User clicks Copy
    copyButton.connect(SEL_COMMAND) do
      customer = customerList.getItemData(customerList.currentItem)
      types = [ FXWindow.stringType ]
      if acquireClipboard(types)
        @clippedCustomer = customer
      end
    end

  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  FXApp.new("ClipboardExample", "FXRuby") do |theApp|
    ClipMainWindow.new(theApp)
    theApp.create
    theApp.run
  end
end