# #
# # Doubot call blueprint APIs
# # Reponse to chatting user
# # cheers!
# # /chatapi/{userid}/tasks -> users ask -> OK
# # /chatapi/{userid}/userRemainDay -> users ask -> OK
# # /chatapi/{userid}/createLeaveRequest -> users ask -> OK
# # /chatapi/{userid}/tasksDueDate -> warning or user ask -> OK
# # /chatapi/{userid}/tasksPhaseDueDate -> warning or user ask -> ??? not use
# # /chatapi/{userid}/{projectId}/tasksUserProject -> users ask -> ??? no need
# # /chatapi/{userid}/UserProjects -> users ask -> OK
# # /chatapi/{usrId}/userPoint -> users ask -> OK
# # /chatapi/{usrId}/{comCd}/bestPerson -> OK
# # /chatapi/{usrId}/{taskNo}/searchTaskDetail -> OK -> detail of task #123 in project abc
# #
# url = "http://10.0.12.78:8080"

# h2t = require 'html-to-text'
# _ = require 'lodash'

# genList = (list) ->
#   sarr = []
#   for item in list
#     itm = "[#" + item.seqNo + " " + item.taskNm.replace(/\]/g, ')').replace(/\[/g, '(') + "](http://blueprint.dounets.com/)"
#     sarr.push itm
#   return sarr.join("\n")

# genPjtList = (list) ->
#   sarr = []
#   i = 0
#   for item in list
#     i++
#     itm = "[#" + "#{i}" + " " + item.pjtNm + "](http://blueprint.dounets.com/)"
#     sarr.push itm
#   return sarr.join("\n")

# parseFlexHtml2String = (body) ->
#   detail = h2t.fromString body
#   lines = detail.split "\n"
#   lines.push ""
#   obj = {}
#   i = 0
#   tmp = ""
#   emptyCount = 0
#   newLines = []
#   key = "empty"
#   for line in lines
#     tmp = line
#     if tmp == ""
#       emptyCount += 1
#       obj[key] = emptyCount
#     else
#       key = line
#       emptyCount = 0
  
#   _.forIn obj, (value, key) ->
#     if key == "empty"
#       newLines.push ""
#     else
#       newLines.push key
#     len = (value - 1) / 2
#     i = 0
#     while i < len
#       newLines.push ''
#       i++
#   return newLines.join "\n"

# module.exports = (robot) ->

#   robot.hear /how many task(s?) do I have/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/tasks")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here

#         data = JSON.parse body
#         # resa.send "#{JSON.stringify(data)}"
#         # tasks = [
#         #   {seqNo: '0012', taskNm: '[[xxx]]Create new User page'},
#         #   {seqNo: '0013', taskNm: '\\[Research\\] about Q-Learning'},
#         #   {seqNo: '0014', taskNm: '\\\[something\\\] Implement CNN Agorithm'},
#         #   {seqNo: '0015', taskNm: '\[Hello\] Study about Rocketchat'},
#         # ]
#         tasks = data.tasks
#         result = "#### @#{res.envelope.user.name}, You have #{tasks.length} tasks\n" + genList tasks
#         res.send result

#   robot.hear /how many expired task do I have/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/tasksDueDate")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here

#         data = JSON.parse body
#         tasks = data.tasks
#         result = "#### @#{res.envelope.user.name}, You have #{tasks.length} tasks expired\n" + genList tasks
#         res.send result

  
#   robot.hear /how many project(s?) do I attend/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/userProjects")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here
#         data = JSON.parse body
#         projects = data.projects
#         result = "#### @#{res.envelope.user.name}, You are attending in #{projects.length} projects\n" + genPjtList projects
#         res.send result
  
#   robot.hear /how many annual vacation day(s?) do I have/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/userRemainDay")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here
#         result = JSON.parse body
#         res.send "@#{res.envelope.user.name}, You have #{result.days.days.currentRemains} days remaining."

#   robot.hear /Leave request from (.*) to (.*) for (.*)/i, (res) ->
#     startDate = res.match[1]
#     # if (startDate NOT correct format)
#     #   res.send "start date should be like this: {date format}"
#     #   return
      
#     endDate = res.match[2]
#     # if (endDate NOT correct format)
#     #   res.send "end date should be like this: {date format}"
#     #   return
    
#     reason = res.match[3]
#     param = {
#         "fmDtStr": startDate,
#         "toDtStr": endDate,
#         "rsn": reason,
#     }
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/createLeaveRequest")
#       .header('Content-Type', 'application/json')
#       .post(JSON.stringify(param)) (err, _res, body) ->
#         # error checking code here
#         if err
#             res.send "Could not submit leave request, please try again!"
#             return

#         result = JSON.parse(body).result
#         result = result.model

#         msg = ""
#         if result.applyResult == 1
#           msg = "Apply success, @#{res.envelope.user.name}: you have #{result.rmnDys} days remaining"
#         else 
#           msg = "Could not request to leave on that day, may you created the request before or you have no remaining day."
#         res.send msg

#   robot.hear /how about my point(s?)/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/userPoint")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here
#         result = JSON.parse body
#         res.send "@#{res.envelope.user.name}, Currently you have #{result.point} points"

#   robot.hear /who is the best person in company/i, (res) ->
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/DOU/bestPerson")
#       .header('Accept', 'application/json')
#       .get() (err, _res, body) ->
#         # error checking code here
#         result = JSON.parse body
#         res.send "Best person is #{result.userNm} with #{result.point} points"

#   robot.hear /Detail of task (.*) in (.*)/i, (res) ->
#     taskId = res.match[1]
#     pjtNm = res.match[2]
#     param = {
#         "projectNm": pjtNm,
#     }
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/#{taskId}/searchTaskDetail")
#       .header('Content-Type', 'application/json')
#       .post(JSON.stringify(param)) (err, _res, body) ->
#         # error checking code here
#         if err
#             res.send "Could not search task detail #{taskId} in project #{pjtNm}, please try again!"
#             return

#         result = JSON.parse body
#         taskDetail = result.taskDetail
#         if taskDetail
#           detail = parseFlexHtml2String result.taskDetail.tskDesc
#           title = result.taskDetail.reqTitNm
#           detail = "```\n#{detail}\n```"
#           resStr = "@#{res.envelope.user.name}, here is the detail\n `[##{taskId}] #{title}`\n#{detail}"
#           res.send resStr
#         else
#           res.send result.result

#   robot.hear /Make comment "(.*)" on task (.*) in (.*)/i, (res) ->
#     comment = res.match[1]
#     taskId = res.match[2]
#     pjtNm = res.match[3]
#     param = {
#         "projectNm": pjtNm,
#         "cmtCntn": comment
#     }
#     robot.http("#{url}/chatapi/#{res.envelope.user.name}/#{taskId}/commentTask")
#       .header('Content-Type', 'application/json')
#       .post(JSON.stringify(param)) (err, _res, body) ->
#         # error checking code here
#         if err
#             res.send "Could not make comment on #{taskId} in project #{pjtNm}, please try again!"
#             return

#         result = JSON.parse body
#         msg = ""
#         if result.result == 'Success'
#           msg = "Apply comment successful"
#         else 
#           msg = "Could not apply comment on the task #{taskId}"
#         res.send msg
  