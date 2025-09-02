# AI Storybook Backend Services

This directory contains the Python Flask backend with converted services from your original Flutter app.

## 🔧 **Services Converted:**

### **1. Gemini Image Service** (`gemini_image_service.py`)
- **Original**: Flutter `GeminiImageService` class
- **Converted**: Python class with same functionality
- **Features**:
  - Image generation using Gemini 2.0 Flash Preview
  - Support for reference images
  - Base64 encoding/decoding
  - Error handling and validation
  - Safety filter detection

### **2. Gemini Text Service** (`gemini_text_service.py`)
- **Original**: Flutter `GeminiTextService` class
- **Converted**: Python class using `google-generativeai` library
- **Features**:
  - Text generation using Gemini 2.0 Flash
  - System instruction support
  - Generation configuration
  - Image input support
  - Error handling

### **3. Feedback Service** (`feedback_service.py`)
- **Original**: Flutter feedback widget and Firebase integration
- **Converted**: Python class with Firebase Admin SDK
- **Features**:
  - Feedback submission with categories
  - Feedback retrieval and statistics
  - Mock Firebase for development
  - Same feedback options as original

## 🚀 **API Endpoints:**

### **Story Generation**
- `POST /api/stories/generate` - Generate complete stories with images

### **Image Generation**
- `POST /api/images/generate` - Generate images using Gemini

### **Text Generation**
- `POST /api/text/generate` - Generate text using Gemini

### **Feedback System**
- `POST /api/feedback` - Submit feedback
- `GET /api/feedback/options` - Get feedback options
- `GET /api/feedback/<story_id>` - Get feedback for story
- `GET /api/feedback/<story_id>/stats` - Get feedback statistics

### **Health Check**
- `GET /api/health` - Backend health status

## 🔧 **Setup Instructions:**

1. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure Environment Variables:**
   - Copy `env.example` to `.env`
   - Add your Gemini API key: `GEMINI_API_KEY=your_key_here`

3. **Run the Backend:**
   ```bash
   python app.py
   ```

4. **Test the Backend:**
   ```bash
   python test_backend.py
   ```

## 🎯 **Key Differences from Flutter Version:**

### **API Key Management:**
- **Flutter**: Used `ApiKeyPool` package
- **Python**: Uses environment variables (`.env` file)

### **Image Handling:**
- **Flutter**: `Uint8List` for image bytes
- **Python**: `bytes` objects with base64 encoding

### **Firebase Integration:**
- **Flutter**: `cloud_firestore` package
- **Python**: `firebase-admin` SDK with mock support

### **Error Handling:**
- **Flutter**: Exception throwing
- **Python**: Dictionary responses with success/error status

## 🔍 **Testing:**

The `test_backend.py` script tests all endpoints:
- Health check
- Feedback options
- Story generation
- Feedback submission
- Image generation
- Text generation

## 🚀 **Deployment:**

Ready for Vercel deployment with `vercel.json` configuration.

## 📝 **Notes:**

- All services maintain the same functionality as your Flutter versions
- Mock Firebase allows development without real Firebase credentials
- Placeholder images are used when Gemini API key is not configured
- Error handling is comprehensive and matches Flutter behavior
