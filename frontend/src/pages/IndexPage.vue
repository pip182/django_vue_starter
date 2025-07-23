<template>
  <q-page class="row items-center justify-evenly">
    <div class="full-width">
      <!-- Hero Section -->
      <div class="row justify-center q-mb-xl">
        <div class="col-12 col-md-8 text-center">
          <h1 class="text-h2 text-weight-light q-mb-md">
            Django Vue Starter
          </h1>
          <p class="text-h6 text-grey-7 q-mb-lg">
            A complete full-stack template with Django 5 REST API and Vue 3 + Quasar
          </p>

          <!-- API Status -->
          <div class="q-mb-lg">
            <q-badge
              :color="apiStore.isAuthenticated ? 'positive' : 'warning'"
              :label="apiStore.isAuthenticated ? 'Authenticated' : 'Not Authenticated'"
              class="q-mr-sm"
            />
            <q-badge
              :color="connectionStatus === 'connected' ? 'positive' : 'negative'"
              :label="connectionStatus === 'connected' ? 'API Connected' : 'API Disconnected'"
            />
          </div>

          <!-- Auth Actions -->
          <div class="q-mb-lg">
            <q-btn
              v-if="!apiStore.isAuthenticated"
              color="primary"
              label="Login"
              @click="login"
              class="q-mr-sm"
            />
            <q-btn
              v-else
              color="negative"
              label="Logout"
              @click="logout"
              class="q-mr-sm"
            />

            <q-btn
              color="secondary"
              label="Refresh Data"
              @click="refreshData"
              :loading="loading"
              icon="refresh"
            />
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="row q-col-gutter-lg">
        <!-- Categories Column -->
        <div class="col-12 col-md-6">
          <q-card>
            <q-card-section>
              <div class="text-h6">Categories</div>
              <div class="text-subtitle2 text-grey-7">
                Manage content categories
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section>
              <div v-if="apiStore.categoriesLoading" class="text-center">
                <q-spinner color="primary" size="3em" />
                <div class="q-mt-sm">Loading categories...</div>
              </div>

              <div v-else-if="apiStore.categoriesError" class="text-center text-negative">
                <q-icon name="error" size="2em" />
                <div class="q-mt-sm">{{ apiStore.categoriesError }}</div>
              </div>

              <div v-else-if="apiStore.categories.length === 0" class="text-center text-grey-7">
                <q-icon name="folder_open" size="2em" />
                <div class="q-mt-sm">No categories found</div>
              </div>

              <q-list v-else separator>
                <q-item
                  v-for="category in apiStore.categories"
                  :key="category.id"
                  clickable
                  @click="selectCategory(category)"
                >
                  <q-item-section>
                    <q-item-label>{{ category.name }}</q-item-label>
                    <q-item-label caption>{{ category.description || 'No description' }}</q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-badge color="primary" :label="category.posts_count || 0" />
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card-section>

            <q-card-actions align="right">
              <q-btn
                flat
                color="primary"
                label="Add Category"
                icon="add"
                @click="showCategoryDialog = true"
                :disable="!apiStore.isAuthenticated"
              />
            </q-card-actions>
          </q-card>
        </div>

        <!-- Posts Column -->
        <div class="col-12 col-md-6">
          <q-card>
            <q-card-section>
              <div class="text-h6">Posts</div>
              <div class="text-subtitle2 text-grey-7">
                Latest blog posts
              </div>
            </q-card-section>

            <q-separator />

            <q-card-section>
              <div v-if="apiStore.postsLoading" class="text-center">
                <q-spinner color="primary" size="3em" />
                <div class="q-mt-sm">Loading posts...</div>
              </div>

              <div v-else-if="apiStore.postsError" class="text-center text-negative">
                <q-icon name="error" size="2em" />
                <div class="q-mt-sm">{{ apiStore.postsError }}</div>
              </div>

              <div v-else-if="apiStore.posts.length === 0" class="text-center text-grey-7">
                <q-icon name="article" size="2em" />
                <div class="q-mt-sm">No posts found</div>
              </div>

              <q-list v-else separator>
                <q-item
                  v-for="post in apiStore.posts.slice(0, 5)"
                  :key="post.id"
                  clickable
                  @click="selectPost(post)"
                >
                  <q-item-section>
                    <q-item-label>{{ post.title }}</q-item-label>
                    <q-item-label caption>
                      by {{ post.author.username }} in {{ post.category.name }}
                    </q-item-label>
                    <q-item-label caption class="text-grey-6">
                      {{ formatDate(post.created_at) }}
                    </q-item-label>
                  </q-item-section>
                  <q-item-section side>
                    <q-badge
                      :color="post.published ? 'positive' : 'warning'"
                      :label="post.published ? 'Published' : 'Draft'"
                    />
                  </q-item-section>
                </q-item>
              </q-list>
            </q-card-section>

            <q-card-actions align="right">
              <q-btn
                flat
                color="primary"
                label="Add Post"
                icon="add"
                @click="showPostDialog = true"
                :disable="!apiStore.isAuthenticated"
              />
            </q-card-actions>
          </q-card>
        </div>
      </div>

      <!-- User Info -->
      <div v-if="apiStore.currentUser" class="row justify-center q-mt-xl">
        <div class="col-12 col-md-6">
          <q-card>
            <q-card-section>
              <div class="text-h6">Current User</div>
              <div class="text-subtitle2 text-grey-7">
                {{ apiStore.currentUser.first_name }} {{ apiStore.currentUser.last_name }}
              </div>
              <div class="text-body2 q-mt-sm">
                <strong>Username:</strong> {{ apiStore.currentUser.username }}<br>
                <strong>Email:</strong> {{ apiStore.currentUser.email }}
              </div>
            </q-card-section>
          </q-card>
        </div>
      </div>
    </div>

    <!-- Category Dialog -->
    <q-dialog v-model="showCategoryDialog">
      <q-card style="min-width: 350px">
        <q-card-section>
          <div class="text-h6">Add Category</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            v-model="newCategory.name"
            label="Name"
            dense
            autofocus
            @keyup.enter="createCategory"
          />
          <q-input
            v-model="newCategory.description"
            label="Description"
            type="textarea"
            rows="3"
            dense
            class="q-mt-sm"
          />
        </q-card-section>

        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="Cancel" @click="showCategoryDialog = false" />
          <q-btn
            flat
            label="Create"
            @click="createCategory"
            :loading="creating"
            :disable="!newCategory.name.trim()"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Post Dialog -->
    <q-dialog v-model="showPostDialog">
      <q-card style="min-width: 500px">
        <q-card-section>
          <div class="text-h6">Add Post</div>
        </q-card-section>

        <q-card-section class="q-pt-none">
          <q-input
            v-model="newPost.title"
            label="Title"
            dense
            autofocus
          />
          <q-select
            v-model="newPost.category_id"
            :options="categoryOptions"
            label="Category"
            option-value="value"
            option-label="label"
            emit-value
            map-options
            dense
            class="q-mt-sm"
          />
          <q-input
            v-model="newPost.content"
            label="Content"
            type="textarea"
            rows="5"
            dense
            class="q-mt-sm"
          />
          <q-checkbox
            v-model="newPost.published"
            label="Published"
            class="q-mt-sm"
          />
        </q-card-section>

        <q-card-actions align="right" class="text-primary">
          <q-btn flat label="Cancel" @click="showPostDialog = false" />
          <q-btn
            flat
            label="Create"
            @click="createPost"
            :loading="creating"
            :disable="!newPost.title.trim() || !newPost.category_id"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApiStore } from '../stores/api-store.js'
import api from '../services/api.js'

// Store
const apiStore = useApiStore()

// State
const loading = ref(false)
const creating = ref(false)
const connectionStatus = ref('checking')
const showCategoryDialog = ref(false)
const showPostDialog = ref(false)

// Form data
const newCategory = ref({
  name: '',
  description: ''
})

const newPost = ref({
  title: '',
  content: '',
  category_id: null,
  published: false
})

// Computed
const categoryOptions = computed(() => {
  return apiStore.categories.map(cat => ({
    label: cat.name,
    value: cat.id
  }))
})

// Methods
const checkConnection = async () => {
  try {
    await api.categories.getAll()
    connectionStatus.value = 'connected'
  } catch (error) {
    connectionStatus.value = 'disconnected'
    console.error('API connection failed:', error)
  }
}

const refreshData = async () => {
  loading.value = true
  try {
    await Promise.all([
      apiStore.fetchCategories(),
      apiStore.fetchPosts(),
      apiStore.checkAuthentication()
    ])
  } catch (error) {
    console.error('Error refreshing data:', error)
  } finally {
    loading.value = false
  }
}

const login = () => {
  api.auth.loginRedirect()
}

const logout = () => {
  api.auth.logoutRedirect()
}

const selectCategory = (category) => {
  console.log('Selected category:', category)
}

const selectPost = (post) => {
  console.log('Selected post:', post)
}

const createCategory = async () => {
  if (!newCategory.value.name.trim()) return

  creating.value = true
  try {
    await apiStore.createCategory(newCategory.value)
    showCategoryDialog.value = false
    newCategory.value = { name: '', description: '' }
  } catch (error) {
    console.error('Error creating category:', error)
  } finally {
    creating.value = false
  }
}

const createPost = async () => {
  if (!newPost.value.title.trim() || !newPost.value.category_id) return

  creating.value = true
  try {
    await apiStore.createPost(newPost.value)
    showPostDialog.value = false
    newPost.value = { title: '', content: '', category_id: null, published: false }
  } catch (error) {
    console.error('Error creating post:', error)
  } finally {
    creating.value = false
  }
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString()
}

// Lifecycle
onMounted(async () => {
  await checkConnection()
  await refreshData()
})
</script>

<style scoped>
.q-page {
  padding: 20px;
}
</style>
