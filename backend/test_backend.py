#!/usr/bin/env python3
"""
Test script for the AI Storybook Flask backend
"""

import requests
import json

BASE_URL = "http://localhost:8080/api"

def test_health():
    """Test health check endpoint"""
    print("🔍 Testing health check...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_feedback_options():
    """Test feedback options endpoint"""
    print("🔍 Testing feedback options...")
    response = requests.get(f"{BASE_URL}/feedback/options")
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_story_generation():
    """Test story generation endpoint"""
    print("🔍 Testing story generation...")
    data = {
        "prompt": "A brave little mouse",
        "theme": "Adventure",
        "additionalContext": "Make it suitable for children aged 5-8"
    }
    response = requests.post(f"{BASE_URL}/stories/generate", json=data)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Success: {result.get('success')}")
        if result.get('data'):
            story = result['data']
            print(f"Title: {story.get('title')}")
            print(f"Theme: {story.get('theme')}")
            print(f"Content length: {len(story.get('content', ''))}")
            print(f"Images: {len(story.get('imageUrls', []))}")
    else:
        print(f"Error: {response.text}")
    print()

def test_feedback_submission():
    """Test feedback submission endpoint"""
    print("🔍 Testing feedback submission...")
    data = {
        "feedbackType": "Positive",
        "selectedFeedback": "Great content",
        "storyId": "test_story_123",
        "rating": 5
    }
    response = requests.post(f"{BASE_URL}/feedback", json=data)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_image_generation():
    """Test image generation endpoint"""
    print("🔍 Testing image generation...")
    data = {
        "prompt": "A cute cartoon mouse wearing a red cape"
    }
    response = requests.post(f"{BASE_URL}/images/generate", json=data)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Success: {result.get('success')}")
        if result.get('imageBase64'):
            print(f"Image base64 length: {len(result['imageBase64'])}")
    else:
        print(f"Error: {response.text}")
    print()

def test_text_generation():
    """Test text generation endpoint"""
    print("🔍 Testing text generation...")
    data = {
        "prompt": "Write a short story about a magical forest",
        "systemInstruction": "Write in a child-friendly style"
    }
    response = requests.post(f"{BASE_URL}/text/generate", json=data)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Success: {result.get('success')}")
        if result.get('text'):
            print(f"Generated text length: {len(result['text'])}")
            print(f"Preview: {result['text'][:100]}...")
    else:
        print(f"Error: {response.text}")
    print()

def main():
    """Run all tests"""
    print("🚀 Testing AI Storybook Flask Backend")
    print("=" * 50)
    
    test_health()
    test_feedback_options()
    test_story_generation()
    test_feedback_submission()
    test_image_generation()
    test_text_generation()
    
    print("✅ All tests completed!")

if __name__ == "__main__":
    main()
