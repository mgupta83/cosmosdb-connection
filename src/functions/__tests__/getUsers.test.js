jest.mock("mongodb");
jest.mock("@azure/functions", () => ({
  app: { http: jest.fn() },
}));

const { MongoClient } = require("mongodb");
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

describe("getUsers function (MongoDB)", () => {
  let mockToArray;
  let mockFind;
  let mockCollection;
  let mockDb;
  let mockClient;

  beforeEach(() => {
    mockToArray = jest.fn();
    mockFind = jest.fn().mockReturnValue({ toArray: mockToArray });
    mockCollection = { find: mockFind };
    mockDb = { collection: jest.fn().mockReturnValue(mockCollection) };
    mockClient = { connect: jest.fn(), db: jest.fn().mockReturnValue(mockDb), close: jest.fn() };

    MongoClient.mockImplementation(() => mockClient);

    process.env.MONGODB_URI = "mongodb://localhost:27017";
    process.env.MONGODB_DB = "testdb";
    process.env.MONGODB_COLLECTION = "users";
  });

  afterEach(() => {
    delete process.env.MONGODB_URI;
    delete process.env.MONGODB_DB;
    delete process.env.MONGODB_COLLECTION;
  });

  const makeContext = () => ({ log: jest.fn() });

  it("registers the getUsers HTTP trigger", () => {
    expect(registeredName).toBe("getUsers");
    expect(registeredConfig).toMatchObject({ methods: ["GET"], authLevel: "function" });
  });

  it("returns users from MongoDB on success", async () => {
    const fakeUsers = [
      { _id: "1", name: "Alice" },
      { _id: "2", name: "Bob" },
    ];
    mockToArray.mockResolvedValue(fakeUsers);

    const response = await handler({}, makeContext());

    expect(MongoClient).toHaveBeenCalledWith("mongodb://localhost:27017");
    expect(mockClient.connect).toHaveBeenCalled();
    expect(mockClient.db).toHaveBeenCalledWith("testdb");
    expect(mockDb.collection).toHaveBeenCalledWith("users");
    expect(mockFind).toHaveBeenCalledWith({});
    expect(response.status).toBe(200);
    expect(response.jsonBody).toEqual({ users: fakeUsers });
  });

  it("defaults collection to 'users' when env var is not set", async () => {
    delete process.env.MONGODB_COLLECTION;
    mockToArray.mockResolvedValue([]);

    await handler({}, makeContext());

    expect(mockDb.collection).toHaveBeenCalledWith("users");
  });

  it("returns 500 when MONGODB_DB is not set", async () => {
    delete process.env.MONGODB_DB;

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toMatch(/MONGODB_DB/);
  });

  it("returns 500 when MongoDB query fails", async () => {
    mockToArray.mockRejectedValue(new Error("Connection refused"));

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toBe("Failed to retrieve users");
    expect(response.jsonBody.details).toBe("Connection refused");
  });

  it("returns 500 when MONGODB_URI is not set", async () => {
    delete process.env.MONGODB_URI;

    const response = await handler({}, makeContext());

    expect(response.status).toBe(500);
    expect(response.jsonBody.error).toMatch(/MONGODB_URI/);
  });
});
