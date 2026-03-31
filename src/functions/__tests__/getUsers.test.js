jest.mock("@azure/cosmos");
jest.mock("@azure/functions", () => ({
  app: { http: jest.fn() },
}));

const { CosmosClient } = require("@azure/cosmos");
const { app } = require("@azure/functions");

// Capture the registered name and config when the module is loaded.
let handler;
let registeredName;
let registeredConfig;

app.http.mockImplementation((name, config) => {
  registeredName = name;
  registeredConfig = config;
  handler = config.handler;
});

// Load the function module so app.http() is called and handler is captured.
require("../getUsers");

describe("getUsers function", () => {
  let mockFetchAll;
  let mockQuery;
  let mockContainer;
  let mockDatabase;
  let mockClient;

  beforeEach(() => {
    mockFetchAll = jest.fn();
    mockQuery = jest.fn().mockReturnValue({ fetchAll: mockFetchAll });
    mockContainer = { items: { query: mockQuery } };
    mockDatabase = { container: jest.fn().mockReturnValue(mockContainer) };
    mockClient = { database: jest.fn().mockReturnValue(mockDatabase) };

    CosmosClient.mockImplementation(() => mockClient);

    process.env.COSMOS_CONNECTION_STRING =
      "AccountEndpoint=https://test.documents.azure.com:443/;AccountKey=dGVzdA==;";
    process.env.COSMOS_DATABASE_ID = "testdb";
    process.env.COSMOS_CONTAINER_ID = "users";
  });

  afterEach(() => {
    delete process.env.COSMOS_CONNECTION_STRING;
    delete process.env.COSMOS_DATABASE_ID;
    delete process.env.COSMOS_CONTAINER_ID;
  });

  const makeContext = () => ({ log: jest.fn() });

  it("registers the getUsers HTTP trigger", () => {
    expect(registeredName).toBe("getUsers");
    expect(registeredConfig).toMatchObject({ methods: ["GET"], authLevel: "function" });
  });

  it("returns users from Cosmos DB on success", async () => {
    const fakeUsers = [
      { id: "1", name: "Alice" },
      { id: "2", name: "Bob" },
    ];
    mockFetchAll.mockResolvedValue({ resources: fakeUsers });

    const response = await handler({}, makeContext());

    expect(CosmosClient).toHaveBeenCalledWith(
      "AccountEndpoint=https://test.documents.azure.com:443/;AccountKey=dGVzdA==;"
    );
    expect(mockClient.database).toHaveBeenCalledWith("testdb");
    expect(mockDatabase.container).toHaveBeenCalledWith("users");
    expect(mockQuery).toHaveBeenCalledWith({ query: "SELECT * FROM c" });
    expect(response.status).toBe(200);
    expect(response.jsonBody).toEqual({ users: fakeUsers });
  });

  it("defaults container ID to 'users' when env var is not set", async () => {
    delete process.env.COSMOS_CONTAINER_ID;
    mockFetchAll.mockResolvedValue({ resources: [] });

    await handler({}, makeContext());

    expect(mockDatabase.container).toHaveBeenCalledWith("users");
  });

  it("returns 500 when COSMOS_DATABASE_ID is not set", async () => {
    delete process.env.COSMOS_DATABASE_ID;

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toMatch(/COSMOS_DATABASE_ID/);
  });

  it("returns 500 when Cosmos DB query fails", async () => {
    mockFetchAll.mockRejectedValue(new Error("Connection refused"));

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toBe("Failed to retrieve users");
    expect(response.jsonBody.details).toBe("Connection refused");
  });

  it("returns 500 when COSMOS_CONNECTION_STRING is not set", async () => {
    delete process.env.COSMOS_CONNECTION_STRING;

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toMatch(/COSMOS_CONNECTION_STRING/);
  });
});
