class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method = pattern, http_method
    @controller_class, @action_name = controller_class, action_name
  end

  def matches?(req)
    @route_params = req.path.match(@pattern)
    return false unless !!@route_params
    return false unless @http_method == req.request_method.downcase.to_sym
    true
  end

  def run(req, res)
    controller = @controller_class.new(req, res, @route_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
    # proc.call
  end

  [:get, :post, :put, :delete].each do |http_method|
    # add these helpers in a loop here
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      if route.matches?(req)
        return route
      end
    end
    nil
  end

  def run(req, res)
    match = match(req)

    unless match.nil?
      match.run(req, res)
    else
      res.status = 404
    end
  end
end
