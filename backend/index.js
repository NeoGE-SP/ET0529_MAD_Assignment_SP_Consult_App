const admin = require("firebase-admin");
const serviceAccount = require("./mad-assignment-b5e70-firebase-adminsdk-fbsvc-1d113bdfce.json");
const express = require("express");
const app = express();

app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();


app.post("/login", async (req, res) => {
  const tokenFromFlutterApp = "";
  const collectionSoT = `${req.body.role}`;

  console.log(req.body);

  const querySnapshot = await db.collection(collectionSoT)
    .where('adm', '==', req.body.username)
    .get();

  if (querySnapshot.empty) {
      return res.status(404).json({ message: 'Username, Password or Role is incorrect.' });
  }

  const userDoc = querySnapshot.docs[0];
  const userData = userDoc.data();

  console.log(userData);

  if (userData.pw !== req.body.password) {
      return res.status(401).json({ message: 'Username, Password or Role is incorrect.' });
    }

  return res.status(200).json({ message: 'Login successful', data: userData });
});

app.listen(3000, () => console.log("Server running on port 3000"));