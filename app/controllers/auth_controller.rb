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
    #client.update_status('is playing with the LinkedIn API')
    @profile = client.profile
    @connections = client.connections
  end
end

