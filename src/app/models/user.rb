class User < ApplicationRecord
  # インスタンス変数を定義
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
    presence: true,
    length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: true
  # 存在チェックも行っている
  has_secure_password
  # nilを許容する
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    # 新たなトークンを発行してremember_digestに保存
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    # DBに保存されているdigestとtokenを比較
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # クラスメソッド
  class << self
    # 渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def new_token
      #  A–Z、a–z、0–9、"-"、"_"のいずれかの文字（26×2+10+1+1=64種類）からなる長さ22のランダムな文字列を返す
      SecureRandom.urlsafe_base64
    end
  end
end
