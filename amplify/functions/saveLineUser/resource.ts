import { defineFunction } from "@aws-amplify/backend";

export const saveLineUser = defineFunction({
  name: "saveLineUser",
  entry: "./handler.ts",
  resourceGroupName: "auth",
});
