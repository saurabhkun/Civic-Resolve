// Authentication functionality
class AuthManager {
    constructor() {
        this.init();
    }

    init() {
        // Check if user is already logged in when page loads
        if (this.isLoggedIn() && window.location.pathname.includes('index.html')) {
            window.location.href = 'dashboard.html';
        }

        // Add event listener for login form
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', (e) => this.handleLogin(e));
        }
        
        // Add event listener for test button
        const testBtn = document.getElementById('test-btn');
        if (testBtn) {
            testBtn.addEventListener('click', () => this.testLogin());
        }
    }

    handleLogin(event) {
        event.preventDefault();
        
        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value.trim();
        const errorElement = document.getElementById('error-message');
        
        // Clear previous error messages
        errorElement.textContent = '';
        
        // Debug logging
        console.log('Login attempt:', { username, password });
        console.log('Username length:', username.length);
        console.log('Password length:', password.length);
        
        // Simple validation (in a real app, this would be server-side)
        if (this.validateCredentials(username, password)) {
            // Store session information
            this.setSession(username);
            
            // Redirect to dashboard
            window.location.href = 'dashboard.html';
        } else {
            errorElement.textContent = 'Invalid username or password';
        }
    }

    testLogin() {
        document.getElementById('username').value = 'admin';
        document.getElementById('password').value = 'admin123';
        const errorElement = document.getElementById('error-message');
        errorElement.textContent = 'Test credentials filled in. Click Login to test.';
        errorElement.style.color = '#27ae60';
    }

    validateCredentials(username, password) {
        // Centralized configuration or environment credentials
        const config = window.CIVIC_CONFIG || {};
        const validCredentials = config.adminCredentials || [
            { username: 'admin', password: 'admin123' },
            { username: 'administrator', password: 'password' },
            { username: 'root', password: 'root123' }
        ];

        return validCredentials.some(cred => 
            cred.username === username && cred.password === password
        );
    }

    setSession(username) {
        const sessionData = {
            username: username,
            loginTime: new Date().toISOString(),
            isLoggedIn: true
        };
        
        localStorage.setItem('adminSession', JSON.stringify(sessionData));
    }

    getSession() {
        const sessionData = localStorage.getItem('adminSession');
        return sessionData ? JSON.parse(sessionData) : null;
    }

    isLoggedIn() {
        const session = this.getSession();
        return session && session.isLoggedIn;
    }

    logout() {
        localStorage.removeItem('adminSession');
        window.location.href = 'index.html';
    }

    checkAuthOnDashboard() {
        if (!this.isLoggedIn()) {
            window.location.href = 'index.html';
        }
    }
}

// Initialize authentication when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.authManager = new AuthManager();
});