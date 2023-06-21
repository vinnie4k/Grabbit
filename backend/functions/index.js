const serviceAccount = "./service_account_key.json";

const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Load other controllers
module.exports = {
  ...require("./controllers/courses"),
  ...require("./controllers/user"),
  ...require("./controllers/tracking"),
  ...require("./controllers/schedule"),
};
