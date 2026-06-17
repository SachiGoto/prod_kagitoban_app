import { defineAuth, secret } from "@aws-amplify/backend";
import { saveLineUser } from "../functions/saveLineUser/resource";

export const auth = defineAuth({
  triggers: {
    postConfirmation: saveLineUser,
    postAuthentication: saveLineUser,
  },
  loginWith: {
    email: true,
    externalProviders: {
      oidc: [
        {
          name: "LINE",
          clientId: secret("LINE_CLIENT_ID"),
          clientSecret: secret("LINE_CLIENT_SECRET"),
          issuerUrl: "https://access.line.me",
          scopes: ["email", "openid", "profile"],
          attributeMapping: {
            email: "email",
            preferredUsername: "name", // LINE display name
            profilePicture: "picture", // LINE profile picture
          },
        },
      ],

      // REQUIRED in your version
      callbackUrls: [
        "http://localhost:57417/",
        "https://main.d3c2p7z3mrhvgx.amplifyapp.com/",
      ],
      logoutUrls: [
        "http://localhost:57417/",
        "https://main.d3c2p7z3mrhvgx.amplifyapp.com/",
      ],
    },
  },
});
