require "caxlsx"

module Suppliers
  class ExportToXlsx
    def self.call
      pkg = Axlsx::Package.new
      wb  = pkg.workbook

      wb.add_worksheet(name: "Suppliers") do |sheet|
        headers = ["No", "Category", "Group by color", "Name", "SKU", "Active", "Inactive", "Link"]
        sheet.add_row headers, style: header_style(wb)

        Supplier.order(:no, :id).find_each do |s|
          sheet.add_row [
            s.no,
            s.category,
            s.group_by_color,
            s.name,
            s.sku,
            s.active ? 1 : 0,
            s.inactive ? 1 : 0,
            s.link
          ]
        end

        sheet.column_widths 6, 18, 24, 60, 22, 10, 10, 50
      end

      [pkg, "exported_data.xlsx"]
    end

    def self.header_style(wb)
      wb.styles.add_style(b: true, alignment: { horizontal: :left }, bg_color: "E8EEF3")
    end
  end
end
