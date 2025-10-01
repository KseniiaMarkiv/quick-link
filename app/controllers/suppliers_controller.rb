class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[ show edit update destroy ]

  # GET /suppliers
  def index
    @suppliers = Supplier.order(:no, :id)
  end

  # GET /suppliers/1
  def show; end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
  end

  # GET /suppliers/1/edit
  def edit; end

  # POST /suppliers
  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to suppliers_path, notice: "Supplier was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /suppliers/1
  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: "Supplier was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy!
    redirect_to suppliers_path, notice: "Supplier was successfully destroyed."
  end

  # ----- Import / Export -----

  # GET /suppliers/import_form
  def import_form
    @expected_headers = %w[No Category Group\ by\ color Name SKU Active Inactive link]
  end

  # POST /suppliers/import_from_excel
  def import_from_excel
    if params[:file].blank?
      redirect_to import_form_suppliers_path, alert: "Please choose a .xlsx or .xls file."
      return
    end

    begin
      count = Suppliers::ImportFromXlsx.call(params[:file])
      redirect_to suppliers_path, notice: "Imported #{count} rows."
    rescue Suppliers::ImportFromXlsx::HeaderError => e
      redirect_to import_form_suppliers_path, alert: e.message
    rescue => e
      redirect_to import_form_suppliers_path, alert: "Import failed: #{e.class} — #{e.message}"
    end
  end

  # GET /suppliers/download_xlsx
  def download_xlsx
    pkg, filename = Suppliers::ExportToXlsx.call
    send_data pkg.to_stream.read, filename:, type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(:no, :category, :group_by_color, :name, :sku, :active, :inactive, :link)
  end
end
