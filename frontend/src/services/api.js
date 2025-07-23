/**
 * API Service for Django Vue Starter
 * Uses native fetch for HTTP requests
 */

// Base configuration
const API_BASE_URL = process.env.NODE_ENV === 'production'
  ? '/api/v1'
  : 'http://localhost:8000/api/v1';

const AUTH_BASE_URL = process.env.NODE_ENV === 'production'
  ? '/api-auth'
  : 'http://localhost:8000/api-auth';

/**
 * Base API client with common functionality
 */
class ApiClient {
  constructor() {
    this.baseURL = API_BASE_URL;
    this.authURL = AUTH_BASE_URL;
  }

  /**
   * Get CSRF token from cookies
   */
  getCSRFToken() {
    const name = 'csrftoken';
    const cookies = document.cookie.split(';');
    for (let cookie of cookies) {
      const [key, value] = cookie.trim().split('=');
      if (key === name) {
        return decodeURIComponent(value);
      }
    }
    return null;
  }

  /**
   * Create request headers
   */
  getHeaders(includeAuth = true) {
    const headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      const csrfToken = this.getCSRFToken();
      if (csrfToken) {
        headers['X-CSRFToken'] = csrfToken;
      }
    }

    return headers;
  }

  /**
   * Handle API response
   */
  async handleResponse(response) {
    if (!response.ok) {
      const errorData = await response.text();
      let errorMessage;

      try {
        const parsedError = JSON.parse(errorData);
        errorMessage = parsedError.detail || parsedError.message || 'API request failed';
      } catch {
        errorMessage = errorData || `HTTP ${response.status}: ${response.statusText}`;
      }

      throw new Error(errorMessage);
    }

    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      return await response.json();
    }

    return await response.text();
  }

  /**
   * Generic request method
   */
  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      credentials: 'include', // Include cookies for authentication
      headers: this.getHeaders(),
      ...options,
    };

    try {
      const response = await fetch(url, config);
      return await this.handleResponse(response);
    } catch (error) {
      console.error('API Request Error:', error);
      throw error;
    }
  }

  // HTTP method helpers
  async get(endpoint, params = {}) {
    const query = new URLSearchParams(params).toString();
    const url = query ? `${endpoint}?${query}` : endpoint;
    return this.request(url, { method: 'GET' });
  }

  async post(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async put(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  async patch(endpoint, data = {}) {
    return this.request(endpoint, {
      method: 'PATCH',
      body: JSON.stringify(data),
    });
  }

  async delete(endpoint) {
    return this.request(endpoint, { method: 'DELETE' });
  }
}

// Create API client instance
const apiClient = new ApiClient();

/**
 * Categories API
 */
export const categoriesAPI = {
  // Get all categories
  getAll(params = {}) {
    return apiClient.get('/categories/', params);
  },

  // Get single category
  getById(id) {
    return apiClient.get(`/categories/${id}/`);
  },

  // Create new category
  create(data) {
    return apiClient.post('/categories/', data);
  },

  // Update category
  update(id, data) {
    return apiClient.put(`/categories/${id}/`, data);
  },

  // Partial update category
  partialUpdate(id, data) {
    return apiClient.patch(`/categories/${id}/`, data);
  },

  // Delete category
  delete(id) {
    return apiClient.delete(`/categories/${id}/`);
  },

  // Get posts for a category
  getPosts(id) {
    return apiClient.get(`/categories/${id}/posts/`);
  },
};

/**
 * Posts API
 */
export const postsAPI = {
  // Get all posts
  getAll(params = {}) {
    return apiClient.get('/posts/', params);
  },

  // Get single post
  getById(id) {
    return apiClient.get(`/posts/${id}/`);
  },

  // Create new post
  create(data) {
    return apiClient.post('/posts/', data);
  },

  // Update post
  update(id, data) {
    return apiClient.put(`/posts/${id}/`, data);
  },

  // Partial update post
  partialUpdate(id, data) {
    return apiClient.patch(`/posts/${id}/`, data);
  },

  // Delete post
  delete(id) {
    return apiClient.delete(`/posts/${id}/`);
  },

  // Get current user's posts
  getMyPosts() {
    return apiClient.get('/posts/my_posts/');
  },
};

/**
 * Users API
 */
export const usersAPI = {
  // Get all users
  getAll(params = {}) {
    return apiClient.get('/users/', params);
  },

  // Get single user
  getById(id) {
    return apiClient.get(`/users/${id}/`);
  },

  // Get current user
  getCurrentUser() {
    return apiClient.get('/users/me/');
  },
};

/**
 * Authentication helpers
 */
export const authAPI = {
  // Check if user is authenticated
  async isAuthenticated() {
    try {
      await usersAPI.getCurrentUser();
      return true;
    } catch {
      return false;
    }
  },

  // Login redirect (to Django's login page)
  loginRedirect() {
    window.location.href = `${AUTH_BASE_URL}/login/`;
  },

  // Logout redirect (to Django's logout page)
  logoutRedirect() {
    window.location.href = `${AUTH_BASE_URL}/logout/`;
  },
};

// Default export
export default {
  categories: categoriesAPI,
  posts: postsAPI,
  users: usersAPI,
  auth: authAPI,
};
