require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let (:michael) { FactoryBot.create(:michael) }
  let (:archer) { FactoryBot.create(:archer) }
  let (:relationship) { Relationship.new(follower_id: michael.id,
                                      followed_id: archer.id) }

  it '有効であること' do
    expect(relationship).to be_valid
  end

  it 'follower_idが必須であること' do
    relationship.follower_id = nil
    expect(relationship).to_not be_valid
  end

  it 'followed_idが必須であること' do
    relationship.followed_id = nil
    expect(relationship).to_not be_valid
  end
end
