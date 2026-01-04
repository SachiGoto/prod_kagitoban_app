const amplifyconfig = '''{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "",
              "Region": "ap-northeast-1"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_pVissLBD7",
            "AppClientId": "56gjnh342fo49sm52pvavf02eb",
            "Region": "ap-northeast-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "OAuth": {
              "WebDomain": "kagitoban.auth.us-east-1.amazoncognito.com",
              "AppClientId": "56gjnh342fo49sm52pvavf02eb",
              "SignInRedirectURI": "http://localhost:59255/",
              "SignOutRedirectURI": "http://localhost:59255/",
              "AllowedCallbackURLs": [
                "http://localhost:59255/"
              ],
              "Scopes": ["openid", "profile", "email"]
            }
          }
        }
      }
    }
  }
}''';
