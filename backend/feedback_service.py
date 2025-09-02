from datetime import datetime
from typing import Dict, Any, List, Optional
from firebase_admin import firestore

class FeedbackService:
    def __init__(self, db):
        self.db = db
        self.feedback_options = {
            "Positive": [
                "Great content",
                "Easy to understand", 
                "Visually appealing",
                "Informative",
                "Well structured",
                "Other"
            ],
            "Negative": [
                "Confusing Too complex",
                "Not visually appealing", 
                "Inappropriate or harmful content",
                "Sexual or adult content",
                "Bug or technical issue",
                "Other"
            ]
        }
    
    def submit_feedback(self, 
                       feedback_type: str,
                       selected_feedback: str,
                       custom_feedback: str = "",
                       story_id: Optional[str] = None,
                       rating: int = 5) -> Dict[str, Any]:
        """
        Submit feedback to Firebase
        
        Args:
            feedback_type: "Positive" or "Negative"
            selected_feedback: Selected feedback option
            custom_feedback: Custom feedback text if "Other" selected
            story_id: Optional story ID
            rating: Rating from 1-5
            
        Returns:
            Dict with success status and message
        """
        try:
            # Determine final feedback text
            final_feedback = custom_feedback if selected_feedback == "Other" else selected_feedback
            
            if not final_feedback:
                return {
                    'success': False,
                    'error': 'Please provide feedback.'
                }
            
            # Prepare feedback data
            feedback_data = {
                'feedbackType': feedback_type,
                'selectedFeedback': selected_feedback,
                'finalFeedback': final_feedback,
                'rating': rating,
                'submittedAt': firestore.SERVER_TIMESTAMP,
                'storyId': story_id
            }
            
            # Add to Firebase
            self.db.collection('reported_messages').add(feedback_data)
            
            return {
                'success': True,
                'message': 'Your feedback has been submitted successfully.'
            }
            
        except Exception as e:
            print(f"Error submitting feedback: {e}")
            return {
                'success': False,
                'error': f'Failed to submit feedback: {e}'
            }
    
    def get_feedback_options(self) -> Dict[str, List[str]]:
        """Get available feedback options"""
        return self.feedback_options
    
    def get_feedback_for_story(self, story_id: str) -> List[Dict[str, Any]]:
        """Get all feedback for a specific story"""
        try:
            feedback_ref = self.db.collection('reported_messages').where('storyId', '==', story_id)
            docs = feedback_ref.stream()
            
            feedback_list = []
            for doc in docs:
                feedback_data = doc.to_dict()
                feedback_data['id'] = doc.id
                feedback_list.append(feedback_data)
            
            return feedback_list
        except Exception as e:
            print(f"Error getting feedback for story: {e}")
            return []
    
    def get_feedback_stats(self, story_id: str) -> Dict[str, Any]:
        """Get feedback statistics for a story"""
        try:
            feedback_list = self.get_feedback_for_story(story_id)
            
            if not feedback_list:
                return {
                    'totalFeedback': 0,
                    'averageRating': 0.0,
                    'positiveCount': 0,
                    'negativeCount': 0,
                    'feedbackBreakdown': {}
                }
            
            total_feedback = len(feedback_list)
            total_rating = sum(f.get('rating', 0) for f in feedback_list)
            average_rating = total_rating / total_feedback if total_feedback > 0 else 0
            
            positive_count = sum(1 for f in feedback_list if f.get('feedbackType') == 'Positive')
            negative_count = total_feedback - positive_count
            
            # Feedback breakdown
            feedback_breakdown = {}
            for feedback in feedback_list:
                feedback_type = feedback.get('feedbackType', 'Unknown')
                if feedback_type not in feedback_breakdown:
                    feedback_breakdown[feedback_type] = 0
                feedback_breakdown[feedback_type] += 1
            
            return {
                'totalFeedback': total_feedback,
                'averageRating': average_rating,
                'positiveCount': positive_count,
                'negativeCount': negative_count,
                'feedbackBreakdown': feedback_breakdown
            }
            
        except Exception as e:
            print(f"Error getting feedback stats: {e}")
            return {
                'totalFeedback': 0,
                'averageRating': 0.0,
                'positiveCount': 0,
                'negativeCount': 0,
                'feedbackBreakdown': {}
            }
