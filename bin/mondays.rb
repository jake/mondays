#!/usr/bin/env ruby

require "active_support/core_ext/date/calculations"
require "active_support/core_ext/date/conversions"

require "twilio-ruby"

def commas(number)
  number.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
end

def percent(number)
  percent = "%g" % ("%.2f" % number)
  "#{percent}%"
end

# system config
twilio_from_number  = ENV["TWILIO_FROM_NUMBER"] || "+15005550006"
twilio_account_sid  = ENV["TWILIO_ACCOUNT_SID"] || "ACf9ed0115dbeba2e65361be75f4c82ea9"
twilio_auth_token   = ENV["TWILIO_AUTH_TOKEN"]  || "51f9efdcf8ebf5216f125151d27ad864"

# input defaults
retirement_age = 65
birthday  = "23/10/1986"
to_number = "+19518344660"

@twilio_client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token

born    = Date.parse birthday
today   = Date.current
retire  = born.advance(years: retirement_age)

if today.monday?
  mondays = today.upto(retire).count(&:monday?)
  message = "There are #{commas mondays} Mondays left until you retire."
end

if today.wednesday?
  day_of_year = today.strftime("%j")
  elapsed     = (day_of_year.to_f / 366.0) * 100
  remaining   = 100 - elapsed

  message = "There is #{percent remaining} of the current year remaining."
end

if false && today.friday?
  # Spring - Mar, Apr, May
  # Summer - Jun, Jul, Aug
  # Autumn - Sep, Oct, Nov
  # Winter - Dec, Jan and Feb

  seasons = {
    3 => :spring,
    4 => :spring,
    5 => :spring,

    6 => :summer,
    7 => :summer,
    8 => :summer,

    9  => :autumn,
    10 => :autumn,
    11 => :autumn,

    12 => :winter,
    1  => :winter,
    2  => :winter,
  }

  current_season = seasons[today.month]
  current_range  = seasons.select{ |month, season| season == current_season}

  next_season = seasons[today.next_month.month]
  next_range  = seasons.select{ |month, season| season == next_season}

  puts current_season, current_range
  puts next_season, next_range
end

if message.nil?
  puts "No message for today."
  abort
end

puts message
@twilio_client.account.messages.create(
  :from => twilio_from_number,
  :to => to_number,
  :body => message
)
