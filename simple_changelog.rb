# frozen_string_literal: true

require 'fileutils'

# Get the current version from CHANGELOG.md
def find_current_version
  if File.exist?('CHANGELOG.md')
    File.foreach('CHANGELOG.md') do |line|
      return line.strip.split.last if line.start_with?('##')
    end
  end
  # TODO: option to set default version number
  # if no version is found
  '0.0.0'
end

def increment_version(current_version, level)
  major, minor, patch = current_version.split('.').map(&:to_i)
  case level
  when 'major'
    "#{major + 1}.0.0"
  when 'minor'
    "#{major}.#{minor + 1}.0"
  when 'patch'
    "#{major}.#{minor}.#{patch + 1}"
  else
    current_version
  end
end

# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
def determine_version_bump(commit_messages)
  bump = nil
  commit_messages.each do |msg|
    if msg.include?('BREAKING CHANGE')
      return 'major'
    elsif msg.match?(/\bfeat\b/)
      bump = 'minor' if bump != 'major'
    elsif msg.match?(/\bfix\b/)
      bump = 'patch' if bump.nil?
    end
  end
  bump || 'patch'
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity

def find_commit_messages
  `git log --pretty=format:%s`.split("\n")
end

def update_changelog(new_version)
  changelog_content = File.exist?('CHANGELOG.md') ? File.read('CHANGELOG.md') : ''
  File.open('CHANGELOG.md', 'w') do |f|
    f.puts "## #{new_version} - #{Time.now.strftime('%Y-%m-%d')}"
    f.puts "\n### Changes:"
    f.puts "- (Add meaningful commit messages here)\n\n"
    f.puts changelog_content
  end
end

def commit_and_push_changes(new_version)
  `git config --global user.name "github-actions[bot]"`
  `git config --global user.email "github-actions[bot]@users.noreply.github.com"`

  `git add CHANGELOG.md`
  `git commit -m "chore: update CHANGELOG.md for version #{new_version}"`
  `git push`
end

def main
  ENV['GITHUB_TOKEN'] || raise('GITHUB_TOKEN is required')

  current_version = find_current_version
  commit_messages = find_commit_messages
  bump = determine_version_bump(commit_messages)
  next_version = increment_version(current_version, bump)

  puts "Current Version: #{current_version}"
  puts "Version Bump: #{bump}"
  puts "Next Version: #{next_version}"

  update_changelog(next_version)
  commit_and_push_changes(next_version)
end

main
