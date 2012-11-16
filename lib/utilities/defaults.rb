require 'bcrypt'

class Defaults

  # Find or create the applciation needed to create the access tokens to
  # send to the physical devices (the only way the can access Lelylan)
  def self.find_or_create_phisical_application
    app = Doorkeeper::Application.find_or_create_by(
      name: 'Physicals',
      redirect_uri: 'http://lelylan.com')
    app.resource_owner_id = Defaults.user_application.id
    app.save and app
  end

  private

  def self.user_application
    user = User.find_or_create_by(email: ENV['LELYLAN_APPS_USER_EMAIL'])
    user.encrypted_password = Defaults.encrypted_password if not user.encrypted_password
    user.save and user
  end

  def self.encrypted_password
    BCrypt::Password.create(ENV['LELYLAN_APPS_USER_PASSWORD'], cost: 10).to_s
  end
end
