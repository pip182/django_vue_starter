# Django Vue Starter

A complete full-stack web application template featuring Django 5 with REST Framework on the backend and Vue 3 with Quasar Framework on the frontend.

## 🚀 Features

### Backend (Django)
- **Django 5** - Latest version with modern Python features
- **Django REST Framework** - Powerful API development
- **CORS Headers** - Cross-origin resource sharing support
- **Environment Variables** - Secure configuration management
- **SQLite Database** - Default database (easily configurable for PostgreSQL/MySQL)
- **Admin Interface** - Django's built-in admin panel
- **Example Models** - Category and Post models with relationships
- **API Authentication** - Session and basic authentication

### Frontend (Vue/Quasar)
- **Vue 3** - Modern composition API
- **Quasar Framework** - Material Design components
- **Pinia** - State management
- **Native Fetch API** - No external HTTP libraries needed
- **SCSS Support** - Advanced styling capabilities
- **Responsive Design** - Mobile-first approach
- **Error Handling** - Comprehensive error management

### Development Tools
- **run.sh Script** - Easy development server management
- **Environment Configuration** - Local and production settings
- **Hot Reload** - Both backend and frontend support
- **Code Organization** - Clean, scalable structure

## 📋 Requirements

- **Python 3.8+**
- **Node.js 18+**
- **npm or yarn**

## 🛠️ Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd django_vue_starter
```

### 2. Environment Setup

Copy the environment file and modify as needed:

```bash
cp .env.example .env
```

### 3. Automatic Setup

Run the setup script to install all dependencies and configure the project:

```bash
./run.sh setup
```

This will:
- Install Python dependencies
- Install Node.js dependencies
- Run Django migrations
- Create the database

### 4. Create a Superuser (Optional)

```bash
./run.sh createsuperuser
```

### 5. Start Development Servers

Start both backend and frontend simultaneously:

```bash
./run.sh dev
```

Or start them separately:

```bash
# Backend only (Django)
./run.sh backend

# Frontend only (Vue/Quasar)
./run.sh frontend
```

## 📁 Project Structure

```
django_vue_starter/
├── backend/                 # Django backend
│   ├── api/                # REST API app
│   │   ├── models.py       # Database models
│   │   ├── serializers.py  # DRF serializers
│   │   ├── views.py        # API views
│   │   ├── urls.py         # API URLs
│   │   └── admin.py        # Admin configuration
│   ├── core/               # Django project settings
│   │   ├── settings.py     # Main settings
│   │   ├── urls.py         # Main URL configuration
│   │   └── wsgi.py         # WSGI configuration
│   ├── requirements.txt    # Python dependencies
│   ├── manage.py           # Django management script
│   └── db.sqlite3          # SQLite database (created after setup)
├── frontend/               # Vue frontend
│   ├── src/
│   │   ├── components/     # Vue components
│   │   ├── pages/          # Page components
│   │   ├── layouts/        # Layout components
│   │   ├── stores/         # Pinia stores
│   │   ├── services/       # API services
│   │   ├── router/         # Vue Router configuration
│   │   └── css/            # Stylesheets
│   ├── package.json        # Node.js dependencies
│   └── quasar.config.js    # Quasar configuration
├── .env                    # Environment variables
├── .env.example           # Environment template
├── .gitignore             # Git ignore rules
├── run.sh                 # Development script
└── README.md              # This file
```

## 🔧 Available Commands

### Development Scripts

```bash
# Start both services
./run.sh dev

# Start individual services
./run.sh backend          # Django development server
./run.sh frontend         # Vue/Quasar development server

# Setup and maintenance
./run.sh setup            # Full project setup
./run.sh migrate          # Run Django migrations
./run.sh createsuperuser  # Create Django admin user

# Dependencies
./run.sh install-backend  # Install Python dependencies
./run.sh install-frontend # Install Node.js dependencies

# Building and testing
./run.sh build-frontend   # Build frontend for production
./run.sh test            # Run tests
./run.sh clean           # Clean generated files

# Help
./run.sh help            # Show all commands
```

## 🌐 API Endpoints

The Django REST API is available at `http://localhost:8000/api/v1/`

### Categories
- `GET /api/v1/categories/` - List all categories
- `POST /api/v1/categories/` - Create a new category
- `GET /api/v1/categories/{id}/` - Get a specific category
- `PUT /api/v1/categories/{id}/` - Update a category
- `DELETE /api/v1/categories/{id}/` - Delete a category
- `GET /api/v1/categories/{id}/posts/` - Get posts for a category

### Posts
- `GET /api/v1/posts/` - List all posts
- `POST /api/v1/posts/` - Create a new post
- `GET /api/v1/posts/{id}/` - Get a specific post
- `PUT /api/v1/posts/{id}/` - Update a post
- `DELETE /api/v1/posts/{id}/` - Delete a post
- `GET /api/v1/posts/my_posts/` - Get current user's posts

### Users
- `GET /api/v1/users/` - List all users
- `GET /api/v1/users/{id}/` - Get a specific user
- `GET /api/v1/users/me/` - Get current user info

### Authentication
- `GET/POST /api-auth/login/` - Django admin login
- `POST /api-auth/logout/` - Django admin logout

## ⚙️ Configuration

### Environment Variables (.env)

```env
# Django Configuration
SECRET_KEY=your-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database Configuration
DB_ENGINE=django.db.backends.sqlite3
DB_NAME=db.sqlite3
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=

# CORS Settings
CORS_ALLOWED_ORIGINS=http://localhost:9000,http://127.0.0.1:9000

# API Settings
API_PREFIX=api/v1

# Development Settings
DJANGO_PORT=8000
VUE_PORT=9000
```

### Database Configuration

The project uses SQLite by default. To use PostgreSQL or MySQL:

1. Update the database settings in `.env`:

```env
DB_ENGINE=django.db.backends.postgresql
DB_NAME=your_database_name
DB_USER=your_username
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
```

2. Install the appropriate database driver:

```bash
# For PostgreSQL
pip install psycopg2-binary

# For MySQL
pip install mysqlclient
```

## 🎨 Frontend Development

### API Integration

The frontend uses a custom API service (`src/services/api.js`) with native fetch:

```javascript
import api from '../services/api.js'

// Get all categories
const categories = await api.categories.getAll()

// Create a new post
const newPost = await api.posts.create({
  title: 'My Post',
  content: 'Post content',
  category_id: 1,
  published: true
})
```

### State Management

Uses Pinia for state management (`src/stores/api-store.js`):

```javascript
import { useApiStore } from '../stores/api-store.js'

const apiStore = useApiStore()

// Fetch data
await apiStore.fetchCategories()
await apiStore.fetchPosts()

// Access state
console.log(apiStore.categories)
console.log(apiStore.isAuthenticated)
```

## 🚀 Production Deployment

### Backend (Django)

1. Set `DEBUG=False` in production environment
2. Configure a production database (PostgreSQL recommended)
3. Use a proper web server (Gunicorn + Nginx)
4. Set up static file serving
5. Configure proper `ALLOWED_HOSTS`

### Frontend (Vue/Quasar)

1. Build the frontend:
   ```bash
   ./run.sh build-frontend
   ```

2. Serve the built files from the `frontend/dist` directory

3. Configure your web server to serve the SPA properly

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues

1. **CORS Errors**: Make sure the frontend URL is in `CORS_ALLOWED_ORIGINS`
2. **Database Issues**: Run `./run.sh migrate` to apply migrations
3. **Port Conflicts**: Change ports in `.env` if default ports are taken
4. **Dependencies**: Run `./run.sh setup` to reinstall all dependencies

### Getting Help

- Check the console for error messages
- Ensure all services are running
- Verify environment variables are set correctly
- Check that all dependencies are installed

## 🔄 Updates

To update the template:

1. Pull the latest changes
2. Run `./run.sh install-backend` and `./run.sh install-frontend`
3. Run `./run.sh migrate` for any new database changes
4. Check for any new environment variables in `.env.example`
