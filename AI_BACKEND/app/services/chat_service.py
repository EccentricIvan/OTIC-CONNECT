import os
import requests
from dotenv import load_dotenv

from app.services.translator_service import translator_service


load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant")

GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"


SUPPORTED_CHAT_LANGUAGES = {
    "english",
    "luganda",
    "swahili",
}


class ChatService:
    def ask_groq(self, prompt: str) -> str:
        if not GROQ_API_KEY:
            raise ValueError("GROQ_API_KEY is missing. Add it to your .env file.")

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": GROQ_MODEL,
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "You are OTIC Connect's local language AI assistant. "
                        "Answer clearly, respectfully, and practically. "
                        "Do not mention internal translation."
                    ),
                },
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
            "temperature": 0.7,
        }

        response = requests.post(
            GROQ_URL,
            headers=headers,
            json=payload,
            timeout=120,
        )

        response.raise_for_status()

        data = response.json()
        return data["choices"][0]["message"]["content"].strip()

    def chat(self, language: str, message: str):
        language = language.lower().strip()
        message = message.strip()

        if language not in SUPPORTED_CHAT_LANGUAGES:
            raise ValueError(
                "Unsupported chat language. Supported languages: english, luganda, swahili"
            )

        if not message:
            raise ValueError("Message cannot be empty.")

        if language == "english":
            english_message = message
        else:
            english_message = translator_service.translate(
                source_language=language,
                target_language="english",
                text=message,
            )

        english_response = self.ask_groq(english_message)

        if language == "english":
            final_response = english_response
        else:
            final_response = translator_service.translate(
                source_language="english",
                target_language=language,
                text=english_response,
            )

        return {
            "language": language,
            "original_message": message,
            "english_message": english_message,
            "english_response": english_response,
            "final_response": final_response,
        }


chat_service = ChatService()