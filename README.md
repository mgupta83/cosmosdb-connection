# cosmosdb-connection

Azure Function App that exposes an HTTP endpoint to connect to Azure Cosmos DB and run a find query on the **users** collection.

## Endpoint

| Method | Route | Auth |
|--------|-------|------|
| `GET` | `/api/getUsers` | Function key |

Returns a JSON object with the list of all documents in the users container:

```json
{
  "users": [
    { "id": "1", "name": "Alice", ... },
    ...
  ]
}
```

## Prerequisites

- [Node.js 18+](https://nodejs.org/)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- An Azure Cosmos DB account (or the [Cosmos DB emulator](https://learn.microsoft.com/azure/cosmos-db/local-emulator))

## Getting started

### 1. Install dependencies

```bash
npm install
```

### 2. Configure local settings

Copy `local.settings.json` and fill in your Cosmos DB details:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "COSMOS_CONNECTION_STRING": "<your-cosmos-db-connection-string>",
    "COSMOS_DATABASE_ID": "<your-database-id>",
    "COSMOS_CONTAINER_ID": "users"
  }
}
```

| Variable | Description |
|----------|-------------|
| `COSMOS_CONNECTION_STRING` | Primary connection string from the Azure portal → your Cosmos DB account → Keys |
| `COSMOS_DATABASE_ID` | Name of your Cosmos DB database |
| `COSMOS_CONTAINER_ID` | Name of the container/collection (defaults to `users`) |

### 3. Run locally

```bash
npm start
# or
func start
```

Then call the endpoint:

```bash
curl "http://localhost:7071/api/getUsers?code=<your-function-key>"
```

### 4. Run tests

```bash
npm test
```

## Deployment

Deploy to Azure using the Azure Functions Core Tools:

```bash
func azure functionapp publish <your-function-app-name>
```

Or use the [Azure Functions extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions).

After deployment, set the application settings in the Azure portal or via the CLI:

```bash
az functionapp config appsettings set \
  --name <your-function-app-name> \
  --resource-group <your-resource-group> \
  --settings \
    COSMOS_CONNECTION_STRING="<your-cosmos-db-connection-string>" \
    COSMOS_DATABASE_ID="<your-database-id>" \
    COSMOS_CONTAINER_ID="users"
```