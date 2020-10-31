FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Title #{n}" }
    content  { "Sample content" }
    status { :todo }
    deadline { 1.week.from_now }
    association :user
  end
end
