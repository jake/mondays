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
  message = "You have #{commas mondays} Mondays left until you retire."
end

if today.wednesday?
  day_of_year = today.strftime("%j")
  elapsed     = (day_of_year.to_f / 366.0) * 100
  remaining   = 100 - elapsed

  message = "There is #{percent remaining} of the current year remaining."
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
