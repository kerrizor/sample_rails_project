class ClearanceBatchesController < ApplicationController

  def index
    @clearance_batches  = ClearanceBatch.all
  end

  def new

  end

  def create
    if params[:csv_batch_file]
      clearancing_status = ClearancingService.new.process_file(params[:csv_batch_file].tempfile)
    elsif params[:batch_ids]
      ids = params[:batch_ids].reject{|e| e == "0" || e.empty?}.map{ |e| e.to_i }.compact

      if ids.empty?
        flash[:alert] = "No IDs submitted."
        redirect_to action: :index and return true
      end

      clearancing_status = ClearancingService.new.process_array(ids)
    end

    clearance_batch    = clearancing_status.clearance_batch
    alert_messages     = []

    if clearance_batch.persisted?
      flash[:notice]  = "#{clearance_batch.items.count} items clearanced in batch #{clearance_batch.id}"
    else
      alert_messages << "No new clearance batch was added"
    end

    if clearancing_status.errors.any?
      alert_messages << "#{clearancing_status.errors.count} item ids raised errors and were not clearanced"
      clearancing_status.errors.each {|error| alert_messages << error }
    end

    flash[:alert] = alert_messages.join("<br/>") if alert_messages.any?

    if clearance_batch.persisted?
      redirect_to clearance_batch
    else
      redirect_to action: :index
    end
  end

  def show
    @clearance_batch = ClearanceBatch.find(params[:id])
    @items = Hash.new

    Item.includes(:style).where(clearance_batch_id: params[:id]).each do |item|
      identifier = item.style.name + item.style.type + item.color + item.size

      if @items.key? identifier
        @items[identifier][:count] += 1
        @items[identifier][:price] += item.price_sold
      else
        @items[identifier] = {
          name:  item.style.name,
          type:  item.style.type,
          size:  item.size,
          color: item.color,
          count: 1,
          retail: item.style.retail_price,
          price: item.price_sold,
        }
      end
    end
  end
end
