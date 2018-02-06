const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
/*
exports.addGame = functions.database.ref('Games').onCreate(event => {

   let ref = admin.database().ref('Totals');
   return ref.once('value').then(snapshot => {
      if (snapshot.hasChildren()) {
        var total= snapshot.val().GamesStarted
        
           total += 1
       
       console.log(total);
       event.data.ref.child('GamesStarted').set(total);
      }
  });
});
*/