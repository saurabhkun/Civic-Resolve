// Centralized Configuration for CivicResolve Web Dashboard
// Allows runtime overrides via window.__ENV__ or localStorage without leaking raw secrets

(function() {
    const env = window.__ENV__ || {};
    
    window.CIVIC_CONFIG = {
        supabaseUrl: env.SUPABASE_URL || localStorage.getItem('SUPABASE_URL') || 'https://ooryormddgyvgthggnzo.supabase.co',
        supabaseKey: env.SUPABASE_ANON_KEY || localStorage.getItem('SUPABASE_ANON_KEY') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vcnlvcm1kZGd5dmd0aGdnbnpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNzQyNzIsImV4cCI6MjA3Mzk1MDI3Mn0.fkqBfcvgYy90HfJWPrqBnNSTCbIzlSN9c0QpE7eYavg',
        geminiApiKey: env.GEMINI_API_KEY || localStorage.getItem('GEMINI_API_KEY') || '',
        appVersion: '2.0.0',
        environment: env.NODE_ENV || 'production'
    };

    console.log('⚙️ CivicResolve Configuration loaded (Env/Secure Store)');
})();

