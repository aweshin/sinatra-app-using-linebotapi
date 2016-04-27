require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rest-client'
require 'docomoru'

get '/' do
  'under construction'
end

post '/linebot/callback' do
  params = JSON.parse(request.body.read)

  params['result'].each do |msg|
    client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
    response = client.create_dialogue(msg['content']['text'])
    msg['content']['text'] = response.body['utt']

    request_text = {
      to: [msg['content']['from']],
      toChannel: 1383378250,
      eventType: "138311608800106203",
      content: msg['content']
    }

    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    content_json = request_text.to_json

    RestClient.proxy = ENV['FIXIE_URL']
    RestClient.post(endpoint_uri, content_json, {
      'Content-Type' => 'application/json: charset=UTF-8',
      'X-Line-ChannelID' => ENV['LINE_CHANNEL_ID'],
      'X-Line-ChannelSecret' => ENV['LINE_CHANNEL_SECRET'],
      'X-Line-Trusted-User-With-ACL' => ENV['LINE_CHANNEL_MID']
    })
  end
end