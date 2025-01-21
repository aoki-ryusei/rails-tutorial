require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:michael) { FactoryBot.create(:michael) }
  let(:micropost) { michael.microposts.build(content: "Lorem ipsum") }

  it 'micropostが有効であること' do
    expect(micropost).to be_valid
  end

  it 'user_idが必須であること' do
    micropost.user_id = nil
    expect(micropost).to_not be_valid
  end

  it 'contentが必須であること' do
    micropost.content = "  "
    expect(micropost).to_not be_valid
  end

  it 'contentが140文字以内であること' do
    micropost.content = "a" * 141
    expect(micropost).to_not be_valid
  end

  it '並び順は投稿の新しい順になっていること' do
    FactoryBot.send(:user_with_posts)
    expect(FactoryBot.create(:most_recent)).to eq Micropost.first
  end
end
