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
            
            // CivicResolve Admin Credentials
            if (username === 'admin' && password === '1234') {
                console.log('Login successful');
                
                // Test database connection
                try {
                    if (window.supabaseService) {
                        const connected = await window.supabaseService.testConnection();
                        if (connected) {
                            console.log('Database connection verified');
                        }
                    }
                } catch (error) {
                    console.warn('Database connection test failed:', error);
                }
                
                // Store session
                localStorage.setItem('civicResolveSession', JSON.stringify({
                    username: username,
                    loginTime: new Date().toISOString(),
                    isLoggedIn: true,
                    role: 'admin'
                }));
                
                // Redirect to dashboard
                window.location.href = 'dashboard.html';
            } else {
                console.log('Login failed');
                errorElement.textContent = 'Invalid admin credentials. Use admin/1234';
            }
        });
    } else {
        console.log('Login form not found');
    }
});