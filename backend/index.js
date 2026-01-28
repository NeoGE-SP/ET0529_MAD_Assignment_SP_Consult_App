const admin = require("firebase-admin");
const serviceAccount = require("./mad-assignment-b5e70-firebase-adminsdk-fbsvc-1d113bdfce.json");
const express = require("express");
const app = express();

app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();



app.listen(3000, () => console.log("Server running on port 3000"));