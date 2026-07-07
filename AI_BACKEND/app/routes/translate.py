from fastapi import APIRouter, HTTPException
from app.models.translation_schema import TranslationRequest, TranslationResponse
from app.services.translator_service import translator_service

router = APIRouter(
    prefix="/translate",
    tags=["Translation"]
)


@router.post("/", response_model=TranslationResponse)
def translate_text(request: TranslationRequest):
    try:
        translated_text = translator_service.translate(
            source_language=request.source_language,
            target_language=request.target_language,
            text=request.text
        )

        return TranslationResponse(
            source_language=request.source_language,
            target_language=request.target_language,
            original_text=request.text,
            translated_text=translated_text
        )

    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))

    except Exception as error:
        raise HTTPException(status_code=500, detail=f"Translation failed: {str(error)}")