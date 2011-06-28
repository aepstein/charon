# Renders PDF supporting document report for a request
class DocumentsReport < Prawn::Document
  attr_accessor :request
  attr_accessor :documents
  attr_accessor :rows
  attr_accessor :item_rows

  def initialize(request)
    self.request = request
    self.documents = Hash.new
    super( :page_size => 'LETTER' )
  end

  def rowify_items( items )
    items.each do |item|
      item_rows << rows.length
      rows << [ item.title, '', '' ]
      documents[item] = item.documents.
        where( 'editions.perspective = ?', Edition::PERSPECTIVES.first ).all
      item.node.document_types.each do |type|
        rows << [ type.name,
          ( documents[item].map(&:document_type).include?( type ) ? 'Yes' : 'No' ),
          '' ]
      end
    end
  end

  def to_pdf
    text "Supporting Documentation Checklist", :align => :center, :size => 16
    text "#{request} (ID##{request.id})", :align => :center, :size => 16
    font 'Helvetica', :size => 10 do
      self.rows = [ [ 'Item/Document Type', 'E-filed?', "Staff Use Only\nReceived?" ] ]
      self.item_rows = Array.new
      rowify_items( request.items )
      table rows, :header => true, :width => 540 do |table|
        table.row(0).background_color = '000000'
        table.row(0).text_color = 'FFFFFF'
        table.cells.padding = 2
        table.columns(1..(table.column_length - 1)).border_left_width = 0.1
        table.columns(0..(table.column_length - 2)).border_right_width = 0.1
        table.rows(0..(table.row_length - 2)).border_bottom_width = 0.1
        table.rows(1..(table.row_length - 1)).border_top_width = 0.1
        table.column(2).background_color = 'DDDDDD'
        item_rows.each do |item_row|
          table.row(item_row).background_color = 'DDDDDD'
          table.row(item_row).borders = [:top, :bottom]
          table.row(item_row).column(0).borders = [ :top, :bottom, :left ]
          table.row(item_row).column(2).borders = [ :top, :bottom, :right ]
        end
      end
    end
    render
  end

end

