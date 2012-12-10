require 'rack/redis_throttle'

class DailyRateLimit < Rack::RedisThrottle::Daily

  def call(env)
    @user_rate_limit = nil
    super
  end

  def client_identifier(request)
    user_rate_limit(request).respond_to?(:_id) ? user_rate_limit(request).id : 'user-unknown'
  end

  def max_per_window(request)
    user_rate_limit(request).respond_to?(:rate_limit) ? user_rate_limit(request).rate_limit : 9999
  end

  def need_protection?(request)
    request.env.has_key?('HTTP_AUTHORIZATION')
  end

  def http_error(request, code, message = nil, headers = {})
    [ code, { 'Content-Type' => 'application/json' }.merge(headers), [body(request).to_json] ]
  end

  def body(request)
    {
      status: 403,
      method: request.env['REQUEST_METHOD'],
      request: "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{request.env['PATH_INFO']}",
      error: {
        code: 'notifications.access.rate_limit',
        description: I18n.t('notifications.access.rate_limit'),
        daily_rate_limit: max_per_window(request)
      }
    }
  end

  private

  def user_rate_limit(request)
    @user_rate_limit ||= find_user_rate_limit(request)
  end

  def find_user_rate_limit(request)
    token         = request.env['HTTP_AUTHORIZATION'].split(' ')[-1]
    access_token  = Doorkeeper::AccessToken.where(token: token).first
    access_token ? User.find(access_token.resource_owner_id) : nil
  end
end
