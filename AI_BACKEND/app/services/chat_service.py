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
    "swahili",
    "luganda",
}


LANGUAGE_ALIASES = {
    "en": "english",
    "eng": "english",
    "english": "english",

    "sw": "swahili",
    "swa": "swahili",
    "kiswahili": "swahili",
    "swahili": "swahili",

    "lg": "luganda",
    "lug": "luganda",
    "luganda": "luganda",
}


LANGUAGE_NAMES = {
    "english": "English",
    "swahili": "Kiswahili",
    "luganda": "Luganda",
}


LOCAL_FALLBACK_RESPONSES = {
    "english": "Sorry, I had trouble generating a response. Please try again with a shorter question.",
    "swahili": "Samahani, nimepata changamoto kidogo. Tafadhali uliza tena kwa maneno mafupi.",
    "luganda": "Nsonyiwa, waliwo obuzibu obutonotono. Nsaba obuuze nate mu bigambo bitono.",
}


ENGLISH_LEAK_WORDS = {
    "the", "and", "you", "your", "are", "is", "can", "should",
    "learn", "study", "help", "with", "this", "that", "to", "of",
    "in", "for", "good", "better", "practice", "please", "sorry",
    "question", "answer", "try", "again", "short", "shorter"
}


class ChatService:
    def normalize_language(self, language: str) -> str:
        cleaned = language.lower().strip()

        if cleaned not in LANGUAGE_ALIASES:
            return "english"

        return LANGUAGE_ALIASES[cleaned]

    def call_groq(self, messages, temperature=0.4, max_tokens=120) -> str:
        if not GROQ_API_KEY:
            return ""

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": GROQ_MODEL,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }

        try:
            response = requests.post(
                GROQ_URL,
                headers=headers,
                json=payload,
                timeout=120,
            )
            response.raise_for_status()
            data = response.json()
            return data["choices"][0]["message"]["content"].strip()

        except Exception:
            return ""

    def looks_like_english_leak(self, text: str) -> bool:
        words = [
            word.strip(".,!?;:()[]{}\"'").lower()
            for word in text.split()
        ]

        words = [word for word in words if word]

        if len(words) < 4:
            return False

        english_count = sum(1 for word in words if word in ENGLISH_LEAK_WORDS)
        ratio = english_count / len(words)

        return ratio >= 0.45

    def safe_translate_to_english(self, language: str, message: str) -> str:
        if language == "english":
            return message

        try:
            translated = translator_service.translate(
                source_language=language,
                target_language="english",
                text=message,
            )

            if translated and translated.strip():
                return translated.strip()

        except Exception:
            pass

        # If translation fails, do not stop the chat.
        # Groq will receive the original message.
        return message

    def safe_translate_from_english(self, target_language: str, english_response: str) -> str | None:
        if target_language == "english":
            return english_response

        try:
            translated_response = translator_service.translate(
                source_language="english",
                target_language=target_language,
                text=english_response,
            )

            translated_response = translated_response.strip()

            if not translated_response:
                return None

            if translated_response.lower() == english_response.lower():
                return None

            if self.looks_like_english_leak(translated_response):
                return None

            return translated_response

        except Exception:
            return None

    def ask_groq_in_english(self, english_message: str) -> str:
        messages = [
            {
                "role": "system",
                "content": (
                    "You are OTIC Connect's assistant. "
                    "Answer in English only. "
                    "Use 2 short, clear sentences. "
                    "Do not mention translation."
                ),
            },
            {
                "role": "user",
                "content": english_message,
            },
        ]

        return self.call_groq(messages, temperature=0.4, max_tokens=120)

    def ask_groq_directly_in_local_language(
        self,
        language: str,
        original_message: str,
        english_response: str = "",
    ) -> str:
        language_name = LANGUAGE_NAMES.get(language, language)

        if english_response:
            user_content = (
                f"Rewrite this answer in {language_name} only. "
                f"Do not use English. Keep it natural and short.\n\n"
                f"Answer:\n{english_response}"
            )
        else:
            user_content = original_message

        messages = [
            {
                "role": "system",
                "content": (
                    f"You are OTIC Connect's assistant. "
                    f"Reply only in {language_name}. "
                    f"Do not use English. "
                    f"Use 2 short, natural sentences."
                ),
            },
            {
                "role": "user",
                "content": user_content,
            },
        ]

        response = self.call_groq(messages, temperature=0.3, max_tokens=120)

        if not response:
            return ""

        if language != "english" and self.looks_like_english_leak(response):
            return ""

        return response.strip()

    def chat(self, language: str, message: str):
        selected_language = self.normalize_language(language)
        message = message.strip()

        if not message:
            return {
                "language": selected_language,
                "response": LOCAL_FALLBACK_RESPONSES[selected_language],
            }

        # English is straightforward.
        if selected_language == "english":
            english_response = self.ask_groq_in_english(message)

            return {
                "language": "english",
                "response": english_response or LOCAL_FALLBACK_RESPONSES["english"],
            }

        # Local language flow.
        english_message = self.safe_translate_to_english(
            language=selected_language,
            message=message,
        )

        english_response = self.ask_groq_in_english(english_message)

        # First attempt: NLLB translates Groq's English answer back to selected language.
        if english_response:
            translated_response = self.safe_translate_from_english(
                target_language=selected_language,
                english_response=english_response,
            )

            if translated_response:
                return {
                    "language": selected_language,
                    "response": translated_response,
                }

        # Second attempt: ask Groq to rewrite directly in the selected local language.
        direct_local_response = self.ask_groq_directly_in_local_language(
            language=selected_language,
            original_message=message,
            english_response=english_response,
        )

        if direct_local_response:
            return {
                "language": selected_language,
                "response": direct_local_response,
            }

        # Final guarantee: never return English for local-language mode.
        return {
            "language": selected_language,
            "response": LOCAL_FALLBACK_RESPONSES[selected_language],
        }


chat_service = ChatService()