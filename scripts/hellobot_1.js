//
// Some hello message
//
var say = require('say')

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
    res.send(msg)
  });
};