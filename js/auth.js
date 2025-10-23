// Supabase configuration (allow runtime override for your own project)
const SUPABASE_URL = (window.RENTO_SUPABASE_URL || localStorage.getItem('SUPABASE_URL')) || 'https://alsmzgubmgjcibezlpbs.supabase.co';
const SUPABASE_ANON_KEY = (window.RENTO_SUPABASE_ANON_KEY || localStorage.getItem('SUPABASE_ANON_KEY')) || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsc216Z3VibWdqY2liZXpscGJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4MTI1ODQsImV4cCI6MjA3NjM4ODU4NH0.Mgx25hvycKJTt8JHJT9O9T3HWBqnHtIoRQuKdkUeQ-Y';

// Helper to set config at runtime if needed
window.setSupabaseConfig = function(url, anonKey) {
    if (url) localStorage.setItem('SUPABASE_URL', url);
    if (anonKey) localStorage.setItem('SUPABASE_ANON_KEY', anonKey);
    location.reload();
};

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

class AuthManager {
    static async signUp(userData) {
        try {
            // Sign up user with Supabase Auth
            const { data: authData, error: authError } = await supabase.auth.signUp({
                email: userData.email.trim().toLowerCase(),
                password: userData.password,
                options: {
                    data: {
                        name: userData.name,
                        phone: userData.phone,
                        occupation: userData.occupation,
                        birthday: userData.birthday,
                        user_role: userData.role
                    },
                    emailRedirectTo: window.location.origin + '/auth/login.html'
                }
            });

            if (authError) {
                throw new Error(authError.message);
            }

            // Create user profile in users table (best-effort)
            if (authData?.user?.id) {
                const { error: profileError } = await supabase
                    .from('users')
                    .insert([
                        {
                            user_id: authData.user.id,
                            email: userData.email.trim().toLowerCase(),
                            name: userData.name,
                            phone_number: userData.phone,
                            occupation: userData.occupation,
                            birthday: userData.birthday,
                            user_role: userData.role,
                            created_at: new Date().toISOString(),
                            updated_at: new Date().toISOString()
                        }
                    ]);

                if (profileError) {
                    console.error('Profile creation error:', profileError);
                    // Continue even if profile creation fails - user can update later
                }
            }

            // If email confirmation is required, authData.session will be null
            if (!authData?.session) {
                // Show info and send to login
                if (window.showNotification) {
                    showNotification('Account created. Please check your email to confirm your address before signing in.', 'info');
                }
                window.location.href = '../auth/login.html';
                return;
            }

            // Redirect to profile photo upload when session exists immediately
            window.location.href = '../auth/profile-photo.html';

        } catch (error) {
            throw error;
        }
    }

    static async signIn(email, password, role) {
        try {
            // Sign in user
            const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
                email: (email || '').trim().toLowerCase(),
                password: password
            });

            if (authError) {
                const msg = (authError.message || '').toLowerCase();
                if (msg.includes('email not confirmed')) {
                    throw new Error('Please confirm your email address before signing in.');
                }
                if (msg.includes('invalid login credentials')) {
                    throw new Error('Invalid email or password.');
                }
                throw new Error(authError.message);
            }

            // Get user profile to verify role
            const { data: userData, error: userError } = await supabase
                .from('users')
                .select('*')
                .eq('user_id', authData.user.id)
                .single();

            if (userError) {
                console.error('User data fetch error:', userError);
                // Continue with auth data if profile fetch fails
            }

            const userRole = userData?.user_role || role;

            // Store user data in localStorage
            localStorage.setItem('user', JSON.stringify({
                id: authData.user.id,
                email: authData.user.email,
                role: userRole,
                ...userData
            }));

            // Redirect based on role
            this.redirectAfterLogin(userRole);

        } catch (error) {
            throw error;
        }
    }

    static redirectAfterLogin(role) {
        switch (role) {
            case 'tenant':
                window.location.href = '../tenant/home.html';
                break;
            case 'broker':
                window.location.href = '../broker/listings.html';
                break;
            case 'property_manager':
                window.location.href = '../property-manager/properties.html';
                break;
            default:
                window.location.href = '../index.html';
        }
    }

    static async resetPassword(email) {
        try {
            const { error } = await supabase.auth.resetPasswordForEmail(email, {
                redirectTo: window.location.origin + '/auth/login.html'
            });

            if (error) {
                throw new Error(error.message);
            }

        } catch (error) {
            throw error;
        }
    }

    static async signOut() {
        try {
            const { error } = await supabase.auth.signOut();
            if (error) {
                throw new Error(error.message);
            }

            localStorage.removeItem('user');
            window.location.href = '../index.html';

        } catch (error) {
            throw error;
        }
    }

    static async switchAccount() {
        try {
            const { error } = await supabase.auth.signOut();
            if (error) {
                throw new Error(error.message);
            }

            localStorage.removeItem('user');
            window.location.href = '../auth/login.html';

        } catch (error) {
            console.error('Switch account error:', error);
            // Even if there's an error, still redirect to login
            localStorage.removeItem('user');
            window.location.href = '../auth/login.html';
        }
    }

    static getCurrentUser() {
        const userData = localStorage.getItem('user');
        return userData ? JSON.parse(userData) : null;
    }

    static async checkAuth() {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session) {
            window.location.href = '../auth/login.html';
            return null;
        }

        return session.user;
    }

    static async updateProfile(updates) {
        try {
            const user = this.getCurrentUser();
            if (!user) throw new Error('No user found');

            const { error } = await supabase
                .from('users')
                .update({
                    ...updates,
                    updated_at: new Date().toISOString()
                })
                .eq('user_id', user.id);

            if (error) {
                throw new Error(error.message);
            }

            // Update localStorage
            const updatedUser = { ...user, ...updates };
            localStorage.setItem('user', JSON.stringify(updatedUser));

            return updatedUser;

        } catch (error) {
            throw error;
        }
    }

    static async getUserAccounts(email) {
        try {
            // Get all accounts associated with this email
            const { data, error } = await supabase
                .from('users')
                .select('user_id, name, email, user_role, profile_photo_url, phone_number')
                .eq('email', email)
                .order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data || [];

        } catch (error) {
            console.error('Error fetching accounts from database:', error);
            // Return mock accounts for testing
            return this.getMockAccounts(email);
        }
    }
    
    static getMockAccounts(email) {
        // Mock accounts for demonstration - same email with different roles
        const mockAccounts = [
            {
                user_id: 'tenant-123',
                name: 'John Smith',
                email: email,
                user_role: 'tenant',
                profile_photo_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face&auto=format&q=80',
                phone_number: '+1 (555) 123-4567'
            },
            {
                user_id: 'broker-456',
                name: 'John Smith',
                email: email,
                user_role: 'broker',
                profile_photo_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face&auto=format&q=80',
                phone_number: '+1 (555) 123-4567'
            },
            {
                user_id: 'property_manager-789',
                name: 'John Smith',
                email: email,
                user_role: 'property_manager',
                profile_photo_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face&auto=format&q=80',
                phone_number: '+1 (555) 123-4567'
            }
        ];
        
        return mockAccounts;
    }

    static async switchToAccount(accountData) {
        try {
            // For demo purposes, allow switching without strict email verification
            // In production, you'd want to verify the account belongs to the current user
            
            // Store the selected account data
            localStorage.setItem('user', JSON.stringify({
                id: accountData.user_id,
                email: accountData.email,
                role: accountData.user_role,
                user_role: accountData.user_role, // Support both formats
                name: accountData.name,
                phone_number: accountData.phone_number,
                profile_photo_url: accountData.profile_photo_url
            }));

            // Show success notification
            if (window.showNotification) {
                showNotification(`Switched to ${accountData.name} (${this.getRoleDisplayName(accountData.user_role)})`, 'success');
            }
            
            // Small delay to show the notification, then redirect
            setTimeout(() => {
                this.redirectAfterLogin(accountData.user_role);
            }, 1000);

        } catch (error) {
            throw error;
        }
    }
    
    static getRoleDisplayName(role) {
        const roleNames = {
            'tenant': 'Tenant',
            'broker': 'Broker', 
            'property_manager': 'Property Manager'
        };
        return roleNames[role] || role;
    }

    static async uploadProfilePhoto(file) {
        try {
            const user = this.getCurrentUser();
            if (!user) throw new Error('No user found');

            const fileExt = file.name.split('.').pop();
            const fileName = `${user.id}-${Math.random()}.${fileExt}`;
            const filePath = `profile-photos/${fileName}`;

            const { error: uploadError } = await supabase.storage
                .from('avatars')
                .upload(filePath, file);

            if (uploadError) {
                throw new Error(uploadError.message);
            }

            const { data } = supabase.storage
                .from('avatars')
                .getPublicUrl(filePath);

            // Update user profile with photo URL
            await this.updateProfile({ profile_photo_url: data.publicUrl });

            return data.publicUrl;

        } catch (error) {
            throw error;
        }
    }
}

// Database operations class
class DatabaseManager {
    static async createProperty(propertyData) {
        try {
            const user = AuthManager.getCurrentUser();
            if (!user) throw new Error('No user found');

            const { data, error } = await supabase
                .from('properties')
                .insert([{
                    ...propertyData,
                    owner_id: user.id,
                    created_at: new Date().toISOString(),
                    updated_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getProperties(filters = {}) {
        try {
            let query = supabase
                .from('properties')
                .select(`
                    *,
                    users:owner_id (
                        name,
                        phone_number,
                        rating,
                        bio
                    )
                `);

            // Apply filters
            if (filters.status) {
                query = query.eq('status', filters.status);
            }
            if (filters.property_type) {
                query = query.eq('property_type', filters.property_type);
            }
            if (filters.location) {
                query = query.ilike('location', `%${filters.location}%`);
            }
            if (filters.min_price) {
                query = query.gte('price', filters.min_price);
            }
            if (filters.max_price) {
                query = query.lte('price', filters.max_price);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getPropertyById(propertyId) {
        try {
            const { data, error } = await supabase
                .from('properties')
                .select(`
                    *,
                    users:owner_id (
                        name,
                        phone_number,
                        rating,
                        bio
                    )
                `)
                .eq('property_id', propertyId)
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getUserProperties(userId) {
        try {
            const { data, error } = await supabase
                .from('properties')
                .select('*')
                .eq('owner_id', userId)
                .order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async createBooking(bookingData) {
        try {
            const { data, error } = await supabase
                .from('bookings')
                .insert([{
                    ...bookingData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getBookings(filters = {}) {
        try {
            let query = supabase
                .from('bookings')
                .select(`
                    *,
                    properties (*),
                    users:tenant_id (
                        name,
                        phone_number,
                        email
                    )
                `);

            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.status) {
                query = query.eq('status', filters.status);
            }

            const { data, error } = await query.order('viewing_date', { ascending: true });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async createPayment(paymentData) {
        try {
            const { data, error } = await supabase
                .from('payments')
                .insert([paymentData])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getPayments(filters = {}) {
        try {
            let query = supabase
                .from('payments')
                .select(`
                    *,
                    properties (property_name, location),
                    tenants (
                        users (name)
                    )
                `);

            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }

            const { data, error } = await query.order('payment_date', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async createComplaint(complaintData) {
        try {
            const { data, error } = await supabase
                .from('complaints')
                .insert([{
                    ...complaintData,
                    created_at: new Date().toISOString(),
                    updated_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async updateComplaint(complaintId, updateData) {
        try {
            const { data, error } = await supabase
                .from('complaints')
                .update({
                    ...updateData,
                    updated_at: new Date().toISOString()
                })
                .eq('complaint_id', complaintId)
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getComplaints(filters = {}) {
        try {
            let query = supabase
                .from('complaints')
                .select(`
                    *,
                    properties (property_name, location),
                    tenants (
                        users (name, phone_number)
                    )
                `);

            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.status) {
                query = query.eq('status', filters.status);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    // Notice/Message Management Functions
    static async createNotice(noticeData) {
        try {
            const { data, error } = await supabase
                .from('notices')
                .insert([{
                    ...noticeData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getNotices(filters = {}) {
        try {
            let query = supabase
                .from('notices')
                .select(`
                    *,
                    properties (property_name, location),
                    from_user:from_user_id (name, user_role),
                    to_user:to_user_id (name, user_role),
                    tenants!tenant_id (
                        users (name)
                    )
                `);

            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.to_user_id) {
                query = query.eq('to_user_id', filters.to_user_id);
            }
            if (filters.from_user_id) {
                query = query.eq('from_user_id', filters.from_user_id);
            }
            if (filters.is_read !== undefined) {
                query = query.eq('is_read', filters.is_read);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async markNoticeAsRead(noticeId) {
        try {
            const { data, error } = await supabase
                .from('notices')
                .update({ is_read: true })
                .eq('notice_id', noticeId)
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async createLead(leadData) {
        try {
            const { data, error } = await supabase
                .from('leads')
                .insert([{
                    ...leadData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async updateLead(leadId, updateData) {
        try {
            const { data, error } = await supabase
                .from('leads')
                .update(updateData)
                .eq('lead_id', leadId)
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getLeads(filters = {}) {
        try {
            let query = supabase
                .from('leads')
                .select(`
                    *,
                    users:tenant_id (name, email, phone_number),
                    assigned_broker:assigned_broker_id (name, email, phone_number)
                `);

            if (filters.status) {
                query = query.eq('status', filters.status);
            }
            if (filters.assigned_broker_id) {
                query = query.eq('assigned_broker_id', filters.assigned_broker_id);
            }
            if (filters.priority) {
                query = query.eq('priority', filters.priority);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getTenantProperties(tenantId) {
        try {
            const { data, error } = await supabase
                .from('tenants')
                .select(`
                    *,
                    properties (*),
                    users:tenant_id (name, email, phone_number)
                `)
                .eq('tenant_id', tenantId)
                .eq('lease_status', 'active')
                .order('lease_start_date', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async createExpense(expenseData) {
        try {
            const { data, error } = await supabase
                .from('expenses')
                .insert([{
                    ...expenseData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getExpenses(filters = {}) {
        try {
            let query = supabase
                .from('expenses')
                .select(`
                    *,
                    properties (property_name, location)
                `);

            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }

            const { data, error } = await query.order('expense_date', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    static async getNotices(filters = {}) {
        try {
            let query = supabase
                .from('notices')
                .select(`
                    *,
                    properties (property_name, location),
                    users:from_user_id (name)
                `);

            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;

        } catch (error) {
            throw error;
        }
    }

    // Property Rating Functions
    static async createPropertyRating(ratingData) {
        try {
            const { data, error } = await supabase
                .from('property_ratings')
                .upsert([{
                    ...ratingData,
                    created_at: new Date().toISOString()
                }], {
                    onConflict: 'property_id,user_id'
                })
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            // Update property owner's average rating
            await this.updateOwnerRating(ratingData.property_id);

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getPropertyRatings(propertyId) {
        try {
            const { data, error } = await supabase
                .from('property_ratings')
                .select(`
                    *,
                    users (name, profile_photo_url)
                `)
                .eq('property_id', propertyId)
                .order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async updateOwnerRating(propertyId) {
        try {
            // Get property owner
            const { data: property, error: propertyError } = await supabase
                .from('properties')
                .select('owner_id')
                .eq('property_id', propertyId)
                .single();

            if (propertyError || !property) {
                throw new Error('Property not found');
            }

            // Calculate average rating for all properties owned by this user
            const { data: avgRating, error: avgError } = await supabase
                .rpc('calculate_owner_average_rating', {
                    owner_id: property.owner_id
                });

            if (avgError) {
                console.error('Error calculating average rating:', avgError);
                return;
            }

            // Update user's rating
            const { error: updateError } = await supabase
                .from('users')
                .update({ 
                    rating: parseFloat(avgRating || 5.0).toFixed(2),
                    updated_at: new Date().toISOString()
                })
                .eq('user_id', property.owner_id);

            if (updateError) {
                console.error('Error updating user rating:', updateError);
            }
        } catch (error) {
            console.error('Error updating owner rating:', error);
        }
    }

    // Tenant Management Functions
    static async createTenant(tenantData) {
        try {
            const { data, error } = await supabase
                .from('tenants')
                .insert([{
                    ...tenantData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getTenants(filters = {}) {
        try {
            let query = supabase
                .from('tenants')
                .select(`
                    *,
                    properties (property_name, location),
                    users (name, email, phone_number, profile_photo_url)
                `);

            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.user_id) {
                query = query.eq('user_id', filters.user_id);
            }
            if (filters.status) {
                query = query.eq('status', filters.status);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    // Tenant Agreement Functions
    static async createTenantAgreement(agreementData) {
        try {
            const { data, error } = await supabase
                .from('tenant_agreements')
                .insert([{
                    ...agreementData,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }

    static async getTenantAgreements(filters = {}) {
        try {
            let query = supabase
                .from('tenant_agreements')
                .select(`
                    *,
                    tenants (
                        users (name, email, phone_number)
                    ),
                    properties (property_name, location)
                `);

            if (filters.tenant_id) {
                query = query.eq('tenant_id', filters.tenant_id);
            }
            if (filters.property_id) {
                query = query.eq('property_id', filters.property_id);
            }
            if (filters.status) {
                query = query.eq('status', filters.status);
            }

            const { data, error } = await query.order('created_at', { ascending: false });

            if (error) {
                throw new Error(error.message);
            }

            return data;
        } catch (error) {
            throw error;
        }
    }
}

// Utility functions
function formatCurrency(amount) {
    if (amount == null) return 'N/A';
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(amount);
}

function showNotification(message, type = 'info') {
    // Remove any existing notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(n => n.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#10b981' : type === 'error' ? '#ef4444' : '#3b82f6'};
        color: white;
        padding: 16px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        z-index: 1000;
        max-width: 400px;
        font-family: 'Poppins', sans-serif;
        font-size: 14px;
        font-weight: 500;
        animation: slideIn 0.3s ease-out;
        word-wrap: break-word;
    `;
    
    notification.textContent = message;
    document.body.appendChild(notification);

    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentNode) {
            notification.style.animation = 'slideOut 0.3s ease-in';
            setTimeout(() => notification.remove(), 300);
        }
    }, 5000);
}

// Add CSS for animations
if (!document.querySelector('#notification-styles')) {
    const style = document.createElement('style');
    style.id = 'notification-styles';
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Global function for switching accounts
async function switchAccount(event) {
    if (event) event.preventDefault();
    await AuthManager.switchAccount();
}

// Export for use in other modules
// Utility function to update user avatar images
function updateUserAvatar(user = null) {
    const currentUser = user || AuthManager.getCurrentUser();
    if (!currentUser) return;
    
    // Find all avatar elements and update them
    const avatarElements = document.querySelectorAll('#userAvatar, .user-avatar, .profile-avatar');
    const profilePhotoUrl = currentUser.profile_photo_url;
    
    avatarElements.forEach(element => {
        if (profilePhotoUrl && profilePhotoUrl !== '') {
            element.src = profilePhotoUrl;
            element.onerror = function() {
                // Fallback to default avatar if profile photo fails to load
                this.src = '../assets/default-avatar.png';
                this.onerror = null; // Prevent infinite loop
            };
        } else {
            // If no profile photo, show initials in a styled div
            if (currentUser.name && element.tagName === 'IMG') {
                const initials = currentUser.name.split(' ').map(n => n[0]).join('').toUpperCase();
                const avatarDiv = document.createElement('div');
                avatarDiv.className = element.className;
                avatarDiv.id = element.id;
                avatarDiv.onclick = element.onclick;
                avatarDiv.style.cssText = `
                    width: 32px;
                    height: 32px;
                    border-radius: 50%;
                    background: var(--primary-color);
                    color: white;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-weight: 600;
                    font-size: 14px;
                    cursor: pointer;
                `;
                avatarDiv.textContent = initials;
                element.parentNode.replaceChild(avatarDiv, element);
            }
        }
    });
    
    // Also update any user name displays
    const nameElements = document.querySelectorAll('#userName, .user-name');
    nameElements.forEach(element => {
        if (currentUser.name) {
            element.textContent = currentUser.name;
        }
    });
    
    // Update initials-based avatars (like in broker pages)
    const initialsElements = document.querySelectorAll('#userInitials, .user-initials');
    initialsElements.forEach(element => {
        if (profilePhotoUrl && profilePhotoUrl !== '') {
            // Replace initials div with image for profile photos
            const img = document.createElement('img');
            img.src = profilePhotoUrl;
            img.onclick = element.onclick;
            img.style.cssText = `
                width: 32px;
                height: 32px;
                border-radius: 50%;
                cursor: pointer;
                object-fit: cover;
            `;
            img.onerror = function() {
                // Fallback to initials if image fails
                const initials = currentUser.name ? currentUser.name.split(' ').map(n => n[0]).join('').toUpperCase() : 'U';
                const initialsDiv = document.createElement('div');
                initialsDiv.id = element.id;
                initialsDiv.onclick = element.onclick;
                initialsDiv.style.cssText = element.style.cssText;
                initialsDiv.textContent = initials;
                img.parentNode.replaceChild(initialsDiv, img);
            };
            element.parentNode.replaceChild(img, element);
        } else if (currentUser.name) {
            const initials = currentUser.name.split(' ').map(n => n[0]).join('').toUpperCase();
            element.textContent = initials;
        }
    });
}

// Function to open account switcher (handles case where account-switcher.js isn't loaded)
function openAccountSwitcher() {
    if (window.accountSwitcher) {
        window.accountSwitcher.openModal();
    } else {
        // If account switcher isn't loaded, show a simple notification
        showNotification('Account switcher is loading...', 'info');
        
        // Try to load the account switcher dynamically
        const script = document.createElement('script');
        script.src = '../js/account-switcher.js';
        script.onload = function() {
            if (window.accountSwitcher) {
                window.accountSwitcher.openModal();
            }
        };
        document.head.appendChild(script);
    }
}

window.AuthManager = AuthManager;
window.DatabaseManager = DatabaseManager;
window.formatCurrency = formatCurrency;
window.formatDate = formatDate;
window.showNotification = showNotification;
window.updateUserAvatar = updateUserAvatar;
window.openAccountSwitcher = openAccountSwitcher;
window.supabaseClient = supabase;
