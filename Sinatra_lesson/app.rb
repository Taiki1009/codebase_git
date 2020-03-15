require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'



client = PG::connect(
    :host => "localhost",
    :user => ENV.fetch("USER", "taikin"),
    :password => '',
    :dbname => "myapp"
)


get '/' do
    return "<h1>こんにちは！</h1>"
end

# get '/mypage/:name' do
#     return erb :mypage
# end



# 画像アップロード
get '/form' do
    erb :form
end
post "/form" do
    @value1 = params[:value1]
    @value2 = params[:value2]
    @value3 = params[:value3]
    if !params[:img].nil? # データがあれば処理を続行する
        tempfile = params[:img][:tempfile] # ファイルがアップロードされた場所
        save_to = "./public/images/#{params[:img][:filename]}" # ファイルを保存したい場所
        FileUtils.mv(tempfile, save_to)
    @img_name = params[:img][:filename]
    end
    return erb :form_receiver
end
# タイムライン
get '/board' do
    @posts = client.exec_params("SELECT * FROM posts").to_a
    return erb :board
end

post '/posts' do
    content = params[:content]
    client.exec_params("INSERT INTO posts (user_id, content) VALUES ($1, $2)", 
    [session[:user]['id'], content])
    redirect '/board'
end






#　Cookie , session
# セッションの宣言
enable :sessions



# 新規作成
get '/signup' do
    return erb :signup
end
post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    client.exec_params("INSERT INTO users (name, email, password) VALUES ($1, $2, $3)", [name, email, password])
    user = client.exec_params("SELECT * from users WHERE email = $1 AND password = $2", [email, password]).to_a.first
    session[:user] = user
    return redirect '/mypage'
end
# get "/mypage" do
#     # @name = cookies[:user]
#     @name = session[:user]['name'] # 書き換える
#     return erb :mypage
# end

# ログイン機能
get '/signin' do
    return erb :signin
end
post '/signin' do
    email = params[:email]
    password = params[:password]
    user = client.exec_params("SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}' LIMIT 1").to_a.first
    if user.nil?
        return erb :signin
    else
        session[:user] = user
        return redirect '/mypage'
    end
end




# ログアウト機能
delete '/signout' do
    session[:user] = nil
    redirect '/signin'
end










get '/self_intro' do
    erb :self_intro
end

# ターミナル終了： Ctrl ＋ C