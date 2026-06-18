import { defineBackend } from "@aws-amplify/backend";
import { auth } from "./auth/resource";
import { data } from "./data/resource";
import { notify } from "./functions/notifyLineUsers/resource";
import { remindKeyDuty } from "./functions/remindKeyDuty/resource";
// import { saveAssignments } from "./functions/saveAssignments/resource";

export default defineBackend({
  auth,
  notify,
  remindKeyDuty,
  data,
});
