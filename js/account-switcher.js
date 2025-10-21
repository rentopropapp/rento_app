// Account Switching Modal Component
class AccountSwitcher {
    constructor() {
        this.isModalOpen = false;
        this.accounts = [];
        this.currentUser = null;
        
        this.createModal();
        this.bindEvents();
    }
    
    createModal() {
        // Remove existing modal if it exists
        const existingModal = document.getElementById('accountSwitchModal');
        if (existingModal) {
            existingModal.remove();
        }
        
        // Create modal HTML
        const modalHTML = `
            <div id="accountSwitchModal" class="account-switch-modal">
                <div class="account-switch-content">
                    <div class="account-switch-header">
                        <h2 class="account-switch-title">Switch Account</h2>
                        <button class="account-switch-close" onclick="accountSwitcher.closeModal()">&times;</button>
                    </div>
                    <div id="accountsList" class="account-list">
                        <div class="loading-accounts">
                            <div class="loading"></div>
                            <span>Loading your accounts...</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
        
        // Append to body
        document.body.insertAdjacentHTML('beforeend', modalHTML);
    }
    
    bindEvents() {
        // Close modal when clicking outside
        document.addEventListener('click', (e) => {
            const modal = document.getElementById('accountSwitchModal');
            if (e.target === modal && this.isModalOpen) {
                this.closeModal();
            }
        });
        
        // Close modal on Escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isModalOpen) {
                this.closeModal();
            }
        });
    }
    
    async openModal() {
        try {
            this.currentUser = AuthManager.getCurrentUser();
            if (!this.currentUser) {
                throw new Error('No user logged in');
            }
            
            const modal = document.getElementById('accountSwitchModal');
            modal.classList.add('show');
            this.isModalOpen = true;
            
            // Load accounts
            await this.loadAccounts();
            
        } catch (error) {
            console.error('Error opening account switcher:', error);
            showNotification('Error loading accounts', 'error');
        }
    }
    
    closeModal() {
        const modal = document.getElementById('accountSwitchModal');
        modal.classList.remove('show');
        this.isModalOpen = false;
    }
    
    async loadAccounts() {
        try {
            this.accounts = await AuthManager.getUserAccounts(this.currentUser.email);
            this.renderAccounts();
        } catch (error) {
            console.error('Error loading accounts:', error);
            this.renderError();
        }
    }
    
    renderAccounts() {
        const container = document.getElementById('accountsList');
        
        if (this.accounts.length === 0) {
            container.innerHTML = `
                <div class="no-accounts">
                    <p>No additional accounts found.</p>
                </div>
            `;
            return;
        }
        
        const accountsHTML = this.accounts.map(account => {
            const isCurrentAccount = account.user_id === this.currentUser.id;
            const initials = this.getInitials(account.name);
            const roleDisplayName = this.getRoleDisplayName(account.user_role);
            const roleBadgeClass = `role-${account.user_role}`;
            
            return `
                <div class="account-option ${isCurrentAccount ? 'current' : ''}" 
                     onclick="accountSwitcher.switchAccount('${account.user_id}')"
                     data-account-id="${account.user_id}">
                    <div class="account-avatar">
                        ${account.profile_photo_url ? 
                            `<img src="${account.profile_photo_url}" alt="${account.name}">` : 
                            initials
                        }
                    </div>
                    <div class="account-info">
                        <div class="account-name">${account.name}</div>
                        <div class="account-role">
                            <span class="account-role-badge ${roleBadgeClass}">
                                ${roleDisplayName}
                            </span>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        container.innerHTML = accountsHTML;
    }
    
    renderError() {
        const container = document.getElementById('accountsList');
        container.innerHTML = `
            <div class="no-accounts">
                <p>Error loading accounts. Please try again.</p>
                <button class="cta-button" onclick="accountSwitcher.loadAccounts()" 
                        style="margin-top: 16px; padding: 8px 16px; font-size: 0.9rem;">
                    Retry
                </button>
            </div>
        `;
    }
    
    async switchAccount(accountId) {
        try {
            // Find the selected account
            const selectedAccount = this.accounts.find(account => account.user_id === accountId);
            if (!selectedAccount) {
                throw new Error('Account not found');
            }
            
            // Don't switch if it's already the current account
            if (selectedAccount.user_id === this.currentUser.id) {
                this.closeModal();
                return;
            }
            
            // Show loading state
            const accountElement = document.querySelector(`[data-account-id="${accountId}"]`);
            if (accountElement) {
                accountElement.style.opacity = '0.5';
                accountElement.style.pointerEvents = 'none';
            }
            
            // Switch to the selected account
            await AuthManager.switchToAccount(selectedAccount);
            
        } catch (error) {
            console.error('Error switching account:', error);
            showNotification('Error switching account. Please try again.', 'error');
            
            // Reset loading state
            const accountElement = document.querySelector(`[data-account-id="${accountId}"]`);
            if (accountElement) {
                accountElement.style.opacity = '1';
                accountElement.style.pointerEvents = 'auto';
            }
        }
    }
    
    getInitials(name) {
        if (!name) return 'U';
        return name.split(' ')
            .map(word => word.charAt(0))
            .join('')
            .toUpperCase()
            .substring(0, 2);
    }
    
    getRoleDisplayName(role) {
        const roleNames = {
            'tenant': 'Tenant',
            'broker': 'Broker',
            'property_manager': 'Property Manager'
        };
        return roleNames[role] || role;
    }
}

// Initialize global instance
let accountSwitcher;

// Initialize when DOM is ready
function initAccountSwitcher() {
    if (!accountSwitcher) {
        accountSwitcher = new AccountSwitcher();
        window.accountSwitcher = accountSwitcher;
    }
}

// Auto-initialize on DOM ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAccountSwitcher);
} else {
    initAccountSwitcher();
}

// Export for use in other modules
window.AccountSwitcher = AccountSwitcher;
window.initAccountSwitcher = initAccountSwitcher;
