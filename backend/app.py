import os
import json
import base64
import requests
from datetime import datetime
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import google.generativeai as genai
from firebase_admin import credentials, firestore, initialize_app
from PIL import Image
import io

# Import our custom services
from gemini_image_service import GeminiImageService
from gemini_text_service import GeminiTextService
from feedback_service import FeedbackService

app = Flask(__name__)
CORS(app)

# Initialize Firebase
try:
    cred = credentials.Certificate("firebase-credentials.json")
    initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Firebase initialization failed: {e}")
    print("Running in development mode without Firebase...")
    # For development, create a mock database
    class MockFirestore:
        def collection(self, name):
            return MockCollection()
    
    class MockCollection:
        def __init__(self, name="feedback"):
            self.name = name
        
        def add(self, data):
            print(f"Mock: Adding to {self.name}: {data}")
            return True
        
        def where(self, field, op, value):
            return self
        
        def order_by(self, field, direction=None):
            return self
        
        def stream(self):
            return []
    
    db = MockFirestore()

# Mock API Key Pool for Python backend
class ApiKeyPool:
    _api_key = None
    
    @staticmethod
    def init(app_name):
        """Initialize API Key Pool with app name"""
        print(f"API Key Pool initialized for app: {app_name}")
        # This should connect to your actual API Key Pool GitHub package
        # For now, we'll simulate the connection
        try:
            # In a real implementation, this would connect to your GitHub package
            # and retrieve the API key for the specified app
            ApiKeyPool._api_key = ApiKeyPool._get_key_from_pool(app_name)
            if ApiKeyPool._api_key:
                print(f"API key retrieved from pool for app: {app_name}")
            else:
                print(f"No API key found in pool for app: {app_name}")
        except Exception as e:
            print(f"Error connecting to API Key Pool: {e}")
            ApiKeyPool._api_key = None
    
    @staticmethod
    def _get_key_from_pool(app_name):
        """Get API key from your GitHub API Key Pool package"""
        # This is where you would integrate with your actual API Key Pool service
        # For now, we'll simulate the connection
        try:
            # Simulate API call to your GitHub package
            # In reality, this would be something like:
            # response = requests.get('https://your-api-key-pool-service.com/api/keys', 
            #                        params={'app_name': app_name})
            # return response.json().get('api_key')
            
            # For development, you can hardcode your actual API key here
            # or implement the actual connection to your GitHub package
            if app_name == 'ai_storybook_backend':
                # Replace this with your actual API key from the pool
                return "AIzaSyCe2weme_cnJk9jKZQSbBPYsuNwZQYqBxA"
            return None
        except Exception as e:
            print(f"Error getting key from pool: {e}")
            return None
    
    @staticmethod
    def get_key():
        """Get API key from the pool"""
        return ApiKeyPool._api_key

# Initialize API Key Pool
ApiKeyPool.init('ai_storybook_backend')

# Initialize services
gemini_api_key = ApiKeyPool.get_key()
gemini_image_service = GeminiImageService()
gemini_text_service = GeminiTextService()
feedback_service = FeedbackService(db)

if gemini_api_key:
    gemini_image_service.initialize(gemini_api_key)
    gemini_text_service.initialize(gemini_api_key)
    genai.configure(api_key=gemini_api_key)
    print(f"Gemini API configured with key: {gemini_api_key[:10]}...")
else:
    print("Warning: No Gemini API key found. Running in development mode.")

class StoryService:
    def __init__(self):
        self.model = genai.GenerativeModel(model_name='gemini-pro') if gemini_api_key else None
        self.image_model = genai.GenerativeModel(model_name='gemini-pro-vision') if gemini_api_key else None
    
    def generate_story(self, prompt, theme, additional_context=None):
        try:
            # Build story prompt
            story_prompt = self._build_story_prompt(prompt, theme, additional_context)
            
            # Generate story content using our text service
            if gemini_api_key:
                story_content = gemini_text_service.generate_text(story_prompt)
            else:
                # Fallback for development
                story_content = f"Once upon a time, there was a {prompt} in a {theme} world. This is a placeholder story for development."
            
            # Extract title
            title = self._extract_title(story_content)
            
            # Generate images using our image service
            image_urls = self._generate_story_images(story_content, theme)
            
            # Generate audio (placeholder)
            audio_url = self._generate_audio(story_content)
            
            return {
                'id': self._generate_id(),
                'title': title,
                'content': story_content,
                'theme': theme,
                'imageUrls': image_urls,
                'audioUrl': audio_url,
                'createdAt': datetime.now().isoformat()
            }
        except Exception as e:
            raise Exception(f'Failed to generate story: {str(e)}')
    
    def _build_story_prompt(self, prompt, theme, additional_context):
        theme_prompts = {
            'Adventure': 'Write an exciting adventure story with brave characters, mysterious quests, and thrilling discoveries.',
            'Fantasy': 'Create a magical fantasy story with mystical creatures, enchanted worlds, and powerful magic.',
            'Space': 'Craft a space adventure story with futuristic technology, alien encounters, and cosmic exploration.',
            'Nature': 'Write a nature story about animals, plants, and the beauty of the natural world.',
            'Friendship': 'Create a heartwarming story about friendship, kindness, and helping others.',
            'Science': 'Write an educational story that teaches scientific concepts in an engaging way.',
        }
        
        theme_prompt = theme_prompts.get(theme, 'Write an engaging story')
        context = f' Additional context: {additional_context}' if additional_context else ''
        
        return f"""
{theme_prompt}

Story prompt: {prompt}
{context}

Please write a complete story with:
- An engaging beginning that hooks the reader
- A clear plot with interesting characters
- A satisfying ending
- Age-appropriate content
- Vivid descriptions that can be illustrated
- A title for the story

Make the story approximately 500-800 words long.
"""
    
    def _extract_title(self, content):
        lines = content.split('\n')
        for line in lines:
            trimmed = line.strip()
            if trimmed and not trimmed.startswith('Title:'):
                title = trimmed
                if title.startswith('Title: '):
                    title = title[7:]
                if len(title) > 100:
                    title = title[:100] + '...'
                return title
        return 'Amazing Story'
    
    def _generate_story_images(self, content, theme):
        try:
            # Split content into scenes
            scenes = self._extract_scenes(content)
            image_urls = []
            
            for i, scene in enumerate(scenes[:3]):
                image_prompt = self._build_image_prompt(scene, theme)
                
                # Generate image using our image service
                if gemini_api_key:
                    result = gemini_image_service.generate_gemini_image(image_prompt)
                    if result['success'] and result.get('imageBytes'):
                        # Save image to a temporary file and return URL
                        import tempfile
                        import os
                        
                        # Create a unique filename
                        timestamp = int(datetime.now().timestamp() * 1000)
                        filename = f"story_image_{timestamp}_{i}.jpg"
                        
                        # Save image to temp directory
                        temp_dir = "temp_images"
                        if not os.path.exists(temp_dir):
                            os.makedirs(temp_dir)
                        
                        image_path = os.path.join(temp_dir, filename)
                        with open(image_path, 'wb') as f:
                            f.write(result['imageBytes'])
                        
                        # Return a URL that can be served by Flask
                        image_url = f"/api/images/{filename}"
                        image_urls.append(image_url)
                        print(f'Generated image saved: {image_path}')
                    else:
                        print(f'Image generation failed: {result.get("error")}')
                        # Fallback to placeholder
                        image_urls.append(f'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Story+Image+{i+1}')
                else:
                    # Fallback for development
                    image_urls.append(f'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Story+Image+{i+1}')
            
            if not image_urls:
                image_urls.append('https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Story+Image')
            
            return image_urls
        except Exception as e:
            print(f'Error generating images: {e}')
            return ['https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Story+Image']
    
    def _extract_scenes(self, content):
        paragraphs = content.split('\n\n')
        scenes = []
        
        for paragraph in paragraphs:
            trimmed = paragraph.strip()
            if trimmed and len(trimmed) > 20:
                scenes.append(trimmed)
        
        return scenes[:3]
    
    def _build_image_prompt(self, scene, theme):
        theme_styles = {
            'Adventure': 'adventure, action, exploration',
            'Fantasy': 'fantasy, magical, mystical',
            'Space': 'sci-fi, futuristic, space',
            'Nature': 'nature, peaceful, beautiful',
            'Friendship': 'warm, friendly, heartwarming',
            'Science': 'educational, scientific, colorful',
        }
        
        style = theme_styles.get(theme, 'beautiful, colorful')
        
        return f"""
Create a beautiful, detailed illustration for a children's story:
Scene: {scene}
Style: {style}, child-friendly, vibrant colors, detailed but simple
Format: High-quality digital art suitable for a storybook
"""
    
    def _generate_audio(self, content):
        # Placeholder for audio generation
        return 'https://example.com/audio/placeholder.mp3'
    
    def _generate_id(self):
        return str(int(datetime.now().timestamp() * 1000))

# Initialize story service
story_service = StoryService()

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'api_key_configured': bool(gemini_api_key)
    })

@app.route('/api/stories/generate', methods=['POST'])
def generate_story():
    try:
        data = request.get_json()
        
        if not data or 'prompt' not in data or 'theme' not in data:
            return jsonify({'success': False, 'error': 'Missing required fields'}), 400
        
        prompt = data['prompt']
        theme = data['theme']
        additional_context = data.get('additionalContext')
        
        story = story_service.generate_story(prompt, theme, additional_context)
        
        return jsonify({
            'success': True,
            'data': story
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/feedback', methods=['POST'])
def submit_feedback():
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'success': False, 'error': 'Missing data'}), 400
        
        feedback_type = data.get('feedbackType', 'Positive')
        selected_feedback = data.get('selectedFeedback', '')
        custom_feedback = data.get('customFeedback', '')
        story_id = data.get('storyId')
        rating = data.get('rating', 5)
        
        result = feedback_service.submit_feedback(
            feedback_type=feedback_type,
            selected_feedback=selected_feedback,
            custom_feedback=custom_feedback,
            story_id=story_id,
            rating=rating
        )
        
        if result['success']:
            return jsonify({
                'success': True,
                'message': result['message']
            })
        else:
            return jsonify({
                'success': False,
                'error': result['error']
            }), 400
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/feedback/options', methods=['GET'])
def get_feedback_options():
    try:
        options = feedback_service.get_feedback_options()
        return jsonify({
            'success': True,
            'data': options
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/feedback/<story_id>', methods=['GET'])
def get_feedback(story_id):
    try:
        feedback = feedback_service.get_feedback_for_story(story_id)
        
        return jsonify({
            'success': True,
            'data': feedback
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/feedback/<story_id>/stats', methods=['GET'])
def get_feedback_stats(story_id):
    try:
        stats = feedback_service.get_feedback_stats(story_id)
        
        return jsonify({
            'success': True,
            'data': stats
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/images/generate', methods=['POST'])
def generate_image():
    try:
        data = request.get_json()
        
        if not data or 'prompt' not in data:
            return jsonify({'success': False, 'error': 'Missing prompt'}), 400
        
        prompt = data['prompt']
        images = data.get('images', [])  # Optional reference images
        
        if not gemini_api_key:
            return jsonify({
                'success': False,
                'error': 'Gemini API key not configured'
            }), 500
        
        result = gemini_image_service.generate_gemini_image(prompt, images)
        
        if result['success']:
            # Convert image bytes to base64 for JSON response
            image_base64 = base64.b64encode(result['imageBytes']).decode('utf-8')
            return jsonify({
                'success': True,
                'imageBase64': image_base64,
                'message': result['message']
            })
        else:
            return jsonify({
                'success': False,
                'error': result['error']
            }), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/images/<filename>')
def serve_image(filename):
    """Serve generated images"""
    try:
        image_path = os.path.join('temp_images', filename)
        if os.path.exists(image_path):
            return send_file(image_path, mimetype='image/jpeg')
        else:
            return jsonify({'error': 'Image not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/text/generate', methods=['POST'])
def generate_text():
    try:
        data = request.get_json()
        
        if not data or 'prompt' not in data:
            return jsonify({'success': False, 'error': 'Missing prompt'}), 400
        
        prompt = data['prompt']
        system_instruction = data.get('systemInstruction')
        generation_config = data.get('generationConfig')
        images = data.get('images', [])  # Optional reference images
        
        if not gemini_api_key:
            return jsonify({
                'success': False,
                'error': 'Gemini API key not configured'
            }), 500
        
        generated_text = gemini_text_service.generate_text(
            prompt=prompt,
            system_instruction=system_instruction,
            generation_config=generation_config,
            images=images
        )
        
        return jsonify({
            'success': True,
            'text': generated_text
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=True)
