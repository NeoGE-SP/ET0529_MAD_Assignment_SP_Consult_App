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

  sendNotificationToToken(token, docID, role);
  res.status(200).send({ success: true });
});


app.post("/requestnotif", async (req, res) => {
  const { token, docID, role } = req.body;
  console.log(token)

  sendRequestNotification(token, docID, role);
  res.status(200).send({ success: true });
});

async function getDataFromFirestore(docID, role) {
    const docRef = db.collection(role).doc(docID);
    const docSnap = await docRef.get();

    const data = docSnap.data();
    return data 
}

async function sendRequestNotification(token, docID, role) {
  const data = await getDataFromFirestore(docID, role);

  const message = {
    tokens: token,
    notification: { title: "Consultation Appointment Request", body: `${data.name} of class ${data.class} for module ${data.module} has requested a consultation` },
  };

  const response = await admin.messaging().sendEachForMulticast(message);

  console.log("Success:", response.successCount);
  console.log("Failures:", response.failureCount);

  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      console.error(`Token ${tokens[idx]} failed:`, resp.error);
    }
  });
}

async function sendReminderNotification(token, docID, role) {
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