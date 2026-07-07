import requests
from fastapi import APIRouter, HTTPException

from app.models.chat_schema import ChatRequest, ChatResponse
from app.services.chat_service import chat_service


router = APIRouter(
    prefix="/chat",
    tags=["Chat"]
)


@router.post("/", response_model=ChatResponse)
def chat(request: ChatRequest):
    try:
        result = chat_service.chat(
            language=request.language,
            message=request.message,
        )

        return ChatResponse(**result)

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))

    except requests.exceptions.HTTPError as error:
        raise HTTPException(
            status_code=502,
            detail=f"Groq API error: {str(error)}"
        )

    except requests.exceptions.ConnectionError:
        raise HTTPException(
            status_code=503,
            detail="Could not connect to Groq API. Check your internet connection."
        )

    except Exception as error:
        raise HTTPException(
            status_code=500,
            detail=f"Chat failed: {str(error)}"
        )