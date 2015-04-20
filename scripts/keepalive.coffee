# Description:
#   Keep alive endpoint
#
# Author:
#   treby

module.exports = (robot) ->
  robot.router.get '/', (req, res) ->
    res.send 'pong'
