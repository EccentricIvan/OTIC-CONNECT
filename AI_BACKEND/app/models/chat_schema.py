from pydantic import BaseModel


class ChatRequest(BaseModel):
    language: str
    message: str


class ChatResponse(BaseModel):
    language: str
    original_message: str
    english_message: str
    english_response: str
    final_response: str