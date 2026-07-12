import os
import re
from typing import List

import requests
from dotenv import load_dotenv

from app.services.translator_service import translator_service


load_dotenv()


GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"


LANGUAGE_ALIASES = {
    "en": "english",
    "eng": "english",
    "english": "english",

    "lg": "luganda",
    "lug": "luganda",
    "luganda": "luganda",

    "sw": "swahili",
    "swa": "swahili",
    "swh": "swahili",
    "kiswahili": "swahili",
    "swahili": "swahili",
}


class ChatService:
    def normalize_language(self, language: str) -> str:
        cleaned = str(language).lower().strip()

        if cleaned not in LANGUAGE_ALIASES:
            raise ValueError(f"Unsupported language: {language}")

        return LANGUAGE_ALIASES[cleaned]

    def call_groq(self, system_prompt: str, user_prompt: str) -> str:
        if not GROQ_API_KEY:
            raise RuntimeError("GROQ_API_KEY is missing. Add it to AI_BACKEND/.env")

        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": GROQ_MODEL,
            "messages": [
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": user_prompt,
                },
            ],
            "temperature": 0.35,
            "max_tokens": 420,
        }

        response = requests.post(
            GROQ_API_URL,
            headers=headers,
            json=payload,
            timeout=45,
        )

        response.raise_for_status()
        data = response.json()

        return data["choices"][0]["message"]["content"].strip()

    def build_english_system_prompt(self) -> str:
        return (
            "You are OTIC CONNECT, a helpful assistant for students and young people. "
            "Answer with simple, practical, realistic advice. "
            "Use plain English. "
            "Avoid repetition. "
            "Avoid markdown formatting. "
            "Avoid long sentences."
        )

    def clean_text_for_translation(self, text: str) -> str:
        text = text.replace("**", "")
        text = text.replace("*", "")
        text = text.replace("#", "")
        text = text.replace("`", "")
        text = re.sub(r"\n{3,}", "\n\n", text)
        return text.strip()

    def translate_user_message_to_english(self, message: str, selected_language: str) -> str:
        if selected_language == "english":
            return message

        translated = translator_service.translate(
            source_language=selected_language,
            target_language="english",
            text=message,
        )

        return translated or message

    def split_for_local_translation(self, text: str) -> List[str]:
        lines = [line.strip() for line in text.splitlines() if line.strip()]

        if lines:
            return lines[:6]

        sentences = re.split(r"(?<=[.!?])\s+", text.strip())
        sentences = [sentence.strip() for sentence in sentences if sentence.strip()]

        return sentences[:6] if sentences else [text.strip()]

    def translate_structured_english_to_local(self, text: str, target_language: str) -> str:
        clean_text = self.clean_text_for_translation(text)
        chunks = self.split_for_local_translation(clean_text)
        translated_chunks = []

        for chunk in chunks:
            match = re.match(r"^(\s*(?:[-*•]|\d+[.)])\s*)(.+)$", chunk)

            if match:
                prefix = match.group(1)
                content = match.group(2)
            else:
                prefix = ""
                content = chunk

            translated = translator_service.translate(
                source_language="english",
                target_language=target_language,
                text=content,
            )

            if translated:
                translated_chunks.append(f"{prefix}{translated}")
            else:
                translated_chunks.append(chunk)

        return "\n".join(translated_chunks).strip()

    def build_structured_english_answer(self, english_meaning: str) -> str:
        english_prompt = (
            f"The user asked this question:\n\n"
            f"{english_meaning}\n\n"
            "Answer in plain simple English for translation into a local African language. "
            "Give exactly 4 numbered points. "
            "Each point must be one short sentence only. "
            "Use everyday words. "
            "Do not use bold text. "
            "Do not use markdown. "
            "Do not use headings. "
            "Do not use idioms. "
            "Do not repeat the same idea. "
            "Focus on realistic advice for the user's situation."
        )

        english_response = self.call_groq(
            system_prompt=self.build_english_system_prompt(),
            user_prompt=english_prompt,
        )

        return self.clean_text_for_translation(english_response)

    def chat(self, message: str, language: str) -> str:
        selected_language = self.normalize_language(language)
        message = str(message).strip()

        if not message:
            return "Please enter a message."

        if selected_language == "english":
            return self.call_groq(
                system_prompt=self.build_english_system_prompt(),
                user_prompt=message,
            )

        english_meaning = self.translate_user_message_to_english(
            message=message,
            selected_language=selected_language,
        )

        english_response = self.build_structured_english_answer(
            english_meaning=english_meaning,
        )

        local_response = self.translate_structured_english_to_local(
            text=english_response,
            target_language=selected_language,
        )

        return local_response or english_response


chat_service = ChatService()
