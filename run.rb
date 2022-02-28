require 'bundler'
Bundler.require

repo = ENV['REPOSITORY']

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
# タグ一覧を取得する
tags = client.tags(repo)
# 最新のreleaseタグを取得する
latest_release_tag = tags.find { |t| t.name.start_with?('release') }
# タグ以降のマージコミットを取得する
merged_commits = []
client.commits(repo).each do |item|
  break if item.sha == latest_release_tag.commit.sha
  merged_commits << item if item.commit.message.start_with?('Merge pull request #')
end

merged_commits.map do |item|
  puts '----------------------'
  puts item.commit.message
  puts '----------------------'
end
