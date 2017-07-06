// var myPythonScriptPath = './scripts/test_script.py'

// var PythonShell = require('python-shell')
// var pyshell = new PythonShell(myPythonScriptPath)

// // pyshell.on('message', function (message) {
// //     // received a message sent from the Python script (a simple "print" statement)
// //     console.log(message);
// // });

// // // end the input stream and allow the process to exit
// // pyshell.end(function (err) {
// //     if (err){
// //         throw err;
// //     };
// //     console.log('finished');
// // });

// var options = {
//     mode: 'text',
//     pythonPath: 'python',
//     // pythonOptions: ['-u'],
//     // scriptPath: './',
//     args: ['value1', 'value2', 'value3']
// };

// options.args = ['abc', 'def']

// PythonShell.run(myPythonScriptPath, options, function (err, results) {
//     if (err) throw err;
//     // results is an array consisting of messages collected during execution
//     console.log('results: %j', results);
//     console.log('finish 1');
// });