#!/usr/bin/env python3
"""
Test script to verify API key persistence functionality
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

# Import the ApiKeyPool class
from app import ApiKeyPool

def test_persistence():
    """Test the API key persistence functionality"""
    print("🧪 Testing API Key Persistence")
    print("=" * 50)
    
    # Test 1: Initialize and check if keys are loaded from file
    print("\n1️⃣ Testing initialization with existing file...")
    try:
        ApiKeyPool.init('test_app')
        
        if ApiKeyPool._api_keys:
            print(f"✅ Loaded {len(ApiKeyPool._api_keys)} keys from file")
            print(f"🔑 Keys: {[key[:10] + '...' for key in ApiKeyPool._api_keys]}")
            print(f"📊 Current index: {ApiKeyPool._current_key_index}")
        else:
            print("❌ No keys loaded - file might not exist or be empty")
            
    except Exception as e:
        print(f"❌ Error during initialization: {e}")
    
    # Test 2: Check if we can get a key
    print("\n2️⃣ Testing key retrieval...")
    try:
        key = ApiKeyPool.get_key()
        if key:
            print(f"✅ Successfully got key: {key[:10]}...")
        else:
            print("❌ No key available")
    except Exception as e:
        print(f"❌ Error getting key: {e}")
    
    # Test 3: Test key rotation
    print("\n3️⃣ Testing key rotation...")
    try:
        old_index = ApiKeyPool._current_key_index
        success = ApiKeyPool.rotate_key()
        if success:
            new_index = ApiKeyPool._current_key_index
            print(f"✅ Rotation successful: {old_index} → {new_index}")
        else:
            print("❌ Rotation failed")
    except Exception as e:
        print(f"❌ Error during rotation: {e}")
    
    # Test 4: Verify file contents
    print("\n4️⃣ Checking file contents...")
    try:
        import json
        if os.path.exists(ApiKeyPool._keys_file):
            with open(ApiKeyPool._keys_file, 'r') as f:
                data = json.load(f)
            print(f"✅ File exists with {len(data.get('api_keys', []))} keys")
            print(f"📊 Current index in file: {data.get('current_key_index', 0)}")
            print(f"🕒 Last updated: {data.get('timestamp', 'Unknown')}")
        else:
            print(f"❌ File {ApiKeyPool._keys_file} does not exist")
    except Exception as e:
        print(f"❌ Error reading file: {e}")
    
    print("\n✅ Persistence test completed!")

if __name__ == "__main__":
    test_persistence()
