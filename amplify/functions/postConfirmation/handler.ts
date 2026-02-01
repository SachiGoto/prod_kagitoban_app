// import type { PostConfirmationTriggerHandler } from 'aws-lambda';
// import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
// import { DynamoDBDocumentClient, PutCommand, GetCommand } from '@aws-sdk/lib-dynamodb';

// const client = new DynamoDBClient({});
// const docClient = DynamoDBDocumentClient.from(client);

// export const handler: PostConfirmationTriggerHandler = async (event) => {
//   console.log('Post confirmation event:', JSON.stringify(event, null, 2));

//   const { userAttributes } = event.request;
//   const cognitoId = userAttributes.sub;
//   const tableName = process.env.USER_TABLE_NAME;

//   if (!tableName) {
//     console.error('USER_TABLE_NAME environment variable not set');
//     return event;
//   }

//   // Extract user info from Cognito attributes
//   // These come from the LINE OIDC attribute mapping
//   const displayName = userAttributes.preferred_username || userAttributes.name || null;
//   const email = userAttributes.email || null;
//   const pictureUrl = userAttributes.picture || null;

//   // Extract LINE user ID from identities if available
//   let lineUserId = null;
//   if (userAttributes.identities) {
//     try {
//       const identities = JSON.parse(userAttributes.identities);
//       const lineIdentity = identities.find((id: any) => id.providerName === 'LINE');
//       if (lineIdentity) {
//         lineUserId = lineIdentity.userId;
//       }
//     } catch (e) {
//       console.error('Error parsing identities:', e);
//     }
//   }

//   const now = new Date().toISOString();

//   try {
//     // Check if user already exists
//     const existingUser = await docClient.send(
//       new GetCommand({
//         TableName: tableName,
//         Key: { cognitoId },
//       })
//     );

//     if (existingUser.Item) {
//       console.log('User already exists, updating lastLoginAt');
//       // User exists, update lastLoginAt
//       await docClient.send(
//         new PutCommand({
//           TableName: tableName,
//           Item: {
//             ...existingUser.Item,
//             displayName: displayName || existingUser.Item.displayName,
//             email: email || existingUser.Item.email,
//             pictureUrl: pictureUrl || existingUser.Item.pictureUrl,
//             lastLoginAt: now,
//           },
//         })
//       );
//     } else {
//       console.log('Creating new user');
//       // Create new user
//       await docClient.send(
//         new PutCommand({
//           TableName: tableName,
//           Item: {
//             cognitoId,
//             lineUserId,
//             displayName,
//             email,
//             pictureUrl,
//             createdAt: now,
//             lastLoginAt: now,
//             owner: `${cognitoId}::${event.userName}`,
//           },
//         })
//       );
//     }

//     console.log('User saved successfully');
//   } catch (error) {
//     console.error('Error saving user to DynamoDB:', error);
//     // Don't throw - we don't want to block the sign-in
//   }

//   return event;
// };
