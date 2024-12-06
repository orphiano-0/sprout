const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyLowSoilMoisture = functions.database
    .ref("/Moisture_Monitoring/{plantId}")
    .onUpdate((change, context) => {
      const beforeData = change.before.val();
      const afterData = change.after.val();

      if (!beforeData || !afterData) {
        console.error("Invalid data structure");
        return null;
      }

      if (beforeData.moisture_value > 20 && afterData.moisture_value <= 20) {
        const fcmToken = afterData.fcm_token;
        const plantName = afterData.plant_name || "your plant";

        if (fcmToken) {
          const message = {
            notification: {
              title: "Low Moisture Alert!",
              body: `Your plant "${plantName}" needs watering.`,
            },
            token: fcmToken,
          };

          return admin.messaging().send(message)
              .then((response) => {
                console.log("Notification sent successfully:", response);
                return response;
              })
              .catch((error) => {
                console.error("Error sending notification:", error);
                return error;
              });
        } else {
          console.error("No FCM token found for plant", context.params.plantId);
        }
      }

      return null; // Exit gracefully if no condition matches
    });
