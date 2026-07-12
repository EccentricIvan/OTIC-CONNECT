import csv
import os
from datetime import datetime
from fastapi import APIRouter, HTTPException

from app.models.feedback_schema import FeedbackRequest, FeedbackResponse


router = APIRouter(
    prefix="/feedback",
    tags=["Feedback"]
)


CORRECTIONS_FILE = "app/Data/corrections.csv"


def ensure_corrections_file_exists():
    os.makedirs("app/Data", exist_ok=True)

    if not os.path.exists(CORRECTIONS_FILE):
        with open(CORRECTIONS_FILE, "w", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)
            writer.writerow([
                "timestamp",
                "language",
                "user_message",
                "ai_response",
                "correct_response",
                "issue_type",
                "reviewer",
                "approved"
            ])


@router.post("/", response_model=FeedbackResponse)
def save_feedback(request: FeedbackRequest):
    try:
        ensure_corrections_file_exists()

        with open(CORRECTIONS_FILE, "a", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)
            writer.writerow([
                datetime.now().isoformat(),
                request.language.strip().lower(),
                request.user_message.strip(),
                request.ai_response.strip(),
                request.correct_response.strip(),
                request.issue_type.strip(),
                request.reviewer.strip(),
                "no"
            ])

        return FeedbackResponse(
            status="success",
            message="Feedback saved for review."
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to save feedback: {str(error)}"
        )