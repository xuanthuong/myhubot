//
// Some hello message
//
var say = require('say')

var brobotScript = 'brobot.py'

var PythonShell = require('python-shell')
// var pyshell = new PythonShell(brobotScript)

var options = {
    mode: 'text',
    pythonPath: '/Users/thuong/.Python_VEnv/Python3.6/.textblob/bin/python',
    // pythonOptions: ['-u'],
    scriptPath: '/Users/thuong/Projects/chatbot/brobot',
    args: ['hello']
};

// function askBot(question){
//   options.args = question
//   ans = "I dont understand, please ask again"
//   PythonShell.run(brobotScript, options, function (err, results) {
//     if (err) throw err;
//     // results is an array consisting of messages collected during execution
//     console.log('results: %j', results);
//     ans = results;
//   }); 
//   return ans;
// }

const askBot = (question) => {
  return new Promise((resolve, reject) => {
    options.args = question
    PythonShell.run(brobotScript, options, function (err, results) {
      if (err) throw err;
      // results is an array consisting of messages collected during execution
      // console.log('results: %j', results);
      resolve(results)
    }); 
  })
}

module.exports = function(robot) {
  robot.hear(/Which chatting platform should we use/i, function(res) {
    return res.send("@" + res.envelope.user.name + ", I suggest to use RocketChat, Hubot will be very helpful to your members");
  });
  robot.hear(/(Hello\s*$)|(Hi\s*$)/i, function(res) {
    msg = "Hi @" + res.envelope.user.name + ", how I help you?"
    // say.speak(msg)
    // return res.send(msg);
    // room = res.envelope.user.name
    // console.log(`first room: ${room}`)
    // robot.adapter.sendDirect( 'thuongtran' , "thuongtran, Hello how are you?")
    // room = robot.adapter.client.rtm.dataStore.getDMByName(res.envelope.envelope.name)
    // robot.messageRoom(room.id, "Hello, this is a private message!")
    // console.log(`room: ${room}`)
    askBot("I am engineering")
      .then((msg) => {
        // console.log('msg: %j', msg);
        res.send(msg.join(' '))
      })
      .catch((error) => {
        throw error
      }) 
  });
};