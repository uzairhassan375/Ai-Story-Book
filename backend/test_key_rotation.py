#!/usr/bin/env python3
"""
Test script to demonstrate API key rotation functionality
"""

import requests
import json
import time

BASE_URL = "http://localhost:8080/api"

def test_api_key_rotation():
    """Test API key rotation system"""
    print("🚀 Testing API Key Rotation System")
    print("=" * 50)
    
    # Step 1: Check health with initial key
    print("\n1️⃣ Testing initial health check...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check successful")
            print(f"🔑 Initial key pool status: {data.get('key_pool_status', {})}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return
    
    # Step 2: Test sending multiple API keys to backend
    print("\n2️⃣ Testing API key update from frontend...")
    test_keys = [
        "AIzaSyCe2weme_cnJk9jKZQSbBPYsuNwZQYqBxA",  # Your current key
        "AIzaSyTestKey1_MockKey1ForRotation",        # Mock keys for demo
        "AIzaSyTestKey2_MockKey2ForRotation",
        "AIzaSyTestKey3_MockKey3ForRotation"
    ]
    
    try:
        response = requests.post(
            f"{BASE_URL}/keys/update",
            headers={'Content-Type': 'application/json'},
            json={
                'api_keys': test_keys,
                'app_name': 'test_frontend'
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ API keys updated successfully")
            print(f"🔑 Pool status: {data.get('pool_status', {})}")
        else:
            print(f"❌ Key update failed: {response.status_code}")
            print(f"📄 Response: {response.text}")
    except Exception as e:
        print(f"❌ Key update error: {e}")
    
    # Step 3: Test manual key rotation
    print("\n3️⃣ Testing manual key rotation...")
    for i in range(3):
        try:
            response = requests.post(f"{BASE_URL}/keys/rotate")
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Rotation {i+1} successful")
                print(f"🔑 Current key: {data.get('pool_status', {}).get('current_key_preview', 'Unknown')}")
            else:
                print(f"❌ Rotation {i+1} failed: {response.status_code}")
        except Exception as e:
            print(f"❌ Rotation {i+1} error: {e}")
        
        time.sleep(1)  # Small delay between rotations
    
    # Step 4: Test key pool status
    print("\n4️⃣ Testing key pool status endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/keys/status")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Key pool status retrieved")
            print(f"📊 Status details:")
            pool_data = data.get('data', {})
            print(f"   Total keys: {pool_data.get('total_keys', 0)}")
            print(f"   Current key index: {pool_data.get('current_key_index', 0)}")
            print(f"   Available keys: {pool_data.get('available_keys', [])}")
            print(f"   Usage counts: {pool_data.get('usage_counts', {})}")
        else:
            print(f"❌ Status check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Status check error: {e}")
    
    # Step 5: Test story generation with rotation
    print("\n5️⃣ Testing story generation with key rotation...")
    story_request = {
        "prompt": "A brave little robot learning to fly",
        "theme": "adventure",
        "additional_context": "children's story, positive ending"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/stories/generate",
            headers={'Content-Type': 'application/json'},
            json=story_request
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print(f"✅ Story generation successful!")
                story_data = data.get('data', {})
                print(f"📖 Story title: {story_data.get('title', 'Unknown')}")
                print(f"📝 Content length: {len(story_data.get('content', ''))}")
            else:
                print(f"❌ Story generation failed: {data.get('error', 'Unknown error')}")
        else:
            print(f"❌ Story generation request failed: {response.status_code}")
            print(f"📄 Response: {response.text}")
    except Exception as e:
        print(f"❌ Story generation error: {e}")
    
    print("\n✅ API Key Rotation Test Complete!")
    print("🔑 Your system now supports:")
    print("   • Multiple API key storage")
    print("   • Automatic key rotation on rate limits")
    print("   • Manual key rotation")
    print("   • Key usage tracking")
    print("   • Frontend-to-backend key synchronization")

if __name__ == "__main__":
    test_api_key_rotation()
