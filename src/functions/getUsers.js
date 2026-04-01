const { app } = require("@azure/functions");
const { MongoClient } = require("mongodb");

app.http("getUsers", {
  methods: ["GET"],
  authLevel: "function",
  handler: async (request, context) => {
    context.log("getUsers HTTP trigger invoked");

    const uri = process.env.MONGODB_URI;
    context.log("Using MongoDB URI:", uri);
    if (!uri) {
      return {
        status: 500,
        jsonBody: { error: "MONGODB_URI environment variable is not set" },
      };
    }

    const dbName = process.env.MONGODB_DB;
    if (!dbName) {
      return {
        status: 500,
        jsonBody: { error: "MONGODB_DB environment variable is not set" },
      };
    }

    const collectionName = process.env.MONGODB_COLLECTION || "users";

    let client;
    try {
      client = new MongoClient(uri);
      await client.connect();

      const collection = client.db(dbName).collection(collectionName);
      const users = await collection.find({}).toArray();

      context.log(`Retrieved ${users.length} user(s) from '${collectionName}'`);

      return {
        status: 200,
        jsonBody: { users },
      };
    } catch (error) {
      context.log("Error querying MongoDB:", error.message);
      return {
        status: 500,
        jsonBody: { error: "Failed to retrieve users", details: error.message },
      };
    } finally {
      try {
        if (client) await client.close();
      } catch (e) {
        context.log("Error closing MongoDB client:", e.message);
      }
    }
  },
});
