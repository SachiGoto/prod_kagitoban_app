const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_73epHulIS",
            "AppClientId": "ush7n9penseivipufssq0iqna",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "OAuth": {
              "WebDomain": "us-east-173ephulis.auth.us-east-1.amazoncognito.com",
              "AppClientId": "ush7n9penseivipufssq0iqna",
              "SignInRedirectURI": "https://main.d3c2p7z3mrhvgx.amplifyapp.com/",
              "SignOutRedirectURI": "hhttps://main.d3c2p7z3mrhvgx.amplifyapp.com/",
              "Scopes": ["openid", "profile"]
            }
          }
        }
      }
    }
  }
}''';
