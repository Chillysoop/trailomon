/* Integration test against the isolated Sites development database, never production. */
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs/promises');
const base=process.env.REVIEW_HOSTED_PREVIEW || 'http://127.0.0.1:5175';
if(!/^http:\/\/(127\.0\.0\.1|localhost):\d+$/.test(base))throw Error('Hosted QA must use an isolated local preview');
async function run(){
 const b=await chromium.launch({channel:'msedge',headless:true});
 try{
  const c=await b.newContext({viewport:{width:390,height:844},colorScheme:'dark'});
  assert.equal((await c.request.get(base+'/api/responses/plan-1')).status(),401);
  const p=await c.newPage();const errors=[];p.on('pageerror',e=>errors.push(e.message));
  await p.goto(base+'/signin-with-chatgpt?return_to=%2Fplan-1.html');
  await p.waitForFunction(()=>!document.querySelector('#finish')?.disabled&&document.querySelector('#finish'));
  await p.getByLabel('General comments',{exact:true}).fill('LOCAL QA ONLY — phone-size hosted review');
  if(await p.getByRole('button',{name:'YES for P1',exact:true}).getAttribute('aria-pressed')!=='true')await p.getByRole('button',{name:'YES for P1',exact:true}).click();
  if(await p.getByRole('button',{name:'NO for P2',exact:true}).getAttribute('aria-pressed')!=='true')await p.getByRole('button',{name:'NO for P2',exact:true}).click();
  await p.getByLabel('Comment on P3',{exact:true}).fill('Unvoted note survives online storage.');
  await p.getByRole('button',{name:'FINISH',exact:true}).click();
  await p.waitForFunction(()=>document.querySelector('#status').textContent.startsWith('FINISH saved.'));
  const response=await c.request.get(base+'/api/responses/plan-1');assert.equal(response.status(),200);
  const data=await response.json();assert.equal(data.finished,true);assert.equal(data.answers.P1.vote,'yes');assert.equal(data.answers.P2.vote,'no');assert.equal(data.answers.P3.note,'Unvoted note survives online storage.');
  await p.reload();await p.waitForFunction(()=>!document.querySelector('#finish').disabled);
  assert.equal(await p.getByLabel('General comments',{exact:true}).inputValue(),'LOCAL QA ONLY — phone-size hosted review');
  const stale=await c.request.post(base+'/api/responses/plan-1',{data:{...data,revision:0}});assert.equal(stale.status(),409);
  assert.equal(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
  await fs.mkdir('.tools/hosted-review-evidence',{recursive:true});
  await p.screenshot({path:'.tools/hosted-review-evidence/phone-dark.png'});
  // Later unfinished draft must not erase the explicitly submitted snapshot.
  await p.getByLabel('General comments',{exact:true}).fill('LOCAL QA ONLY — later unsubmitted draft');
  await p.waitForFunction(()=>document.querySelector('#status').textContent==='Saved securely online');
  assert.deepEqual(errors,[]);
  console.log('PASS hosted preview: authentication, phone layout, YES/NO, note-only answer, FINISH, online reload, stale-write protection, and later draft. Local DB only.');
  await c.close();
 }finally{await b.close()}
}
run().catch(e=>{console.error(e);process.exitCode=1;});
