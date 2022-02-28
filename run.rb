require 'bundler'
Bundler.require

repo = ENV['REPOSITORY']

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
# タグ一覧を取得する
tags = client.tags(repo)
# 最新のreleaseタグを取得する
latest_release_tag = tags.find{ |t| t.name.start_with?("release") }

puts latest_release_tag
