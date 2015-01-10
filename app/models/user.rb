class User < ActiveRecord::Base
  acts_as_followable
  acts_as_follower
  has_private_messages
  has_one :user_setting
  has_many :messages
  has_many :posts
  has_many :comments
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:confirmable,
         :recoverable, :rememberable, :timeoutable, :trackable#, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me, :first_name, :last_name, :username,
                  :birthday, :gender, :country, :website, :bio, :avatar, :user_setting_attributes, :agree
  # attr_accessible :title, :body
  mount_uploader :avatar, AvatarUploader
  accepts_nested_attributes_for :user_setting, :allow_destroy => true
 # validates :agree, :acceptance => true, :on => :create, :presence => {:message => "Click it"}

  validates :username, :uniqueness => true
  scope :get_group_by_results, lambda{|chartBy, user_names|
    { :select => "#{chartBy}, count(*) as count",
      :group => chartBy,
      :conditions => ['username in (?)', user_names],
      :order => 'username DESC'}
    }
  protected
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:username)
    where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first  if !login.blank?
  end
end
