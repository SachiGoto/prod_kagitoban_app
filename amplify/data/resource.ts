import { type ClientSchema, a, defineData } from "@aws-amplify/backend";
import { saveLineUser } from "../functions/saveLineUser/resource";
import { notify } from "../functions/notifyLineUsers/resource";
import { remindKeyDuty } from "../functions/remindKeyDuty/resource";
// import { saveSchedule } from "../functions/saveSchedule/resource";
// import { saveAssignments } from "../functions/saveAssignments/resource";

const schema = a
  .schema({
    LineUser: a
      .model({
        id: a.id(),
        name: a.string(),
        email: a.string(),
        avatar: a.string(),
      })
      .authorization((allow) => [allow.authenticated()]),

    Schedule: a
      .model({
        yearMonth: a.string().required(), // e.g. "2025-01"
      })
      .authorization((allow) => [
        allow.publicApiKey().to(["read"]),
        allow.authenticated(),
      ]),

    Assignment: a
      .model({
        yearMonth: a.string().required(), // "2025-01"
        date: a.string().required(), // "2025-01-15"
        memberId: a.string().required(),
        memberName: a.string().required(),
      })
      .authorization((allow) => [allow.publicApiKey(), allow.authenticated()]),

    notifyUsers: a
      .mutation()
      .arguments({
        assignments: a.json().required(),
      })
      .returns(a.json())
      .handler(a.handler.function(notify))
      .authorization((allow) => [allow.authenticated(), allow.publicApiKey()]),
  })
  .authorization((allow) => [
    allow.resource(saveLineUser).to(["query", "mutate"]),
    allow.resource(notify).to(["query", "mutate"]),
    allow.resource(remindKeyDuty).to(["query"]),
  ]);

// saveAssignments: a
//   .mutation()
//   .arguments({
//     yearMonth: a.string().required(),
//     date: a.string().required(),
//     memberId: a.string().required(),
//     memberName: a.string().required(),
//     assignments: a.json().required(), // array of all assignments for the month
//   })
//   .returns(a.json())
//   .handler(a.handler.function(saveAssignments))
//   .authorization((allow) => [allow.authenticated()]),

//   notifyUsers: a
//     .mutation()
//     .arguments({
//       assignments: a.json().required(),
//     })
//     .returns(a.json())
//     // .handler(a.handler.function(saveAssignments)) // Reuse the same function for simplicity
//     .authorization((allow) => [allow.authenticated()]),
// });

export type Schema = ClientSchema<typeof schema>;

// export const data = defineData({
//   schema,
//   authorizationModes: {
//     defaultAuthorizationMode: "apiKey",
//     apiKeyAuthorizationMode: {
//       expiresInDays: 30,
//     },
//   },
// });

// Mutation to update assignments for a given schedule
// updateAssignments: a
//   .mutation()
//   .arguments({
//     id: a.id().required(),
//     assignments: a.json().required(),
//   })
//   .returns(a.json())
//   .handler(
//     a.handler.inlineCode(`
//       import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
//       import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

//       const client = DynamoDBDocumentClient.from(new DynamoDBClient({}));

//       export const handler = async (event) => {
//         const { id, assignments } = event.arguments;

//         const result = await client.send(new UpdateCommand({
//           TableName: process.env.SCHEDULE_TABLE_NAME,
//           Key: { id },
//           UpdateExpression: "SET assignments = :assignments, updatedAt = :updatedAt",
//           ExpressionAttributeValues: {
//             ":assignments": assignments,
//             ":updatedAt": new Date().toISOString(),
//           },
//           ReturnValues: "ALL_NEW",
//         }));

//         return result.Attributes;
//       };
//     `)
//   )
//   .authorization((allow) => [allow.authenticated()]),

// Existing notify mutation
//   notifyUsers: a
//     .mutation()
//     .arguments({
//       assignments: a.json().required(),
//     })
//     .returns(a.json())
//     .handler(a.handler.function(saveSchedule))
//     .authorization((allow) => [allow.authenticated()]),
// });

// export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: "apiKey",
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
  },
});
