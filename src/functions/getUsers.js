const { app } = require("@azure/functions");
const { CosmosClient } = require("@azure/cosmos");

app.http("getUsers", {
  methods: ["GET"],
  authLevel: "function",
  handler: async (request, context) => {
    context.log("getUsers HTTP trigger invoked");

    const connectionString = process.env.COSMOS_CONNECTION_STRING;
    if (!connectionString) {
      return {
        status: 500,
        jsonBody: { error: "COSMOS_CONNECTION_STRING environment variable is not set" },
      };
    }

    const databaseId = process.env.COSMOS_DATABASE_ID;
    if (!databaseId) {
      return {
        status: 500,
        jsonBody: { error: "COSMOS_DATABASE_ID environment variable is not set" },
      };
    }

    const containerId = process.env.COSMOS_CONTAINER_ID || "users";

    try {
      const client = new CosmosClient(connectionString);
      const { resources: users } = await client
        .database(databaseId)
        .container(containerId)
        .items.query({ query: "SELECT * FROM c" })
        .fetchAll();

      context.log(`Retrieved ${users.length} user(s) from '${containerId}'`);

      return {
        status: 200,
        jsonBody: { users },
      };
    } catch (error) {
      context.log("Error querying Cosmos DB:", error.message);
      return {
        status: 500,
        jsonBody: { error: "Failed to retrieve users", details: error.message },
      };
    }
  },
});
