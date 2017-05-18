# 
# Some hello message
#

# helloMsg = ["Hello", "Hi"]
# askMsg = ["May I help you?", "How are you today?"]

module.exports = (robot) ->

  # robot.hear /Hello/i, (res) ->
  #   res.send "Helo @#{res.envelope.user.name}, may I help you?"

  # robot.hear /Hi/i, (res) ->
  #   res.send "Hi @#{res.envelope.user.name}, how are you?"

  robot.hear /Which chatting platform should we use/i, (res) ->
    res.send "@#{res.envelope.user.name}, I suggest to use RocketChat, Hubot will be very helpful to your members"
  
  robot.hear /(Hello\s*$)|(Hi\s*$)/i, (res) ->
    res.send "Hi @#{res.envelope.user.name}, may I help you?"
  