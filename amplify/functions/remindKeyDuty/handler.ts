import { Amplify } from "aws-amplify";
import { generateClient } from "aws-amplify/data";
import { getAmplifyDataClientConfig } from "@aws-amplify/backend/function/runtime";
import { env } from "$amplify/env/remindKeyDuty";
import type { Schema } from "../../data/resource";

const LINE_TOKEN = process.env.LINE_CHANNEL_ACCESS_TOKEN!;

const { resourceConfig, libraryOptions } =
  await getAmplifyDataClientConfig(env);

Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

export const handler = async () => {
  if (!LINE_TOKEN) {
    throw new Error("LINE_CHANNEL_ACCESS_TOKEN is missing");
  }

  const tomorrow = getTomorrowInJapan();
  console.log(`Searching assignments for ${tomorrow}`);

  const { data: assignments, errors } = await client.models.Assignment.list({
    filter: {
      date: {
        eq: tomorrow,
      },
    },
  });

  if (errors?.length) {
    throw new Error(errors.map((error) => error.message).join(", "));
  }

  for (const assignment of assignments ?? []) {
    await pushLineMessage(
      assignment.memberId,
      `${assignment.memberName}さん\n\n🔔 明日は鍵当番です。\n日付: ${assignment.date}\nよろしくお願いします。`,
    );
  }

  return {
    success: true,
    date: tomorrow,
    sentCount: assignments?.length ?? 0,
  };
};

const getTomorrowInJapan = () => {
  const now = new Date();
  const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(tomorrow);

  const year = parts.find((part) => part.type === "year")?.value;
  const month = parts.find((part) => part.type === "month")?.value;
  const day = parts.find((part) => part.type === "day")?.value;

  if (!year || !month || !day) {
    throw new Error("Failed to calculate tomorrow in Asia/Tokyo");
  }

  return `${year}-${month}-${day}`;
};

const pushLineMessage = async (to: string, text: string) => {
  const lineResponse = await fetch("https://api.line.me/v2/bot/message/push", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${LINE_TOKEN}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      to,
      messages: [
        {
          type: "text",
          text,
        },
      ],
    }),
  });

  const lineBody = await lineResponse.text();

  console.log(`LINE response for ${to}: ${lineResponse.status} ${lineBody}`);

  if (!lineResponse.ok) {
    throw new Error(`LINE push failed: ${lineResponse.status} ${lineBody}`);
  }
};
