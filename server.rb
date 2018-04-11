require "bundler/setup"
require "sinatra"
require "rest_client"
require "json"
require "octokit"
require "./github"

Bundler.require(:default, ENV["RACK_ENV"] || "development")

SCOPES = [
  "user:email",
  "repo",
  "write:repo_hook",
]

CLIENT_ID = ENV["GH_BASIC_CLIENT_ID"]
CLIENT_SECRET = ENV["GH_BASIC_SECRET_ID"]

use Rack::Session::Cookie, key: "PutsLabel",
                           path: "/",
                           expire_after: 14400,
                           secret: ENV["COOKIE_SECRET"]

def authenticated?
  session[:access_token]
end

def authenticate!
  oauth_url = "https://github.com/login/oauth/authorize?scope=#{SCOPES.join(",")}&client_id=#{CLIENT_ID}"

  erb :index, locals: {oauth_url: oauth_url}
end

def list_repos(token)
  client = Octokit::Client.new(access_token: token)

  client.create_hook(
    "phstc/putslabel",
    "web",
    {
      url: "https://putslabel.herokuapp.com/webhook",
      content_type: "json",
    },
    {
      events: ["issues", "status", "pull_request_review", "push", "pull_request"],
      active: true,
    }
  )
rescue Octokit::UnprocessableEntity
end

get "/" do
  return authenticate! if !authenticated?

  access_token = session[:access_token]

  list_repos(access_token)

  erb :advanced, locals: {access_token: access_token}
end

post "/webhook" do
  GitHub.new(ENV["GH_ACCESS_TOKEN"])
  github.handle_github(request.env["HTTP_X_GITHUB_EVENT"], JSON.parse(request.body.read))
  status :ok
end

get "/callback" do
  session_code = request.env["rack.request.query_hash"]["code"]

  result = RestClient.post("https://github.com/login/oauth/access_token",
                           {:client_id => CLIENT_ID,
                            :client_secret => CLIENT_SECRET,
                            :code => session_code},
                           :accept => :json)

  session[:access_token] = JSON.parse(result)["access_token"]

  redirect "/"
end
