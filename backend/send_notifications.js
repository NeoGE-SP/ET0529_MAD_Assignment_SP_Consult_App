const admin = require("firebase-admin");
const serviceAccount = require("./project-caf11-firebase-adminsdk-fbsvc-b0ca401b9c.json");
const express = require("express");
const app = express();

app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();


app.post("/getnotif", async (req, res) => {
  const tokenFromFlutterApp = "eOXxym0iSByJEXopQEA_za:APA91bHZoNzG-Vb9Zyd8raU620Z8j3PwyneR-EiifXaqbsshqjzhFiqEB9GdM-vhKq3jbxY00IXxaNErAfc9lXQ8CpCxenhTOcBdC-hvfytDXMSei_S4yIs";
  const docId = "fQx8IJxLWn4xJ5M7D3oW";

  sendNotificationToToken(tokenFromFlutterApp, docId);
  res.status(200).send({ success: true });
});

async function getDataFromFirestore(docId) {
    const docRef = db.collection("/consulationData").doc(docId);
    const docSnap = await docRef.get();

    const data = docSnap.data();
    return data 
}

async function sendNotificationToToken(fcmToken, docId) {
  const data = await getDataFromFirestore(docId);

  const message = {
    token: fcmToken,
    notification: { title: "Consultation Appointment Reminder", body: `You have a consultation appointment with ${data.studentName} in 10 minutes at ${data.location}` },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
  } catch (err) {
    console.error("Error sending notification:", err);
  }
}

app.listen(3000, () => console.log("Server running on port 3000"));