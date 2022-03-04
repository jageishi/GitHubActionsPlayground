require 'bundler'
Bundler.require

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
client.create_pull_request(ENV['REPOSITORY'], 'main', ENV['BRANCH_NAME'], 'タイトル', '本文')
