#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'httparty'

# take out :owner, :repo and :api_token
# have them passed in on the command-line
owner_repo = ARGV.shift
api_token = ARGV.shift
raise "First argument is owner and repo like this: owner/repo " unless owner_repo

(owner, repo) = owner_repo.split('/')

raise "Need owner and repo like this: owner/repo " unless owner && repo
API_ROOT = 'https://api.github.com/repos/'
pulls_URL = API_ROOT + owner_repo + '/pulls'
pulls_URL += "?access_token=#{api_token}" if(api_token)
response = HTTParty.get(pulls_URL)

#puts response.body, response.code, response.message, response.headers.inspect

pulls = JSON.parse( response.body )
raise "No pulls to search" unless pulls.size > 0
#puts pulls.inspect

open_pulls = pulls.select {|p| p["state"] == "open"}
raise "No open pulls to search" unless open_pulls.size > 0

#puts "Total pulls: " + pulls.size.to_s
#puts "Open pulls: " + open_pulls.size.to_s

match_keywords = %w{/dev/null raise .write %x exec}
output = {}
open_pulls.each do |op|
  no_spec = true
  pull_number = op["number"]
  puts "Checking pull #{pull_number}"
  output[pull_number] = []
  pull_url = API_ROOT + owner_repo + "/pulls/#{pull_number}/files"
  pull_url += "?access_token=#{api_token}" if(api_token)
  resp = HTTParty.get(pull_url)
  files = JSON.parse( resp.body )
  files.each do |file|
    raise "error: " + file.inspect unless file.is_a?( Hash )
    filename = file["filename"]
    puts "Checking file #{filename}"
    if(file["filename"] =~ /spec\//)
      no_spec = false
    end
    if(file["filename"] =~ /Gemfile/)
      output[pull_number] << "Interesting: Gemfile changed"
    end
    if(file["filename"] =~ /.gemspec/)
      output[pull_number] << "Interesting: .gemspec changed"
    end
    match_keywords.each do |keyword|
      escaped_keyword = Regexp.escape(keyword)
      if(file["patch"] =~ /\b#{escaped_keyword}\b/)
        output[pull_number] << "Interesting: #{filename} matched #{keyword}"
      end
    end
  end

  if(no_spec)
    output[pull_number] << "Interesting: no spec change"
  end
end

open_pulls.each do |op|
  pull_number = op["number"]
  link_text = "https://github.com/puppetlabs/puppet/pull/#{pull_number}"
  if(output[pull_number].size > 0)
    puts link_text + " - Interesting"
  else
    puts link_text + " - Not Interesting"
  end
end

open_pulls.each do |op|
  pull_number = op["number"]
  if(output[pull_number].size > 0)
    output[pull_number].each do |detail|
      puts "Pull #{pull_number} was " + detail
    end
  end
end
