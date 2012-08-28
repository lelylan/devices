class Hostable
  def initialize(app)
    @app = app
  end

  def call(env)
    puts "REGGIE LOG"
    puts env
    env['HTTP_HOST'] = env['HTTP_X_HOST'] if env['HTTP_X_HOST']
    puts env['HTTP_HOST']
    @app.call(env)
  end
end
