FactoryBot.define do
  factory :michael, class: User do
    name { 'Michael Example' }
    email { 'michael@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { true }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :inactive, class: User do
    name { 'Inactive User' }
    email { 'inactive@example.com' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    activated { false }
    activated_at { nil }
  end

  factory :archer, class: User do
    name { 'Sterling Archer' }
    email { 'duchess@example.gov' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :lana, class: User do
    name { 'Lana Kane' }
    email { 'hands@example.gov' }
    password { 'password' }
    password_confirmation { 'password' }
    admin { false }
    activated { true }
    activated_at { Time.zone.now }
  end
end
