const LINE_TOKEN = process.env.LINE_CHANNEL_ACCESS_TOKEN!;

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

    const assignments = Array.isArray(parsed) ? parsed : parsed.items;

    if (!Array.isArray(assignments)) {
      throw new Error(
        `assignments must be an array: ${JSON.stringify(parsed)}`,
      );
    }

    // memberId ごとに重複を除く
    const uniqueMembers = new Map<
      string,
      {
        memberName: string;
      }
    >();

    for (const item of assignments) {
      if (!item.memberId || !item.memberName) {
        throw new Error(`Invalid assignment item: ${JSON.stringify(item)}`);
      }

      if (!uniqueMembers.has(item.memberId)) {
        uniqueMembers.set(item.memberId, {
          memberName: item.memberName,
        });
      }
    }

    // 各メンバーに1通だけ送る
    for (const [memberId, member] of uniqueMembers.entries()) {
      const lineResponse = await fetch(
        "https://api.line.me/v2/bot/message/push",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${LINE_TOKEN}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            to: memberId,
            messages: [
              {
                type: "text",
                text: `${member.memberName}さん\n\n📅 スケジュールが確定しました。\nアプリで担当日をご確認ください。`,
              },
            ],
          }),
        },
      );

      const lineBody = await lineResponse.text();

      if (!lineResponse.ok) {
        throw new Error(`LINE push failed: ${lineResponse.status} ${lineBody}`);
      }
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
