import { env } from "cloudflare:workers";
import { getChatGPTUser } from "../../../chatgpt-auth";

export const dynamic = "force-dynamic";
type Context = {params: Promise<{page: string}>};
const reply = (value: unknown, status = 200) => Response.json(value, {status, headers: {"Cache-Control": "no-store"}});
const validPage = (page: string) => /^[a-z0-9][a-z0-9_-]{0,79}$/.test(page);

async function existing(db: D1Database, page: string, userId: string) {
  const row = await db.prepare("SELECT user_id, payload FROM review_responses WHERE page = ?").bind(page).first<{user_id:string; payload:string}>();
  if (row && row.user_id !== userId) return null;
  return row ? JSON.parse(row.payload) : {};
}

export async function GET(_request: Request, context: Context) {
  const user = await getChatGPTUser();
  if (!user) return reply({error: "Sign in with ChatGPT to read your review"}, 401);
  const {page} = await context.params;
  if (!validPage(page)) return reply({error:"Invalid page"}, 400);
  if (!env.DB) return reply({error:"Review storage unavailable"}, 503);
  const data = await existing(env.DB, page, user.userId);
  return data === null ? reply({error:"This review belongs to another account"}, 403) : reply(data);
}

export async function POST(request: Request, context: Context) {
  const user = await getChatGPTUser();
  if (!user) return reply({error:"Sign in with ChatGPT to save your review"}, 401);
  const origin = request.headers.get("Origin");
  if (origin && origin !== new URL(request.url).origin) return reply({error:"Invalid origin"}, 403);
  const {page} = await context.params;
  if (!validPage(page)) return reply({error:"Invalid page"}, 400);
  const db = env.DB;
  if (!db) return reply({error:"Review storage unavailable"}, 503);
  let data: Record<string, any>;
  try {
    const raw = await request.text();
    if (raw.length > 262144) return reply({error:"Answers are too large"}, 413);
    data = JSON.parse(raw);
    if (!data || typeof data !== "object" || Array.isArray(data)) throw Error();
    if (!data.answers || typeof data.answers !== "object" || Array.isArray(data.answers)) throw Error();
    if (Object.keys(data.answers).length > 100) throw Error();
    for (const value of Object.values(data.answers) as any[]) {
      if (!value || !["", "yes", "no"].includes(value.vote || "") || typeof (value.note || "") !== "string" || (value.note || "").length > 20000 || typeof (value.at || "") !== "string") throw Error();
    }
    if (!Object.keys(data.answers).every(code => /^[A-Z][A-Z0-9_-]{0,39}$/.test(code))) throw Error();
    for (const key of ["general", "title", "updated_at", "general_at", "finished_at"]) if (data[key] !== undefined && (typeof data[key] !== "string" || data[key].length > 20000)) throw Error();
    if (typeof data.finished !== "boolean" || !Number.isSafeInteger(data.revision || 0) || (data.revision || 0) < 0) throw Error();
  } catch { return reply({error:"Invalid answers; your previous answers were preserved"}, 400); }
  const current = await existing(db, page, user.userId);
  if (current === null) return reply({error:"This review belongs to another account"}, 403);
  const expected = data.revision || 0;
  if (expected !== (current.revision || 0)) return reply({error:"Newer answers exist", current}, 409);
  const savedAt = new Date().toISOString(), writeId = crypto.randomUUID();
  data = {page, title:data.title || "", general:data.general || "", general_at:data.general_at || "", answers:data.answers,
    finished:data.finished, finished_at:data.finished ? (data.finished_at || savedAt) : "", updated_at:data.updated_at || savedAt,
    saved_at:savedAt, revision:expected + 1};
  const payload = JSON.stringify(data);
  const statements = [db.prepare(`INSERT INTO review_responses (page,user_id,revision,write_id,payload,saved_at) VALUES (?,?,?,?,?,?)
    ON CONFLICT(page) DO UPDATE SET revision=excluded.revision,write_id=excluded.write_id,payload=excluded.payload,saved_at=excluded.saved_at
    WHERE review_responses.user_id=excluded.user_id AND review_responses.revision=?`)
    .bind(page,user.userId,expected+1,writeId,payload,savedAt,expected)];
  if (data.finished) {
    statements.push(db.prepare("DELETE FROM review_submissions WHERE page=? AND EXISTS (SELECT 1 FROM review_responses WHERE page=? AND write_id=?)").bind(page,page,writeId));
    // Split by Unicode code points so a chunk never separates a surrogate pair.
    const chars = Array.from(payload), count = Math.ceil(chars.length / 1000);
    for (let part = 0; part < count; part++) {
      statements.push(db.prepare(`INSERT INTO review_submissions (page,revision,part,parts,payload_chunk,finished_at)
        SELECT ?,?,?,?,?,? WHERE EXISTS (SELECT 1 FROM review_responses WHERE page=? AND write_id=?)`)
        .bind(page,expected+1,part,count,chars.slice(part*1000,(part+1)*1000).join(""),data.finished_at,page,writeId));
    }
  }
  const result = await db.batch(statements);
  if (!result[0].meta.changes) return reply({error:"Newer answers exist", current:await existing(db,page,user.userId)},409);
  return reply({ok:true,revision:expected+1,saved_at:savedAt});
}
