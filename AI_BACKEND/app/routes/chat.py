from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from app.services.chat_service import chat_service


router = APIRouter()


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1)
    language: str = Field(..., examples=["english", "luganda", "swahili"])


@router.get("/")
def chat_status():
    return {
        "status": "ok",
        "service": "OTIC local language chat",
        "supported_languages": ["english", "luganda", "swahili"],
        "mode": "fast-rich-local-mode",
        "flow": [
            "English chat uses Groq directly",
            "Local chat translates user message to English if needed",
            "Groq answers directly in Luganda or Swahili",
            "Fine-tuned LoRA repairs the response only if English leaks",
        ],
    }


@router.post("/")
def chat(request: ChatRequest):
    try:
        reply = chat_service.chat(
            message=request.message,
            language=request.language,
        )

        return {
            "language": request.language,
            "message": request.message,
            "response": reply,
            "reply": reply,
            "answer": reply,
        }

    except ValueError as error:
        raise HTTPException(
            status_code=400,
            detail=str(error),
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Chat service error: {str(error)}",
        )