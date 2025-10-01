# app/services/suppliers/import_from_xlsx.rb
require "roo"

module Suppliers
  class ImportFromXlsx
    class HeaderError < StandardError; end

    # Canonical labels we want in this order (used for export and mapping)
    CANON = ["No", "Category", "Group by color", "Name", "SKU", "Active", "Inactive", "Link"].freeze
    CANON_DOWN = CANON.map { |h| h.downcase } # for matching

    def self.call(uploaded_io)
      ext   = File.extname(uploaded_io.original_filename).delete(".").downcase
      book  = Roo::Spreadsheet.open(uploaded_io.tempfile.path, extension: ext)
      sheet = book.sheet("Sheet1")

      Rails.logger.debug "[IMPORT] Sheets: #{book.sheets.inspect}"
      Rails.logger.debug "[IMPORT] Last row: #{sheet.last_row.inspect}"
      (1..5).each do |i|
        Rails.logger.debug "[IMPORT] Row #{i}: #{sheet.row(i).inspect}"
      end

      norm = ->(s) { s.to_s.gsub(/\u00A0/, " ").strip }              # trim + replace NBSP
      nlow = ->(s) { norm.call(s).downcase.gsub(/\s+/, " ") }        # normalized lower

      # ---- find header row within the first 20 rows ----
      header_index = nil
      header_preview = nil
      (1..20).each do |row_idx|
        row = safe_row(sheet, row_idx)
        next if row.nil? || row.compact.empty?
        header_preview ||= row # remember the very first non-empty row for debugging
        Rails.logger.debug "[IMPORT] Header found at row #{header_index}: #{sheet.row(header_index).inspect}"

        low = row.map { |v| nlow.call(v) }.reject(&:empty?)
        if low.first(CANON_DOWN.size) == CANON_DOWN
          header_index = row_idx
          break
        end
      end

      if header_index.nil?
        # Helpful debug in flash + logs
        msg = "Missing header row. Expected: #{CANON.join(', ')}"
        msg << ". First non-empty row seen by Roo: #{Array(header_preview).map { |v| v.to_s }.join(' | ')}" if header_preview
        Rails.logger.warn("[IMPORT] #{msg}")
        raise HeaderError, msg
      end

      # ---- import rows after header ----
      Supplier.delete_all # remove this if you want additive imports

      imported = 0
      blank_streak = 0
      row_idx = header_index + 1

      while blank_streak < 25
        values = safe_row(sheet, row_idx)
        break if values.nil? # sheet ended

        if blank_row?(values)
          blank_streak += 1
        else
          blank_streak = 0
          data = Hash[ CANON.zip(values.first(CANON.size)) ]
          Supplier.create!(
            no:             integerish(data["No"]),
            category:       norm.call(data["Category"]),
            group_by_color: norm.call(data["Group by color"]),
            name:           norm.call(data["Name"]),
            sku:            norm.call(data["SKU"]),
            active:         truthy?(data["Active"]),
            inactive:       truthy?(data["Inactive"]),
            link:           norm.call(data["Link"])
          )
          imported += 1
        end

        row_idx += 1
      end

      imported
    end

    # ------- helpers -------
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
