/* =========================================================
   Smart WhatsApp Message Generator — app.js
   ========================================================= */

// ---------- CONFIG: replace with your real OpenAI key handling ----------
// IMPORTANT: Never expose a real API key in client-side code in production.
// Route requests through a backend/serverless proxy. The fetch below
// targets a placeholder endpoint `/api/generate` that your backend should
// implement to call the OpenAI API.
const API_ENDPOINT = "/api/generate";

// ---------- DATA ----------
const CATEGORIES = [
  { id: "leave", label: "Leave Application", icon: "🛏️" },
  { id: "support", label: "Customer Support Reply", icon: "🎧" },
  { id: "freelance", label: "Freelance Proposal", icon: "💼" },
  { id: "business", label: "Business Message", icon: "🏢" },
  { id: "email", label: "Formal Email Draft", icon: "✉️" },
  { id: "job", label: "Job Application", icon: "📄" },
  { id: "followup", label: "Follow-up Message", icon: "🔄" },
  { id: "love", label: "Love Message", icon: "❤️" },
  { id: "apology", label: "Apology Message", icon: "🙏" },
  { id: "greeting", label: "Birthday & Greeting", icon: "🎉" },
];

const TONES = ["Professional", "Formal", "Friendly", "Polite", "Romantic", "Confident"];

const FAQS = [
  {
    q: "Do I need to write perfect Bangla?",
    a: "No. Write naturally, even with mixed spelling or casual phrasing — the AI understands context and converts it into polished English.",
  },
  {
    q: "Is my data stored anywhere?",
    a: "Your message history is saved only in your browser's local storage. It is never uploaded to a server unless you choose to use account-based sync (Premium).",
  },
  {
    q: "Can I edit the generated message?",
    a: "Yes. The output box is fully editable — tweak any part before copying, downloading, or sharing.",
  },
  {
    q: "What's the difference between tones?",
    a: "Each tone (Professional, Formal, Friendly, Polite, Romantic, Confident) changes vocabulary and sentence structure to match the relationship and context of your message.",
  },
  {
    q: "Is SmartWA free to use?",
    a: "Yes, the core generator is completely free. Premium unlocks 50+ language translation, voice input, AI reply suggestions, chat analysis, and conversation starters.",
  },
];

const EXAMPLES = [
  {
    category: "Leave Application",
    bangla: "আমার জ্বর, আজ অফিসে যেতে পারবো না",
    english: "Hello Sir, I am feeling unwell due to a fever and will not be able to attend the office today. I kindly request you to grant me leave for the day. Thank you for your understanding.",
  },
  {
    category: "Customer Support Reply",
    bangla: "দুঃখিত স্যার, আপনার অর্ডারটি দুই দিনের মধ্যে পাঠানো হবে",
    english: "Hi there, we sincerely apologize for the delay. Your order will be shipped within the next two business days, and you'll receive a tracking link as soon as it's dispatched. Thank you for your patience!",
  },
  {
    category: "Freelance Proposal",
    bangla: "আমি আপনার প্রজেক্টে কাজ করতে চাই, আমার ৩ বছরের অভিজ্ঞতা আছে",
    english: "Hello! I'm very interested in working on your project. With 3 years of hands-on experience in this field, I'm confident I can deliver high-quality results within your timeline. I'd love to discuss the details further.",
  },
];

// ---------- STATE ----------
const LS_HISTORY = "smartwa_history";
const LS_STATS = "smartwa_stats";
const LS_THEME = "smartwa_theme";

let state = {
  category: CATEGORIES[0].id,
  tone: TONES[0],
};

// ---------- THEME ----------
function initTheme() {
  const saved = localStorage.getItem(LS_THEME);
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const isDark = saved ? saved === "dark" : prefersDark;
  document.documentElement.classList.toggle("dark", isDark);
}
function toggleTheme() {
  const isDark = document.documentElement.classList.toggle("dark");
  localStorage.setItem(LS_THEME, isDark ? "dark" : "light");
}

// ---------- RENDER: CATEGORIES ----------
function renderCategories() {
  const grid = document.getElementById("categoryGrid");
  grid.innerHTML = CATEGORIES.map(
    (c) => `
    <button data-cat="${c.id}" class="cat-btn group flex flex-col items-center gap-1.5 text-center rounded-xl border px-2 py-3 text-xs font-semibold transition-all
      ${c.id === state.category
        ? "border-leaf-500 bg-leaf-50 dark:bg-leaf-900/40 text-leaf-700 dark:text-leaf-300 shadow-glow"
        : "border-leaf-100 dark:border-ink-500 hover:border-leaf-300 dark:hover:border-leaf-700 text-ink-600 dark:text-leaf-100/70"
      }">
      <span class="text-xl">${c.icon}</span>
      <span class="leading-tight">${c.label}</span>
    </button>`
  ).join("");

  grid.querySelectorAll(".cat-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      state.category = btn.dataset.cat;
      renderCategories();
    });
  });
}

// ---------- RENDER: TONES ----------
function renderTones() {
  const grid = document.getElementById("toneGrid");
  grid.innerHTML = TONES.map(
    (t) => `
    <button data-tone="${t}" class="tone-btn text-sm font-semibold px-4 py-2 rounded-full border transition-all
      ${t === state.tone
        ? "grad-bg text-white border-transparent shadow-glow"
        : "border-leaf-200 dark:border-ink-500 text-ink-600 dark:text-leaf-100/70 hover:border-leaf-400 dark:hover:border-leaf-600"
      }">
      ${t}
    </button>`
  ).join("");

  grid.querySelectorAll(".tone-btn").forEach((btn) => {
    btn.addEventListener("click", () => {
      state.tone = btn.dataset.tone;
      renderTones();
    });
  });
}

// ---------- RENDER: FAQ ----------
function renderFAQ() {
  const list = document.getElementById("faqList");
  list.innerHTML = FAQS.map(
    (f, i) => `
    <details class="group bg-white dark:bg-ink-700 rounded-2xl border border-leaf-100 dark:border-ink-500 p-5 reveal" data-reveal>
      <summary class="flex items-center justify-between cursor-pointer font-display font-semibold text-base list-none">
        ${f.q}
        <svg class="w-5 h-5 text-leaf-500 group-open:rotate-180 transition-transform" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
      </summary>
      <p class="mt-3 text-sm text-ink-600 dark:text-leaf-100/70 leading-relaxed">${f.a}</p>
    </details>`
  ).join("");
  observeReveal();
}

// ---------- RENDER: EXAMPLES ----------
function renderExamples() {
  const grid = document.getElementById("exampleCarousel");
  grid.innerHTML = EXAMPLES.map(
    (ex) => `
    <div class="reveal bg-white dark:bg-ink-700 rounded-2xl border border-leaf-100 dark:border-ink-500 p-5" data-reveal>
      <span class="inline-block text-[11px] font-semibold px-2.5 py-1 rounded-full bg-leaf-50 dark:bg-leaf-900/40 text-leaf-600 dark:text-leaf-300 mb-3">${ex.category}</span>
      <div class="relative bubble-tail-r ml-auto max-w-full bg-leaf-100 dark:bg-leaf-900/40 rounded-2xl rounded-br-sm px-3 py-2.5 text-sm font-bn mb-3">${ex.bangla}</div>
      <div class="relative bubble-tail-l max-w-full bg-leaf-50/60 dark:bg-ink-600 border border-leaf-100 dark:border-ink-500 rounded-2xl rounded-bl-sm px-3 py-2.5 text-sm leading-relaxed">${ex.english}</div>
    </div>`
  ).join("");
  observeReveal();
}

// ---------- STATS ----------
function getStats() {
  try {
    return JSON.parse(localStorage.getItem(LS_STATS)) || { total: 0, byCategory: {}, byDate: {} };
  } catch {
    return { total: 0, byCategory: {}, byDate: {} };
  }
}
function saveStats(stats) {
  localStorage.setItem(LS_STATS, JSON.stringify(stats));
}
function recordGeneration(categoryLabel) {
  const stats = getStats();
  stats.total += 1;
  stats.byCategory[categoryLabel] = (stats.byCategory[categoryLabel] || 0) + 1;
  const today = new Date().toISOString().slice(0, 10);
  stats.byDate[today] = (stats.byDate[today] || 0) + 1;
  saveStats(stats);
  renderStats();
}
function renderStats() {
  const stats = getStats();
  document.getElementById("statTotal").textContent = stats.total;
  const top = Object.entries(stats.byCategory).sort((a, b) => b[1] - a[1])[0];
  document.getElementById("statTop").textContent = top ? top[0] : "—";
  const today = new Date().toISOString().slice(0, 10);
  document.getElementById("statToday").textContent = stats.byDate[today] || 0;
}

// ---------- HISTORY ----------
function getHistory() {
  try {
    return JSON.parse(localStorage.getItem(LS_HISTORY)) || [];
  } catch {
    return [];
  }
}
function saveHistory(items) {
  localStorage.setItem(LS_HISTORY, JSON.stringify(items));
}
function addToHistory(entry) {
  const items = getHistory();
  items.unshift(entry);
  saveHistory(items.slice(0, 100));
  renderHistory();
}
function renderHistory(filter = "") {
  const list = document.getElementById("historyList");
  const empty = document.getElementById("historyEmpty");
  const items = getHistory().filter(
    (it) =>
      !filter ||
      it.bangla.toLowerCase().includes(filter.toLowerCase()) ||
      it.english.toLowerCase().includes(filter.toLowerCase()) ||
      it.category.toLowerCase().includes(filter.toLowerCase())
  );

  if (items.length === 0) {
    empty.style.display = "block";
    list.innerHTML = "";
    list.appendChild(empty);
    return;
  }
  empty.style.display = "none";

  list.innerHTML = items
    .map(
      (it, idx) => `
    <div class="group relative bg-leaf-50/50 dark:bg-ink-600 rounded-xl p-3 text-xs border border-leaf-100 dark:border-ink-500 hover:border-leaf-300 dark:hover:border-leaf-700 transition-colors cursor-pointer" data-idx="${idx}" data-filter="${filter ? "1" : "0"}">
      <div class="flex items-center justify-between mb-1">
        <span class="font-semibold text-leaf-600 dark:text-leaf-400">${it.category}</span>
        <button class="del-history opacity-0 group-hover:opacity-100 text-red-400 hover:text-red-500 transition-opacity" data-id="${it.id}" aria-label="Delete">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m3 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></svg>
        </button>
      </div>
      <p class="text-ink-700 dark:text-leaf-100/80 line-clamp-2">${it.english}</p>
    </div>`
    )
    .join("");

  // re-attach handlers
  list.querySelectorAll("[data-idx]").forEach((card) => {
    card.addEventListener("click", (e) => {
      if (e.target.closest(".del-history")) return;
      const idx = Number(card.dataset.idx);
      const useItems = getHistory().filter(
        (it) =>
          !filter ||
          it.bangla.toLowerCase().includes(filter.toLowerCase()) ||
          it.english.toLowerCase().includes(filter.toLowerCase()) ||
          it.category.toLowerCase().includes(filter.toLowerCase())
      );
      const entry = useItems[idx];
      if (entry) loadHistoryEntry(entry);
    });
  });

  list.querySelectorAll(".del-history").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();
      const id = btn.dataset.id;
      const items = getHistory().filter((it) => it.id !== id);
      saveHistory(items);
      renderHistory(document.getElementById("historySearch").value);
    });
  });
}
function loadHistoryEntry(entry) {
  document.getElementById("banglaInput").value = entry.bangla;
  state.tone = entry.tone;
  renderTones();
  const catObj = CATEGORIES.find((c) => c.label === entry.category);
  if (catObj) state.category = catObj.id;
  renderCategories();
  showOutput(entry.english);
  document.getElementById("app").scrollIntoView({ behavior: "smooth" });
}

// ---------- GENERATION ----------
function showOutput(text) {
  const wrap = document.getElementById("outputWrap");
  const skeleton = document.getElementById("outputSkeleton");
  const textarea = document.getElementById("outputText");
  wrap.classList.remove("hidden");
  skeleton.classList.add("hidden");
  textarea.classList.remove("hidden");
  textarea.value = text;
}

function showSkeleton() {
  const wrap = document.getElementById("outputWrap");
  const skeleton = document.getElementById("outputSkeleton");
  const textarea = document.getElementById("outputText");
  wrap.classList.remove("hidden");
  skeleton.classList.remove("hidden");
  textarea.classList.add("hidden");
}

function showToast(msg) {
  const toast = document.getElementById("toastMsg");
  toast.textContent = msg;
  toast.classList.remove("hidden");
  setTimeout(() => toast.classList.add("hidden"), 2500);
}

/**
 * Calls the backend AI endpoint to convert Bangla input into a polished
 * English WhatsApp message. The backend is expected to call the OpenAI
 * Chat Completions API with a system prompt tailored to the selected
 * category and tone.
 */
async function generateMessage(banglaText, categoryLabel, tone) {
  const systemPrompt = buildSystemPrompt(categoryLabel, tone);

  try {
    const res = await fetch(API_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: banglaText },
        ],
        temperature: 0.7,
      }),
    });

    if (!res.ok) throw new Error(`API error: ${res.status}`);
    const data = await res.json();
    // Expecting backend to proxy OpenAI's response shape:
    // data.choices[0].message.content
    return data.choices?.[0]?.message?.content?.trim() || fallbackMessage(banglaText, categoryLabel, tone);
  } catch (err) {
    console.warn("Falling back to local demo generation:", err.message);
    return fallbackMessage(banglaText, categoryLabel, tone);
  }
}

function buildSystemPrompt(categoryLabel, tone) {
  return `You are an expert bilingual writing assistant. The user will provide a short message written in Bangla (Bengali). 
Convert it into a polished, grammatically correct, professional English WhatsApp message.
Category: "${categoryLabel}".
Tone: "${tone}".
Rules:
- Improve grammar and clarity automatically.
- Adjust vocabulary, structure, and politeness to match the category and tone.
- Keep the message concise and appropriate for WhatsApp (2-5 sentences).
- Do not include explanations, only return the final message text.`;
}

// Local fallback so the UI is fully demonstrable without a live API key.
function fallbackMessage(banglaText, categoryLabel, tone) {
  const toneOpeners = {
    Professional: "Hello,",
    Formal: "Dear Sir/Madam,",
    Friendly: "Hey there!",
    Polite: "Hello, I hope you're doing well.",
    Romantic: "My dearest,",
    Confident: "Hi,",
  };

  const templates = {
    "Leave Application": (op) =>
      `${op} I am feeling unwell and will not be able to attend the office today. I kindly request you to approve my leave for the day. Thank you for your understanding.`,
    "Customer Support Reply": (op) =>
      `${op} Thank you for reaching out. We understand your concern and want to assure you that we're addressing it right away. We appreciate your patience and will update you shortly.`,
    "Freelance Proposal": (op) =>
      `${op} I'm excited about the opportunity to work on your project. I have relevant experience and can deliver high-quality results within your timeline. I'd love to discuss the details further.`,
    "Business Message": (op) =>
      `${op} I wanted to follow up regarding our recent discussion. Please let me know a convenient time to connect so we can move forward.`,
    "Formal Email Draft": (op) =>
      `${op}\n\nI hope this message finds you well. I am writing to bring the following matter to your attention and would appreciate your guidance.\n\nThank you for your time.`,
    "Job Application": (op) =>
      `${op} I am writing to express my interest in the position at your company. I believe my skills and experience make me a strong fit, and I would welcome the opportunity to discuss further.`,
    "Follow-up Message": (op) =>
      `${op} I just wanted to follow up on my previous message. Please let me know if you need any additional information from my side.`,
    "Love Message": (op) =>
      `${op} I just wanted to take a moment to tell you how much you mean to me. You make every day brighter, and I'm so grateful to have you in my life.`,
    "Apology Message": (op) =>
      `${op} I sincerely apologize for any inconvenience caused. It was not my intention, and I truly value our relationship. Thank you for your understanding.`,
    "Birthday & Greeting": (op) =>
      `${op} Wishing you a very happy birthday! May this year bring you joy, success, and wonderful memories. Have a fantastic celebration!`,
  };

  const opener = toneOpeners[tone] || "Hello,";
  const generator = templates[categoryLabel] || templates["Business Message"];
  return generator(opener);
}

// ---------- EVENT HANDLERS ----------
async function handleGenerate() {
  const bangla = document.getElementById("banglaInput").value.trim();
  if (!bangla) {
    document.getElementById("banglaInput").focus();
    document.getElementById("banglaInput").classList.add("ring-2", "ring-red-400");
    setTimeout(() => document.getElementById("banglaInput").classList.remove("ring-2", "ring-red-400"), 1200);
    return;
  }

  const catObj = CATEGORIES.find((c) => c.id === state.category);
  const categoryLabel = catObj ? catObj.label : "Business Message";

  showSkeleton();
  document.getElementById("outputWrap").scrollIntoView({ behavior: "smooth", block: "nearest" });

  const result = await generateMessage(bangla, categoryLabel, state.tone);
  showOutput(result);

  recordGeneration(categoryLabel);
  addToHistory({
    id: crypto.randomUUID ? crypto.randomUUID() : String(Date.now()),
    category: categoryLabel,
    tone: state.tone,
    bangla,
    english: result,
    timestamp: Date.now(),
  });
}

function handleCopy() {
  const text = document.getElementById("outputText").value;
  navigator.clipboard.writeText(text).then(() => showToast("Copied to clipboard!"));
}

function handleDownload() {
  const text = document.getElementById("outputText").value;
  const blob = new Blob([text], { type: "text/plain;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "smartwa-message.txt";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
  showToast("Downloaded as .txt");
}

function handleShare() {
  const text = document.getElementById("outputText").value;
  const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
  window.open(url, "_blank");
}

function handleRegenerate() {
  handleGenerate();
}

function handleVoiceClick() {
  showToast("🎙️ Voice input is a Premium feature — upgrade to unlock!");
}

// ---------- SCROLL REVEAL ----------
function observeReveal() {
  const els = document.querySelectorAll(".reveal:not(.is-visible)");
  const obs = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.1 }
  );
  els.forEach((el) => obs.observe(el));
}

// ---------- INIT ----------
document.addEventListener("DOMContentLoaded", () => {
  initTheme();
  renderCategories();
  renderTones();
  renderFAQ();
  renderExamples();
  renderStats();
  renderHistory();
  observeReveal();

  document.getElementById("themeToggle").addEventListener("click", toggleTheme);
  document.getElementById("generateBtn").addEventListener("click", handleGenerate);
  document.getElementById("copyBtn").addEventListener("click", handleCopy);
  document.getElementById("downloadBtn").addEventListener("click", handleDownload);
  document.getElementById("regenerateBtn").addEventListener("click", handleRegenerate);
  document.getElementById("shareBtn").addEventListener("click", handleShare);
  document.getElementById("voiceBtn").addEventListener("click", handleVoiceClick);

  document.getElementById("clearHistory").addEventListener("click", () => {
    if (confirm("Clear all message history?")) {
      saveHistory([]);
      renderHistory();
    }
  });

  document.getElementById("historySearch").addEventListener("input", (e) => {
    renderHistory(e.target.value);
  });

  // Allow Ctrl/Cmd+Enter to generate
  document.getElementById("banglaInput").addEventListener("keydown", (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === "Enter") handleGenerate();
  });
});
