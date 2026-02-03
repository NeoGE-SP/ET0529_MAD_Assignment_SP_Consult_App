const admin = require("firebase-admin");
const serviceAccount = require("./mad-assignment-b5e70-firebase-adminsdk-fbsvc-1d113bdfce.json");
const express = require("express");
const app = express();

app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();



app.post("/requestnotif", async (req, res) => {
  const { token, docID, role , moduleName} = req.body;

  sendRequestNotification(token, docID, role, moduleName);
  res.status(200).send({ success: true });
});

app.post("/rejectnotif", async (req, res) => {
  const { token, docID, role , moduleName, l_name} = req.body;

  sendRejectNotification(token, docID, role, moduleName, l_name);
  res.status(200).send({ success: true });
});

app.post("/acceptnotif", async (req, res) => {
  const { token, docID, role , moduleName} = req.body;

  sendAcceptNotification(token, docID, role, moduleName);
  res.status(200).send({ success: true });
});

async function getDataFromFirestore(docID, role) {
    const docRef = db.collection(role).doc(docID);
    const docSnap = await docRef.get();

    const data = docSnap.data();
    return data 
}

async function sendRequestNotification(token, docID, role, module,) {
  const data = await getDataFromFirestore(docID, role);

  if (Array.isArray(token) && token.length > 0) {
    const message = {
      tokens: token,
      notification: { title: "Consultation Appointment Request", body: `${data.name} of class ${data.class} for module ${module} has requested a consultation` },
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
  else {
    console.log('No tokens provided (lecturer not logged in on any device). Skipping notification, but request is successful.');
  }
}

async function sendRejectNotification(token, docID, role, module, l_name) {
  const data = await getDataFromFirestore(docID, role);

  if (Array.isArray(token) && token.length > 0) {
    const message = {
      tokens: token,
      notification: { title: "Consultation Appointment Rejection", body: `Your appointment request for ${module} with ${l_name} has been rejected` },
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
  else {
    console.log('No tokens provided (student not logged in on any device). Skipping notification, but rejection is successful.');
  }
}

async function sendAcceptNotification(token, docID, role, module) {
  const data = await getDataFromFirestore(docID, role);

  if (Array.isArray(token) && token.length > 0) {
    const message = {
      tokens: token,
      notification: { title: "Consultation Appointment Scheduled", body: `Your appointment request for ${module} with ${data.name} has been scheduled` },
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
  else {
    console.log('No tokens provided (student not logged in on any device). Skipping notification, but scheduling is successful.');
  }
}

app.listen(3000, () => console.log("Server running on port 3000"));