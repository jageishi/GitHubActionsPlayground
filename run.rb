require 'bundler'
Bundler.require

repo = ENV['REPOSITORY']

client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
# タグ一覧を取得する
tags = client.tags(repo)
# 最新のreleaseタグを取得する
latest_release_tag = tags.find { |t| t.name.start_with?('release') }
# 最新のreleaseタグ以降のコミットを取得する
commits = []
page = 1
while true
  temp = client.commits(repo, { :per_page => 100, :page => page })
  commits.concat(temp)
  break if temp.any? { |i| i.sha == latest_release_tag.commit.sha }
  page += 1
end
# マージコミットのみを取得する
merged_commits = commits.filter { |i| i.commit.message.start_with?('Merge pull request #') }
# マージされたプルリクエストを取得する
merged_pulls = merged_commits.map { |i| client.commit_pulls(repo, i.sha) }.flatten

merged_pulls.each do |i|
  puts "・ #{i.title}"
end
