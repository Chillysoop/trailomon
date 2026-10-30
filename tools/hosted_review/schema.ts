import { integer, sqliteTable, text, primaryKey } from "drizzle-orm/sqlite-core";

export const reviewResponses = sqliteTable("review_responses", {
  page: text("page").primaryKey(),
  userId: text("user_id").notNull(),
  revision: integer("revision").notNull().default(0),
  writeId: text("write_id").notNull(),
  payload: text("payload").notNull(),
  savedAt: text("saved_at").notNull(),
});

// Small cells keep complete submissions readable through bounded agent tools.
// Draft autosaves do not replace the last explicitly finished submission.
export const reviewSubmissions = sqliteTable("review_submissions", {
  page: text("page").notNull(),
  revision: integer("revision").notNull(),
  part: integer("part").notNull(),
  parts: integer("parts").notNull(),
  payloadChunk: text("payload_chunk").notNull(),
  finishedAt: text("finished_at").notNull(),
}, table => [primaryKey({columns: [table.page, table.part]})]);
