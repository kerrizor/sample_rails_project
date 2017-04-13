require 'csv'

class ClearancingService
  def process_file(uploaded_file)
    ids_to_process = CSV.read(uploaded_file, headers: false).inject([]) do |ids, row|
      ids << row[0].to_i
    end

    confirm_clearancability_of_items(ids_to_process)
  end

  def process_array(ids_to_process = [])
    ids_to_process.map! do |item|
      case item
      when Item
        item.id
      when Numeric
        item.to_i
      else
        item
      end
    end

    confirm_clearancability_of_items(ids_to_process)
  end

private

  def confirm_clearancability_of_items(ids_to_process)
    @clearancing_status = create_clearancing_status

    ids_to_process.each do |potential_item_id|
      is_this_a_clearancable_item?(potential_item_id)
    end

    clearance_items!(@clearancing_status)
  end

  def is_this_a_clearancable_item?(potential_item_id)
    if clearancing_error = what_is_the_clearancing_error?(potential_item_id)
      @clearancing_status.errors << clearancing_error
    else
      @clearancing_status.item_ids_to_clearance << potential_item_id
    end
  end

  def clearance_items!(clearancing_status)
    if clearancing_status.item_ids_to_clearance.any?
      Item.transaction do
        clearancing_status.clearance_batch.save!
        clearancing_status.item_ids_to_clearance.each do |item_id|
          item = Item.find(item_id)
          item.clearance!
          clearancing_status.clearance_batch.items << item
        end
      end
    end
    clearancing_status
  end

  def what_is_the_clearancing_error?(potential_item_id)
    if potential_item_id.blank? || potential_item_id == 0 || !potential_item_id.is_a?(Integer)
      return "Item id #{potential_item_id} is not valid"
    end

    if Item.where(id: potential_item_id).none?
      return "Item id #{potential_item_id} could not be found"
    end

    if Item.sellable.where(id: potential_item_id).none?
      return "Item id #{potential_item_id} could not be clearanced"
    end

    return nil
  end

  def create_clearancing_status
    ClearancingStatus.new
  end

  class ClearancingStatus
    attr_accessor :clearance_batch, :item_ids_to_clearance, :errors

    def initialize
      @clearance_batch       = ClearanceBatch.new
      @item_ids_to_clearance = []
      @errors                = []
    end
  end
end
