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
isBreak = false
while true
  client.commits(repo, { :per_page => 100, :page => page }).each do |i|
    if i.sha == latest_release_tag.commit.sha
      isBreak = true
      break
    else
      commits << i
    end
  end
  break if isBreak
  page += 1
end
# マージコミットのみを取得する
merged_commits = commits.filter { |i| i.commit.message.start_with?('Merge pull request #') }
# マージされたプルリクエストを取得する
merged_pulls = merged_commits.map { |i| client.commit_pulls(repo, i.sha) }.flatten

File.open("release_note.txt", mode = "w") do |f|
  merged_pulls.each do |i|
    f.write("・#{i.title}\n")
  end
end

File.open("pull_request_message.txt", mode = "w") do |f|
  f.write(<<~MESSAGE)
    # 変更点

    #{merged_pulls.map { |i| "- ##{i.number}" }.join("\n")}
  MESSAGE
end

