/* Export the authored PC review as a standalone reading copy and printable PDF.
   NODE_PATH may point to the installed Playwright bundle. No owner answers are read. */
const fs=require('node:fs/promises');
const path=require('node:path');
const {pathToFileURL}=require('node:url');
const {chromium}=require('playwright');
const root=path.resolve(__dirname,'..');
const stem='Trailomon-Integrated-Plan-2026-11-04';
async function main(){
 const output=path.join(root,'output/pdf');
 const downloads=path.join(root,'reviews/downloads');
 await fs.mkdir(output,{recursive:true});await fs.mkdir(downloads,{recursive:true});
 let html=await fs.readFile(path.join(root,'reviews/integration-2.html'),'utf8');
 const css=await fs.readFile(path.join(root,'reviews/review.css'),'utf8');
 html=html.replace('<link rel="stylesheet" href="review.css">','<style>'+css+'</style>')
  .replace('<script src="review.js" defer></script>','')
  .replace(/<section class="general">[\s\S]*?<\/section>/,'')
  .replace(/<div class="downloads">[\s\S]*?<\/div>/,'')
  .replace(/<footer class="bar">[\s\S]*?<\/footer>/,'')
  .replace('The combat, growth, recovery, collecting and sheet work above was already requested. These two proposals choose how deeper wagon/cargo systems should work.','These two proposals are unresolved in this dated planning snapshot. Submit decisions in the live PC review; this reading copy does not collect answers.');
 html=html.replace('A creature-collecting expedition built around automatic wagon defense.','Offline reading copy - November 4, 2026. A creature-collecting expedition built around automatic wagon defense.');
 const images=[...new Set([...html.matchAll(/(?:src|href)="(evidence\/integration-2\/[^\"]+\.png)"/g)].map(m=>m[1]))];
 for(const image of images){const data=await fs.readFile(path.join(root,'reviews',image));html=html.split('"'+image+'"').join('"data:image/png;base64,'+data.toString('base64')+'"')}
 html=html.replaceAll('\u2011','-').replaceAll('\u2013','-').replaceAll('\u2014','-');
 html=html.replace('</head>',`<style>
 body{padding-bottom:30px}.print-note{font-size:14px;color:var(--muted)}
 @media print{
 :root{color-scheme:light;--bg:#fff;--paper:#fff;--ink:#243c34;--muted:#52645a;--rule:#bdc7b9;--accent:#85541c}
 body{padding:0;background:white;font-size:10pt;line-height:1.42}main{max-width:none}h1{font-size:30pt}h2{font-size:19pt;margin-top:18pt}h3{font-size:13pt}h4{font-size:11pt}
 h1,h2,h3,h4,summary{break-after:avoid}p{orphans:3;widows:3}nav{display:none}
 .general,.bar,.downloads{display:none}details{border:0;padding:8pt 0}summary{font-size:16pt;list-style:none}summary::marker{display:none}.doc{break-before:page}.doc>summary{display:none}
 .doc h2{font-size:24pt}.doc h3{font-size:16pt;margin-top:18pt}.doc h4{font-size:12pt}
 table{font-size:8pt;line-height:1.35;table-layout:fixed}td,th{min-width:0;padding:5pt;overflow-wrap:anywhere}table{break-inside:avoid}thead{display:table-header-group}#roadmap-doc table th:first-child{width:6%}#roadmap-doc table th:nth-child(2){width:24%}#roadmap-doc table th:nth-child(3){width:30%}#roadmap-doc table th:nth-child(4){width:30%}#roadmap-doc table th:last-child{width:10%}tr{break-inside:avoid}.table-wrap{overflow:visible;margin:10pt 0}
 .loop{grid-template-columns:repeat(3,1fr);break-inside:avoid}.loop section{padding:9pt}.loop h3{font-size:14pt}.loop p{font-size:9pt}.loop b{font-size:7pt}.connection{font-size:8pt}
 .two{gap:14pt}.layout{font-size:8pt;break-inside:avoid}.layout>div{padding:6pt}.layout .world{min-height:80px}.layout .party span{padding:5pt 2pt}.evidence-grid{break-inside:avoid}figure{break-inside:avoid}.caption,figcaption{font-size:8pt}
 .idea{break-inside:avoid;padding:12pt 0}.evidence,.cost,.lede{font-size:9pt}.notice{break-inside:avoid;margin:12pt 0}.subnav{display:none}a{color:inherit}code{font-size:8pt}
 }
 </style></head>`);
 const htmlPath=path.join(output,stem+'.html');await fs.writeFile(htmlPath,html);
 const browser=await chromium.launch({headless:true,channel:process.env.REVIEW_BROWSER==='chromium'?undefined:'msedge'});
 try{
  const page=await browser.newPage({viewport:{width:1280,height:900},colorScheme:'light'});
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(pathToFileURL(htmlPath).href);await page.evaluate(()=>document.querySelectorAll('details').forEach(el=>{const section=document.createElement('section');for(const a of el.attributes)section.setAttribute(a.name,a.value);section.innerHTML=el.innerHTML;el.replaceWith(section)}));
  await page.evaluate(()=>Promise.all([...document.images].map(i=>i.decode())));
  if(errors.length)throw new Error(errors.join('\n'));
  await page.pdf({path:path.join(output,stem+'.pdf'),format:'A4',printBackground:true,displayHeaderFooter:true,margin:{top:'15mm',bottom:'18mm',left:'15mm',right:'15mm'},headerTemplate:'<div></div>',footerTemplate:'<div style="font-size:8px;width:100%;margin:0 15mm;color:#52645a;display:flex;justify-content:space-between"><span>TRAILOMON / INTEGRATED PLAN / 2026-11-04</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>',outline:true,tagged:true});
 }finally{await browser.close()}
 for(const ext of ['pdf','html'])await fs.copyFile(path.join(output,stem+'.'+ext),path.join(downloads,stem+'.'+ext));
 console.log(JSON.stringify({pdf:path.join(output,stem+'.pdf'),html:htmlPath}));
}
main().catch(e=>{console.error(e);process.exitCode=1});
