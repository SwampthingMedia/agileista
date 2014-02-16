class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_domain
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  TheDomain = 'app.agileista.com'

  def after_sign_in_path_for(resource)
    projects_path
  end

  def ensure_domain
    if request.env['HTTP_HOST'] != TheDomain && Rails.env == "production"
      redirect_to "https://#{TheDomain}"
    end
  end

  def ssl_required?
    return false if (local_request? || ['development', 'test'].include?(Rails.env))
    super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
