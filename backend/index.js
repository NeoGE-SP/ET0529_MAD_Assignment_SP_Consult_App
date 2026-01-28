const admin = require("firebase-admin");
const serviceAccount = require("./mad-assignment-b5e70-firebase-adminsdk-fbsvc-1d113bdfce.json");
const express = require("express");
const app = express();

app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();


app.post("/getnotif", async (req, res) => {
  const { token, docID, role } = req.body;
  console.log(role);
  console.log(docID);
  console.log(token);

  sendNotificationToToken(token, docID, role);
  res.status(200).send({ success: true });
});

async function getDataFromFirestore(docID, role) {
    const docRef = db.collection(role).doc(docID);
    const docSnap = await docRef.get();

    const data = docSnap.data();
    return data 
}

async function sendNotificationToToken(token, docID, role) {
  const data = await getDataFromFirestore(docID, role);

  const message = {
    token: token,
    notification: { title: "Consultation Appointment Reminder", body: `You have a consultation appointment with ${data.name} in 10 minutes at ${data.class}` },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
  } catch (err) {
    console.error("Error sending notification:", err);
  }
}

app.listen(3000, () => console.log("Server running on port 3000"));