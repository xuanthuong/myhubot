
//
// Doubot call blueprint APIs
// Reponse to chatting user
// cheers!
// /chatapi/{userid}/tasks -> users ask -> OK
// /chatapi/{userid}/userRemainDay -> users ask -> OK
// /chatapi/{userid}/createLeaveRequest -> users ask -> OK
// /chatapi/{userid}/tasksDueDate -> warning or user ask -> OK
// /chatapi/{userid}/tasksPhaseDueDate -> warning or user ask -> ??? not use
// /chatapi/{userid}/{projectId}/tasksUserProject -> users ask -> ??? no need
// /chatapi/{userid}/UserProjects -> users ask -> OK
// /chatapi/{usrId}/userPoint -> users ask -> OK
// /chatapi/{usrId}/{comCd}/bestPerson -> OK
// /chatapi/{usrId}/{taskNo}/searchTaskDetail -> OK -> detail of task #123 in project abc
//

var _, genList, genPjtList, h2t, parseFlexHtml2String, url;

url = "http://10.0.12.78:8080";

h2t = require('html-to-text');
var say = require('say')

_ = require('lodash');

genList = function(list) {
  var item, itm, j, len1, sarr;
  sarr = [];
  for (j = 0, len1 = list.length; j < len1; j++) {
    item = list[j];
    itm = "[#" + item.seqNo + " " + item.taskNm.replace(/\]/g, ')').replace(/\[/g, '(') + "](http://blueprint.dounets.com/)";
    sarr.push(itm);
  }
  return sarr.join("\n");
};

genPjtList = function(list) {
  var i, item, itm, j, len1, sarr;
  sarr = [];
  i = 0;
  for (j = 0, len1 = list.length; j < len1; j++) {
    item = list[j];
    i++;
    itm = "[#" + ("" + i) + " " + item.pjtNm + "](http://blueprint.dounets.com/)";
    sarr.push(itm);
  }
  return sarr.join("\n");
};

parseFlexHtml2String = function(body) {
  var detail, emptyCount, i, j, key, len1, line, lines, newLines, obj, tmp;
  detail = h2t.fromString(body);
  lines = detail.split("\n");
  lines.push("");
  obj = {};
  i = 0;
  tmp = "";
  emptyCount = 0;
  newLines = [];
  key = "empty";
  for (j = 0, len1 = lines.length; j < len1; j++) {
    line = lines[j];
    tmp = line;
    if (tmp === "") {
      emptyCount += 1;
      obj[key] = emptyCount;
    } else {
      key = line;
      emptyCount = 0;
    }
  }
  _.forIn(obj, function(value, key) {
    var len, results;
    if (key === "empty") {
      newLines.push("");
    } else {
      newLines.push(key);
    }
    len = (value - 1) / 2;
    i = 0;
    results = [];
    while (i < len) {
      newLines.push('');
      results.push(i++);
    }
    return results;
  });
  return newLines.join("\n");
};

module.exports = function(robot) {
  robot.hear(/how many task(s?) do I have/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/tasks").header('Accept', 'application/json').get()(function(err, _res, body) {
      var data, result, tasks;
      data = JSON.parse(body);
      tasks = data.tasks;
      result = ("#### @" + res.envelope.user.name + ", You have " + tasks.length + " tasks\n") + genList(tasks);
      say_msg = res.envelope.user.name + ", You have " + tasks.length + " tasks"
      say.speak(say_msg)
      return res.send(result);
    });
  });
  robot.hear(/how many expired task do I have/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/tasksDueDate").header('Accept', 'application/json').get()(function(err, _res, body) {
      var data, result, tasks;
      data = JSON.parse(body);
      tasks = data.tasks;
      result = ("#### @" + res.envelope.user.name + ", You have " + tasks.length + " tasks expired\n") + genList(tasks);
      say_msg = res.envelope.user.name + ", You have " + tasks.length + " tasks expired"
      say.speak(say_msg)
      return res.send(result);
    });
  });
  robot.hear(/how many project(s?) do I attend/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/userProjects").header('Accept', 'application/json').get()(function(err, _res, body) {
      var data, projects, result;
      data = JSON.parse(body);
      projects = data.projects;
      result = ("#### @" + res.envelope.user.name + ", You are attending in " + projects.length + " projects\n") + genPjtList(projects);
      say_msg = res.envelope.user.name + ", You are attending in " + projects.length + " projects"
      say.speak(say_msg)
      return res.send(result);
    });
  });
  robot.hear(/how many annual vacation day(s?) do I have/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/userRemainDay").header('Accept', 'application/json').get()(function(err, _res, body) {
      var result;
      result = JSON.parse(body);
      say_msg = res.envelope.user.name + ", You have " + result.days.days.currentRemains + " days remaining."
      say.speak(say_msg)
      return res.send("@" + res.envelope.user.name + ", You have " + result.days.days.currentRemains + " days remaining.");
    });
  });
  robot.hear(/Leave request from (.*) to (.*) for (.*)/i, function(res) {
    var endDate, param, reason, startDate;
    startDate = res.match[1];
    endDate = res.match[2];
    reason = res.match[3];
    param = {
      "fmDtStr": startDate,
      "toDtStr": endDate,
      "rsn": reason
    };
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/createLeaveRequest").header('Content-Type', 'application/json').post(JSON.stringify(param))(function(err, _res, body) {
      var msg, result;
      if (err) {
        res.send("Could not submit leave request, please try again!");
        return;
      }
      result = JSON.parse(body).result;
      result = result.model;
      msg = "";
      if (result.applyResult === 1) {
        msg = "Apply success, @" + res.envelope.user.name + ": you have " + result.rmnDys + " days remaining";
      } else {
        msg = "Could not request to leave on that day, may you created the request before or you have no remaining day.";
      }
      say.speak(msg)
      return res.send(msg);
    });
  });
  robot.hear(/how about my point(s?)/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/userPoint").header('Accept', 'application/json').get()(function(err, _res, body) {
      var result;
      result = JSON.parse(body);
      var msg = "@" + res.envelope.user.name + ", Currently you have " + result.point + " points"
      say.speak(msg)
      return res.send(msg);
    });
  });
  robot.hear(/who is the best person in company/i, function(res) {
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/DOU/bestPerson").header('Accept', 'application/json').get()(function(err, _res, body) {
      var result;
      result = JSON.parse(body);
      var msg = "Best person is " + result.userNm + " with " + result.point + " points"
      say.speak(msg)
      return res.send(msg);
    });
  });
  robot.hear(/Detail of task (.*) in (.*)/i, function(res) {
    var param, pjtNm, taskId;
    taskId = res.match[1];
    pjtNm = res.match[2];
    param = {
      "projectNm": pjtNm
    };
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/" + taskId + "/searchTaskDetail").header('Content-Type', 'application/json').post(JSON.stringify(param))(function(err, _res, body) {
      var detail, resStr, result, taskDetail, title;
      if (err) {
        res.send("Could not search task detail " + taskId + " in project " + pjtNm + ", please try again!");
        return;
      }
      result = JSON.parse(body);
      taskDetail = result.taskDetail;
      if (taskDetail) {
        detail = parseFlexHtml2String(result.taskDetail.tskDesc);
        title = result.taskDetail.reqTitNm;
        detail = "```\n" + detail + "\n```";
        resStr = "@" + res.envelope.user.name + ", here is the detail\n `[#" + taskId + "] " + title + "`\n" + detail;
        return res.send(resStr);
      } else {
        return res.send(result.result);
      }
    });
  });
  return robot.hear(/Make comment "(.*)" on task (.*) in (.*)/i, function(res) {
    var comment, param, pjtNm, taskId;
    comment = res.match[1];
    taskId = res.match[2];
    pjtNm = res.match[3];
    param = {
      "projectNm": pjtNm,
      "cmtCntn": comment
    };
    return robot.http(url + "/chatapi/" + res.envelope.user.name + "/" + taskId + "/commentTask").header('Content-Type', 'application/json').post(JSON.stringify(param))(function(err, _res, body) {
      var msg, result;
      if (err) {
        res.send("Could not make comment on " + taskId + " in project " + pjtNm + ", please try again!");
        return;
      }
      result = JSON.parse(body);
      msg = "";
      if (result.result === 'Success') {
        msg = "Apply comment successful";
      } else {
        msg = "Could not apply comment on the task " + taskId;
      }
      return res.send(msg);
    });
  });
};

