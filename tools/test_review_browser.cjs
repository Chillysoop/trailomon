/* Run with Node and Playwright (package location may be supplied by NODE_PATH).
   Uses installed Edge by default. Every test response is isolated from reviews/.
   Set REVIEW_BROWSER=chromium for a Playwright-managed browser on another OS. */
const {chromium} = require('playwright');
const fs = require('node:fs/promises');
const path = require('node:path');
const {spawn} = require('node:child_process');
const assert = require('node:assert/strict');
const repo = path.resolve(__dirname, '..');
const python = process.env.REVIEW_PYTHON || 'python';
const root = path.join(repo, '.tools', 'review-browser-' + Date.now());
const port = Number(process.env.REVIEW_TEST_PORT || 18765);
const url = `http://127.0.0.1:${port}`;
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
async function eventually(fn) {
  let error;
  for (let i = 0; i < 60; i++) { try { return await fn(); } catch(e) { error = e; await delay(100); } }
  throw error;
}
async function run() {
  await fs.mkdir(root, {recursive: true});
  for (const name of ['review.css','review.js']) await fs.copyFile(path.join(repo,'reviews',name),path.join(root,name));
  const template = await fs.readFile(path.join(repo,'reviews','_template.html'),'utf8');
  const third = '<section class="idea" data-code="X3" data-top><h3>X3 Note only</h3></section>';
  await fs.writeFile(path.join(root,'fixture.html'),template.replace('</main>',third + '</main>'));
  const server = spawn(python,[path.join(repo,'tools','review_server.py'),'--root',root,'--port',String(port)],{windowsHide:true});
  let serverError=''; server.stderr.on('data', data=>serverError+=data.toString());
  let browser;
  try {
    await eventually(async()=>{ const r=await fetch(url+'/api/health'); const d=await r.json(); assert.equal(path.resolve(d.root),root); });
    browser=await chromium.launch({headless:true,...(process.env.REVIEW_BROWSER==='chromium'?{}:{channel:'msedge'})});
    const context=await browser.newContext({viewport:{width:1280,height:900},colorScheme:'light',acceptDownloads:true});
    const page=await context.newPage(); const errors=[]; let offline=false;
    page.on('pageerror',e=>errors.push(e.message));
    page.on('console',message=>{if(message.type()==='error'&&!offline)errors.push(message.text());});
    await page.goto(url+'/fixture.html'); await page.waitForFunction(()=>!document.querySelector('#finish').disabled);
    await page.getByLabel('General comments',{exact:true}).fill('Browser integration test only');
    await page.getByRole('button',{name:'YES for X1',exact:true}).click();
    await page.getByRole('button',{name:'NO for X2',exact:true}).click();
    await page.getByLabel('Comment on X3',{exact:true}).fill('Note without a vote');
    const read=async()=>JSON.parse(await fs.readFile(path.join(root,'responses','fixture.json'),'utf8'));
    await eventually(async()=>{const d=await read();assert.equal(d.answers.X3.note,'Note without a vote');assert.equal(d.finished,false);});
    await page.reload(); await page.waitForFunction(()=>!document.querySelector('#finish').disabled);
    assert.equal(await page.getByRole('button',{name:'YES for X1',exact:true}).getAttribute('aria-pressed'),'true');
    assert.equal(await page.getByLabel('Comment on X3',{exact:true}).inputValue(),'Note without a vote');
    // Finish immediately after typing: a delayed autosave must not undo submission.
    await page.getByLabel('General comments',{exact:true}).fill('Final note immediately before FINISH');
    const waiter=spawn(python,[path.join(repo,'tools','review_server.py'),'--root',root,'--wait','fixture','--timeout','15'],{windowsHide:true});
    let output=''; waiter.stdout.on('data',data=>output+=data.toString());
    const waited=new Promise((resolve,reject)=>{waiter.on('exit',code=>code===0?resolve():reject(new Error('wait exit '+code)));waiter.on('error',reject);});
    await page.getByRole('button',{name:'FINISH',exact:true}).click(); await waited; await delay(600);
    const finished=await read(); assert.equal(finished.finished,true); assert.equal(JSON.parse(output).general,'Final note immediately before FINISH');
    assert.equal(JSON.parse(output).answers.X2.vote,'no');
    assert.equal(await fs.stat(path.join(root,'responses','fixture.finished')).then(()=>true,()=>false),false);
    await page.getByRole('button',{name:'Yes to all top picks',exact:true}).click();
    assert.equal(await page.getByRole('button',{name:'YES for X3',exact:true}).getAttribute('aria-pressed'),'true');
    assert.equal(await page.getByRole('button',{name:'NO for X2',exact:true}).getAttribute('aria-pressed'),'true');
    await page.screenshot({path:path.join(root,'desktop-light.png'),fullPage:true});
    await page.setViewportSize({width:390,height:844}); await page.emulateMedia({colorScheme:'dark'});
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
    await page.screenshot({path:path.join(root,'phone-dark.png'),fullPage:true});
    // API outage: browser storage, downloadable JSON, and truthful clipboard status.
    assert.deepEqual(errors,[]); offline=true;
    await page.route('**/api/responses/**',route=>route.abort());
    await page.getByLabel('Comment on X2',{exact:true}).fill('Offline note');
    const downloadPromise=page.waitForEvent('download');
    await page.getByRole('button',{name:'FINISH',exact:true}).click();
    const download=await downloadPromise; const file=path.join(root,'fallback.json'); await download.saveAs(file);
    const fallback=JSON.parse(await fs.readFile(file,'utf8')); assert.equal(fallback.page,'fixture');assert.equal(fallback.finished,true);assert.equal(fallback.answers.X2.note,'Offline note');
    await page.reload();await page.waitForFunction(()=>!document.querySelector('#finish').disabled);
    assert.equal(await page.getByLabel('Comment on X2',{exact:true}).inputValue(),'Offline note');
    assert.deepEqual(errors,[]);
    console.log('PASS browser: YES/NO, note-only answer, autosave/reload, FINISH race, waiter, top picks, phone/dark layout, offline download and restore.');
    console.log('Evidence: '+root);
    await context.close();
  } finally { if(browser)await browser.close();server.kill();if(serverError)process.stderr.write(serverError); }
}
run().catch(error=>{console.error(error);process.exitCode=1;});
