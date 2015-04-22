# Description:
#   Tell you current border that you want
#
# Author:
#   treby

request = require 'request'
numeral = require 'numeral'
moment  = require 'moment'
INFLUXDB_HOST = process.env.HUBOT_INFLUXDB_HOST
INFLUXDB_PORT = process.env.HUBOT_INFLUXDB_PORT
INFLUXDB_USER = process.env.HUBOT_INFLUXDB_USER
INFLUXDB_PASS = process.env.HUBOT_INFLUXDB_PASS
INFLUXDB_DATABASE = process.env.HUBOT_INFLUXDB_DATABASE
INFLUXDB_SERIES = process.env.HUBOT_INFLUXDB_SERIES

getBorder = (msg, rank = 1200) ->
  encoded_query = encodeURIComponent("SELECT * FROM \"#{INFLUXDB_SERIES}\" ORDER DESC LIMIT 1")
  url = "#{INFLUXDB_HOST}:#{INFLUXDB_PORT}/db/#{INFLUXDB_DATABASE}/series?u=#{INFLUXDB_USER}&p=#{INFLUXDB_PASS}&q=#{encoded_query}"

  request.get
    url: url
    json: true
  , (err, response, body) ->
    str = "ごめんなさい、ちょっと分からないわ"
    if body[0]['columns'].indexOf("border_#{rank}") > -1
      time_index = body[0]['columns'].indexOf("time")
      t = moment(new Date(body[0]['points'][0][time_index]))
      pt_index = body[0]['columns'].indexOf("border_#{rank}")
      pt_value = body[0]['points'][0][pt_index]
      str = "#{t.format('MM月DD日 HH:mm')}での#{rank}位のボーダーは#{numeral(pt_value).format('0,0')}ptよ、プロデューサー！" if pt_value?
    msg.send(str)

module.exports = (robot) ->
  robot.respond /ボーダー/i, (msg) ->
    getBorder msg
  robot.respond /([0-9]+)位のボーダー/i, (msg) ->
    rank = msg.match[1]
    getBorder msg, rank
