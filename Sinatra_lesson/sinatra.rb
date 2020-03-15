require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'

enable :sessions



client = PG::connect(
    :host => "localhost",
    :user => ENV.fetch("USER", "taikin"),
    :password => '',
    :dbname => "myapp"
)


def check_user
    unless session[:user]
        redirect "/signin"
    end
end
def user_name
    if session[:user]
        @name = session[:user]['name'] + " さん"
    else
        @name = 'Friend'
    end
end


get '/' do
    user_name
    @now =Time.now

    erb :index
end




# 新規登録
get '/signup' do
    user_name
    erb :signup
end
post '/config' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    client.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", [name, email, password])
    user = client.exec_params("SELECT * from users WHERE email = $1 AND password = $2", [email, password]).to_a.first
    session[:user] = user

    redirect '/config'
end
get '/config' do
    user_name
    @name = session[:user]['name']
    @email = session[:user]['email']
    @password = session[:user]['password']
    @pass = "*" * @password.size

    erb :config
end

# ログイン機能
get '/signin' do
    session[:user] = nil
    user_name
    return erb :signin
end
post '/signin' do
    email = params[:email]
    password = params[:password]
    user = client.exec_params("SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}' LIMIT 1").to_a.first
    if user.nil?
        @error_coment = "ログインに失敗しました"
        return erb :signin
    else
        session[:user] = user
        return redirect '/board'
    end
end

# ログアウト機能
delete '/signout' do
    session[:user] = nil
    user_name
    redirect '/'
end




# 投稿機能
get '/board' do
    user_name
    redirect "/signin" unless session[:user]
    user_id = session[:user]['id']
    @posts = client.exec_params("SELECT * FROM posts WHERE user_id = #{user_id}")

    return erb :board
end

post '/posts' do
    title = params[:title]
    content = params[:content]
    start_time = params[:start]
    end_time = params[:end]
    # time = start_time.to_i - end_time.to_i
    client.exec_params("INSERT INTO posts (user_id, title, content, start_time, end_time) VALUES ($1, $2, $3, $4, $5)", 
    [session[:user]['id'], title, content, start_time, end_time])
    redirect '/board'
end


get '/new_schedule' do
    user_name
    check_user
    @now = Time.now
    return erb :new_schedule
end

