require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'pg'
require 'time'
require 'date'

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

    @now = Time.now
    @posts = client.exec_params("SELECT * FROM posts WHERE user_id = #{user_id} ORDER BY start_time ASC")
    return erb :board
end




post '/posts' do
    title = params[:title]
    content = params[:content]
    start_time = params[:start]
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
        t1 = Time.parse(params['start'])
        t2 = Time.parse(params['end']) + 24*60*60 -1
        @today = t1
    else
        t1 = Time.parse("00:00:00")
        t2 = Time.parse("23:59:59") 
        @today = Time.new
    end
    @test = t1
    @test2 = t2


    @posts = client.exec_params("SELECT * FROM posts WHERE user_id = #{user_id} AND start_time BETWEEN '#{t1}' AND '#{t2}' ORDER BY user_id, start_time DESC")
    @user_name = session[:user]['name']
    erb :schedule
end

get '/all_schedule' do
    user_name
    check_user
    user_id = session[:user]['id']

    if params['start'] && params['end']
        t1 = Time.parse(params['start'])
        t2 = Time.parse(params['end']) + 24*60*60 -1
        @today = t1
    else
        t1 = Time.parse("00:00:00")
        t2 = Time.parse("23:59:59") 
        @today = Time.new
    end
    @test = t1
    @test2 = t2

    # TASK ユーザー名を取得したい
    @posts = client.exec_params("SELECT * FROM posts WHERE start_time BETWEEN '#{t1}' AND '#{t2}' AND end_time BETWEEN '#{t1}' AND '#{t2}' ORDER BY user_id, start_time DESC")
    erb :all_schedule
end










# 予定の詳細
get '/post/:id' do
    check_user
    user_name

    @posts = client.exec_params("SELECT * FROM posts WHERE id = #{params['id']}")
    erb :detail
end



# TASK　編集・削除機能の追加
# mypage無いにのみ配置
# ユーザーが分かる状態で編集や削除をするため
get '/delete/:id' do
    check_user
    user_name
    client.exec_params('delete from posts where id = $1',[params['id']])
    redirect '/board'
  end

  get '/edit/:id' do
    check_user
    user_name

    @posts = client.exec_params("SELECT * FROM posts WHERE id = #{params['id']}")
    erb :edit
  end
  
  post '/edit/:id' do
    title = params[:title]
    content = params[:content]
    start_time = params[:start]
    end_time = params[:end]
    id = params['id']
    
    if params['image']
        FileUtils.mv(params[:image][:tempfile], "./public/images/#{params[:image][:filename]}")
        # DBに  各データを追加
        client.exec_params("UPDATE posts 
            SET title = $1, content = $2, start_time = $3, end_time = $4, image = $5 WHERE id = #{id}", 
            [title, content, start_time, end_time, params[:image][:filename]])
    else
        client.exec_params("UPDATE posts 
            SET title = $1, content = $2, start_time = $3, end_time = $4 WHERE id = #{id}", 
            [title, content, start_time, end_time])
    end
    redirect '/board'
  end
