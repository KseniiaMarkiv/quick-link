module Suppliers
  class ImportFromXlsx
    class HeaderError < StandardError; end

    EXPECTED = ["No", "Category", "Group by color", "Name", "SKU", "Active", "Inactive", "link"].freeze

    def self.call(uploaded_io)
      x = Roo::Spreadsheet.open(uploaded_io.tempfile.path, extension: File.extname(uploaded_io.original_filename).delete("."))
      sheet = x.sheet(0)

      # Validate headers exactly
      headers = sheet.row(1).map(&:to_s)
      unless headers == EXPECTED
        raise HeaderError, "Wrong headers. Expected: #{EXPECTED.join(', ')}"
      end

      # Clear & re-import? If you prefer additive, remove the delete_all line.
      Supplier.delete_all

      count = 0
      (2..sheet.last_row).each do |r|
        row = Hash[[EXPECTED, sheet.row(r)].transpose]

        Supplier.create!(
          no:            integerish(row["No"]),
          category:      row["Category"].to_s.strip,
          group_by_color:row["Group by color"].to_s.strip,
          name:          row["Name"].to_s.strip,
          sku:           row["SKU"].to_s.strip,
          active:        truthy?(row["Active"]),
          inactive:      truthy?(row["Inactive"]),
          link:          row["link"].to_s.strip
        )
        count += 1
      end
      count
    end

    def self.truthy?(val)
      return false if val.nil?
      s = val.to_s.strip.downcase
      ["1", "true", "yes", "y", "t"].include?(s)
    end

    def self.integerish(val)
      val.to_s.strip == "" ? nil : val.to_i
    end
  end
end
