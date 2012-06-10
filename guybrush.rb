#!/usr/bin/env ruby
# encoding: utf-8

require 'twitter'
require "#{File.dirname(__FILE__)}/lib/array.rb"
require "#{File.dirname(__FILE__)}/lib/markov_chain.rb"

PATH_PREFIX = File.expand_path(File.dirname(__FILE__))

# Set with heroku config:add
Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

def makeString(mc)
  string = mc.sentences(1).capitalize
  # Capitalise letters after .!?
  string = string.gsub(/([.!?])([\s]*)([[:alpha:]]{1})/) {"#{$1}#{$2}#{$3.capitalize}"}
  # Ugh, I know. Will do it a better way later. Maybe.
  cap = ["guybrush", "threepwood", "elaine", "marley", "herman", "toothrot", "stan", "dominique", "i'm", "i'll", "i've"]
  for item in cap
    string = string.gsub(item, item.capitalize)
  end
  # Others. Sorry.
  string = string.gsub("lechuck", "LeChuck")
  string = string.gsub(" i ", " I ")
  string = string.gsub("monkey island™", "Monkey Island™")
  string = string.gsub("mêlée island™", "Mêlée Island™")
end

prob = 60

while 1
  # One in 60 times, generate a chain
  if(rand(prob) < 1)
    mc = MarkovChain.new(File.read(PATH_PREFIX + "/guybrush.txt"))
    # If it's less than 141 chars, tweet it
    string = makeString(mc) 
    # Otherwise re-generate until it fits
    while string.size > 140
      string = makeString(mc) 
    end
    puts "Posting tweet: #{string}"
    Twitter.update(string)
  end
  sleep 5 # It's how Guybrush would code.
end
