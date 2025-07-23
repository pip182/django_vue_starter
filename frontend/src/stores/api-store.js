import { defineStore } from 'pinia'
import api from '../services/api.js'

export const useApiStore = defineStore('api', {
  state: () => ({
    // Categories
    categories: [],
    currentCategory: null,
    categoriesLoading: false,
    categoriesError: null,

    // Posts
    posts: [],
    currentPost: null,
    postsLoading: false,
    postsError: null,

    // User
    currentUser: null,
    userLoading: false,
    userError: null,
    isAuthenticated: false,
  }),

  getters: {
    // Get posts by category
    getPostsByCategory: (state) => (categoryId) => {
      return state.posts.filter(post => post.category.id === categoryId)
    },

    // Get published posts
    getPublishedPosts: (state) => {
      return state.posts.filter(post => post.published)
    },

    // Get categories with post count
    getCategoriesWithCounts: (state) => {
      return state.categories.map(category => ({
        ...category,
        postsCount: state.posts.filter(post => post.category.id === category.id).length
      }))
    },
  },

  actions: {
    // Categories actions
    async fetchCategories() {
      this.categoriesLoading = true
      this.categoriesError = null

      try {
        const response = await api.categories.getAll()
        this.categories = response.results || response
      } catch (error) {
        this.categoriesError = error.message
        console.error('Error fetching categories:', error)
      } finally {
        this.categoriesLoading = false
      }
    },

    async fetchCategory(id) {
      try {
        const category = await api.categories.getById(id)
        this.currentCategory = category
        return category
      } catch (error) {
        this.categoriesError = error.message
        console.error('Error fetching category:', error)
        throw error
      }
    },

    async createCategory(categoryData) {
      try {
        const newCategory = await api.categories.create(categoryData)
        this.categories.push(newCategory)
        return newCategory
      } catch (error) {
        this.categoriesError = error.message
        console.error('Error creating category:', error)
        throw error
      }
    },

    async updateCategory(id, categoryData) {
      try {
        const updatedCategory = await api.categories.update(id, categoryData)
        const index = this.categories.findIndex(cat => cat.id === id)
        if (index !== -1) {
          this.categories[index] = updatedCategory
        }
        return updatedCategory
      } catch (error) {
        this.categoriesError = error.message
        console.error('Error updating category:', error)
        throw error
      }
    },

    async deleteCategory(id) {
      try {
        await api.categories.delete(id)
        this.categories = this.categories.filter(cat => cat.id !== id)
      } catch (error) {
        this.categoriesError = error.message
        console.error('Error deleting category:', error)
        throw error
      }
    },

    // Posts actions
    async fetchPosts(params = {}) {
      this.postsLoading = true
      this.postsError = null

      try {
        const response = await api.posts.getAll(params)
        this.posts = response.results || response
      } catch (error) {
        this.postsError = error.message
        console.error('Error fetching posts:', error)
      } finally {
        this.postsLoading = false
      }
    },

    async fetchPost(id) {
      try {
        const post = await api.posts.getById(id)
        this.currentPost = post
        return post
      } catch (error) {
        this.postsError = error.message
        console.error('Error fetching post:', error)
        throw error
      }
    },

    async createPost(postData) {
      try {
        const newPost = await api.posts.create(postData)
        this.posts.unshift(newPost)
        return newPost
      } catch (error) {
        this.postsError = error.message
        console.error('Error creating post:', error)
        throw error
      }
    },

    async updatePost(id, postData) {
      try {
        const updatedPost = await api.posts.update(id, postData)
        const index = this.posts.findIndex(post => post.id === id)
        if (index !== -1) {
          this.posts[index] = updatedPost
        }
        return updatedPost
      } catch (error) {
        this.postsError = error.message
        console.error('Error updating post:', error)
        throw error
      }
    },

    async deletePost(id) {
      try {
        await api.posts.delete(id)
        this.posts = this.posts.filter(post => post.id !== id)
      } catch (error) {
        this.postsError = error.message
        console.error('Error deleting post:', error)
        throw error
      }
    },

    async fetchMyPosts() {
      try {
        const response = await api.posts.getMyPosts()
        return response.results || response
      } catch (error) {
        this.postsError = error.message
        console.error('Error fetching my posts:', error)
        throw error
      }
    },

    // User actions
    async fetchCurrentUser() {
      this.userLoading = true
      this.userError = null

      try {
        const user = await api.users.getCurrentUser()
        this.currentUser = user
        this.isAuthenticated = true
        return user
      } catch (error) {
        this.currentUser = null
        this.isAuthenticated = false
        this.userError = error.message
        console.error('Error fetching current user:', error)
      } finally {
        this.userLoading = false
      }
    },

    async checkAuthentication() {
      try {
        const isAuth = await api.auth.isAuthenticated()
        this.isAuthenticated = isAuth
        if (isAuth && !this.currentUser) {
          await this.fetchCurrentUser()
        }
        return isAuth
      } catch (error) {
        console.error('Authentication check failed:', error)
        this.isAuthenticated = false
        this.currentUser = null
        return false
      }
    },

    // Clear state
    clearCategories() {
      this.categories = []
      this.currentCategory = null
      this.categoriesError = null
    },

    clearPosts() {
      this.posts = []
      this.currentPost = null
      this.postsError = null
    },

    clearUser() {
      this.currentUser = null
      this.isAuthenticated = false
      this.userError = null
    },

    clearAll() {
      this.clearCategories()
      this.clearPosts()
      this.clearUser()
    },
  },
})
