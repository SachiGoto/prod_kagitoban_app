const amplifyConfig = r'''{
  "auth": {
    "user_pool_id": "ap-northeast-1_WiZvIHXl9",
    "aws_region": "ap-northeast-1",
    "user_pool_client_id": "4ade25ka46ctj42d986vnjmu98",
    "identity_pool_id": "ap-northeast-1:e03716ae-c4d7-4d7c-b1c9-9148f0cc4dbb",
    "mfa_methods": [],
    "standard_required_attributes": [
      "email"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
    "groups": [],
    "mfa_configuration": "NONE",
    "password_policy": {
      "min_length": 8,
      "require_lowercase": true,
      "require_numbers": true,
      "require_symbols": true,
      "require_uppercase": true
    },
    "oauth": {
      "identity_providers": [],
      "redirect_sign_in_uri": [
        "http://localhost:57417/",
        "https://main.d1vatehoq5fvk6.amplifyapp.com"
      ],
      "redirect_sign_out_uri": [
        "http://localhost:57417/",
        "https://main.d3c2p7z3mrhvgx.amplifyapp.com/"
      ],
      "response_type": "code",
      "scopes": [
        "phone",
        "email",
        "openid",
        "profile",
        "aws.cognito.signin.user.admin"
      ],
      "domain": "e4cb1af719ecd6a24679.auth.ap-northeast-1.amazoncognito.com"
    },
    "unauthenticated_identities_enabled": true
  },
  "data": {
    "url": "https://t2n4s5fh6rbxnph3xgiu4matqy.appsync-api.ap-northeast-1.amazonaws.com/graphql",
    "aws_region": "ap-northeast-1",
    "api_key": "da2-ukdodij6ffe6nnk6cklzvvlaky",
    "default_authorization_type": "API_KEY",
    "authorization_types": [
      "AMAZON_COGNITO_USER_POOLS",
      "AWS_IAM"
    ],
    "model_introspection": {
      "version": 1,
      "models": {
        "LineUser": {
          "name": "LineUser",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "name": {
              "name": "name",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "email": {
              "name": "email",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "avatar": {
              "name": "avatar",
              "isArray": false,
              "type": "String",
              "isRequired": false,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "LineUsers",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "key",
              "properties": {
                "fields": [
                  "id"
                ]
              }
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Schedule": {
          "name": "Schedule",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "yearMonth": {
              "name": "yearMonth",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Schedules",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "apiKey",
                    "operations": [
                      "read"
                    ]
                  },
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        },
        "Assignment": {
          "name": "Assignment",
          "fields": {
            "id": {
              "name": "id",
              "isArray": false,
              "type": "ID",
              "isRequired": true,
              "attributes": []
            },
            "yearMonth": {
              "name": "yearMonth",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "date": {
              "name": "date",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "memberId": {
              "name": "memberId",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "memberName": {
              "name": "memberName",
              "isArray": false,
              "type": "String",
              "isRequired": true,
              "attributes": []
            },
            "createdAt": {
              "name": "createdAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            },
            "updatedAt": {
              "name": "updatedAt",
              "isArray": false,
              "type": "AWSDateTime",
              "isRequired": false,
              "attributes": [],
              "isReadOnly": true
            }
          },
          "syncable": true,
          "pluralName": "Assignments",
          "attributes": [
            {
              "type": "model",
              "properties": {}
            },
            {
              "type": "auth",
              "properties": {
                "rules": [
                  {
                    "allow": "public",
                    "provider": "apiKey",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  },
                  {
                    "allow": "private",
                    "operations": [
                      "create",
                      "update",
                      "delete",
                      "read"
                    ]
                  }
                ]
              }
            }
          ],
          "primaryKeyInfo": {
            "isCustomPrimaryKey": false,
            "primaryKeyFieldName": "id",
            "sortKeyFieldNames": []
          }
        }
      },
      "enums": {},
      "nonModels": {},
      "mutations": {
        "notifyUsers": {
          "name": "notifyUsers",
          "isArray": false,
          "type": "AWSJSON",
          "isRequired": false,
          "arguments": {
            "assignments": {
              "name": "assignments",
              "isArray": false,
              "type": "AWSJSON",
              "isRequired": true
            }
          }
        }
      }
    }
  },
  "version": "1.4"
}''';
