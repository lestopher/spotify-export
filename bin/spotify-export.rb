#!/usr/bin/env ruby

require 'bundler/setup'
require_relative '../lib/spotify-playlist'

formats      = %w{json csv txt}.freeze
playlist     = SpotifyPlaylist.new(ARGV.first)
outputFormat = "txt"
outputFile   = "stdout"

if ARGV.include? "-f"
  formatIdx    = ARGV.index("-f").to_i + 1
  outputFormat = ARGV[formatIdx].downcase

  raise "Not a valid format." unless formats.include? outputFormat
end

if ARGV.include? "-o"
  fileIdx    = ARGV.index("-o").to_i + 1
  outputFile = ARGV[fileIdx]
end


if outputFile != "stdout"
  # Open a file descriptor
  fileD = File.open outputFile, 'w'
end

# Specific thigns we need to do for each format
case outputFormat
  when "txt"
    trackInfo = ''
  when "csv"
    trackInfo = "NAME,ARTIST,ALBUM\n"
  when "json"
    trackInfo = "["
end

playlist.tracks.each_with_index do |track, count|
  # Sanity check
  unless track.nil?
    if outputFormat == "txt"
      trackInfo << "#{count + 1}. #{ track.name } -- #{ track.artist } -- #{ track.album }\n"
    elsif outputFormat == "csv"
      trackInfo << "\"#{track.name}\",\"#{track.artist}\",\"#{track.album}\""
    else
      # Assumed json
      trackInfo << track.to_json << ","
    end
  end
end

if outputFormat == "json"
  # Removes the last comma from json struct, as it's invalid
  trackInfo.chop!
  trackInfo << "]"
end

# Outputting options
if outputFile == "stdout"
  puts trackInfo 
else
  fileD.write trackInfo
  # Close our file descriptor
  fileD.close
end

