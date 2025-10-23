# Rento - Property Management Platform

A comprehensive property management application combining brokerage, tenant management, and escrow transactions within a single platform.

## 🏠 Features

### Multi-Role System
- **Tenants**: Browse properties, schedule viewings, manage payments
- **Brokers**: List properties, manage leads, track earnings
- **Property Managers**: Manage properties, tenants, bookings, and payments

### Key Functionality
- ✅ User authentication with role-based access
- ✅ Property listing and management
- ✅ Property search and filtering
- ✅ Booking system for property viewings
- ✅ Payment tracking and management
- ✅ Lead generation system for brokers
- ✅ Tenant complaint system
- ✅ Responsive mobile and desktop design
- ✅ Airbnb-inspired UI with modern styling

## 🎨 Design

- **Font**: Poppins
- **Primary Color**: #08967e
- **Design Style**: Modern, clean interface inspired by Airbnb
- **Framework**: Custom CSS (Tailwind-inspired utilities)
- **Responsive**: Mobile-first design approach

## 🚀 Getting Started

### Prerequisites
- Web browser (Chrome, Firefox, Safari, or Edge)
- Internet connection (for Supabase and fonts)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/rentopropapp/rento_app.git
   cd rento_app
   ```

2. **Run locally**
   - **Option 1**: Open `index.html` directly in your browser
   - **Option 2**: Use a local server (recommended)
     ```bash
     # Using Python
     python -m http.server 8000
     # Then open: http://localhost:8000
     
     # Using Node.js (install http-server first: npm install -g http-server)
     http-server -p 8000
     # Then open: http://localhost:8000
     
     # Using PHP
     php -S localhost:8000
     # Then open: http://localhost:8000
     ```
   - **Option 3**: Use VS Code Live Server extension
     - Install "Live Server" extension in VS Code
     - Right-click `index.html` and select "Open with Live Server"

3. **Quick Access Links** (when running locally)
   - 🏠 [Home Page](http://localhost:8000/index.html)
   - 🔐 [Login](http://localhost:8000/auth/login.html)
   - 📝 [Sign Up](http://localhost:8000/auth/signup.html)
   - 👤 [Tenant Dashboard](http://localhost:8000/tenant/home.html)
   - 🏢 [Property Manager Dashboard](http://localhost:8000/property-manager/home.html)
   - 💼 [Broker Dashboard](http://localhost:8000/broker/leads.html)

2. **Database Setup**
   - The app is configured to use Supabase
   - Database URL: `https://alsmzgubmgjcibezlpbs.supabase.co`
   - You'll need to set up the following tables in Supabase:

### Required Database Tables

```sql
-- Users table
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    phone_number VARCHAR(20),
    profile_photo_url TEXT,
    birthday DATE,
    occupation VARCHAR(255),
    user_role VARCHAR(50) CHECK (user_role IN ('tenant', 'broker', 'property_manager')),
    bio TEXT,
    rating DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Properties table
CREATE TABLE properties (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES users(user_id),
    property_name VARCHAR(255),
    location VARCHAR(255),
    property_type VARCHAR(100),
    amenities TEXT[],
    description TEXT,
    viewing_fee DECIMAL(10,2),
    lease_type VARCHAR(50),
    price DECIMAL(10,2),
    status VARCHAR(50) CHECK (status IN ('for_rent', 'for_sale', 'airbnb')),
    photos_urls TEXT[],
    availability_calendar JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Bookings table
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES users(user_id),
    property_id UUID REFERENCES properties(property_id),
    viewing_date TIMESTAMP,
    status VARCHAR(50) CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID,
    property_id UUID REFERENCES properties(property_id),
    amount DECIMAL(10,2),
    payment_date DATE,
    payment_type VARCHAR(50) CHECK (payment_type IN ('rent', 'viewing_fee')),
    status VARCHAR(50) CHECK (status IN ('completed', 'pending')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Complaints table
CREATE TABLE complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID,
    property_id UUID REFERENCES properties(property_id),
    description TEXT,
    status VARCHAR(50) CHECK (status IN ('new', 'in_progress', 'resolved')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Leads table
CREATE TABLE leads (
    lead_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES users(user_id),
    tenant_name VARCHAR(255),
    email VARCHAR(255),
    phone_number VARCHAR(20),
    property_type_required VARCHAR(100),
    location_preferred VARCHAR(255),
    price_range_min DECIMAL(10,2),
    price_range_max DECIMAL(10,2),
    additional_requirements TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 📁 Project Structure

```
rento-app/
├── index.html                 # Welcome page
├── styles.css                 # Main stylesheet
├── README.md                  # This file
├── assets/                    # Images and logos
│   ├── rento-logo-dark.svg
│   ├── rento-logo-light.svg
│   └── default-avatar.png
├── js/                        # JavaScript files
│   └── auth.js               # Authentication and database logic
├── auth/                      # Authentication pages
│   ├── login.html
│   ├── signup.html
│   ├── reset-password.html
│   └── profile-photo.html
├── tenant/                    # Tenant interface
│   ├── dashboard.html
│   └── properties.html
├── broker/                    # Broker interface
│   └── listings.html
└── property-manager/          # Property manager interface
    └── properties.html
```

## 🔐 User Roles

### Tenant Features
- Browse available properties with search/filter
- Schedule property viewings
- Submit search requests to brokers
- View payment history
- Manage profile and preferences

### Broker Features
- List properties with 3-step process
- Manage property availability calendar
- View and respond to leads
- Track viewing bookings
- Confirm/reschedule appointments

### Property Manager Features
- Manage property portfolio
- Add and edit properties
- Track tenant information
- Manage bookings and viewings
- Monitor property performance

## 🎯 How to Use

1. **Start Here**: Open `index.html` in your browser
2. **Sign Up**: Create an account and select your role
3. **Upload Photo**: Add a profile photo (optional)
4. **Dashboard**: Access your role-specific dashboard
5. **Explore**: Use the navigation to explore different features

## 🔧 Technical Details

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Supabase (Database & Authentication)
- **Styling**: Custom CSS with utility classes
- **Responsive**: Mobile-first design
- **Icons**: Inline SVG icons
- **Fonts**: Google Fonts (Poppins)

## 🌐 Browser Support

- Chrome 70+
- Firefox 65+
- Safari 12+
- Edge 79+

## 📱 Mobile Experience

The application is fully responsive and optimized for mobile devices with:
- Touch-friendly navigation
- Mobile-optimized forms
- Responsive grid layouts
- Mobile-specific navigation bar

## 🎨 Customization

To customize the application:

1. **Colors**: Modify CSS variables in `styles.css`
2. **Fonts**: Change font imports in HTML head sections
3. **Layout**: Adjust grid and flexbox layouts in CSS
4. **Features**: Add new functionality in JavaScript files

## 🚀 Deployment

To deploy the application:

1. Upload all files to a web server
2. Configure Supabase database tables
3. Update Supabase credentials if needed
4. Test all features in production environment

## 📞 Support

For questions or issues:
- Check the browser console for error messages
- Verify Supabase connection and credentials
- Ensure all required database tables are created

---

**Rento** - Making property management simple and efficient! 🏡