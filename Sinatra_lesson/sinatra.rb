require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'
require 'time'

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
        @name = 'Guest'
    end
end

get '/' do
    user_name
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

    @posts = client.exec_params("SELECT * FROM posts WHERE user_id = #{user_id} ORDER BY start_time ASC")
    return erb :board
end

post '/posts' do
    title = params[:title]
    content = params[:content]
    start_time = params[:start]
    # start_time = params[:start_date].to_s + " " + params[:start_time].to_s
    end_time = params[:end]
    
    if params['image']
        FileUtils.mv(params[:image][:tempfile], "./public/images/#{params[:image][:filename]}")
        # DBに  各データを追加
        client.exec_params("INSERT INTO posts (user_id, title, content, start_time, end_time, image) VALUES ($1, $2, $3, $4, $5, $6)", 
        [session[:user]['id'], title, content, start_time, end_time, params[:image][:filename]])
    else
        client.exec_params("INSERT INTO posts (user_id, title, content, start_time, end_time) VALUES ($1, $2, $3, $4, $5)", 
        [session[:user]['id'], title, content, start_time, end_time])
    end
    redirect '/board'
end

get '/new_schedule' do
    user_name
    check_user
    return erb :new_schedule
end


# スケジュール機能
get '/schedule' do
    user_name
    check_user
    user_id = session[:user]['id']

    if params['start'] && params['end']
        t1 = params['start']
        t2 = params['end']
        @today = Time.parse(t1)
    else
        t1 = Time.parse("00:00:00");
        t2 = Time.parse("23:59:59"); 
        @today = Time.new
    end

    @posts = client.exec_params("SELECT * FROM posts WHERE user_id = #{user_id} AND start_time BETWEEN '#{t1}' AND '#{t2}' ORDER BY user_id, start_time DESC")
    @user_name = session[:user]['name']
    erb :schedule
end
get '/all_schedule' do
    user_name
    check_user
    user_id = session[:user]['id']

    if params['start'] && params['end']
        t1 = params['start']
        t2 = params['end']
        @today = Time.parse(t1)
    else
        t1 = Time.parse("00:00:00");
        t2 = Time.parse("23:59:59"); 
        @today = Time.new
    end

    @posts = client.exec_params("SELECT * FROM posts WHERE start_time BETWEEN '#{t1}' AND '#{t2}' ORDER BY user_id, start_time DESC")
    # @user_name = client.exec_params("SELECT name FROM users WHERE id = '#{post['user_id']}")
    # @user_name = session[:user]['name']
    erb :all_schedule
end










# 予定の詳細
get '/post/:id' do
    check_user
    user_name

    @posts = client.exec_params("SELECT * FROM posts WHERE id = #{params['id']}")
    erb :detail
end

# mypage無いにのみ配置
# ユーザーが分かる状態で編集や削除をするため
# get '/delete/:id' do
#     check_login
#     client.exec_params('delete from posts where id = $1',[params['id']])
#     redirect '/board'
#   end

#   get '/edit/:id' do
#     check_login
#     @res = client.exec_params('select * from posts where id = $1',[params['id']]).first
#     @post_id = @res['id']
#     erb :edit
#   end
  
#   post '/edit/:id' do
#     title = params['title']
#     contents = params['contents']
#     id = params['id']
#     FileUtils.mv(params['image']['tempfile'], "./public/images/#{params['image']['filename']}")
#     client.exec_params('update posts set title = $1, contents = $2, image = $3 where id = $4', [title, contents,params['image']['filename'], id])
#     redirect '/board'
#   end
  