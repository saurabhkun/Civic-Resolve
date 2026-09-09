// Dashboard functionality
class Dashboard {
    constructor() {
        this.init();
    }

    init() {
        // Check authentication first
        if (window.authManager) {
            window.authManager.checkAuthOnDashboard();
        }

        // Set up welcome message
        this.setupWelcomeMessage();
        
        // Set up navigation
        this.setupNavigation();
        
        // Set up logout functionality
        this.setupLogout();
        
        // Load default section
        this.showSection('overview');
    }

    setupWelcomeMessage() {
        const welcomeElement = document.getElementById('welcome-message');
        if (welcomeElement && window.authManager) {
            const session = window.authManager.getSession();
            if (session) {
                welcomeElement.textContent = `Welcome, ${session.username}!`;
            }
        }
    }

    setupNavigation() {
        const navLinks = document.querySelectorAll('.nav-link');
        console.log('Found nav links:', navLinks.length);
        
        navLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href');
                const section = link.getAttribute('data-section');
                
                console.log('Clicked link:', { href, section });
                
                // Check if this is an external navigation link (different page)
                if (href && href !== 'dashboard.html' && href !== '#' && !section) {
                    // Allow default navigation for external links
                    console.log('External navigation allowed');
                    return;
                }
                
                // Handle internal dashboard navigation
                e.preventDefault();
                if (section) {
                    console.log('Showing section:', section);
                    this.showSection(section);
                    
                    // Update active navigation
                    navLinks.forEach(l => l.classList.remove('active'));
                    link.classList.add('active');
                }
            });
        });
    }

    setupLogout() {
        const logoutBtn = document.getElementById('logout-btn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', () => {
                if (confirm('Are you sure you want to logout?')) {
                    if (window.authManager) {
                        window.authManager.logout();
                    }
                }
            });
        }
    }

    showSection(sectionId) {
        console.log('showSection called with:', sectionId);
        
        // Hide all sections
        const sections = document.querySelectorAll('.content-section');
        console.log('Found sections:', sections.length);
        
        sections.forEach(section => {
            section.classList.remove('active');
        });

        // Show selected section
        const targetSection = document.getElementById(sectionId);
        console.log('Target section found:', !!targetSection);
        
        if (targetSection) {
            targetSection.classList.add('active');
            console.log('Section made active:', sectionId);
        }

        // Load section-specific content
        this.loadSectionContent(sectionId);
    }

    loadSectionContent(sectionId) {
        switch(sectionId) {
            case 'overview':
                this.loadOverviewData();
                break;
            case 'users':
                this.loadUsersData();
                break;
            case 'settings':
                this.loadSettingsData();
                break;
            case 'reports':
                this.loadReportsData();
                break;
        }
    }

    loadOverviewData() {
        // Simulate loading dashboard statistics
        const stats = [
            { selector: '.stat-card:nth-child(1) .stat-number', value: this.generateRandomStat(1000, 2000) },
            { selector: '.stat-card:nth-child(2) .stat-number', value: this.generateRandomStat(20, 100) },
            { selector: '.stat-card:nth-child(3) .stat-number', value: '$' + this.generateRandomStat(10000, 50000).toLocaleString() },
            { selector: '.stat-card:nth-child(4) .stat-number', value: '+' + this.generateRandomStat(5, 25) + '%' }
        ];

        stats.forEach(stat => {
            const element = document.querySelector(stat.selector);
            if (element) {
                element.textContent = stat.value;
            }
        });

        // Load charts
        this.loadReportsOverTimeChart();
        this.loadCategoryBreakdownChart();
    }

    loadReportsOverTimeChart() {
        const ctx = document.getElementById('reportsChart');
        if (ctx) {
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [{
                        label: 'Reports Submitted',
                        data: [65, 78, 90, 81, 95, 105, 110, 125, 140, 155, 170, 185],
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        tension: 0.4,
                        fill: true
                    }, {
                        label: 'Reports Resolved',
                        data: [45, 65, 80, 70, 85, 95, 100, 115, 130, 145, 160, 175],
                        borderColor: '#27ae60',
                        backgroundColor: 'rgba(39, 174, 96, 0.1)',
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0,0,0,0.1)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            position: 'top',
                        },
                        title: {
                            display: false
                        }
                    }
                }
            });
        }
    }

    loadCategoryBreakdownChart() {
        const ctx = document.getElementById('categoryChart');
        if (ctx) {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Road Issues', 'Water & Sanitation', 'Public Safety', 'Parks & Recreation', 'Waste Management', 'Other'],
                    datasets: [{
                        data: [30, 25, 20, 15, 8, 2],
                        backgroundColor: [
                            '#3498db',
                            '#2ecc71',
                            '#e74c3c',
                            '#f39c12',
                            '#9b59b6',
                            '#95a5a6'
                        ],
                        borderWidth: 2,
                        borderColor: '#fff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true
                            }
                        },
                        title: {
                            display: false
                        }
                    }
                }
            });
        }
    }

    loadUsersData() {
        const usersSection = document.getElementById('users');
        if (usersSection && !usersSection.querySelector('.users-table')) {
            usersSection.innerHTML = `
                <h2>User Management</h2>
                <div class="users-table">
                    <table style="width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                        <thead style="background: #34495e; color: white;">
                            <tr>
                                <th style="padding: 1rem; text-align: left;">ID</th>
                                <th style="padding: 1rem; text-align: left;">Username</th>
                                <th style="padding: 1rem; text-align: left;">Email</th>
                                <th style="padding: 1rem; text-align: left;">Status</th>
                                <th style="padding: 1rem; text-align: left;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr style="border-bottom: 1px solid #eee;">
                                <td style="padding: 1rem;">1</td>
                                <td style="padding: 1rem;">john_doe</td>
                                <td style="padding: 1rem;">john@example.com</td>
                                <td style="padding: 1rem;"><span style="background: #27ae60; color: white; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.8rem;">Active</span></td>
                                <td style="padding: 1rem;">
                                    <button style="background: #3498db; color: white; border: none; padding: 0.25rem 0.5rem; border-radius: 4px; margin-right: 0.5rem; cursor: pointer;">Edit</button>
                                    <button style="background: #e74c3c; color: white; border: none; padding: 0.25rem 0.5rem; border-radius: 4px; cursor: pointer;">Delete</button>
                                </td>
                            </tr>
                            <tr style="border-bottom: 1px solid #eee;">
                                <td style="padding: 1rem;">2</td>
                                <td style="padding: 1rem;">jane_smith</td>
                                <td style="padding: 1rem;">jane@example.com</td>
                                <td style="padding: 1rem;"><span style="background: #f39c12; color: white; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.8rem;">Pending</span></td>
                                <td style="padding: 1rem;">
                                    <button style="background: #3498db; color: white; border: none; padding: 0.25rem 0.5rem; border-radius: 4px; margin-right: 0.5rem; cursor: pointer;">Edit</button>
                                    <button style="background: #e74c3c; color: white; border: none; padding: 0.25rem 0.5rem; border-radius: 4px; cursor: pointer;">Delete</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            `;
        }
    }

    loadSettingsData() {
        // Settings section content is already loaded in HTML
        // Database testing functionality is handled by the DatabaseTester class
        console.log('Settings section loaded');
    }

    loadReportsData() {
        const reportsSection = document.getElementById('reports');
        if (reportsSection && !reportsSection.querySelector('.reports-content')) {
            reportsSection.innerHTML = `
                <h2>Reports</h2>
                <div class="reports-content">
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem;">
                        <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                            <h3 style="color: #2c3e50; margin-bottom: 1rem;">User Activity Report</h3>
                            <p style="color: #7f8c8d; margin-bottom: 1rem;">Track user engagement and activity patterns</p>
                            <button style="background: #3498db; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Generate Report</button>
                        </div>
                        <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                            <h3 style="color: #2c3e50; margin-bottom: 1rem;">Revenue Report</h3>
                            <p style="color: #7f8c8d; margin-bottom: 1rem;">Analyze revenue trends and performance</p>
                            <button style="background: #27ae60; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Generate Report</button>
                        </div>
                        <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
                            <h3 style="color: #2c3e50; margin-bottom: 1rem;">System Performance</h3>
                            <p style="color: #7f8c8d; margin-bottom: 1rem;">Monitor system health and performance metrics</p>
                            <button style="background: #e67e22; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">Generate Report</button>
                        </div>
                    </div>
                </div>
            `;
        }
    }

    generateRandomStat(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new Dashboard();
});