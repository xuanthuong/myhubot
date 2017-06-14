module.exports = (robot) ->
  # the expected value of :room is going to vary by adapter, it might be a numeric id, name, token, or some other value
  robot.router.post '/hubot/notification/:room', (req, res) ->
    room   = req.params.room
    data = req.body

    type = data.type
    users = data.userId
    contents = data.contents
    noticeType = data.noticeType
    subBrdTpCd = data.subBrdTpCd

    console.log "notification type: #{type}"
    console.log "users list: #{users}"
    console.log "contents: #{contents}"
    console.log "Notice Type: #{noticeType}"
    console.log "Board Type Code: #{subBrdTpCd}"

    detail = "```\n#{contents}\n```"
    if noticeType == 'DOU' 
      resStr = "* @All Staffs *, New notice from blueprint #{detail}"
      robot.messageRoom room, resStr
    else
      resStr = "* @Users *, You have new notification #{detail}"
      robot.messageRoom room, resStr
      # if type == 'Notice'
        # user = 'thuongtran'
        # resStr = "* @#{user} *, You have new notification #{detail}"
        # robot.messageRoom room, resStr
    #   else if type == "Communication"
    #     # def
    #   else if type == "YourTasks"
    #     # ghi

    res.send 'OK'