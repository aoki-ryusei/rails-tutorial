FactoryBot.define do
  factory :orange, class: Micropost do
    content { "I just ate an orange!" }
    created_at { 10.minutes.ago }
  end

  factory :most_recent, class: Micropost do
    content { "Writing a short test" }
    created_at { Time.zone.now }
    user { association :michael, email: 'recent@example.com' }
  end

end

def user_with_posts(posts_count: 5)
  FactoryBot.create(:michael) do |user|
    FactoryBot.create_list(:orange, posts_count, user: user)
  end
end
