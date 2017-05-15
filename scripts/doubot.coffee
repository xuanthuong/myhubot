#
# Doubot call blueprint APIs
# Reponse to chatting user
# cheers!
# /chatapi/{userid}/tasks -> users ask -> OK
# /chatapi/{userid}/userRemainDay -> users ask -> OK
# /chatapi/{userid}/createLeaveRequest -> users ask -> OK
# /chatapi/{userid}/tasksDueDate -> warning or user ask -> OK
# /chatapi/{userid}/tasksPhaseDueDate -> warning or user ask -> ??? not use
# /chatapi/{userid}/{projectId}/tasksUserProject -> users ask -> ??? no need
# /chatapi/{userid}/UserProjects -> users ask -> OK
# / chatapi/{usrId}/userPoint -> users ask -> OK
#

genList = (list) ->
  sarr = []
  for item in list
    itm = "[#" + item.seqNo + " " + item.taskNm.replace(/\]/g, ')').replace(/\[/g, '(') + "](http://blueprint.dounets.com/)"
    sarr.push itm
  return sarr.join("\n")

genPjtList = (list) ->
  sarr = []
  i = 0
  for item in list
    i++
    itm = "[#" + "#{i}" + " " + item.pjtNm + "](http://blueprint.dounets.com/)"
    sarr.push itm
  return sarr.join("\n")

module.exports = (robot) ->

  robot.hear /how many task do I have/i, (res) ->
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/tasks")
      .header('Accept', 'application/json')
      .get() (err, _res, body) ->
        # error checking code here

        data = JSON.parse body
        # resa.send "#{JSON.stringify(data)}"
        # tasks = [
        #   {seqNo: '0012', taskNm: '[[xxx]]Create new User page'},
        #   {seqNo: '0013', taskNm: '\\[Research\\] about Q-Learning'},
        #   {seqNo: '0014', taskNm: '\\\[something\\\] Implement CNN Agorithm'},
        #   {seqNo: '0015', taskNm: '\[Hello\] Study about Rocketchat'},
        # ]
        tasks = data.tasks
        result = "#### You have #{tasks.length} tasks\n" + genList tasks
        res.send result

  robot.hear /how many expired task do I have/i, (res) ->
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/tasksDueDate")
      .header('Accept', 'application/json')
      .get() (err, _res, body) ->
        # error checking code here

        data = JSON.parse body
        tasks = data.tasks
        result = "#### You have #{tasks.length} tasks expired s\n" + genList tasks
        res.send result

  
  robot.hear /how many project do I attend/i, (res) ->
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/userProjects")
      .header('Accept', 'application/json')
      .get() (err, _res, body) ->
        # error checking code here
        data = JSON.parse body
        projects = data.projects
        result = "#### You are attending in #{projects.length} projects\n" + genPjtList projects
        res.send result
  
  robot.hear /how many remained annual vacation days I have/i, (res) ->
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/userRemainDay")
      .header('Accept', 'application/json')
      .get() (err, _res, body) ->
        # error checking code here
        result = JSON.parse body
        res.send "You have #{result.days.days.currentRemains} days remaining"

  robot.hear /Leave request from (.*) to (.*) for (.*)/i, (res) ->
    startDate = res.match[1]
    # if (startDate NOT correct format)
    #   res.send "start date should be like this: {date format}"
    #   return
      
    endDate = res.match[2]
    # if (endDate NOT correct format)
    #   res.send "end date should be like this: {date format}"
    #   return
    
    reason = res.match[3]
    param = {
        "fmDtStr": startDate,
        "toDtStr": endDate,
        "rsn": reason,
    }
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/createLeaveRequest")
      .header('Content-Type', 'application/json')
      .post(JSON.stringify(param)) (err, _res, body) ->
        # error checking code here
        if err
            res.send "Could not submit leave request, please try again!"
            return

        result = JSON.parse(body).result
        result = result.model

        msg = ""
        if result.applyResult == 1
          msg = "Apply success, you have #{result.rmnDys} days remaining"
        else 
          msg = "Could not request to leave on that day, may you created the request before or you have no remaining day."
        res.send msg

  robot.hear /how about my points/i, (res) ->
    robot.http("http://10.0.12.78:8080/chatapi/#{res.envelope.user.name}/userPoint")
      .header('Accept', 'application/json')
      .get() (err, _res, body) ->
        # error checking code here
        result = JSON.parse body
        res.send "Currently you have #{result.point} points"
