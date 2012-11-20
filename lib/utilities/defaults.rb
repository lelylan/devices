require 'bcrypt'

class Defaults

  # Find or create the applciation needed to create the access tokens to
  # send to the physical devices (the only way the can access Lelylan)
  def self.phisical_application_id
    Rails.cache.fetch 'client:name:physicals:id' do
      app = Doorkeeper::Application.find_or_create_by(
        name: 'Physicals',
        redirect_uri: 'http://lelylan.com')
      app.resource_owner_id = Defaults.user_application_id
      app.save and app.id
    end
  end

  private

  def self.user_application_id
    Rails.cache.fetch "user:mail:-#{ENV['LELYLAN_APPS_USER_EMAIL']}:id" do
      user = User.find_or_create_by(email: ENV['LELYLAN_APPS_USER_EMAIL'])
      user.encrypted_password = Defaults.encrypted_password if not user.encrypted_password
      user.save and user.id
    end
  end

  def self.encrypted_password
    BCrypt::Password.create(ENV['LELYLAN_APPS_USER_PASSWORD'], cost: 10).to_s
  end
end
