/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const {onCall, HttpsError} =
    require("firebase-functions/v2/https");
const {onDocumentCreated} =
    require("firebase-functions/v2/firestore");
const {onValueWritten} = require("firebase-functions/v2/database");

const admin = require("firebase-admin");

admin.initializeApp();
const logger = require("firebase-functions/logger");

const messages = {
  en: {
    callMeTitle: "Call Me",
    callMeBody: (name) => `${name} wants you to call.`,
    alertTitle: "Lynra Alert",
  },
  tr: {
    callMeTitle: "Beni Ara",
    callMeBody: (name) => `${name} aramanı istiyor.`,
    alertTitle: "Lynra Alarm",
  },
  es: {
    callMeTitle: "Llámame",
    callMeBody: (name) => `${name} quiere que lo llames.`,
    alertTitle: "Alerta de Lynra",
  },
};

function getLanguageFromCountry(countryCode) {
  const code = (countryCode || "").toUpperCase();

  if (code === "TR") return "tr";
  if (code === "ES") return "es";

  return "en";
}

async function getCountryCodeForTarget(collectionName, targetId, groupId) {
  try {
    const targetSnap = await admin
      .firestore()
      .collection(collectionName)
      .doc(targetId)
      .get();

    const targetCountryCode = targetSnap.data()?.countryCode;

    if (targetCountryCode) {
      return targetCountryCode;
    }

    const groupSnap = await admin
      .firestore()
      .collection("groups")
      .doc(groupId)
      .get();

    return groupSnap.data()?.countryCode || "US";
  } catch (error) {
    console.error("COUNTRY CODE ERROR", error);
    return "US";
  }
}

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCallMeCreated = onDocumentCreated(
  "groups/{groupId}/call_me/{targetId}/items/{callMeId}",
  async (event) => {
    const data = event.data.data();
		
		const createdAtMillis =
				data.createdAt?.toMillis?.() ?? Date.now();

    const targetId = event.params.targetId;
    const callMeId = event.params.callMeId;

    const isRequesterToLocator =
      data.targetLocatorId === targetId;

    const isLocatorToRequester =
      data.targetRequesterId === targetId;

    let topic = "";
    let payload = {
      type: "call_me",
      callMeId,
			createdAt: createdAtMillis.toString(),
    };

    if (isRequesterToLocator) {
      const requesterName =
        data.requesterName || "Requester";
      const requesterCode =
        data.requesterCode || "";

      topic = `locator_${targetId}`;
			
			
      payload = {
        ...payload,
        requesterName,
        requesterCode,
      };
    } else if (isLocatorToRequester) {
      const locatorName =
        data.locatorName || "Member";
      const locatorCode =
        data.locatorCode || "";

      topic = `requester_${targetId}`;
			
			payload = {
        ...payload,
        locatorName,
        locatorCode,
      };
    } else {
      console.error("CALL ME ERROR => unknown target", data);
      return;
    }

    console.log("CALL ME CREATED", data);
    console.log("CALL ME FCM TOPIC", topic);

		try {
			let text = messages.en;

			try {
				const targetCollection =
					isRequesterToLocator ? "locators" : "requesters";

				const countryCode = await getCountryCodeForTarget(
					targetCollection,
					targetId,
					event.params.groupId,
				);

				const lang = getLanguageFromCountry(countryCode);
				text = messages[lang] || messages.en;
			} catch (error) {
				console.error("CALL ME LOCALIZATION ERROR", error);
			}

			const notificationTitle = text.callMeTitle;

			const callerName =
				isRequesterToLocator
					? data.requesterName || "Requester"
					: data.locatorName || "Member";

			const notificationBody = text.callMeBody(callerName);

			const response = await admin.messaging().send({
				topic,

				android: {
				priority: "high",
			},

			data: {
				...payload,
				title: notificationTitle,
				body: notificationBody,
			},
		});

			console.log("CALL ME FCM SENT", topic, response);
		} catch (error) {
			console.error("CALL ME FCM ERROR", error);
		}
  }
);
exports.onAlertCreated = onDocumentCreated(
  "groups/{groupId}/alerts/{requesterId}/items/{alertId}",
  async (event) => {
    const data = event.data.data();
		
		const createdAtMillis =
			data.createdAt?.toMillis?.() ?? Date.now();

    const requesterId = event.params.requesterId;
    const alertId = event.params.alertId;

    const locatorName = data.locatorName || "Locator";
    const locatorCode = data.locatorCode || "";
    const alertType = data.type || "alert";
		const placeName = data.placeName || "";

    const topic = `requester_${requesterId}`;

    console.log("ALERT CREATED", data);
    console.log("ALERT FCM TOPIC", topic);

			try {
			let text = messages.en;

			try {
				const countryCode = await getCountryCodeForTarget(
					"requesters",
					requesterId,
					event.params.groupId,
				);

				const lang = getLanguageFromCountry(countryCode);
				text = messages[lang] || messages.en;
			} catch (error) {
				console.error("ALERT LOCALIZATION ERROR", error);
			}

			const response = await admin.messaging().send({
			topic,

			android: {
				priority: "high",
			},

			data: {
				type: "alert",
				alertId,
				alertType,
				locatorName,
				locatorCode,
				placeName,
				createdAt: createdAtMillis.toString(),
			},
		});
			console.log("ALERT FCM SENT", topic, response);
		} catch (error) {
			console.error("ALERT FCM ERROR", error);
		}
  }
);
		
exports.onActiveWatchersChanged = onValueWritten(
  "/presence/groups/{groupId}/active_watchers/{locatorId}",
  async (event) => {
    const locatorId = event.params.locatorId;

    const before = event.data.before.val() || {};
    const after = event.data.after.val() || {};

    const beforeCount = Object.keys(before).length;
    const afterCount = Object.keys(after).length;

    console.log(
      "ACTIVE WATCHERS CHANGED",
      "locatorId=", locatorId,
      "beforeCount=", beforeCount,
      "afterCount=", afterCount,
    );

    if (beforeCount === afterCount) {
      console.log("ACTIVE WATCHERS => count unchanged, skip FCM");
      return;
    }

    const topic = `locator_${locatorId}`;

    try {
      const response = await admin.messaging().send({
        topic,

        android: {
          priority: "high",
        },

        data: {
          type: "active_watchers_changed",
        },
      });

      console.log("ACTIVE WATCHERS FCM SENT", topic, response);
    } catch (error) {
      console.error("ACTIVE WATCHERS FCM ERROR", error);
    }
  }
);
exports.createFleetManager = onCall(
    async (request) => {
      // ==========================================
      // AUTH CHECK
      // ==========================================

      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "Authentication required.",
        );
      }

      const callerUid = request.auth.uid;

      const email =
          request.data.email?.trim().toLowerCase();

      const password =
          request.data.password;

      const groupId =
          request.data.groupId?.trim();

      if (!email || !password || !groupId) {
        throw new HttpsError(
            "invalid-argument",
            "Email, password and groupId are required.",
        );
      }

      if (password.length < 6) {
        throw new HttpsError(
            "invalid-argument",
            "Password must contain at least 6 characters.",
        );
      }

      // ==========================================
      // GROUP CHECK
      // ==========================================

      const groupRef = admin
          .firestore()
          .collection("groups")
          .doc(groupId);

      const groupSnap = await groupRef.get();

      if (!groupSnap.exists) {
        throw new HttpsError(
            "not-found",
            "Fleet not found.",
        );
      }

      const groupData = groupSnap.data();

      // Buradaki field senin mevcut yapına göre.
      // groups/{groupId}.masterRequesterId
      const masterRequesterId =
          groupData.masterRequesterId;

      if (!masterRequesterId) {
        throw new HttpsError(
            "failed-precondition",
            "Fleet master not found.",
        );
      }

      // ==========================================
      // VERIFY REQUESTER OWNER
      // ==========================================

      const requesterSnap = await admin
          .firestore()
          .collection("requesters")
          .doc(masterRequesterId)
          .get();

      if (!requesterSnap.exists) {
        throw new HttpsError(
            "permission-denied",
            "Fleet owner not found.",
        );
      }

      const requesterAuthUid =
          requesterSnap.data().authUid;

      if (requesterAuthUid !== callerUid) {
        throw new HttpsError(
            "permission-denied",
            "Only the fleet owner can create web access.",
        );
      }

      // ==========================================
      // CREATE FIREBASE AUTH USER
      // ==========================================

      let userRecord;

      try {
        userRecord =
            await admin.auth().createUser({
          email,
          password,
          emailVerified: false,
          disabled: false,
        });
      } catch (error) {
        console.error(
            "CREATE FLEET MANAGER AUTH ERROR",
            error,
        );

        if (error.code === "auth/email-already-exists") {
          throw new HttpsError(
              "already-exists",
              "This email address is already registered.",
          );
        }

        throw new HttpsError(
            "internal",
            "Could not create web account.",
        );
      }

      const managerUid = userRecord.uid;

      // ==========================================
      // GROUP ACCESS
      // ==========================================

      try {
        await admin
            .firestore()
            .collection("fleet_managers")
            .doc(managerUid)
            .collection("groups")
            .doc(groupId)
            .set({
              groupId,
              email,
              createdAt:
                  admin.firestore.FieldValue.serverTimestamp(),
              createdBy: callerUid,
            });
      } catch (error) {
        // Auth user oluşturuldu ama Firestore yazılamadı.
        // Yarım hesap bırakmayalım.
        await admin.auth().deleteUser(managerUid);

        console.error(
            "CREATE FLEET MANAGER FIRESTORE ERROR",
            error,
        );

        throw new HttpsError(
            "internal",
            "Could not create web access.",
        );
      }

      console.log(
          "FLEET MANAGER CREATED",
          "uid=", managerUid,
          "groupId=", groupId,
      );

      return {
        success: true,
        uid: managerUid,
      };
    },
);