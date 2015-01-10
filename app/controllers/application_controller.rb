class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  private
    def after_sign_in_path_for(users)
      root_path
    end

    def after_sign_out_path_for(users)
      root_path
    end

    def stored_location_for(user)
      root_path
    end
end
