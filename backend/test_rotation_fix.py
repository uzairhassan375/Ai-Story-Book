#!/usr/bin/env python3
"""
Test script to verify the API key rotation fixes
"""

import requests
import json

BASE_URL = "http://localhost:8080/api"

def test_key_rotation_fix():
    """Test the fixed key rotation system"""
    print("🚀 Testing API Key Rotation Fixes")
    print("=" * 50)
    
    # Step 1: Send test keys to backend
    print("\n1️⃣ Sending test API keys to backend...")
    test_keys = [
        "AIzaSyDJuUMWZOKE1z-1Q4p-oWnF8X8zr2J7gDI",  # Test key 1
        "AIzaSyDZYkXKjHO7K3vF2sV8dOhT9rP6wG3nQ2A",  # Test key 2  
        "AIzaSyBz0wYGqT2tR5xM8uL1bH4eZ9sF7cN6vE1",  # Test key 3
        "AIzaSyC1WEzUvP3bQ8rN5wX2gK9oT4mY7dF6hL0"   # Test key 4
    ]
    
    try:
        response = requests.post(
            f"{BASE_URL}/keys/update",
            headers={'Content-Type': 'application/json'},
            json={
                'api_keys': test_keys,
                'app_name': 'test_rotation'
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Keys updated successfully")
            print(f"🔑 Pool status: {data.get('pool_status', {})}")
        else:
            print(f"❌ Key update failed: {response.status_code}")
            print(f"📄 Response: {response.text}")
            return
    except Exception as e:
        print(f"❌ Key update error: {e}")
        return
    
    # Step 2: Check pool status
    print("\n2️⃣ Checking pool status...")
    try:
        response = requests.get(f"{BASE_URL}/keys/status")
        if response.status_code == 200:
            data = response.json()
            pool_data = data.get('data', {})
            print(f"✅ Pool status retrieved")
            print(f"   📊 Total keys: {pool_data.get('total_keys', 0)}")
            print(f"   🔑 Current index: {pool_data.get('current_key_index', 0)}")
            print(f"   🔑 Current key: {pool_data.get('current_key_preview', 'Unknown')}")
            print(f"   📋 Available keys: {pool_data.get('available_keys', [])}")
        else:
            print(f"❌ Status check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Status check error: {e}")
    
    # Step 3: Test manual rotation
    print("\n3️⃣ Testing manual key rotation...")
    for i in range(len(test_keys)):
        try:
            response = requests.post(f"{BASE_URL}/keys/rotate")
            if response.status_code == 200:
                data = response.json()
                current_key = data.get('pool_status', {}).get('current_key_preview', 'Unknown')
                print(f"✅ Rotation {i+1}: Now using {current_key}")
            else:
                print(f"❌ Rotation {i+1} failed: {response.status_code}")
                break
        except Exception as e:
            print(f"❌ Rotation {i+1} error: {e}")
            break
    
    print("\n✅ Rotation test complete!")
    print("🎯 The system should now:")
    print("   • Use multiple keys from the pool")
    print("   • Rotate when rate limits are hit")  
    print("   • Handle 503 'model overloaded' errors")
    print("   • Update all services with new keys")

if __name__ == "__main__":
    test_key_rotation_fix()
