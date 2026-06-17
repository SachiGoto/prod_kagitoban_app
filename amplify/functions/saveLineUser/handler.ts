import { Amplify } from "aws-amplify";
import { generateClient } from "aws-amplify/data";
import { getAmplifyDataClientConfig } from "@aws-amplify/backend/function/runtime";
import { env } from "$amplify/env/saveLineUser";
import type { Schema } from "../../data/resource";

const { resourceConfig, libraryOptions } =
  await getAmplifyDataClientConfig(env);

Amplify.configure(resourceConfig, libraryOptions);

const client = generateClient<Schema>();

export const handler = async (event: any) => {
  const attrs = event.request.userAttributes;
  const identities = attrs.identities ? JSON.parse(attrs.identities) : [];
  const lineIdentity = identities.find((i: any) => i.providerName === "LINE");
  const id = lineIdentity?.userId ?? attrs.sub;

  if (!id) {
    throw new Error("LINE user ID and Cognito sub are both missing");
  }

  const input = {
    id,
    name: attrs.preferred_username ?? attrs.name ?? "",
    email: attrs.email ?? "",
    avatar: attrs.picture ?? "",
  };

  const { data: existing, errors: getErrors } =
    await client.models.LineUser.get({ id });

  if (getErrors?.length) {
    throw new Error(getErrors.map((error) => error.message).join(", "));
  }

  const result = existing
    ? await client.models.LineUser.update(input)
    : await client.models.LineUser.create(input);

  if (result.errors?.length) {
    throw new Error(result.errors.map((error) => error.message).join(", "));
  }

  console.log(`LINE user ${existing ? "updated" : "created"}: ${id}`);

  return event;
};
