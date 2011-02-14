#require 'rubygems'
require 'linkedin'

class AuthController < ApplicationController

  def index
    # get your api keys at https://www.linkedin.com/secure/developer
    client = LinkedIn::Client.new(
        "NBxTSeJiKjsnPH6pFR9-B2lhqlDb4LZNMuzL63YuyuLKqhdwhQVzWa3kP0Exgnnk",
        "PGg4Yl6xvkrLveG7jKq1eFbLrkWINV5AH0eY-TaYBGWOWi-XjpxuLXGFk9YW35p7"
    )
    request_token = client.request_token(:oauth_callback =>
                                      "http://#{request.host_with_port}/auth/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret

    redirect_to client.request_token.authorize_url

  end

  def callback
    client = LinkedIn::Client.new(
        "NBxTSeJiKjsnPH6pFR9-B2lhqlDb4LZNMuzL63YuyuLKqhdwhQVzWa3kP0Exgnnk",
        "PGg4Yl6xvkrLveG7jKq1eFbLrkWINV5AH0eY-TaYBGWOWi-XjpxuLXGFk9YW35p7"
    )
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      client.authorize_from_access(session[:atoken], session[:asecret])
    end
    if !session[:pdate].nil?
      client.share({
         :comment => "Testing out the LinkedIn API",
         :title => "Sfhare",
         :url => "http://www.linkedin.com",
         :image_url => "http://www.southdacola.com/blog/wp-content/uploads/2009/09/scooby-doo.jpeg"
     })
      client.update_status("schhmurfs!")
    end
    @profile = client.profile
    connections = client.connections.find_all{|connection| !connection.picture_url.empty?}.sort_by{ rand }.slice(0...5)
    @guess = connections.sort_by{ rand }.first
    @connections = connections.sort_by{ rand }
    #@updates = client.network_updates(:type => "SHAR").updates
  end
end

