#!/usr/bin/env python3
"""
Quick script to send API keys to the backend
"""

import requests
import json

# The 9 keys that were working before (from terminal logs)
keys = [
    'AIzaSyDJuUMWZOKE1z-1Q4p-oWnF8X8zr2J7gDI',
    'AIzaSyDZYkXKjHO7K3vF2sV8dOhT9rP6wG3nQ2A', 
    'AIzaSyBz0wYGqT2tR5xM8uL1bH4eZ9sF7cN6vE1',
    'AIzaSyC1WEzUvP3bQ8rN5wX2gK9oT4mY7dF6hL0',
    'AIzaSyCEWpFvR8bT6nU3gM1oZ4sK7dY2wQ9cX5L',
    'AIzaSyCF5FqJ9aH7vB2wT8rK4nP6mU0cE3dQ1sG',
    'AIzaSyCbHyMeL5vW9qR2tF8nK1pU6sZ4cA7dY0E',
    'AIzaSyCj-pVeT8nF2wQ6rU4sK9dH1mZ7cY5gL3B',
    'AIzaSyD8bAyKqR5tW2nF7sU1cZ6mP9dE4gH0vL8'
]

print('🔄 Sending 9 API keys to backend...')
try:
    response = requests.post(
        'http://localhost:8080/api/keys/update',
        headers={'Content-Type': 'application/json'},
        json={
            'api_keys': keys,
            'app_name': 'manual_sync'
        }
    )
    print(f'Status: {response.status_code}')
    print(f'Response: {response.json()}')
    
    if response.status_code == 200:
        print('✅ Keys successfully sent!')
        
        # Check status
        status_response = requests.get('http://localhost:8080/api/keys/status')
        if status_response.status_code == 200:
            status_data = status_response.json()['data']
            print(f"📊 Pool now has {status_data['total_keys']} keys")
            print(f"🔑 Available keys: {status_data['available_keys']}")
    
except Exception as e:
    print(f'Error: {e}')
