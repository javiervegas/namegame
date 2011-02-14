#require 'rubygems'
require 'linkedin'
require 'andand'

class AuthController < ApplicationController

  def index
    client = get_client
    request_token = client.request_token(:oauth_callback =>
                                      "http://#{request.host_with_port}/auth/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret

    redirect_to client.request_token.authorize_url

  end

  def callback
    client = get_client
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      client.authorize_from_access(session[:atoken], session[:asecret])
    end
    @profile = client.profile
    connections = client.connections.find_all{|connection| !connection.picture_url.andand.empty?}.sort_by{ rand }.slice(0...5)
    @mistery = connections.sort_by{ rand }.first
    @connections = connections.sort_by{ rand }
    #@updates = client.network_updates(:type => "SHAR").updates

    @oauth_verifier = params[:oauth_verifier]
    @oauth_token = params[:oauth_token]
    if !params[:mistery].nil?
      @ok = params[:ok].to_i
      @ko = params[:ko].to_i
      if (params[:guess]==params[:mistery])
        @ok+=1
        @result = "Yes, that was #{params[:guess]}"
      else
        @ko+=1
        @result = "No, that was #{params[:guess]}, not #{params[:mistery]}"
      end
    else
      @ok=@ko=0
    end
  end

  def get_client
    client = LinkedIn::Client.new(
        "NBxTSeJiKjsnPH6pFR9-B2lhqlDb4LZNMuzL63YuyuLKqhdwhQVzWa3kP0Exgnnk",
        "PGg4Yl6xvkrLveG7jKq1eFbLrkWINV5AH0eY-TaYBGWOWi-XjpxuLXGFk9YW35p7"
    )
  end
end

