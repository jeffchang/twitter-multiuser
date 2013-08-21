get '/' do
  @user = User.find_by_username(session[:username]) rescue nil

  if @user
    Twitter.configure do |config|
      config.oauth_token = @user.oauth_token
      config.oauth_token_secret = @user.oauth_secret
    end
    @tweets = Twitter.user_timeline(@user.username).map(&:text)
  end

  session.delete(:request_token)
  erb :index
end

post '/' do
  @user = User.find_by_username(session[:username]) rescue nil
  Twitter.configure do |config|
    config.oauth_token = @user.oauth_token
    config.oauth_token_secret = @user.oauth_secret
  end
  Twitter.update(params[:tweet])
  redirect '/'
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)

  # at this point in the code is where you'll need to create your user account and store the access token

  Twitter.configure do |config|
    config.oauth_token = @access_token.token
    config.oauth_token_secret = @access_token.secret
  end

  @user = User.find_by_username(Twitter.user.name) rescue nil
  unless @user
    @user = User.create({username: Twitter.user.name, oauth_token: @access_token.token, oauth_secret: @access_token.secret})
  else
    @user.oauth_token = @access_token.token
    @user.oauth_secret = @access_token.secret
    @user.save
  end
  session[:username] = @user.username

  redirect '/'
end
