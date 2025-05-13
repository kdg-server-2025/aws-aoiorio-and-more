
# 📜 Credits
- [How to create billing alarms with Terraform?](https://qiita.com/ngyuki/items/bbabe8252203634b6f47)
- [What is Terraform state?](https://zenn.dev/spacemarket/articles/b7bd1422b896ca)
- [What is terraform init command?](https://zenn.dev/ishii1648/articles/e3464a668978cb)

# 🏮 Error Solutions

### 1️⃣

```
Error: Failed to load plugin schemas
│
│ Error while loading schemas for plugin components: Failed to obtain provider schema: Could not load the schema for provider
│ registry.terraform.io/hashicorp/aws: failed to instantiate provider "registry.terraform.io/hashicorp/aws" to obtain schema: Unrecognized
│ remote plugin message:
│
│ This usually means that the plugin is either invalid or simply
│ needs to be recompiled to support the latest protocol...
```
- [Solve by restarting the Mac itself (Zenn)](https://zenn.dev/bun913/articles/m1-mac-terraform-unstable)
- [Solve by adding environment variable (Terraform Gives errors Failed to load plugin schemas, Stackoverflow)](https://stackoverflow.com/questions/70407525/terraform-gives-errors-failed-to-load-plugin-schemas)