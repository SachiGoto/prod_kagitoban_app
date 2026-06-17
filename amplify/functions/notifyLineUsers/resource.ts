import { defineFunction, secret } from "@aws-amplify/backend";

export const notify = defineFunction({
  name: "notifyLineUsers",
  timeoutSeconds: 30,
  environment: {
    LINE_CHANNEL_ACCESS_TOKEN: secret("LINE_CHANNEL_ACCESS_TOKEN"),
  },
});
