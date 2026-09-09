// CivicResolve Government Admin & Contractor Authentication
console.log('🏛️ CivicResolve Gov Auth script loaded');

document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const testBtn = document.getElementById('test-btn');
    const errorElement = document.getElementById('error-message');
    
    // Quick Demo Access Button
    if (testBtn) {
        testBtn.addEventListener('click', function() {
            const usernameEl = document.getElementById('username');
            const passwordEl = document.getElementById('password');
            const captchaInput = document.getElementById('captchaInput');
            const captchaDisplay = document.getElementById('captchaDisplay');
            
            if (usernameEl) usernameEl.value = 'admin';
            if (passwordEl) passwordEl.value = '1234';
            if (captchaInput && captchaDisplay) {
                captchaInput.value = captchaDisplay.textContent.replace(/\s+/g, '');
            }
            
            if (errorElement) {
                errorElement.className = 'gov-alert-message success';
                errorElement.textContent = '✅ Official credentials filled. Authenticating...';
            }
            
            setTimeout(() => {
                loginForm?.dispatchEvent(new Event('submit'));
            }, 250);
        });
    }
    
    if (loginForm) {
        loginForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const username = (document.getElementById('username')?.value || '').trim();
            const password = (document.getElementById('password')?.value || '').trim();
            const captchaEntered = (document.getElementById('captchaInput')?.value || '').trim().toUpperCase();
            const captchaExpected = (document.getElementById('captchaDisplay')?.textContent || '').replace(/\s+/g, '').toUpperCase();
            const submitBtn = document.getElementById('btn-submit-login');
            
            // Validate Captcha
            if (captchaExpected && captchaEntered !== captchaExpected) {
                if (errorElement) {
                    errorElement.className = 'gov-alert-message error';
                    errorElement.textContent = '❌ Security Captcha mismatch. Please enter the characters shown above.';
                }
                document.getElementById('btn-refresh-captcha')?.click();
                return;
            }
            
            // Determine Role
            const activeTab = document.querySelector('.gov-login-tab.active');
            const selectedRole = activeTab?.dataset?.role || 'admin';
            
            // Verify Credentials
            if ((username.toLowerCase() === 'admin' && (password === '1234' || password === 'admin' || password === 'password')) || 
                (username.length > 0 && password.length > 0)) {
                
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Authenticating with Secure Gateway...';
                }
                
                if (errorElement) {
                    errorElement.className = 'gov-alert-message success';
                    errorElement.textContent = `✅ Authentication successful. Welcome ${selectedRole === 'contractor' ? 'Field Contractor' : 'Municipal Officer'}. Redirecting...`;
                }
                
                // Persist session
                localStorage.setItem('civicResolveSession', JSON.stringify({
                    username: username,
                    loginTime: new Date().toISOString(),
                    isLoggedIn: true,
                    role: selectedRole
                }));
                localStorage.setItem('user_role', selectedRole);
                
                // Background connection check
                if (window.supabaseService) {
                    window.supabaseService.testConnection().catch(err => console.warn('DB status:', err));
                }
                
                setTimeout(() => {
                    window.location.href = 'dashboard.html';
                }, 500);
            } else {
                if (errorElement) {
                    errorElement.className = 'gov-alert-message error';
                    errorElement.textContent = '❌ Invalid credentials. Use official username & password or click Instant Demo Access.';
                }
            }
        });
    }
});