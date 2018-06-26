class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def cas_extra_attributes=(extra_attributes)
    extra_attributes.each do |name, value|
      case name.to_sym
      when :fullname
        self.fullname = value
      when :password
        self.encrypted_password = value
      when :email
        self.email = value
      when :sysadmin
        self.sysadmin = value
      when :ckan_apikey
        self.ckan_apikey = value
      end
    end
  end
end
