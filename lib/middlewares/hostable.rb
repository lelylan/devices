class Hostable
  def initialize(app)
    @app = app
  end

  def call(env)
    env['HTTP_HOST'] = env['HTTP_X_HOST'] if env['HTTP_X_HOST']
    @app.call(env)
  end
end
