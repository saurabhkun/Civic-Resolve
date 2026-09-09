// AI Municipal Copilot - Grounded Civic Intelligence Assistant
class CivicCopilot {
    constructor() {
        this.isOpen = false;
        this.history = [];
        this.isProcessing = false;
        this.init();
    }

    init() {
        this.injectUI();
        this.bindEvents();
        console.log('✨ AI Municipal Copilot initialized');
    }

    injectUI() {
        // Create Floating Action Button
        const fab = document.createElement('button');
        fab.id = 'copilot-fab';
        fab.className = 'copilot-fab';
        fab.innerHTML = `
            <span class="copilot-fab-sparkle">✨</span>
            <span>Civic Copilot</span>
        `;
        document.body.appendChild(fab);

        // Create Drawer HTML
        const overlay = document.createElement('div');
        overlay.id = 'copilot-overlay';
        overlay.className = 'copilot-overlay';

        const drawer = document.createElement('div');
        drawer.id = 'copilot-drawer';
        drawer.className = 'copilot-drawer';
        drawer.innerHTML = `
            <div class="copilot-header">
                <div class="copilot-header-info">
                    <div class="copilot-avatar">✨</div>
                    <div>
                        <h3 class="copilot-header-title">Municipal Copilot</h3>
                        <p class="copilot-header-sub">Grounded Civic Intelligence</p>
                    </div>
                </div>
                <button id="copilot-close" class="copilot-close-btn" title="Close Copilot">✕</button>
            </div>

            <div class="copilot-chips-container">
                <div class="copilot-chips-label">Quick Prompts</div>
                <div class="copilot-chips-grid">
                    <button class="copilot-chip" data-prompt="Summarize high-priority complaints this week">🚨 High-priority this week</button>
                    <button class="copilot-chip" data-prompt="Show recurring issues in waste management">🗑️ Waste recurring issues</button>
                    <button class="copilot-chip" data-prompt="Which complaints are currently overdue?">⏳ Overdue complaints</button>
                    <button class="copilot-chip" data-prompt="Generate daily municipal handover report">📋 Daily handover report</button>
                </div>
            </div>

            <div id="copilot-messages" class="copilot-messages">
                <div class="copilot-msg assistant">
                    <div class="copilot-msg-bubble">
                        👋 <strong>Hello Officer!</strong> I am your AI Municipal Copilot. I analyze live complaints from your database in real-time. Ask me to summarize queues, detect hotspot patterns, or generate executive handover reports.
                    </div>
                    <span class="copilot-msg-time">${this.formatTime(new Date())}</span>
                </div>
            </div>

            <div class="copilot-footer">
                <form id="copilot-form" class="copilot-input-form">
                    <input type="text" id="copilot-input" class="copilot-input" placeholder="Ask Copilot about municipal complaints..." autocomplete="off">
                    <button type="submit" id="copilot-send" class="copilot-send-btn" title="Send message">➤</button>
                </form>
            </div>
        `;

        document.body.appendChild(overlay);
        document.body.appendChild(drawer);
    }

    bindEvents() {
        const fab = document.getElementById('copilot-fab');
        const closeBtn = document.getElementById('copilot-close');
        const overlay = document.getElementById('copilot-overlay');
        const form = document.getElementById('copilot-form');
        const chips = document.querySelectorAll('.copilot-chip');

        fab.addEventListener('click', () => this.toggle(true));
        closeBtn.addEventListener('click', () => this.toggle(false));
        overlay.addEventListener('click', () => this.toggle(false));

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            const input = document.getElementById('copilot-input');
            const query = input.value.trim();
            if (query && !this.isProcessing) {
                input.value = '';
                this.ask(query);
            }
        });

        chips.forEach(chip => {
            chip.addEventListener('click', () => {
                const prompt = chip.getAttribute('data-prompt');
                if (prompt && !this.isProcessing) {
                    this.ask(prompt);
                }
            });
        });
    }

    toggle(open) {
        this.isOpen = open;
        const drawer = document.getElementById('copilot-drawer');
        const overlay = document.getElementById('copilot-overlay');
        if (open) {
            drawer.classList.add('open');
            overlay.classList.add('active');
            document.getElementById('copilot-input')?.focus();
        } else {
            drawer.classList.remove('open');
            overlay.classList.remove('active');
        }
    }

    async fetchActiveContext() {
        try {
            if (window.supabaseService) {
                const reports = await window.supabaseService.getAllReports({ limit: 50 });
                if (reports && reports.length > 0) {
                    return reports.map(r => ({
                        id: r.id,
                        title: r.title,
                        category: r.category,
                        priority: r.priority,
                        status: r.status,
                        location: r.location,
                        created_at: r.created_at,
                        assigned_to: r.assigned_to || r.assigned_officer_name || 'Unassigned'
                    }));
                }
            }
        } catch (e) {
            console.warn('Could not fetch active context via SupabaseService:', e);
        }

        // Direct fetch fallback
        try {
            const config = window.CIVIC_CONFIG || {};
            const url = `${config.supabaseUrl}/rest/v1/reports?select=id,title,category,priority,status,location,created_at,assigned_to&order=created_at.desc&limit=50`;
            const resp = await fetch(url, {
                headers: {
                    'apikey': config.supabaseKey,
                    'Authorization': `Bearer ${config.supabaseKey}`,
                    'Content-Type': 'application/json'
                }
            });
            if (resp.ok) {
                return await resp.json();
            }
        } catch (e) {
            console.error('Direct context fetch error:', e);
        }

        return [];
    }

    async ask(query) {
        this.isProcessing = true;
        this.appendMessage('user', query);

        const loadingId = this.showLoading();

        try {
            const reports = await this.fetchActiveContext();
            let apiKey = config.geminiApiKey || localStorage.getItem('GEMINI_API_KEY');

            if (!apiKey) {
                const userKey = prompt('🔑 Enter your Google Gemini API Key for Civic Copilot:\n(This will be securely saved only to your local browser storage)');
                if (userKey && userKey.trim()) {
                    apiKey = userKey.trim();
                    localStorage.setItem('GEMINI_API_KEY', apiKey);
                    if (window.CIVIC_CONFIG) window.CIVIC_CONFIG.geminiApiKey = apiKey;
                } else {
                    throw new Error('Gemini API key is required to use the Municipal Copilot. Set it via localStorage or window.__ENV__.');
                }
            }

            const prompt = `
You are the Civic Intelligence Officer Assistant for CivicResolve Municipal Administration.
Answer the user's question using ONLY the provided list of 50 active/recent complaints.
Always cite the Report ID with a hash tag (e.g., #104) and the location whenever discussing specific complaints so the administrator can reference them.
Provide concise, actionable executive summaries with bullet points and bold highlights.

ACTIVE COMPLAINTS DATA (JSON):
${JSON.stringify(reports, null, 2)}

USER QUESTION:
${query}
`;

            const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    contents: [{
                        parts: [{ text: prompt }]
                    }],
                    generationConfig: {
                        temperature: 0.2,
                        maxOutputTokens: 1000
                    }
                })
            });

            if (!response.ok) {
                const errData = await response.json();
                throw new Error(errData?.error?.message || `Gemini API returned HTTP ${response.status}`);
            }

            const data = await response.json();
            const textResponse = data.candidates?.[0]?.content?.parts?.[0]?.text || "No response generated by assistant.";

            this.removeLoading(loadingId);
            this.appendMessage('assistant', textResponse);

        } catch (error) {
            console.error('Copilot Query Error:', error);
            this.removeLoading(loadingId);
            this.appendMessage('assistant', `⚠️ **Error querying Copilot:** ${error.message}\n\nPlease check your internet connection and API key configuration.`);
        } finally {
            this.isProcessing = false;
        }
    }

    appendMessage(role, rawContent) {
        const container = document.getElementById('copilot-messages');
        const msgDiv = document.createElement('div');
        msgDiv.className = `copilot-msg ${role}`;

        const formattedHtml = role === 'user' 
            ? this.escapeHtml(rawContent) 
            : this.formatMarkdown(rawContent);

        msgDiv.innerHTML = `
            <div class="copilot-msg-bubble">
                ${formattedHtml}
            </div>
            <span class="copilot-msg-time">${this.formatTime(new Date())}</span>
        `;

        container.appendChild(msgDiv);
        container.scrollTop = container.scrollHeight;
    }

    showLoading() {
        const container = document.getElementById('copilot-messages');
        const id = 'copilot-typing-' + Date.now();
        const typingDiv = document.createElement('div');
        typingDiv.id = id;
        typingDiv.className = 'copilot-msg assistant';
        typingDiv.innerHTML = `
            <div class="copilot-msg-bubble copilot-typing">
                <div class="copilot-dot"></div>
                <div class="copilot-dot"></div>
                <div class="copilot-dot"></div>
            </div>
        `;
        container.appendChild(typingDiv);
        container.scrollTop = container.scrollHeight;
        return id;
    }

    removeLoading(id) {
        const el = document.getElementById(id);
        if (el) el.remove();
    }

    formatMarkdown(text) {
        let html = this.escapeHtml(text);

        // Bold **text**
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        // Italic *text*
        html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');

        // Headers
        html = html.replace(/^### (.*$)/gim, '<h5 style="margin:8px 0 4px 0;font-size:14px;color:#0f172a;">$1</h5>');
        html = html.replace(/^## (.*$)/gim, '<h4 style="margin:10px 0 4px 0;font-size:15px;color:#0f172a;">$1</h4>');
        html = html.replace(/^# (.*$)/gim, '<h3 style="margin:12px 0 6px 0;font-size:16px;color:#0f172a;">$1</h3>');

        // Bullet points
        html = html.replace(/^\s*[\-\*]\s+(.*)$/gim, '<li style="margin-left:14px;">$1</li>');
        html = html.replace(/(<li.*<\/li>)/s, '<ul style="margin:6px 0;padding:0;">$1</ul>');

        // Line breaks
        html = html.replace(/\n\n/g, '<p style="margin:6px 0;"></p>');
        html = html.replace(/\n/g, '<br>');

        // Make ticket IDs clickable (#123 or [#123])
        html = html.replace(/(?:\[#|#)(\d+)\]?/g, (match, id) => {
            return `<button type="button" class="copilot-ticket-badge" onclick="window.copilot.openReport('${id}')" title="Open Report #${id}">#${id} ↗</button>`;
        });

        return html;
    }

    openReport(reportId) {
        console.log('📌 Copilot opening report:', reportId);
        if (window.dashboard && typeof window.dashboard.showReportDetails === 'function') {
            window.dashboard.showReportDetails(reportId);
        } else if (window.reportsPage && typeof window.reportsPage.showReportDetails === 'function') {
            window.reportsPage.showReportDetails(reportId);
        } else if (window.location.pathname.includes('reports.html')) {
            window.location.href = `reports.html?id=${reportId}`;
        } else {
            window.location.href = `dashboard.html?id=${reportId}`;
        }
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    formatTime(date) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
}

// Instantiate and expose globally
document.addEventListener('DOMContentLoaded', () => {
    window.copilot = new CivicCopilot();
});
