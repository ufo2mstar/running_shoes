require 'require_all'
require_all 'support'
require 'axlsx'
require 'combos'
require 'active_support/all'
require 'csv'

include YamlRider
# YamlLoadError = Class.new(StandardError)
file_loc = File.dirname(__FILE__)
path     = (Dir[file_loc+"/*.yml"].first) # full vars
# path     = (Dir[file_loc+"/*.yml"].last) # shorter vars
p "Files:\n#{path}\n"
erb = erb_eval(path)

flattened_erb = {}
erb.each { |head, unflat_list|
  flat_list = []
  unflat_list.each { |val|
    if val.class == Hash
      val.each { |sub_head, sub_list| sub_list.each { |sub_val| flat_list << "#{sub_head.titleize} -> #{sub_val}" } }
    elsif val.class == String
      flat_list << val
    else
      p "Shouldnt get here!", :r
    end
  }
  flattened_erb[head.to_s]=flat_list
}
erb = flattened_erb

include Combos
@vars = erb.values
p @headers = erb.keys
COL_END = (65+@headers.length).chr # to get the Excel col num
p @vars.map(&:length).reduce(&:*)


# File.open('pow.txt', 'w') do |f|
#   @combos = power_pair *@vars do |line|
#     f.write line
#   end
#   # @combos = combo_pair 12332, *@vars
#   # f.write @combos
# end

# CSV.open('pow2.csv', 'w') do |csv|
#   # @combos = power_pair *@vars
#   # f.puts @combos
#   @combos = combo_pair (1e6-1).to_i, *@vars do |comb|
#     csv << comb
#   end
# end


timestamp = Time.now.strftime "%Y-%m-%d_%H-%M-%S"
# date_string = Time.now.strftime("%m-%d-%Y")

book_name = "./scens/ClientScenarios_#{timestamp}.xlsx"


def make_book book_name
  text_fix    =-> ary { ary.map(&:titleize) }
  text_suffix =-> ary, suffix { ary.map { |itm| "#{itm}#{suffix}" } }
  p "making #{book_name}"
  Axlsx::Package.new do |pac|
    p tic book_name

# write the combos sheet!
    write_to_xlsx =-> sheet_name {
      opts_sheet_name = "#{sheet_name}_options"

      # == Making the scenarios sheet
      p "started sheet '#{sheet_name}' at #{tic sheet_name}", :bl
      tots = 0
      pac.workbook.add_worksheet(:name => sheet_name) do |sheet|
        header_style  = sheet.styles.add_style :sz => 10, :b => true, :alignment => { :horizontal => :center }, name: "Ariel"
        content_style = sheet.styles.add_style :sz => 10, :b => false, :alignment => { :horizontal => :left }, name: "calibri"

        sheet.add_row(['Scenario ID']+text_fix[@headers], :widths => :auto, :style => header_style)
        @combos.each_with_index do |row_ary, row_count|
          tots +=1
          begin
            sheet.add_row([row_count+1]+row_ary, :widths => :auto, :style => content_style)
          rescue Exception => e
            puts e.class, e.message
            puts e.stacktrace if defined? e.stacktrace
          ensure
            # toc sheet_name
          end
        end
        # adding filters enabled by default
        sheet.auto_filter = "A1:#{COL_END}1"
        # adding data_validation for the combo boxes
        @headers.each_with_index { |itm, itm_idx|
          col      = (66+itm_idx).chr # offset for formulae
          vars_len = @vars[itm_idx].length
          range    = "#{opts_sheet_name}!$#{col}$2:$#{col}$#{vars_len+1}"
          sheet.add_data_validation("#{col}:#{col}", {
              :type             => :list,
              :formula1         => range,
              :showDropDown     => false, # displays the combobox
              :showErrorMessage => true,
              :errorTitle       => '',
              :error            => "Kindly enter the right #{itm.upcase} values ie: found in the range #{range}",
              :errorStyle       => :stop,
              :showInputMessage => true,
              :promptTitle      => '',
              :prompt           => "Select the #{itm.upcase} type" })
        }


        p "#{sheet_name}.. Done!\n#{tots} rows in #{toc sheet_name}s", :g
        # options_sheet pac,"#{sheet_name}_options"
      end

      # == Making the options sheet
      p "started sheet '#{opts_sheet_name}' at #{tic opts_sheet_name}", :bl
      tots = 0
      pac.workbook.add_worksheet(:name => opts_sheet_name) do |sheet|
        header_style  = sheet.styles.add_style :sz => 10, :u => true, :alignment => { :horizontal => :center }
        content_style = sheet.styles.add_style :sz => 10, :b => false, :alignment => { :horizontal => :left }, name: "calibri"

        header_size = @headers.length
        header_row  = ['sl.no']+text_fix[@headers]+["Count"]+text_suffix[@headers, " count"]
        # adding header
        sheet.add_row(header_row, :widths => :auto, :style => header_style)
        @data = []

        max_vals = @vars.map(&:length).max
        max_vals.times.each_with_index do |row_num, row_count|
          row_ary     = @vars.map { |list| list[row_num] }
          tots        +=1
          options_row = [row_count+1]+row_ary+[nil] # blank space for count separation
          header_size.times do |i|
            col         = (66+i).chr # offset for formulae
            count_col   = col # offset for formulae
            option_cell = "#{count_col}#{row_num+2}"
            count_range = "#{sheet_name}!#{col}:#{col}"
            options_row<<"=IF(COUNTIFS(#{count_range},#{option_cell})<>0,COUNTIFS(#{count_range},#{option_cell}),IF(ISBLANK(#{option_cell}),\" \",0))"
          end
          begin
            sheet.add_row(options_row, :widths => :auto, :style => content_style)
          rescue Exception => e
            puts e.class, e.message
            puts e.stacktrace if defined? e.stacktrace
          ensure
            # toc sheet_name
          end
        end

        @start_val = nil
        #todo: loop over all the headers and generate the charts sequentially (change end based on how large the variables are)
        header_size.times do |itm_idx|
          # data range
          col          = (66+itm_idx).chr # offset for formulae
          itm_offset   = itm_idx + header_size +1 # label offset
          count_col    = (66+itm_offset).chr # offset for formulae
          vars_len     = @vars[itm_idx].length+1 # +1 for title offset
          # range      = "#{opts_sheet_name}!$#{col}$2:$#{col}$#{vars_len+1}"

          title_cell   = "#{count_col}1"
          labels_range = "#{col}2:#{col}#{vars_len}"
          data_range   = "#{count_col}2:#{count_col}#{vars_len}"

          # chart limits
          @start_val   ||= max_vals+4

          start_col   = "A"
          start_row   = @start_val
          @start_at   = "#{start_col}#{start_row}"
          end_col_len = (66+(vars_len/3).to_i) # based on values (x axis elements)
          end_col     = [end_col_len, 66+26].min.chr
          end_row     = (@start_val+vars_len*1.5).to_i # based on labels (y axis elements)
          @end_at     = "#{end_col}#{end_row}"

          # reset limits for next round
          @start_val  = end_row + 2

          # Chart try, but dangit, this is broke as hell.. need to figure this out
          sheet.add_chart(Axlsx::Bar3DChart, :start_at => @start_at, :end_at => @end_at, :title => sheet[title_cell]) do |chart|
            chart.add_series :data => sheet[data_range], :labels => sheet[labels_range], :title => sheet[title_cell]
            # chart.valAxis.label_rotation = -45
            # chart.catAxis.label_rotation = 45
            chart.d_lbls.d_lbl_pos = :outEnd
            chart.d_lbls.show_val  = true

            chart.catAxis.tick_lbl_pos = :none
          end
        end

        p "#{opts_sheet_name} and Charts.. Done!\n#{tots} rows in #{toc opts_sheet_name}s", :g
      end
    }


# run_ary = %w[power_pair serial_pair random_pair]
    run_ary       = %w[serial_pair random_pair]
# run_ary = ['serial_pair']
# make the sheets!
    run_ary.each { |sheet_name|
      pseudo_key = 123; srand pseudo_key # for repeatability
      @combos = send(sheet_name, *@vars)
      # p combos
      write_to_xlsx[sheet_name]
    }

    sheet_name = 'combo_pair'
    pseudo_key = 123; srand pseudo_key # for repeatability
    @combos = send(sheet_name, 1000, *@vars)
    write_to_xlsx[sheet_name]

    toc book_name
    pac.serialize(book_name)
# file closes automatically - thanks to idiomatic ruby
  end
end


make_book book_name
