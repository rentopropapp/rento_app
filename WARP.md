# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

### Running the Application
```bash
# Open the main application
start index.html
# Or navigate to the directory and open in your preferred browser

# Open specific role dashboards directly
start tenant/home.html          # Tenant interface
start broker/listings.html      # Broker interface  
start property-manager/home.html # Property manager interface
```

### Database Setup
```bash
# Set up Supabase database (required for full functionality)
# 1. Copy contents of supabase-setup-simple.sql
# 2. Paste into Supabase SQL Editor at https://alsmzgubmgjcibezlpbs.supabase.co
# 3. Run the script

# For troubleshooting, use the simpler setup
# Copy supabase-setup-simple.sql instead of supabase-setup.sql to avoid permission errors
```

### File Management
```bash
# Update user avatars across the application
PowerShell -File update-avatars.ps1

# Test application features
start test-features.html
```

### Development Tasks
```bash
# Serve files locally (if using a local server)
python -m http.server 8000
# Or use any other static file server

# Open developer tools to debug JavaScript
# F12 in browser, check Console tab for errors
```

## Architecture Overview

### Application Structure
This is a **client-side web application** built with vanilla HTML, CSS, and JavaScript, using **Supabase** as the backend service for authentication and database operations.

### Core Components

#### 1. Multi-Role Authentication System
- **Three distinct user roles**: Tenant, Broker, Property Manager
- **Account switching capability**: Users can have multiple roles under the same email
- **Role-based routing**: Different dashboards and features per role
- **Authentication files**: `auth/` directory contains login, signup, profile setup
- **Auth management**: `js/auth.js` - centralized authentication and user management

#### 2. Database Layer (Supabase Integration)
- **DatabaseManager class**: Handles all CRUD operations (`js/auth.js` lines 346-798)
- **Real-time capabilities**: Supabase provides real-time data sync
- **Row Level Security**: Database policies ensure users only access their own data
- **File storage**: Separate buckets for property photos and profile photos

#### 3. Role-Specific Interfaces

**Tenant Interface** (`tenant/` directory):
- Property browsing and search
- Booking management
- Payment tracking
- Profile management

**Broker Interface** (`broker/` directory):
- Property listing management
- Lead tracking and management
- Wallet/earnings tracking
- Multi-step property creation workflow

**Property Manager Interface** (`property-manager/` directory):
- Comprehensive property portfolio management
- Tenant management and agreements
- Maintenance request handling
- Financial tracking and reporting
- Booking oversight

#### 4. Shared Components
- **Styling system**: Single `styles.css` with CSS custom properties and utility classes
- **Authentication state management**: Persistent user sessions via localStorage
- **Notification system**: Global toast notifications for user feedback
- **Account switcher**: Modal component for switching between user roles (`js/account-switcher.js`)

### Key Design Patterns

#### 1. Class-Based Architecture
- **AuthManager**: Handles all authentication operations, user management, and role switching
- **DatabaseManager**: Provides database abstraction layer for all Supabase operations
- **AccountSwitcher**: Modal component for account switching functionality

#### 2. Role-Based Access Control
- Each role has dedicated directory structure with specific pages
- Navigation and features adapt based on user role
- Database policies enforce data access restrictions

#### 3. Progressive Enhancement
- Core functionality works without JavaScript
- Enhanced features require JavaScript and Supabase connection
- Graceful fallbacks for offline scenarios

#### 4. Component Modularity
- Shared JavaScript modules for common functionality
- Reusable CSS classes and components
- Consistent UI patterns across all roles

### Database Schema
The application uses **9 main tables**:
- `users` - User profiles and authentication data
- `properties` - Property listings and details
- `tenants` - Property-tenant associations
- `bookings` - Property viewing appointments
- `payments` - Payment tracking and history
- `property_expenses` - Property maintenance costs
- `complaints` - Tenant complaint management
- `tenant_agreements` - Lease agreements and contracts
- `leads` - Broker lead generation and tracking

### File Organization Principles
- **Role-based directories**: Each user role has dedicated folder
- **Shared resources**: Common CSS, JS, and assets in root level
- **Authentication flow**: Dedicated `auth/` directory for login/signup process
- **Asset management**: Images and logos in `assets/` directory

### Configuration and Deployment
- **Environment variables**: Database credentials stored in `.env` and hardcoded fallbacks
- **Runtime configuration**: Supabase URL and keys can be overridden via JavaScript
- **Static deployment**: Application can be deployed to any static hosting service
- **Database dependency**: Requires Supabase setup for full functionality

### Development Notes
- **No build process**: Pure HTML/CSS/JS - no compilation required
- **Browser compatibility**: Modern browsers with ES6+ support
- **Mobile responsive**: Mobile-first design with responsive layouts
- **Performance**: Lazy loading and efficient DOM manipulation patterns
- **Error handling**: Comprehensive error handling with user-friendly messages

### Testing and Debugging
- **Browser console**: Primary debugging tool for JavaScript errors
- **Supabase dashboard**: Real-time database monitoring and logs
- **Test file**: `test-features.html` for feature validation
- **Account switching**: `account-switcher-test.md` documents testing scenarios