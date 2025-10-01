module Suppliers
  class ImportFromXlsx
    class HeaderError < StandardError; end

    # Canonical labels (for docs/exports only)
    CANON = ["No", "Category", "Group by color", "Name", "SKU", "Active", "Inactive", "link"].freeze
    # For matching: downcased
    EXPECTED_DOWN = CANON.map { |h| h.downcase }.freeze

    def self.call(uploaded_io)
      ext   = File.extname(uploaded_io.original_filename).delete(".").downcase
      book  = Roo::Spreadsheet.open(uploaded_io.tempfile.path, extension: ext)
      sheet = book.sheet(0)

      norm = ->(s) { s.to_s.gsub(/\u00A0/, " ").strip }               # trim + replace NBSP
      nlow = ->(s) { norm.call(s).downcase.gsub(/\s+/, " ") }         # normalized lower-case

      # ----- locate header row (scan first 20 rows) -----
      header_index = nil
      (1..20).each do |row_idx|
        raw = safe_row(sheet, row_idx)
        next if raw.nil? || raw.compact.empty?
        low = raw.map { |v| nlow.call(v) }.reject { |v| v.nil? || v == "" }
        # Only compare the first CANON.size columns, ignore extras
        if low.first(EXPECTED_DOWN.size) == EXPECTED_DOWN
          header_index = row_idx
          break
        end
      end
      raise HeaderError, "Missing header row. Expected: #{CANON.join(', ')}" if header_index.nil?

      # ----- import rows after header -----
      start_row     = header_index + 1
      blank_streak  = 0
      imported_rows = 0

      Supplier.delete_all  # remove for additive behavior

      row_idx = start_row
      while blank_streak < 25
        values = safe_row(sheet, row_idx)
        break if values.nil?

        if blank_row?(values)
          blank_streak += 1
        else
          blank_streak = 0
          # Map by position (first N columns)
          vals = values.first(CANON.size)
          rowh = Hash[ CANON.zip(vals) ]

          Supplier.create!(
            no:             integerish(rowh["No"]),
            category:       norm.call(rowh["Category"]),
            group_by_color: norm.call(rowh["Group by color"]),
            name:           norm.call(rowh["Name"]),
            sku:            norm.call(rowh["SKU"]),
            active:         truthy?(rowh["Active"]),
            inactive:       truthy?(rowh["Inactive"]),
            link:           norm.call(rowh["link"])
          )
          imported_rows += 1
        end

        row_idx += 1
      end

      imported_rows
    end

    # --- helpers ---

    def self.safe_row(sheet, idx)
      r = sheet.row(idx) rescue nil
      r.is_a?(Array) ? r : (r.nil? ? nil : Array(r))
    end

    def self.blank_row?(values)
      return true if values.nil?
      values.compact.all? { |v| v.to_s.strip.empty? }
    end

    def self.truthy?(val)
      return false if val.nil?
      %w[1 true yes y t].include?(val.to_s.strip.downcase)
    end

    def self.integerish(val)
      s = val.to_s.strip
      s.empty? ? nil : s.to_i
    end
  end
end
