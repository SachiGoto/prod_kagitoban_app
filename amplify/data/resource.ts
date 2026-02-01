import { type ClientSchema, a, defineData } from "@aws-amplify/backend";

const schema = a.schema({
  LineUser: a
    .model({
      id: a.id(),
      name: a.string(),
      email: a.string(),
      avatar: a.string(),
    })
    .authorization((allow) => [allow.authenticated()]),
  // 変更
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  // authorizationModes: {
  //   defaultAuthorizationMode: "userPool", // 変更
  //   // API 認証の記述を削除
  // },
});

// amplify/data/resource.ts
// import { a, defineData } from "@aws-amplify/backend";

// export const data = defineData({
//   schema: a.schema({
//     LineUser: a.model({
//       id: a.id(),
//       name: a.string(),
//       email: a.string(),
//       avatar: a.string(),
//     }),
//     .authorization((allow) => [
//       allow.owner({ operations: ["create", "update", "delete"] }),
//       allow.private({ operations: ["read"] }),
//     ]),
//   }),
// });

// import { a } from "@aws-amplify/backend";

// export const data = a.schema({
//   LineUser: a
//     .model({
//       id: a.id(),
//       name: a.string(),
//       email: a.string(),
//       avatar: a.string(),
//     })
//     .authorization((allow) => [
//       // Owner has full access to their own record
//       // allow.owner(),

//       // Any signed-in user can read all users
//       allow.authenticated(),
//     ]),
// });
