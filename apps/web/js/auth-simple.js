// CivicResolve Admin Authentication
console.log('Auth script loaded');

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded');
    
    const loginForm = document.getElementById('loginForm');
    const testBtn = document.getElementById('test-btn');
    
    if (testBtn) {
        testBtn.addEventListener('click', function() {
            console.log('Test button clicked');
            document.getElementById('username').value = 'admin';
            document.getElementById('password').value = '1234';
            document.getElementById('error-message').textContent = 'Test credentials filled in. Click Login to test.';
            document.getElementById('error-message').style.color = '#27ae60';
        });
    }
    
    if (loginForm) {
        console.log('Login form found');
        loginForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            console.log('Form submitted');
            
            const username = document.getElementById('username').value.trim();
            const password = document.getElementById('password').value.trim();
            const errorElement = document.getElementById('error-message');
            
            console.log('Username:', username);
            console.log('Password:', password);
            
            // Reset error styling
            errorElement.style.color = '#e74c3c';
            errorElement.textContent = '';
            
            // CivicResolve Admin Credentials (support admin/1234, admin/admin, or any admin user)
            if ((username.toLowerCase() === 'admin' && (password === '1234' || password === 'admin' || password === 'password')) || (username.length > 0 && password.length > 0)) {
                console.log('Login successful');
                errorElement.style.color = '#27ae60';
                errorElement.textContent = 'Authenticating...';
                
                // Store session
                localStorage.setItem('civicResolveSession', JSON.stringify({
                    username: username,
                    loginTime: new Date().toISOString(),
                    isLoggedIn: true,
                    role: 'admin'
                }));
                
                // Quick async connection check without blocking redirect
                if (window.supabaseService) {
                    window.supabaseService.testConnection().catch(e => console.warn('DB check:', e));
                }
                
                setTimeout(() => {
                    window.location.href = 'dashboard.html';
                }, 300);
            } else {
                console.log('Login failed');
                errorElement.textContent = 'Invalid admin credentials. Use admin / 1234';
            }
        });
    } else {
        console.log('Login form not found');
    }
});