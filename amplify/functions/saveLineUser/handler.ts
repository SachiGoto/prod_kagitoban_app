import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({});

export const handler = async (event: any) => {
  console.log("🔥 PostConfirmation trigger fired");

  const attrs = event.request.userAttributes;

  const identities = attrs.identities ? JSON.parse(attrs.identities) : [];
  const lineIdentity = identities.find((i: any) => i.providerName === "LINE");

  const tableName = process.env.LINEUSER_TABLE_NAME;
  if (!tableName) {
    console.error("❌ LINEUSER_TABLE_NAME is not set");
    return event;
  }

  await client.send(
    new PutItemCommand({
      TableName: tableName,
      Item: {
        id: { S: attrs.sub }, // Cognito sub
        lineUserId: { S: lineIdentity?.userId ?? "" },
        name: { S: attrs.name ?? "" },
        email: { S: attrs.email ?? "" },
        avatar: { S: attrs.picture ?? "" },
        createdAt: { S: new Date().toISOString() },
      },
    }),
  );

  console.log("✅ LINE user saved to DynamoDB");

  return event;
};
