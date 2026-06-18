import { defineFunction, secret } from "@aws-amplify/backend";

export const remindKeyDuty = defineFunction({
  name: "remindKeyDuty",
  timeoutSeconds: 30,
  schedule: "0 0 * * ? *",
  environment: {
    LINE_CHANNEL_ACCESS_TOKEN: secret("LINE_CHANNEL_ACCESS_TOKEN"),
  },
});
