// import type { Schema } from "../../data/resource";
// import { Amplify } from "aws-amplify";
// import { generateClient } from "aws-amplify/data";

// Amplify.configure(
//   {
//     API: {
//       GraphQL: {
//         endpoint: process.env.AMPLIFY_DATA_GRAPHQL_ENDPOINT || "",
//         region: process.env.AWS_REGION || "us-east-1",
//         defaultAuthMode: "iam",
//       },
//     },
//   },
//   { ssr: true },
// );

// const client = generateClient<Schema>({ authMode: "iam" });

// type AssignmentInput = {
//   date: string;
//   memberId: string;
//   memberName: string;
//   role: string;
// };

// // export const handler: Schema["saveAssignments"]["functionHandler"] = async (
// //   event: any,
// // ) => {
// //   const { scheduleId, assignments } = event.arguments;

// //   const parsed: AssignmentInput[] = JSON.parse(assignments);

// //   // Delete existing assignments for this schedule first
// //   const { data: existing } = await client.models.Assignment.list({
// //     filter: { scheduleId: { eq: scheduleId } },
// //   });

// //   await Promise.all(
// //     (existing ?? []).map((a) => client.models.Assignment.delete({ id: a.id })),
// //   );

// //   // Insert new assignments
// //   const results = await Promise.all(
// //     parsed.map((a) =>
// //       client.models.Assignment.create({
// //         scheduleId,
// //         date: a.date,
// //         memberId: a.memberId,
// //         memberName: a.memberName,
// //         role: a.role,
// //       }),
// //     ),
// //   );

// //   return JSON.stringify(results);
// // };
