require 'bundler'
Bundler.require

repo = ENV['REPOSITORY']

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
# タグ一覧を取得する
tags = client.tags(repo)
# 最新のreleaseタグを取得する
latest_release_tag = tags.find { |t| t.name.start_with?('release') }
# タグ以降のコミットを取得する
commits = []
page = 1
while true
  temp = client.commits(repo, { :page => page })
  commits.push(temp)
  break if commits.any? { |i| i.commit.sha == latest_release_tag.commit.sha }
  page += 1
end
# マージコミットのみを取得する
merged_commits = commits.filter {|i| i.commit.messsage.start_with?('Merge pull request ') || i.commit.messsage.start_with?('Merge pull request ')}

merged_commits.map do |item|
  puts '----------------------'
  puts item.commit.message
  puts '----------------------'
end
