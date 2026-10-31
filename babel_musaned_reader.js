
/*
 * Babel Riyadh — Musaned PDF import (Flutter Web, entirely in the browser).
 * Content-first OCR: discover labels and nearby values, not fixed page numbers
 * or fixed crop coordinates. The source PDF is never uploaded or stored.
 * Compatible with babelMusanedAnalyze(File) -> Promise<{field: string}>.
 * OCR cannot guarantee accuracy. The Flutter review dialog remains mandatory.
 */
(() => {
  'use strict';

  const localUrl = (path) => new URL(path, document.baseURI).href;
  const AR_DIGITS = '٠١٢٣٤٥٦٧٨٩';
  const FA_DIGITS = '۰۱۲۳۴۵۶۷۸۹';
  const MAX_PAGES = 18;
  const MAX_FILE_SIZE = 25 * 1024 * 1024;
  const VALID_KEYS = [
    'contractNumber', 'visaNumber', 'contractDate', 'sponsorName',
    'sponsorIDNumber', 'sponsorPhoneNumber', 'salary', 'contractType',
    'musanidPayment', 'religion', 'experienced'
  ];

  function normalize(value) {
    return String(value ?? '')
      .replace(/[٠-٩]/g, (c) => String(AR_DIGITS.indexOf(c)))
      .replace(/[۰-۹]/g, (c) => String(FA_DIGITS.indexOf(c)))
      .replace(/[\u200e\u200f\u202a-\u202e\u2066-\u2069\u0640]/g, '')
      .replace(/[\u064b-\u065f\u0670]/g, '')
      .replace(/[إأآٱ]/g, 'ا').replace(/ى/g, 'ي').replace(/ة/g, 'ه')
      .replace(/[\u00a0\t]+/g, ' ').replace(/ +/g, ' ').trim();
  }

  const digits = (s) => normalize(s).replace(/[^\d]/g, '');
  const between = (v, a, b) => v >= a && v <= b;
  const box = (x, y, width, height) => ({
    x, y, w: width, h: height, cx: x + width / 2, cy: y + height / 2
  });
  const hasGeometry = (a) => a && Number.isFinite(a.cy);

  function regexTest(type, text) {
    const t = normalize(text).toLowerCase();
    switch (type) {
      case 'contractNumber':
        return /رقم\s*(?:ال)?عقد|contract\s*(?:number|no\.?)/i.test(t);
      case 'visaNumber':
        return /رقم\s*(?:ال)?تاشير[هه]|visa\s*(?:number|no\.?)/i.test(t);
      case 'sponsorIDNumber':
        return /رقم\s*(?:ال)?هوي[هه]|identity\s*(?:number|no\.?)/i.test(t);
      case 'sponsorPhoneNumber':
        return /رقم\s*(?:ال)?جوال|(?:رقم\s*)?(?:ال)?هاتف\s*(?:المتحرك)?|رقم\s*(?:ال)?اتصال|mobile\s*(?:number|no\.?)/i.test(t);
      case 'sponsorName':
        return /اسم\s*صاحب\s*العمل|اسم\s*الطرف\s*الثاني|domestic\s*(?:employer\s*)?(?:names?|employer)|employer\s*names?/i.test(t);
      case 'salary':
        return /(?:ال)?اجر\s*(?:ال)?شهري|(?:ال)?راتب\s*(?:ال)?شهري|monthly\s*(?:wage|salary)/i.test(t);
      case 'musanidPayment':
        return /اجمالي\s*تكلف[هه]\s*الاستقدام|total\s*(?:recruitment\s*)?(?:cost|fee)/i.test(t);
      case 'contractDate':
        return /الموافق|تم\s*الاتفاق|حرر\s*(?:هذا\s*)?العقد|contract\s*date/i.test(t);
      case 'religion':
        return /(?:ال)?ديان[هه]|religion/i.test(t);
      case 'experienced':
        return /(?:ال)?خبر[هه]\s*العملي[هه]|work\s*experience|الخبر[هه]\s*السابق[هه]/i.test(t);
      default: return false;
    }
  }

  // TSV is requested explicitly, since v5.x of Tesseract.js no longer
  // guarantees data.words / data.lines in its default output.
  function tsvLines(tsv, width, height) {
    if (!tsv || typeof tsv !== 'string') return [];
    const groups = new Map();
    for (const record of tsv.split(/\r?\n/).slice(1)) {
      const cols = record.split('\t');
      if (cols.length < 12 || cols[0] !== '5') continue;
      const text = cols.slice(11).join('\t').trim();
      const conf = Number(cols[10]);
      if (!text || conf < 0) continue;
      const x = Number(cols[6]), y = Number(cols[7]);
      const w = Number(cols[8]), h = Number(cols[9]);
      if (![x, y, w, h].every(Number.isFinite) || w <= 0 || h <= 0) continue;
      const id = cols.slice(1, 5).join(':');
      if (!groups.has(id)) groups.set(id, []);
      groups.get(id).push({text, conf, order: Number(cols[5]), ...box(x / width, y / height, w / width, h / height)});
    }
    const lines = [];
    for (const words of groups.values()) {
      words.sort((a, b) => a.order - b.order);
      const x = Math.min(...words.map((w) => w.x));
      const y = Math.min(...words.map((w) => w.y));
      const right = Math.max(...words.map((w) => w.x + w.w));
      const bottom = Math.max(...words.map((w) => w.y + w.h));
      lines.push({text: words.map((w) => w.text).join(' '),
        conf: words.reduce((s, w) => s + w.conf, 0) / words.length,
        ...box(x, y, right - x, bottom - y)});
    }
    return lines.sort((a, b) => a.cy - b.cy || b.x - a.x);
  }

  function textContentLines(content, page) {
    const view = page.view;
    const left = view[0], bottom = view[1];
    const pw = view[2] - view[0], ph = view[3] - view[1];
    const items = [];
    for (const item of content.items || []) {
      if (!item.str || !item.str.trim() || !item.transform) continue;
      const x = (item.transform[4] - left) / pw;
      const y = 1 - (item.transform[5] - bottom) / ph;
      const w = Math.max(0.001, (item.width || 5) / pw);
      const h = Math.max(0.006, (item.height || 9) / ph);
      items.push({text: item.str, conf: 99, ...box(x, y - h, w, h)});
    }
    items.sort((a, b) => a.cy - b.cy || b.x - a.x);
    const rows = [];
    for (const item of items) {
      let row = rows.find((r) => Math.abs(r.cy - item.cy) < Math.max(0.005, item.h * 0.5));
      if (!row) {row = {cy:item.cy, parts:[]}; rows.push(row);}
      row.parts.push(item);
    }
    return rows.map((r) => {
      r.parts.sort((a, b) => b.x - a.x);
      const x = Math.min(...r.parts.map((i) => i.x));
      const y = Math.min(...r.parts.map((i) => i.y));
      const right = Math.max(...r.parts.map((i) => i.x + i.w));
      const low = Math.max(...r.parts.map((i) => i.y + i.h));
      return {text:r.parts.map((i) => i.text).join(' '), conf:99,
        ...box(x,y,right-x,low-y)};
    });
  }

  function linesFromOcr(data, width, height) {
    let result = tsvLines(data.tsv, width, height);
    if (result.length) return result;
    // Fallback for installations that omit TSV; parsing stays label-driven,
    // but proximity is unavailable and only strict inline values are accepted.
    result = String(data.text || '').split(/\r?\n/).map((text) => ({text:text.trim(), conf:60}))
      .filter((line) => line.text);
    return result;
  }

  function numberCandidates(line, size) {
    const src = normalize(line).replace(/(?<=\d)[Oo](?=\d)/g, '0');
    const values = src.match(/\d+/g) || [];
    return [...new Set(values.filter((v) => v.length === size))];
  }

  function phoneCandidates(input) {
    const t = normalize(input).replace(/[\s()\-]/g, '');
    const hits = t.match(/(?:\+?966|0)?5\d{8}(?!\d)/g) || [];
    return [...new Set(hits.map((v) => {
      const d = digits(v);
      if (/^9665\d{8}$/.test(d)) return d;
      if (/^05\d{8}$/.test(d)) return `966${d.slice(1)}`;
      if (/^5\d{8}$/.test(d)) return `966${d}`;
      return null;
    }).filter(Boolean))];
  }

  function salaryCandidates(text) {
    return [...new Set((normalize(text).match(/\b\d{3,5}\b/g) || [])
      .map(Number).filter((n) => between(n, 400, 8000) && Number.isInteger(n))
      .map(String))];
  }

  function amountCandidates(text) {
    const t = normalize(text).replace(/(\d)[,،](\d{3})(?!\d)/g, '$1$2');
    const raw = [...t.matchAll(/(?:^|[^\d])(\d{3,7})(?:[.,](\d{1,2}))?(?!\d)/g)];
    return [...new Set(raw.map((m) => {
      const value = Number(m[1] + (m[2] !== undefined ? '.' + m[2] : ''));
      return between(value, 1000, 100000) ? String(value) : null;
    }).filter(Boolean))];
  }

  function parseDate(text) {
    const s = normalize(text).replace(/[م]/g, '');
    const matches = [...s.matchAll(/(?<!\d)(20\d{2})\s*[-\/.]\s*(\d{1,2})\s*[-\/.]\s*(\d{1,2})(?!\d)/g),
      ...s.matchAll(/(?<!\d)(\d{1,2})\s*[-\/.]\s*(\d{1,2})\s*[-\/.]\s*(20\d{2})(?!\d)/g)];
    const dates = [];
    for (const m of matches) {
      const y = m[1].length === 4 ? +m[1] : +m[3];
      const month = +m[2];
      const day = m[1].length === 4 ? +m[3] : +m[1];
      const date = new Date(Date.UTC(y, month - 1, day));
      if (date.getUTCFullYear() === y && date.getUTCMonth() === month - 1 &&
          date.getUTCDate() === day) dates.push(`${y}-${String(month).padStart(2, '0')}-${String(day).padStart(2,'0')}`);
    }
    return [...new Set(dates)];
  }

  const NAME_BLOCKLIST = /(?:مكتب|شرك[هه]|استقدام|رقم|هاتف|جوال|عنوان|المملكه|العربيه|السعوديه|الاستقبال|الاول|الثاني|اسم|صاحب|العمل|domestic|employer|names|contact)/i;
  function nameCandidates(input) {
    // Support either a standalone name in the adjacent table cell or a
    // label+name in the same cell (a common layout variation).
    let text = normalize(input);
    if (regexTest('sponsorName', text)) {
      text = text.replace(/^.*?(?:اسم\s*صاحب\s*العمل(?:\s*المنزلي)?|اسم\s*الطرف\s*الثاني|domestic\s*employer\s*names?|employer\s*names?)\s*[:：\-]*/i, '');
    }
    const t = text.replace(/[A-Za-z\d@+_.:,\/\\|()\[\]{}<>~!?]+/g, ' ')
      .replace(/[^\u0600-\u06ff\s]/g, ' ').replace(/\s+/g, ' ').trim();
    if (!t || NAME_BLOCKLIST.test(t) || t.length > 85) return [];
    if (!between(t.split(' ').length, 3, 8)) return [];
    return [t];
  }

  function valuesFor(type, text) {
    switch (type) {
      case 'visaNumber': return numberCandidates(text, 10);
      case 'sponsorIDNumber': return numberCandidates(text, 10).filter((v) => /^[12]/.test(v));
      case 'contractNumber': return [8,9,10,11,12].flatMap((s) => numberCandidates(text,s));
      case 'sponsorPhoneNumber': return phoneCandidates(text);
      case 'salary': return salaryCandidates(text);
      case 'musanidPayment': return amountCandidates(text);
      case 'sponsorName': return nameCandidates(text);
      case 'contractDate': return parseDate(text);
      default: return [];
    }
  }

  function nearbyScore(anchor, value, type) {
    if (!hasGeometry(anchor) || !hasGeometry(value)) return -Infinity;
    const dy = value.cy - anchor.cy;
    const dx = anchor.cx - value.cx; // values usually LEFT of Arabic labels
    // Accept tables on same row or a close row immediately below.
    const maxDown = type === 'sponsorName' ? 0.11 : 0.095;
    if (dy < -0.028 || dy > maxDown) return -Infinity;
    let result = dy < 0.023 ? 100 - Math.abs(dy) * 500 : 86 - dy * 360;
    if (Math.abs(dy) < 0.023 && dx >= 0) result += 18;
    if (dx < -0.10 && Math.abs(dy) < 0.023) result -= 25;
    if (value === anchor) result += 35;
    return result;
  }

  function addCandidate(all, key, value, confidence, origin) {
    if (!value || !Number.isFinite(confidence)) return;
    if (key === 'sponsorName' && !nameCandidates(value).length) return;
    if (key === 'contractNumber' && !/^\d{8,12}$/.test(value)) return;
    if (key === 'visaNumber' && !/^\d{10}$/.test(value)) return;
    if (key === 'sponsorIDNumber' && !/^[12]\d{9}$/.test(value)) return;
    if (key === 'sponsorPhoneNumber' && !/^9665\d{8}$/.test(value)) return;
    if (key === 'contractDate' && !/^20\d{2}-\d{2}-\d{2}$/.test(value)) return;
    (all[key] ||= []).push({value, score:confidence, origin});
  }

  // Never confuse the price table heading with a legal formula mentioning
  // "إجمالي تكلفة الاستقدام" (e.g. cancellation penalties).
  function isPriceTableHeading(line, lines) {
    if (!hasGeometry(line)) return false;
    const label = normalize(line.text).toLowerCase();
    const match = /اجمالي\s*تكلف[هه]\s*الاستقدام|total\s+(?:recruitment\s+)?(?:cost|fee)/i.exec(label);
    if (!match) return false;
    if (match.index > 28 || label.length > 105) return false;
    if (/[÷×=*]/.test(label) ||
        /(?:غرام|جزاء|المخالفات|التعويضات|الغاء|فسخ|المتبقي[هه]|مد[هه]\s*العقد|بالايام|حساب\s*الغرام[هه])/.test(label)) {
      return false;
    }
    // A real price heading introduces a nearby amount row or written amount.
    // A phrase embedded in ordinary contract provisions does not.
    return lines.some((candidate) => {
      if (candidate === line || !hasGeometry(candidate)) return false;
      const dy = candidate.cy - line.cy;
      if (dy <= 0.004 || dy >= 0.14) return false;
      const t = normalize(candidate.text);
      return /(?:ريال\s*سعودي|السعودي|هللات|كتاب[هه]|رقما|[Rr][Ii][Yy][Aa][Ll]|SAR)/i.test(t);
    });
  }

  function pageEvidence(lines) {
    const full = normalize(lines.map((l) => l.text).join(' '));
    return {
      office: /(?:الطرف الاول|مكتب الاستقدام|المرخص له|رقم ترخيص الوزاره)/.test(full),
      sponsor: /(?:رقم الهويه|نوع الهويه|اسم صاحب العمل|employer names|الطرف الثاني)/i.test(full),
      type: /(?:استقدام حسب مواصفات|استقدام معين باسم|استقدام بالاسم)/.test(full)
    };
  }

  function extractLabeled(pageInfo, output) {
    const lines = pageInfo.lines;
    const evid = pageEvidence(lines);
    const targets = ['contractNumber','visaNumber','sponsorIDNumber',
      'sponsorPhoneNumber','salary','musanidPayment','sponsorName','contractDate'];
    for (const type of targets) {
      const labels = lines.filter((l) => type === 'musanidPayment'
        ? isPriceTableHeading(l,lines)
        : regexTest(type,l.text));
      for (const anchor of labels) {
        // Date must belong to the signature/agreement phrase, not print date.
        if (type === 'contractDate' && !/الموافق|تم\s*الاتفاق|contract\s*date/i.test(normalize(anchor.text))) continue;
        let labelBoost = 0;
        if (type === 'sponsorName') labelBoost += 35;
        if (type === 'sponsorPhoneNumber') {
          labelBoost += evid.sponsor ? 16 : -10;
          if (evid.office && !evid.sponsor) labelBoost -= 35;
        }
        if (type === 'sponsorIDNumber' && evid.sponsor) labelBoost += 18;
        if (type === 'musanidPayment' && /اجمالي\s*تكلف[هه]\s*الاستقدام/.test(normalize(anchor.text))) labelBoost += 22;
        for (const valueLine of lines) {
          // Don't select a second label as a name; reject unrelated paragraphs.
          const proximity = valueLine === anchor ? (hasGeometry(anchor) ? 135 : 90)
            : nearbyScore(anchor,valueLine,type);
          if (!Number.isFinite(proximity)) continue;
          for (const value of valuesFor(type, valueLine.text)) {
            if (type === 'contractNumber' && value.length !== 8 && valueLine !== anchor) continue;
            if (type === 'musanidPayment' && valueLine !== anchor &&
                /(?:التامين|القسط|غرامه|الالغاء|فسخ)/.test(normalize(valueLine.text))) continue;
            let score = proximity + labelBoost + Math.min(10, (valueLine.conf || 0) / 10);
            if (type === 'sponsorPhoneNumber' && /9665\d{8}/.test(normalize(valueLine.text))) score += 14;
            if (type === 'contractDate' && /الموافق/.test(normalize(anchor.text))) score += 35;
            if (type === 'sponsorName' && valueLine === anchor) score -= 45;
            addCandidate(output,type,value,score,`p${pageInfo.number}`);
          }
        }
      }
    }
    // Recognize preference values on the same table row when OCR includes
    // text, without treating general contractual paragraphs as preferences.
    for (const key of ['religion','experienced']) {
      const anchors = lines.filter(l=>hasGeometry(l) && regexTest(key,l.text));
      for (const anchor of anchors) {
        for (const near of lines) {
          if (!hasGeometry(near) || near===anchor) continue;
          if (Math.abs(near.cy-anchor.cy)>0.025 || near.cx>anchor.cx+0.04) continue;
          const candidate = key==='religion' ? religionCandidate(near.text) : experienceCandidate(near.text);
          if (candidate!==null) addCandidate(output,key,candidate,155,`p${pageInfo.number}-near`);
        }
      }
    }

    // Explicit type requested by Musaned (not guessed from worker details).
    for (const line of lines) {
      const t = normalize(line.text);
      if (/استقدام\s*حسب\s*مواصفات|حسب\s*مواصفات\s*محدده/.test(t))
        addCandidate(output,'contractType','2',175,`p${pageInfo.number}`);
      if (/استقدام\s*معين\s*باسم|استقدام\s*بالاسم|عامل\s*معين\s*باسم/.test(t))
        addCandidate(output,'contractType','1',175,`p${pageInfo.number}`);
    }
  }

  async function renderPage(page) {
    const viewport = page.getViewport({scale:2.05});
    const canvas = document.createElement('canvas');
    canvas.width = Math.ceil(viewport.width);
    canvas.height = Math.ceil(viewport.height);
    const ctx = canvas.getContext('2d', {willReadFrequently:true});
    ctx.fillStyle = '#fff';
    ctx.fillRect(0,0,canvas.width,canvas.height);
    await page.render({canvasContext:ctx,viewport}).promise;
    return canvas;
  }

  // Crop relative to OCR-detected labels/values (not PDF page positions).
  function cropNormalized(canvas, x1, y1, x2, y2, factor = 2) {
    const left = Math.max(0, Math.floor(x1 * canvas.width));
    const top = Math.max(0, Math.floor(y1 * canvas.height));
    const right = Math.min(canvas.width, Math.ceil(x2 * canvas.width));
    const bottom = Math.min(canvas.height, Math.ceil(y2 * canvas.height));
    if (right - left < 8 || bottom - top < 8) return null;
    const image = document.createElement('canvas');
    image.width = (right - left) * factor;
    image.height = (bottom - top) * factor;
    const ctx = image.getContext('2d', {willReadFrequently:true});
    ctx.fillStyle = '#fff';
    ctx.fillRect(0,0,image.width,image.height);
    ctx.drawImage(canvas,left,top,right-left,bottom-top,0,0,image.width,image.height);
    return image;
  }

  function religionCandidate(text) {
    const t = normalize(text).toLowerCase();
    if (/غير\s*مسلم|غير\s*مسلمه/.test(t)) return null; // unknown other category
    if (/مسلم|اسلام|muslim|islam/.test(t)) return '1';
    if (/مسيحي|نصراني|christian/.test(t)) return '2';
    if (/بوذي|هندو|ديانه\s*اخر|other/.test(t)) return '3';
    return null;
  }

  function experienceCandidate(text) {
    const t = normalize(text).toLowerCase();
    // Apply negatives first, otherwise "لم يسبق" would be interpreted as experience.
    if (/لم\s*يسبق|لم\s*تسبق|بدون\s*خبر|لا\s*يوجد\s*خبر|ليس\s*لها\s*خبر|not\s*experienced|no\s*experience/.test(t)) return 'false';
    if (/سبق\s*(?:له|لها)?\s*العمل|سبق\s*العمل|ذو\s*خبر|ذات\s*خبر|لدي[هه]?\s*خبر|experienced|previously\s*worked/.test(t)) return 'true';
    return null;
  }

  async function targetedPreferences(worker,pageInfo,all) {
    if (!pageInfo.canvas) return;
    const lines = pageInfo.lines;
    const getNearby = (anchor, key) => {
      for (const l of lines) {
        if (l === anchor || !hasGeometry(l)) continue;
        const dy = Math.abs(l.cy - anchor.cy);
        if (dy > 0.024 || l.cx > anchor.cx + 0.05) continue;
        const value = key === 'religion' ? religionCandidate(l.text) : experienceCandidate(l.text);
        if (value !== null) addCandidate(all,key,value,150,`p${pageInfo.number}-text`);
      }
    };

    // The Arabic-only OCR model reads 'مسلم' more reliably than bilingual
    // OCR in bordered table cells. Restore both languages afterward.
    let switched = false;
    try {
      if (typeof worker.reinitialize === 'function') {
        try { await worker.reinitialize('ara',1); switched = true; }
        catch (_) { /* bilingual fallback */ }
      }
    for (const [key, distance] of [['religion',0.25],['experienced',0.54]]) {
      const anchors = lines.filter((l) => hasGeometry(l) && regexTest(key,l.text));
      for (const anchor of anchors.slice(0,3)) {
        getNearby(anchor,key);
        const image = cropNormalized(
          pageInfo.canvas,
          Math.max(key==='religion'?0.06:0.015,anchor.x-distance),
          Math.max(0,anchor.y-0.014),
          Math.max(0.03,anchor.x-(key==='religion'?0.008:0.003)),
          Math.min(1,anchor.y+anchor.h+(key==='religion'?0.009:0.023)),
          2
        );
        if (!image) continue;
        try {
          await worker.setParameters({tessedit_pageseg_mode:'7'});
          const {data} = await worker.recognize(image, {}, {text:true});
          const val = key === 'religion' ? religionCandidate(data.text) : experienceCandidate(data.text);
          if (val !== null) addCandidate(all,key,val,190,`p${pageInfo.number}-cell`);
        } finally { image.width=0; image.height=0; }
      }
    }
    } finally {
      if (switched) await worker.reinitialize(['ara','eng'],1);
      await worker.setParameters({tessedit_pageseg_mode:'11'});
    }
  }

  // Focus the numeric row connected to the total-cost heading. Full-page
  // Arabic OCR often reports "9 ريال سعودي" when the actual cell is 6796.9.
  function amountCellCandidates(pageInfo) {
    const lines = pageInfo.lines;
    const anchors = lines.filter(l => isPriceTableHeading(l,lines));
    if (window.babelMusanedDebug === true) {
      console.log('[Musaned price headings]', `page=${pageInfo.number}`, `verified=${anchors.length}`);
    }
    const regions=[];
    for (const anchor of anchors) {
      // Prefer the numbered price row immediately below the heading; the
      // "كتابة" row is explanatory text, NOT another numeric price.
      const currencyRows = lines.filter(l => {
        if (!hasGeometry(l)) return false;
        const dy = l.cy - anchor.cy;
        return dy > 0.006 && dy < 0.105 &&
          /(?:ريال\s*سعودي|[Rr][Ii][Yy][Aa][Ll]|SAR)/i.test(normalize(l.text)) &&
          !/(?:غرام|التامين|القسط|هللات)/.test(normalize(l.text));
      }).sort((a,b) => a.cy - b.cy);

      if (currencyRows.length) {
        // Don't OCR the second currency mention in the written Arabic amount.
        const row = currencyRows[0];
        regions.push({
          x1:Math.max(0.02,row.x-0.25),
          y1:Math.max(0,row.y-0.014),
          x2:Math.min(0.98,row.x+row.w+0.042),
          y2:Math.min(1,row.y+row.h+0.023),
          tag:'price-row'
        });
      } else {
        // For OCR that missed currency text, inspect only the first amount
        // line after the verified price table heading.
        regions.push({
          x1:Math.max(0.02,anchor.x-0.22),
          y1:Math.min(0.98,anchor.y+anchor.h+0.021),
          x2:Math.min(0.98,anchor.x+anchor.w+0.04),
          y2:Math.min(1,anchor.y+anchor.h+0.071),
          tag:'price-heading-fallback'
        });
      }
    }
    return regions;
  }

  // Crop coordinates are DERIVED from detected label geometry; they are not
  // tied to page index / a specific Musaned print template.
  function amountRowBelow(canvas, anchor) {
    const left = Math.floor(canvas.width * Math.max(0, anchor.x - 0.09));
    const right = Math.ceil(canvas.width * Math.min(1, anchor.x + anchor.w + 0.045));
    const top = Math.max(0, Math.floor(canvas.height * Math.min(0.99, anchor.y + anchor.h - 0.006)));
    const bottom = Math.min(canvas.height, Math.ceil(canvas.height * Math.min(1, anchor.y + anchor.h + 0.055)));
    if (right <= left || bottom <= top) return null;
    const scale = 2;
    const crop = document.createElement('canvas');
    crop.width = (right - left) * scale;
    crop.height = (bottom - top) * scale;
    const ctx = crop.getContext('2d', {willReadFrequently:true});
    ctx.fillStyle = '#fff';
    ctx.fillRect(0,0,crop.width,crop.height);
    ctx.drawImage(canvas, left, top, right-left, bottom-top, 0,0,crop.width,crop.height);
    return crop;
  }

  async function targetedAmount(worker, pageInfo, all) {
    if (!pageInfo.canvas) return;
    const regions = amountCellCandidates(pageInfo);
    if (!regions.length) return;
    let switched = false;
    try {
      if (typeof worker.reinitialize === 'function') {
        try { await worker.reinitialize('eng',1); switched = true; }
        catch (_) { /* bilingual OCR fallback */ }
      }
      // Primary: targeted amount cell (not a full-page OCR guess).
      for (const r of regions.slice(0,6)) {
        const image = cropNormalized(pageInfo.canvas,r.x1,r.y1,r.x2,r.y2,2);
        if (!image) continue;
        try {
          for (const mode of ['7','6','11']) {
            await worker.setParameters({tessedit_pageseg_mode:mode});
            const {data} = await worker.recognize(image, {}, {text:true});
            const values = amountCandidates(data.text||'');
            if (window.babelMusanedDebug === true) {
              console.log('[Musaned price OCR]', `page=${pageInfo.number}`, r.tag, `psm=${mode}`, 'numbers=',JSON.stringify(values));
            }
            // Do not mistake an insurance installment or stray number for price.
            if (values.length === 1) {
              addCandidate(all,'musanidPayment',values[0],195,
                `p${pageInfo.number}-${r.tag}`);
              break;
            }
            if (values.length > 1) break;
          }
        } finally {image.width=0;image.height=0;}
      }
    } finally {
      if (switched) await worker.reinitialize(['ara','eng'],1);
      await worker.setParameters({tessedit_pageseg_mode:'11'});
    }
  }

  // -----------------------------------------------------------------------
  // Price table fallback for image-only Musaned PDFs.
  // It identifies an actual TWO-ROW TABLE by its border lines and reads the
  // right-hand headings "رقماً" / "كتابة". Page number, price and crop position
  // are NOT hard-coded. In particular, it never uses a cancellation formula
  // mentioning recruitment cost as if it were the price table.
  // -----------------------------------------------------------------------
  function findLongHorizontalRules(canvas) {
    const w = canvas.width, h = canvas.height;
    const ctx = canvas.getContext('2d', {willReadFrequently: true});
    const rgba = ctx.getImageData(0, 0, w, h).data;
    const lines = [];
    const lo = Math.floor(w * 0.035), hi = Math.ceil(w * 0.975);
    const dark = (x,y) => {
      const i = (y*w + x)*4;
      return rgba[i] + rgba[i+1] + rgba[i+2] < 310;
    };
    for (let y = 8; y < h-8; y++) {
      let from = -1, bestStart = -1, bestEnd = -1;
      for (let x = lo; x <= hi; x++) {
        const isBlack = x < hi && dark(x,y);
        if (isBlack && from < 0) from = x;
        if (!isBlack && from >= 0) {
          if (x - from > bestEnd-bestStart) {
            bestStart = from;
            bestEnd = x;
          }
          from = -1;
        }
      }
      if (bestEnd - bestStart < w * 0.58 ||
          bestStart > w * 0.18 || bestEnd < w * 0.82) continue;
      if (lines.length && y-lines[lines.length-1].y <= 4) continue;
      lines.push({y, x1:bestStart, x2:bestEnd});
    }
    return {lines, rgba, dark};
  }

  function findTwoRowTables(canvas) {
    const w=canvas.width, h=canvas.height;
    const {lines, dark}=findLongHorizontalRules(canvas);
    const result=[];
    for (let i=0; i<lines.length-2; i++) {
      const a=lines[i];
      for (let j=i+1; j<lines.length-1; j++) {
        const b=lines[j];
        const gap1=b.y-a.y;
        if (gap1>h*0.10) break;
        if (gap1<h*0.018) continue;
        for (let k=j+1; k<lines.length; k++) {
          const c=lines[k];
          const gap2=c.y-b.y;
          if (gap2>h*0.10) break;
          if (gap2<h*0.018 || Math.abs(gap1-gap2)>h*0.018) continue;
          if (Math.max(
            Math.abs(a.x1-b.x1), Math.abs(a.x2-b.x2),
            Math.abs(b.x1-c.x1), Math.abs(b.x2-c.x2)
          ) > w*0.045) continue;

          const left=Math.max(a.x1,b.x1,c.x1);
          const right=Math.min(a.x2,b.x2,c.x2);
          // The last/rightmost column is the narrow row-heading column.
          // It must have a vertical rule continuing through BOTH rows.
          let separator=null, maxFraction=0;
          for (let x=Math.round(right-w*.22); x<Math.round(right-w*.025); x+=1) {
            if (x<=left) continue;
            let count=0, samples=0;
            for (let y=a.y+5; y<c.y-5; y+=3) {
              samples++;
              if (dark(x,y)) count++;
            }
            const fraction=samples ? count/samples : 0;
            if (fraction>0.70 && fraction>maxFraction) {
              separator=x;
              maxFraction=fraction;
            }
          }
          if (separator===null ||
              separator>right-w*.025 || separator<right-w*.19) continue;
          result.push({left,right,separator, y0:a.y,y1:b.y,y2:c.y});
        }
      }
    }
    // De-duplicate overlapping detections caused by thick table borders.
    return result.filter((t,i) => !result.slice(0,i).some(
      o=>Math.abs(o.y0-t.y0)<7 && Math.abs(o.y2-t.y2)<7
    ));
  }

  function gridCrop(canvas, x1,y1,x2,y2) {
    return cropNormalized(canvas,
      x1/canvas.width,y1/canvas.height,
      x2/canvas.width,y2/canvas.height,3);
  }

  async function gridRead(worker, canvas, bounds, mode='7') {
    const img=gridCrop(canvas,...bounds);
    if (!img) return '';
    try {
      await worker.setParameters({tessedit_pageseg_mode:mode});
      const result=await worker.recognize(img,{}, {text:true});
      return normalize(result.data?.text || '');
    } finally {img.width=0;img.height=0;}
  }

  async function targetedAmountFromGrid(worker,pageInfo,all) {
    if (!pageInfo.canvas || (all.musanidPayment||[]).some(c=>c.score>=250)) return;
    const canvas=pageInfo.canvas;
    const tables=findTwoRowTables(canvas);
    if (window.babelMusanedDebug === true) {
      console.log('[Musaned price table grids]',
        `page=${pageInfo.number} tables=${tables.length}`);
    }
    if (!tables.length) return;

    let switched=false;
    try {
      // First verify the row titles using the Arabic model. We do not
      // accept a price until BOTH "رقماً" and "كتابة" are identified.
      if (typeof worker.reinitialize === 'function') {
        await worker.reinitialize('ara',1);
        switched=true;
      }
      const approved=[];
      for (const t of tables.slice(0,8)) {
        // IMPORTANT: the cancellation-penalty base elsewhere in Musaned can
        // ALSO have a "رقماً / كتابة" table. Never identify price by row
        // headings alone. Require recruitment-cost context or the same page
        // to show BOTH visa and actual Musaned contract numbers.
        const thisPage=`p${pageInfo.number}`;
        const hasVisa=(all.visaNumber||[]).some(c=>c.origin===thisPage);
        const hasContract=(all.contractNumber||[]).some(c=>c.origin===thisPage);
        const nearbyText=normalize(pageInfo.lines.filter(l=>
          hasGeometry(l) && l.cy >= t.y0/canvas.height-0.18 &&
          l.cy <= t.y2/canvas.height+0.13
        ).map(l=>l.text).join(' '));
        const financeContext=/الجوانب\s*المالي|القيمه\s*المضافه|القسط\s*التاميني|اجمالي\s*تكلفه\s*الاستقدام/.test(nearbyText);
        const penaltyContext=/غرام|المخالفات|التعويضات|فسخ|الغاء\s*العقد|حساب\s*الغرامه/.test(nearbyText);
        if (penaltyContext || (!(hasVisa && hasContract) && !financeContext)) {
          if (window.babelMusanedDebug === true) {
            console.log('[Musaned grid rejected]',
              `page=${pageInfo.number} visa=${hasVisa} contract=${hasContract} finance=${financeContext} penalty=${penaltyContext}`);
          }
          continue;
        }
        const x1=t.separator+6, x2=t.right-6;
        const row1=await gridRead(worker,canvas,
          [x1,t.y0+6,x2,t.y1-6],'7');
        const row2=await gridRead(worker,canvas,
          [x1,t.y1+6,x2,t.y2-6],'7');
        if (window.babelMusanedDebug === true) {
          console.log('[Musaned table row headings]',
            `page=${pageInfo.number}`, JSON.stringify({row1,row2}));
        }

const normalizedRow1 = normalize(row1).replace(/\s+/g, '');
const normalizedRow2 = normalize(row2).replace(/\s+/g, '');

const hasNumberLabel = /رقم[اأآ]?/.test(normalizedRow1);
const hasWrittenLabel = /كتاب[هة]?/.test(normalizedRow2);

// نسمح بفشل قراءة "كتابة" فقط إذا كان سياق
// الجدول المالي مؤكدًا، وليس جدول غرامات أو إلغاء.
const hasReliableContext =
    !penaltyContext &&
    (financeContext || (hasVisa && hasContract));

if (
    !hasNumberLabel ||
    (!hasWrittenLabel && !hasReliableContext)
) {
    continue;
}
        approved.push(t);
        if (window.babelMusanedDebug === true) {
          console.log('[Musaned verified amount table]',
            `page=${pageInfo.number}`,JSON.stringify({row1,row2}));
        }
      }
      if (!approved.length) return;
      if (typeof worker.reinitialize === 'function') {
        await worker.reinitialize('eng',1);
      }
      for (const t of approved) {
        // Only the amount CELL, immediately left of the "رقماً" heading.
        // The wider body of the PDF contains insurance, VAT and penalties.
        const bounds=[
          Math.max(t.left+6,t.separator-canvas.width*.34),
          t.y0+7,
          t.separator-6,
          t.y1-7
        ];
        const readings=[];
        for (const mode of ['7','6']) {
          const raw=await gridRead(worker,canvas,bounds,mode);
          const values=amountCandidates(raw);
          readings.push({mode,raw,values});
        }
        if (window.babelMusanedDebug === true) {
          console.log('[Musaned amount cell]',
            `page=${pageInfo.number}`,JSON.stringify(readings));
        }
        const a=readings[0].values, b=readings[1].values;
        // If both modes propose different figures, this is ambiguous;
        // refuse to silently populate a financial field with a wrong value.
        if (a.length===1 && (b.length===0 || (b.length===1 && b[0]===a[0]))) {
          addCandidate(all,'musanidPayment',a[0],260,
            `p${pageInfo.number}-verified-amount-table`);
        } else if (a.length===0 && b.length===1) {
          addCandidate(all,'musanidPayment',b[0],250,
            `p${pageInfo.number}-verified-amount-table`);
        }
      }
    } finally {
      if (switched) await worker.reinitialize(['ara','eng'],1);
      await worker.setParameters({tessedit_pageseg_mode:'11'});
    }
  }

  // Keep ambiguous/conflicting candidates empty rather than silently filling.
  function finalizeCandidates(all) {
    const output = {};
    for (const key of VALID_KEYS) {
      const candidates = all[key] || [];
      if (!candidates.length) continue;
      const grouped = new Map();
      for (const c of candidates) {
        const entry = grouped.get(c.value) || {value:c.value,max:-Infinity,pages:new Set()};
        entry.max = Math.max(entry.max,c.score);
        entry.pages.add(c.origin.split('-')[0]);
        grouped.set(c.value,entry);
      }
      const sorted = [...grouped.values()].map((e) => ({
        ...e, score:e.max + Math.min(12,(e.pages.size-1)*5)
      })).sort((a,b) => b.score - a.score);
      const best = sorted[0];
      const runnerUp = sorted[1];
      // Strong OCR ambiguity: two different values with comparable scores.
      if (runnerUp && runnerUp.score >= best.score - 13) continue;
      if (best.score < 90) continue;
      output[key] = best.value;
    }
    return output;
  }

  async function openPdf(file) {
    if (!window.pdfjsLib || !window.Tesseract)
      throw new Error('مكتبات PDF.js أو Tesseract غير محمّلة من web/vendor.');
    window.pdfjsLib.GlobalWorkerOptions.workerSrc = localUrl('vendor/pdfjs/pdf.worker.min.js');
    const bytes = new Uint8Array(await file.arrayBuffer());
    return window.pdfjsLib.getDocument({data:bytes,isEvalSupported:false}).promise;
  }

  window.babelMusanedAnalyze = async (file) => {
    if (!file || !/\.pdf$/i.test(String(file.name || ''))) throw new Error('اختر ملف PDF صحيح.');
    if (file.size > MAX_FILE_SIZE) throw new Error('حجم ملف PDF يتجاوز 25 ميجابايت.');
    const pdf = await openPdf(file);
    let worker;
    try {
      if (!pdf.numPages) throw new Error('ملف PDF فارغ أو غير مدعوم.');
      const all = {};
      for (let p = 1; p <= Math.min(pdf.numPages,MAX_PAGES); p++) {
        const page = await pdf.getPage(p);
        const text = await page.getTextContent();
        const textLines = textContentLines(text,page);
        const textSize = textLines.reduce((sum,line) => sum + line.text.length,0);
        let pageInfo = {number:p,lines:textLines,canvas:null};
        // Scanned/image-only PDFs require full-page local OCR. Text PDFs do not.
        if (textSize < 90) {
          if (!worker) {
            worker = await window.Tesseract.createWorker(['ara','eng'],1,{
              workerPath:localUrl('vendor/tesseract/worker.min.js'),
              corePath:localUrl('vendor/tesseract/core'),
              langPath:localUrl('vendor/tesseract/lang'),
              workerBlobURL:false,gzip:true,cacheMethod:'none'
            });
            await worker.setParameters({tessedit_pageseg_mode:'11'});
          }
          const canvas = await renderPage(page);
          pageInfo.canvas = canvas;
          const {data} = await worker.recognize(canvas, {}, {text:true,tsv:true});
          pageInfo.lines = linesFromOcr(data,canvas.width,canvas.height);
        }
        extractLabeled(pageInfo,all);
        if (worker && pageInfo.canvas) {
          await targetedPreferences(worker,pageInfo,all);
          await targetedAmount(worker,pageInfo,all);
          // Fallback when OCR misses the "total recruitment cost" heading.
          // Never let optional table OCR stop extraction of other fields.
          try {
            await targetedAmountFromGrid(worker,pageInfo,all);
          } catch (error) {
            if (window.babelMusanedDebug === true) {
              console.warn('[Musaned amount table OCR error]',String(error));
            }
          }
        }
        if (pageInfo.canvas) {pageInfo.canvas.width=0;pageInfo.canvas.height=0;}
        page.cleanup();
        // Stop only after the desired fields have been found, otherwise later
        // pages may contain moved tables. Even then require a unique winner.
        const current = finalizeCandidates(all);
        if (VALID_KEYS.every((k) => current[k])) break;
      }
      return finalizeCandidates(all);
    } finally {
      if (worker) await worker.terminate();
      await pdf.destroy();
    }
  };
})();
