# Renders PDF supporting document report for a fund_request
class DocumentsReport < Prawn::Document
  attr_accessor :fund_request
  attr_accessor :documents
  attr_accessor :rows
  attr_accessor :fund_item_rows

  def initialize(fund_request)
    self.fund_request = fund_request
    self.documents = Hash.new
    super( :page_size => 'LETTER' )
  end

  def rowify_fund_items( fund_items )
    fund_items.each do |fund_item|
      fund_item_rows << rows.length
      rows << [ fund_item.title, '', '' ]
      documents[fund_item] = fund_item.documents.
        where( 'fund_editions.perspective = ?', FundEdition::PERSPECTIVES.first ).all
      fund_item.node.document_types.each do |type|
        rows << [ type.name,
          ( documents[fund_item].map(&:document_type).include?( type ) ? 'Yes' : 'No' ),
          '' ]
      end
    end
  end

  def to_pdf
    text "Supporting Documentation Checklist", :align => :center, :size => 16
    text "#{fund_request} (ID##{fund_request.id})", :align => :center, :size => 16
    font 'Helvetica', :size => 10 do
      self.rows = [ [ 'FundItem/Document Type', 'E-filed?', "Staff Use Only\nReceived?" ] ]
      self.fund_item_rows = Array.new
      rowify_fund_items( fund_request.fund_items.documentable.uniq )
      table rows, :header => true, :width => 540 do |table|
        table.row(0).background_color = '000000'
        table.row(0).text_color = 'FFFFFF'
        table.cells.padding = 2
        table.columns(1..(table.column_length - 1)).border_left_width = 0.1
        table.columns(0..(table.column_length - 2)).border_right_width = 0.1
        table.rows(0..(table.row_length - 2)).border_bottom_width = 0.1
        table.rows(1..(table.row_length - 1)).border_top_width = 0.1
        table.column(2).background_color = 'DDDDDD'
        fund_item_rows.each do |fund_item_row|
          table.row(fund_item_row).background_color = 'DDDDDD'
          table.row(fund_item_row).borders = [:top, :bottom]
          table.row(fund_item_row).column(0).borders = [ :top, :bottom, :left ]
          table.row(fund_item_row).column(2).borders = [ :top, :bottom, :right ]
        end
      end
    end
    render
  end

end

