const LINE_TOKEN = process.env.LINE_CHANNEL_ACCESS_TOKEN!;

type AssignmentNotification = {
  date: string;
  memberId: string;
  memberName: string;
};

type ChangeNotification = AssignmentNotification & {
  previousMemberId?: string;
  previousMemberName?: string;
};

export const handler = async (event: any) => {
  console.log("event:", JSON.stringify(event, null, 2));

  try {
    if (!LINE_TOKEN) {
      throw new Error("LINE_CHANNEL_ACCESS_TOKEN is missing");
    }

    const rawAssignments = event.arguments?.assignments;

    if (!rawAssignments) {
      throw new Error("assignments is missing");
    }

    const parsed =
      typeof rawAssignments === "string"
        ? JSON.parse(rawAssignments)
        : rawAssignments;

    const notificationType = parsed.type ?? "finalized";
    const assignments = Array.isArray(parsed) ? parsed : parsed.items;
    console.log("type:", notificationType);
    console.log("assignments:", JSON.stringify(assignments, null, 2));

    if (!Array.isArray(assignments)) {
      throw new Error(
        `assignments must be an array: ${JSON.stringify(parsed)}`,
      );
    }

    if (notificationType === "changed") {
      await notifyChangedAssignments(assignments);

      return {
        success: true,
        type: notificationType,
        assignmentCount: assignments.length,
      };
    }

    const uniqueMembers = new Map<string, { memberName: string }>();

    for (const item of assignments as AssignmentNotification[]) {
      if (!item.memberId || !item.memberName) {
        throw new Error(`Invalid assignment item: ${JSON.stringify(item)}`);
      }

      if (!uniqueMembers.has(item.memberId)) {
        uniqueMembers.set(item.memberId, {
          memberName: item.memberName,
        });
      }
    }

    for (const [memberId, member] of uniqueMembers.entries()) {
      console.log(`Sending LINE message to ${member.memberName}: ${memberId}`);

      await pushLineMessage(
        memberId,
        `${member.memberName}さん\n\n📅 スケジュールが確定しました。\nアプリで担当日をご確認ください。`,
      );
    }

    return {
      success: true,
      sentCount: uniqueMembers.size,
      assignmentCount: assignments.length,
    };
  } catch (e) {
    console.error("notifyLineUsers error:", e);
    throw e;
  }
};

const notifyChangedAssignments = async (changes: ChangeNotification[]) => {
  const messagesByMemberId = new Map<string, string[]>();

  for (const change of changes) {
    if (!change.date || !change.memberId || !change.memberName) {
      throw new Error(`Invalid change item: ${JSON.stringify(change)}`);
    }

    const previousMemberName = change.previousMemberName ?? "未設定";
    const message = `🔄 鍵当番のスケジュールが変更されました。\n\n${change.date}\n変更前: ${previousMemberName}さん\n変更後: ${change.memberName}さん`;

    if (change.previousMemberId) {
      const messages = messagesByMemberId.get(change.previousMemberId) ?? [];
      messages.push(message);
      messagesByMemberId.set(change.previousMemberId, messages);
    }

    const newMessages = messagesByMemberId.get(change.memberId) ?? [];
    newMessages.push(message);
    messagesByMemberId.set(change.memberId, newMessages);
  }

  for (const [memberId, messages] of messagesByMemberId.entries()) {
    await pushLineMessage(memberId, messages.join("\n\n---\n\n"));
  }
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
