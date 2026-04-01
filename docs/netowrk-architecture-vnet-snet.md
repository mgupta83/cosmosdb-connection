# Network Architecture Options

## 🔹 Option 1: Per-App Subnet Isolation (Recommended)

### Overview
- One **VNet per region per environment**
- One **subnet per app/database within each VNet**
- Function Apps use **app-specific subnet for outbound traffic**
- Cosmos DB allows **only corresponding subnet for inbound traffic**

---

### 📁 Resource Structure

```
corp-<<env>>-rg:

  corp-<<env>>-vnet-east2
    <<app-name-1>>-<<env>>-snet-east2
    <<app-name-2>>-<<env>>-snet-east2

  corp-<<env>>-vnet-west
    <<app-name-1>>-<<env>>-snet-west
    <<app-name-2>>-<<env>>-snet-west

  <<app-name-1>>-<<env>>-cosmosdb
  <<app-name-1>>-<<env>>-functionapp-east2
  <<app-name-1>>-<<env>>-functionapp-west

  <<app-name-2>>-<<env>>-cosmosdb
  <<app-name-2>>-<<env>>-functionapp-east2
  <<app-name-2>>-<<env>>-functionapp-west
```

---

### ✅ Benefits

- Strong **isolation between applications**
- Prevents accidental cross-access between databases
- Enables **fine-grained network security controls**
- Better alignment with **least privilege principles**

---

## 🔹 Option 2: Shared Subnet per Region (Simpler)

### Overview
- One **VNet per region per environment**
- One **shared subnet per region**
- Function Apps use **region-level subnet**
- Cosmos DB allows **region-level subnet**

---

### 📁 Resource Structure

```
corp-<<env>>-rg:

  corp-<<env>>-vnet-east2
    corp-<<env>>-snet-east2

  corp-<<env>>-vnet-west
    corp-<<env>>-snet-west

  <<app-name-1>>-<<env>>-cosmosdb
  <<app-name-1>>-<<env>>-functionapp-east2
  <<app-name-1>>-<<env>>-functionapp-west

  <<app-name-2>>-<<env>>-cosmosdb
  <<app-name-2>>-<<env>>-functionapp-east2
  <<app-name-2>>-<<env>>-functionapp-west
```

---

### ✅ Benefits

- Simpler to implement and manage
- Fewer subnets and configurations
- Lower operational overhead

---

### ⚠️ Trade-offs

- Reduced isolation between applications
- Less granular control over network rules
- Higher risk of unintended cross-access if misconfigured
- *TBD how Azure limits the number of Function Apps/App Service Plans per subnet.*

---
## ⚖️ Comparison

| Traffic | Option 1 (Per-App Subnet Isolation) | Option 2 (Shared Subnet per Region)|
|--------|--------|--------|
| `<<app-name-1>>-<<env>>-functionapp-*` → `<<app-name-1>>-<<env>>-cosmosdb` | Allowed | Allowed |
| `<<app-name-2>>-<<env>>-functionapp-*` → `<<app-name-2>>-<<env>>-cosmosdb` | Allowed | Allowed |
| `<<app-name-1>>-<<env>>-functionapp-*` → `<<app-name-2>>-<<env>>-cosmosdb` | Not Allowed | ⚠️ Allowed |
| `<<app-name-2>>-<<env>>-functionapp-*` → `<<app-name-1>>-<<env>>-cosmosdb` | Not Allowed | ⚠️ Allowed |
| From any other network | Not Allowed | Not Allowed |

---

## 🧠 Summary

| Feature | Option 1 | Option 2 |
|--------|--------|--------|
| Isolation | ✅ High | ⚠️ Medium |
| Complexity | ❌ Higher | ✅ Lower |
| Security Control | ✅ Fine-grained | ⚠️ Limited |
| Recommended | ✅ Yes (prod) | 👍 Acceptable (simpler use cases) |

---

## 💡 Recommendation
Use **Option 1** for production-grade isolation and security.  
Use **Option 2** when simplicity and speed outweigh strict isolation requirements.

---

## � Considerations
- [Azure Limits](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits)

  - Virtual Networks = 1000
  - Subnets per Virtual Network = 3000

- [Azure Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)