import os
import google.generativeai as genai
from typing import Optional, List, Dict, Any

class GeminiTextService:
    def __init__(self):
        self._api_key = ''
    
    def initialize(self, api_key: str):
        """Initialize the service with API key"""
        self._api_key = api_key
        genai.configure(api_key=api_key)
    
    def generate_text(self, 
                     prompt: str, 
                     system_instruction: Optional[str] = None,
                     generation_config: Optional[Dict[str, Any]] = None,
                     images: Optional[List[bytes]] = None) -> str:
        """
        Generate text using Gemini API
        
        Args:
            prompt: Text prompt for generation
            system_instruction: Optional system instruction
            generation_config: Optional generation configuration
            images: Optional list of image bytes
            
        Returns:
            Generated text string
        """
        # Use API key from API Key Pool
        from app import ApiKeyPool
        api_key = ApiKeyPool.get_key()
        
        if not api_key:
            return "Error: API key not initialized"
        
        try:
            # Configure the model
            if generation_config:
                model = genai.GenerativeModel(
                    model_name='gemini-2.0-flash',
                    generation_config=generation_config
                )
            else:
                model = genai.GenerativeModel(model_name='gemini-2.0-flash')
            
            # Build content
            content_parts = [prompt]
            
            # Add system instruction if provided
            if system_instruction:
                content_parts.insert(0, f"System: {system_instruction}")
            
            # Add images if provided
            if images:
                for image_bytes in images:
                    # Convert bytes to PIL Image
                    from PIL import Image
                    import io
                    image = Image.open(io.BytesIO(image_bytes))
                    content_parts.append(image)
            
            # Generate content
            response = model.generate_content(content_parts)
            return response.text or ""
            
        except Exception as e:
            print(f"Error in generate_text: {e}")
            return f"Error generating text: {e}"
