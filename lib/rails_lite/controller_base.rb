require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  def session
    @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_built
  end

  def redirect_to(url)
    # @res.status = 302
    # @res.header['location'] = url.to_s

    # Above is roughly equivalent to below:
    @res.set_redirect(WEBrick::HTTPStatus[302], url)
    session.store_session(@res)

    @already_built = true
  end

  def render_content(content, type)
    @res.content_type = type
    @res.body = content
    session.store_session(@res)

    @already_built = true
  end

  def render(action_name)
    controller_name = self.class.to_s.underscore

    template = File.read("views/#{controller_name}/#{action_name}.html.erb")
    content = ERB.new(template).result(binding)

    render_content(content, 'text/text')
  end

  def invoke_action(name)
    send(name)

    unless already_rendered?
      render name
    end
  end
end
