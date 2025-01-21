require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(name: "Example User",
                        email: "user@example.com",
                        password: "foobar",
                        password_confirmation: "foobar") }
  it 'userが有効であること' do
    expect(user).to be_valid
  end

  it 'nameが必須であること' do
    user.name = "  "
    expect(user).to_not be_valid
  end

  it 'emailが必須であること' do
    user.email = "  "
    expect(user).to_not be_valid
  end

  it 'nameが50文字以内であること' do
    user.name = "a" * 51
    expect(user).to_not be_valid
  end

  it 'emailが255文字以内であること' do
    user.email = "a" * 244 + "@example.com"
    expect(user).to_not be_valid
  end

  it 'emailが不正な形式の場合は無効であること' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).to_not be_valid
    end
  end

  it 'emailが重複している場合は無効であること' do
    duplicate_user = user.dup
    duplicate_user.email = user.email.upcase
    user.save
    expect(duplicate_user).to_not be_valid
  end

  it 'emailは小文字として保存されること' do
    mixed_case_email = "Owq5W@example.com"
    user.email = mixed_case_email
    user.save
    expect(mixed_case_email.downcase).to eq user.reload.email
  end

  it 'passwordが必須であること' do
    user.password = user.password_confirmation = " " * 6
    expect(user).to_not be_valid
  end

  it 'passwordが6文字以上であること' do
    user.password = user.password_confirmation = "a" * 5
    expect(user).to_not be_valid
  end

  it 'トークンが一致していないときに有効であることauthenticated?がfalseを返すこと' do
    expect(user.authenticated?(:remember, '')).to be_falsy
  end

  it 'remember_digestが保存されること' do
    expect(user.remember_digest).to be_nil
    user.remember
    expect(user.remember_digest).to_not be_nil
  end

  it 'remember_digestが削除されていること' do
    user.remember
    expect(user.remember_digest).to_not be_nil
    user.forget
    expect(user.remember_digest).to be_nil
  end

  it '関連されたmicropostsが削除されること' do
    user.save
    user.microposts.create!(content: "Lorem ipsum")
    expect { user.destroy }.to change(Micropost, :count).by(-1)
  end

  context 'フォローされていない場合'  do
    let (:michael) { FactoryBot.create(:michael) }
    let (:archer) { FactoryBot.create(:archer) }

    it 'フォローできること' do
      expect(michael.following?(archer)).to be_falsy
      michael.follow(archer)
      expect(michael.following?(archer)).to be_truthy
      expect(archer.followers.include?(michael)).to be_truthy
    end

    it 'フォロー解除できること' do
      michael.follow(archer)
      michael.unfollow(archer)
      expect(michael.following?(archer)).to be_falsy
    end

    it '自分自身はフォローできないこと' do
      michael.follow(michael)
      expect(michael.following?(michael)).to be_falsy
    end
  end

  it '正しい投稿が表示されること' do
    michael = FactoryBot.create(:michael)
    archer = FactoryBot.create(:archer)
    lana = FactoryBot.create(:lana)

    # フォローしているユーザーの投稿を確認
    lana.microposts.each do |post_following|
      expect(michael.feed.include?(post_following)).to be_truthy
    end

    # フォロワーがいるユーザー自身の投稿を確認
    michael.microposts.each do |post_self|
      expect(michael.feed.include?(post_self)).to be_truthy
      expect(michael.feed.distinct).to eq michael.feed
    end

    # フォローしていないユーザーの投稿を確認
    archer.microposts.each do |post_unfollowed|
      expect(michael.feed.include?(post_unfollowed)).to be_falsy
    end
  end
end
