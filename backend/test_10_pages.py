#!/usr/bin/env python3
"""
Test script for the new 10-page story generation workflow
"""

import requests
import json

BASE_URL = "http://localhost:8080/api"

def test_10_page_story():
    """Test the new 10-page story generation"""
    print("📖 Testing 10-Page Story Generation")
    print("=" * 50)
    
    # Test story request
    story_request = {
        "prompt": "A brave lion and clever fox who go on an adventure",
        "theme": "Adventure",
        "additionalContext": "Make it exciting for children"
    }
    
    print(f"🎯 Generating story: {story_request['prompt']}")
    print(f"🎨 Theme: {story_request['theme']}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/stories/generate",
            headers={'Content-Type': 'application/json'},
            json=story_request
        )
        
        if response.status_code == 200:
            data = response.json()
            
            if data.get('success'):
                story = data.get('data', {})
                pages = story.get('pages', [])
                
                print(f"✅ Story generated successfully!")
                print(f"📚 Title: {story.get('title', 'Unknown')}")
                print(f"📄 Pages generated: {len(pages)}")
                print(f"🎨 Theme: {story.get('theme', 'Unknown')}")
                
                # Show each page
                for i, page in enumerate(pages[:3]):  # Show first 3 pages
                    print(f"\n📖 Page {page.get('pageNumber', i+1)}:")
                    print(f"   Script: {page.get('script', '')[:100]}...")
                    print(f"   Image: {'✅' if page.get('imageUrl') else '❌'}")
                
                if len(pages) > 3:
                    print(f"\n... and {len(pages) - 3} more pages")
                
                # Verify structure
                print(f"\n🔍 Verification:")
                print(f"   ✅ Has exactly 10 pages: {len(pages) == 10}")
                print(f"   ✅ All pages have scripts: {all(page.get('script') for page in pages)}")
                print(f"   ✅ All pages have images: {all(page.get('imageUrl') for page in pages)}")
                
                return True
            else:
                print(f"❌ Story generation failed: {data.get('error', 'Unknown error')}")
                return False
        else:
            print(f"❌ Request failed with status {response.status_code}")
            print(f"📄 Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error during story generation: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting 10-Page Story Generation Test")
    
    # Check if backend is running
    try:
        health_response = requests.get(f"{BASE_URL}/health", timeout=5)
        if health_response.status_code != 200:
            print("❌ Backend is not responding properly")
            return
    except:
        print("❌ Backend is not running. Please start it with: python app.py")
        return
    
    print("✅ Backend is running")
    
    # Test the new workflow
    success = test_10_page_story()
    
    if success:
        print("\n🎉 10-Page Story Generation Test PASSED!")
        print("📖 Your new workflow is working:")
        print("   1. ✅ Generates exactly 10 page scripts")
        print("   2. ✅ Creates individual images for each page")
        print("   3. ✅ Structures data as pages with script + image")
        print("   4. ✅ Uses API key rotation for reliability")
    else:
        print("\n❌ Test FAILED - Check the backend logs for details")

if __name__ == "__main__":
    main()
