const admin = require('firebase-admin');
const serviceAccount = require('./halisaha-84959-firebase-adminsdk-fbsvc-0e0faa0c78.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();

module.exports = { admin, auth };
