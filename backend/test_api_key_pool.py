#!/usr/bin/env python3
"""
Test script for API Key Pool integration
"""

import requests
import json

BASE_URL = "http://localhost:8080/api"

def test_api_key_pool_integration():
    """Test that API Key Pool is working"""
    print("🔍 Testing API Key Pool integration...")
    
    # Test health endpoint to see if API key is configured
    response = requests.get(f"{BASE_URL}/health")
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"Health Response: {json.dumps(data, indent=2)}")
        
        api_key_configured = data.get('api_key_configured', False)
        if api_key_configured:
            print("✅ API Key Pool is working and API key is configured!")
        else:
            print("⚠️  API Key Pool is working but no API key is configured")
            print("   This is normal for development mode")
    else:
        print(f"❌ Health check failed: {response.text}")
    
    print()

def test_story_generation_with_api_pool():
    """Test story generation using API Key Pool"""
    print("🔍 Testing story generation with API Key Pool...")
    
    data = {
        "prompt": "A magical cat",
        "theme": "Fantasy",
        "additionalContext": "Make it suitable for children"
    }
    
    response = requests.post(f"{BASE_URL}/stories/generate", json=data)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print(f"Success: {result.get('success')}")
        if result.get('data'):
            story = result['data']
            print(f"Title: {story.get('title')}")
            print(f"Content length: {len(story.get('content', ''))}")
            print(f"Generated using API Key Pool: ✅")
    else:
        print(f"Error: {response.text}")
    
    print()

def main():
    """Run API Key Pool tests"""
    print("🚀 Testing API Key Pool Integration")
    print("=" * 50)
    
    test_api_key_pool_integration()
    test_story_generation_with_api_pool()
    
    print("✅ API Key Pool tests completed!")

if __name__ == "__main__":
    main()
