FactoryGirl.define do

  factory :clearance_batch do

    factory :clearance_batch_with_items do
      transient do
        item_count 5
      end

      after(:create) do |clearance_batch, evaluator|
        create_list(:item, evaluator.item_count, clearance_batch: clearance_batch)
      end
    end
  end

  factory :item do
    style
    price_sold 5
    color "Blue"
    size "M"
    status "sellable"
  end

  factory :style do
    name "Snoopy Pajamas"
    type "Pajamas"
    wholesale_price 55
    retail_price 75
  end
end
