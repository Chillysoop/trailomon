/* No external services or credentials. All requests stay on the local server. */
(() => {
  'use strict';
  const PAGE = location.pathname.split('/').pop().replace(/\.html?$/, '') || 'page';
  const API = (location.protocol.startsWith('http') ? '' : 'http://localhost:8765') + '/api/responses/' + PAGE;
  const KEY = 'trailomon-review:v1:' + PAGE;
  const HOSTED = document.documentElement.dataset.hosted === 'true';
  const $ = s => document.querySelector(s);
  const ideas = [...document.querySelectorAll('.idea')];
  let state = {page: PAGE, title: document.title, general: '', general_at: '', answers: {}, finished: false, updated_at: ''};
  let revision = 0, timer, queue = Promise.resolve(), busy = false;
  const clone = x => JSON.parse(JSON.stringify(x));
  const now = () => new Date().toISOString();
  const status = text => { $('#status').textContent = text; };
  function store() { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch { status('Browser storage unavailable. Keep the local server running.'); } }
  function merge(local, remote) {
    const result = {...remote, answers: {...(remote.answers || {})}};
    for (const [code, answer] of Object.entries(local.answers || {})) {
      if (!result.answers[code] || (answer.at || '') >= (result.answers[code].at || '')) result.answers[code] = answer;
    }
    if ((local.general_at || '') >= (remote.general_at || '')) { result.general = local.general || ''; result.general_at = local.general_at || ''; }
    if ((local.updated_at || '') > (remote.updated_at || '')) {
      result.updated_at = local.updated_at; result.finished = local.finished; result.finished_at = local.finished_at || '';
    }
    return {...result, page: PAGE, title: document.title};
  }
  function render() {
    let yes = 0, no = 0, open = 0;
    for (const el of ideas) {
      const a = state.answers[el.dataset.code] || {vote: '', note: ''};
      el.querySelector('.yes').setAttribute('aria-pressed', String(a.vote === 'yes'));
      el.querySelector('.no').setAttribute('aria-pressed', String(a.vote === 'no'));
      const input = el.querySelector('textarea');
      if (document.activeElement !== input) input.value = a.note || '';
      if (a.vote === 'yes') yes++; else if (a.vote === 'no') no++; else open++;
    }
    if (document.activeElement !== $('#general')) $('#general').value = state.general || '';
    $('#tally').textContent = `${yes} yes · ${no} no · ${open} open`;
  }
  function answer(code) { return state.answers[code] ||= {vote: '', note: '', at: ''}; }
  function changed() {
    state.finished = false; state.finished_at = ''; state.updated_at = now();
    store(); render(); status('Saving…'); clearTimeout(timer);
    timer = setTimeout(() => enqueue(false), 350);
  }
  function setVote(code, vote) {
    const a = answer(code); a.vote = a.vote === vote ? '' : vote; a.at = now(); changed();
  }
  function controls(el) {
    const code = el.dataset.code;
    if (el.hasAttribute('data-top')) {
      const badge = document.createElement('span'); badge.className = 'top'; badge.textContent = 'Top pick';
      el.querySelector('h3').append(badge);
    }
    const votes = document.createElement('div'); votes.className = 'vote';
    for (const vote of ['yes', 'no']) {
      const button = document.createElement('button'); button.type = 'button'; button.className = vote;
      button.textContent = vote.toUpperCase(); button.setAttribute('aria-label', `${vote.toUpperCase()} for ${code}`);
      button.setAttribute('aria-pressed', 'false'); button.onclick = () => setVote(code, vote); votes.append(button);
    }
    const label = document.createElement('label'); label.htmlFor = `note-${code}`; label.textContent = `Comment on ${code}`;
    const note = document.createElement('textarea'); note.id = label.htmlFor; note.maxLength = 20000;
    note.oninput = e => { const a = answer(code); a.note = e.target.value; a.at = now(); changed(); };
    el.append(votes, label, note);
  }
  async function request(options) {
    const controller = new AbortController(); const timeout = setTimeout(() => controller.abort(), 4500);
    try { return await fetch(API, {...options, signal: controller.signal}); } finally { clearTimeout(timeout); }
  }
  async function send(payload) {
    try {
      for (let attempt = 0; attempt < 3; attempt++) {
        payload.revision = revision;
        const response = await request({method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload)});
        const data = await response.json();
        if (response.status === 409 && data.current) {
          revision = data.current.revision || 0;
          const finished = payload.finished, finishedAt = payload.finished_at;
          payload = merge(payload, data.current); payload.finished = finished; payload.finished_at = finishedAt;
          state = merge(state, payload); render(); store(); continue;
        }
        if (!response.ok) throw new Error(data.error || 'Save failed');
        revision = data.revision; state.revision = revision; state.saved_at = data.saved_at; store();
        status(payload.finished ? 'FINISH saved. The active agent waiter will receive your answers.' : (HOSTED ? 'Saved securely online' : 'Saved on this computer'));
        document.body.classList.remove('fallback'); return true;
      }
      throw new Error('Another tab is saving; export or try FINISH again.');
    } catch {
      document.body.classList.add('fallback');
      status('Saved in this browser only. FINISH will export a copy if the server is unavailable.'); return false;
    }
  }
  function enqueue(finished) {
    const payload = clone(state); payload.finished = finished;
    queue = queue.then(() => send(payload)); return queue;
  }
  async function exportAnswers() {
    const data = JSON.stringify({...state, page: PAGE}, null, 2);
    let copied = false;
    try { await navigator.clipboard.writeText(`Review answers for ${PAGE}:\n${data}`); copied = true; } catch { /* Download is always offered. */ }
    const link = document.createElement('a'); const url = URL.createObjectURL(new Blob([data], {type: 'application/json'}));
    link.href = url; link.download = `${PAGE}.json`; link.click(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    status(copied ? 'Answers copied and downloaded. Paste them into the agent chat.' : 'Answers downloaded. Attach the JSON or paste its contents into the agent chat. Clipboard access was unavailable.');
  }
  function disable(value) { document.querySelectorAll('button,textarea').forEach(el => { el.disabled = value; }); }
  async function finish() {
    if (busy) return;
    busy = true; clearTimeout(timer); disable(true);
    state.general = $('#general').value; state.finished = true; state.finished_at = now(); state.updated_at = now(); store();
    status('Sending FINISH…');
    try { if (!(await enqueue(true))) await exportAnswers(); } finally { busy = false; disable(false); }
  }
  async function load() {
    disable(true); let local;
    try { local = JSON.parse(localStorage.getItem(KEY)); } catch { /* Optional local storage. */ }
    if (local && local.answers) state = {...state, ...local};
    try {
      const r = await request(); if (!r.ok) throw new Error('Load failed'); const remote = await r.json();
      if (remote.answers) { revision = remote.revision || 0; state = merge(state, remote); }
      status(state.finished ? 'Previously finished. Edit answers and press FINISH to send an update.' : 'Ready. Changes save automatically.');
    } catch { status('Server unavailable. Answers stay in this browser; FINISH exports a copy.'); document.body.classList.add('fallback'); }
    state.page = PAGE; state.title = document.title; store(); render(); disable(false);
  }
  ideas.forEach(controls);
  $('#general').oninput = e => { state.general = e.target.value; state.general_at = now(); changed(); };
  $('#allTop').onclick = () => { for (const el of ideas.filter(el => el.hasAttribute('data-top'))) Object.assign(answer(el.dataset.code), {vote: 'yes', at: now()}); changed(); };
  $('#finish').onclick = finish; $('#export').onclick = exportAnswers;
  new ResizeObserver(() => { document.body.style.paddingBottom = `${$('.bar').getBoundingClientRect().height + 28}px`; }).observe($('.bar'));
  window.addEventListener('pagehide', store);
  load();
})();
