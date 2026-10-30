"""Copy the shared review UI and authored backend into the dedicated Sites checkout."""
import argparse
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument("checkout", type=Path)
args = parser.parse_args()
checkout = args.checkout.resolve()
if not checkout.is_relative_to(ROOT / ".tools"):
    raise SystemExit("Use the dedicated checkout inside this repository's .tools folder")
manifest_file = checkout / ".openai/hosting.json"
manifest = json.loads(manifest_file.read_text(encoding="utf-8"))
if not manifest.get("project_id"):
    raise SystemExit("Register and persist the Site identity before synchronizing")
manifest["d1"] = "DB"
manifest_file.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
public = checkout / "public"
public.mkdir(exist_ok=True)
for name in ("review.js", "review.css"):
    shutil.copyfile(ROOT / "reviews" / name, public / name)
for page in (ROOT / "reviews").glob("*.html"):
    if page.name.startswith("_"):
        continue
    content = page.read_text(encoding="utf-8").replace('<html lang="en">', '<html lang="en" data-hosted="true">')
    content = content.replace("Your answers stay on this computer; if the server is unavailable, FINISH downloads them and attempts to copy them for pasting.", "Your answers are saved privately to your signed-in ChatGPT account. FINISH submits them for the active agent to read. If you are offline, FINISH downloads a copy and attempts clipboard export.")
    (public / page.name).write_text(content, encoding="utf-8")
api = checkout / "app/api/responses/[page]"
api.mkdir(parents=True, exist_ok=True)
shutil.copyfile(ROOT / "tools/hosted_review/route.ts", api / "route.ts")
shutil.copyfile(ROOT / "tools/hosted_review/schema.ts", checkout / "db/schema.ts")
(checkout / "app/page.tsx").write_text('import { redirect } from "next/navigation";\nexport default function Page(){redirect("/plan-1.html");}\n', encoding="utf-8")
(checkout / "app/layout.tsx").write_text('import type { Metadata } from "next";\nexport const metadata: Metadata = {title:"Trailomon owner reviews", description:"Private expedition design reviews"};\nexport default function Layout({children}:{children:React.ReactNode}) {return <html lang="en"><body>{children}</body></html>;}\n', encoding="utf-8")
print("Shared review UI and private storage routes synchronized; Site identity preserved.")
