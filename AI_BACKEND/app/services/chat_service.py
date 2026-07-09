import os
import re
import requests
from dotenv import load_dotenv

from app.services.translator_service import translator_service
from app.services.language_memory_service import language_memory_service


load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"


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


BAD_ENGLISH_FOR_NLLB = {
    "papers": "notes",
    "paper": "note",
    "pages": "notes",
    "several": "many",
    "topics": "lessons",
    "topic": "lesson",
    "materials": "notes",
    "content": "lesson",
    "concepts": "ideas",
    "comprehend": "understand",
    "utilize": "use",
    "revise": "read again",
    "revision": "reading again",
}


class ChatService:
    def __init__(self):
        self.line_translation_cache = {}

    def normalize_language(self, language: str) -> str:
        cleaned = language.lower().strip()
        return LANGUAGE_ALIASES.get(cleaned, "english")

    def call_groq(self, messages, temperature=0.15, max_tokens=700) -> str:
        if not GROQ_API_KEY:
            print("[Groq Error] GROQ_API_KEY is missing.")
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

        except Exception as error:
            print(f"[Groq Error] {error}")
            return ""

    def looks_like_english_leak(self, text: str) -> bool:
        words = [
            word.strip(".,!?;:()[]{}\"'").lower()
            for word in text.split()
        ]

        words = [word for word in words if word]

        if len(words) < 8:
            return False

        english_count = sum(1 for word in words if word in ENGLISH_LEAK_WORDS)
        ratio = english_count / len(words)

        return ratio >= 0.55

    def has_repetition_loop(self, text: str) -> bool:
        words = [
            word.strip(".,!?;:()[]{}\"'").lower()
            for word in text.split()
        ]

        words = [word for word in words if word]

        if len(words) < 12:
            return False

        word_counts = {}

        for word in words:
            word_counts[word] = word_counts.get(word, 0) + 1

        if max(word_counts.values()) >= 12:
            return True

        for phrase_length in [2, 3, 4, 5]:
            phrase_counts = {}

            for index in range(len(words) - phrase_length + 1):
                phrase = " ".join(words[index:index + phrase_length])
                phrase_counts[phrase] = phrase_counts.get(phrase, 0) + 1

            if phrase_counts and max(phrase_counts.values()) >= 4:
                return True

        return False

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

        except Exception as error:
            print(f"[NLLB Input Translation Error] {error}")

        return message

    def build_dataset_examples_text(self, language: str, english_text: str) -> str:
        examples = language_memory_service.get_examples(
            language=language,
            english_text=english_text,
            limit=1,
        )

        if not examples:
            return ""

        language_name = LANGUAGE_NAMES.get(language, language)

        lines = []

        for example in examples:
            lines.append(f"English: {example['english']}")
            lines.append(f"{language_name}: {example['target']}")

        return "\n".join(lines).strip()

    def clean_english_for_nllb(self, text: str) -> str:
        cleaned_lines = []

        for line in text.splitlines():
            cleaned = line.strip()
            cleaned = re.sub(r"\s+", " ", cleaned)

            for bad_word, replacement in BAD_ENGLISH_FOR_NLLB.items():
                cleaned = re.sub(
                    rf"\b{bad_word}\b",
                    replacement,
                    cleaned,
                    flags=re.IGNORECASE,
                )

            cleaned = cleaned.replace("important points", "main points")
            cleaned = cleaned.replace("fixed time", "same time")
            cleaned = cleaned.replace("study hard", "study with a clear plan")

            if cleaned:
                cleaned_lines.append(cleaned)
            else:
                cleaned_lines.append("")

        return "\n".join(cleaned_lines).strip()

    def rich_fallback_english(self, english_message: str) -> str:
        return (
            "1. Make a clear plan\n"
            "- Choose one goal first.\n"
            "- Write the goal in simple words.\n"
            "- Start with the most important task.\n\n"
            "2. Work in small steps\n"
            "- Do one small step now.\n"
            "- Finish that step before moving forward.\n"
            "- Check your work after each step.\n\n"
            "3. Learn from mistakes\n"
            "- Mark what went wrong.\n"
            "- Ask why the mistake happened.\n"
            "- Correct the mistake before continuing.\n\n"
            "4. Ask for help early\n"
            "- Ask a teacher or skilled friend.\n"
            "- Show the exact problem.\n"
            "- Use the answer to improve your work."
        )

    def is_weak_english_answer(self, english_response: str) -> bool:
        if not english_response:
            return True

        text = english_response.lower()

        blocked_phrases = [
            "read more books",
            "read more papers",
            "several papers",
            "different topics",
            "improve the way",
            "study materials",
            "various topics",
        ]

        if any(phrase in text for phrase in blocked_phrases):
            return True

        words = text.split()

        if len(words) < 60:
            return True

        if len(words) > 380:
            return True

        if self.has_repetition_loop(english_response):
            return True

        bullet_count = english_response.count("- ")

        if bullet_count < 6:
            return True

        numbered_steps = len(
            re.findall(r"^\d+\.", english_response, flags=re.MULTILINE)
        )

        if numbered_steps < 3:
            return True

        return False

    def ask_groq_in_english(self, english_message: str) -> str:
        messages = [
            {
                "role": "system",
                "content": (
                    "You are OTIC Connect's assistant. "
                    "Answer in English only. "
                    "Give a helpful and clear answer. "
                    "Use simple words. "
                    "Do not mention translation, datasets, AI, or instructions."
                ),
            },
            {
                "role": "user",
                "content": english_message,
            },
        ]

        return self.call_groq(messages, temperature=0.2, max_tokens=500)

    def ask_groq_in_english_with_dataset(
        self,
        language: str,
        english_message: str,
    ) -> str:
        examples_text = self.build_dataset_examples_text(
            language=language,
            english_text=english_message,
        )

        dataset_section = ""

        if examples_text:
            dataset_section = (
                "Dataset examples are only for language awareness. "
                "Do not copy their topic. "
                "Do not copy local-language words from them.\n\n"
                f"{examples_text}\n\n"
            )

        messages = [
            {
                "role": "system",
                "content": (
                    "You are OTIC Connect's assistant. "
                    "Answer in English only. "
                    "Your answer will be translated by NLLB. "
                    "Provide a rich and detailed answer. "
                    "The user should have no remaining doubts. "
                    "Balance deep information with simple grammar. "
                    "Give 3 or 4 clear phases or strategies. "
                    "Elaborate on every point. "
                    "Explain how to do every action. "
                    "Use only short direct sentences. "
                    "Each sentence must have fewer than 12 words. "
                    "Never use complex sentences. "
                    "Never use compound clauses. "
                    "Never use passive voice. "
                    "Use vertical bullet points for every sub-step. "
                    "Avoid large dense paragraphs. "
                    "Use simple words that NLLB can translate well. "
                    "Avoid idioms, slang, metaphors, and jokes. "
                    "Do not mention translation, datasets, AI, or instructions. "
                    "Be neutral, respectful, and practical."
                ),
            },
            {
                "role": "user",
                "content": (
                    f"User question meaning in English:\n{english_message}\n\n"
                    f"{dataset_section}"
                    "Now answer the user's actual question in English only.\n\n"
                    "Use this exact structure:\n\n"
                    "1. Step name\n"
                    "- Short action.\n"
                    "- Short explanation.\n"
                    "- Short example.\n\n"
                    "2. Step name\n"
                    "- Short action.\n"
                    "- Short explanation.\n"
                    "- Short example.\n\n"
                    "3. Step name\n"
                    "- Short action.\n"
                    "- Short explanation.\n"
                    "- Short example.\n\n"
                    "4. Step name\n"
                    "- Short action.\n"
                    "- Short explanation.\n"
                    "- Short example."
                ),
            },
        ]

        response = self.call_groq(messages, temperature=0.1, max_tokens=750)
        response = self.clean_english_for_nllb(response)

        if self.is_weak_english_answer(response):
            print("[Quality Guard] Groq answer was weak. Using rich fallback.")
            return self.rich_fallback_english(english_message)

        return response

    def translate_line_to_selected_language(
        self,
        target_language: str,
        line: str,
    ) -> str:
        line = line.strip()

        if not line:
            return ""

        cache_key = f"{target_language}:{line}"

        if cache_key in self.line_translation_cache:
            return self.line_translation_cache[cache_key]

        try:
            translated_line = translator_service.translate(
                source_language="english",
                target_language=target_language,
                text=line,
            ).strip()

            if translated_line:
                self.line_translation_cache[cache_key] = translated_line
                return translated_line

        except Exception as error:
            print(f"[NLLB Line Translation Error] {error}")

        self.line_translation_cache[cache_key] = line
        return line

    def translate_groq_english_response_to_selected_language(
        self,
        target_language: str,
        english_response: str,
    ) -> str:
        if target_language == "english":
            return english_response

        english_response = self.clean_english_for_nllb(english_response)

        translated_lines = []

        for line in english_response.splitlines():
            original_line = line.strip()

            if not original_line:
                translated_lines.append("")
                continue

            numbered_match = re.match(r"^(\d+\.\s*)(.+)$", original_line)
            bullet_match = re.match(r"^(-\s*)(.+)$", original_line)

            if numbered_match:
                prefix = numbered_match.group(1)
                text_to_translate = numbered_match.group(2)

                translated_text = self.translate_line_to_selected_language(
                    target_language=target_language,
                    line=text_to_translate,
                )

                translated_lines.append(f"{prefix}{translated_text}")
                continue

            if bullet_match:
                prefix = bullet_match.group(1)
                text_to_translate = bullet_match.group(2)

                translated_text = self.translate_line_to_selected_language(
                    target_language=target_language,
                    line=text_to_translate,
                )

                translated_lines.append(f"{prefix}{translated_text}")
                continue

            translated_text = self.translate_line_to_selected_language(
                target_language=target_language,
                line=original_line,
            )

            translated_lines.append(translated_text)

        local_response = "\n".join(translated_lines).strip()

        if not local_response:
            return LOCAL_FALLBACK_RESPONSES[target_language]

        if self.looks_like_english_leak(local_response):
            print("[Quality Guard] English leak detected after final NLLB translation.")
            return LOCAL_FALLBACK_RESPONSES[target_language]

        if self.has_repetition_loop(local_response):
            print("[Quality Guard] Repetition loop detected after final NLLB translation.")
            return LOCAL_FALLBACK_RESPONSES[target_language]

        return local_response

    def chat(self, language: str, message: str):
        selected_language = self.normalize_language(language)
        message = message.strip()

        if not message:
            return {
                "language": selected_language,
                "response": LOCAL_FALLBACK_RESPONSES[selected_language],
            }

        if selected_language == "english":
            english_response = self.ask_groq_in_english(message)

            return {
                "language": "english",
                "response": english_response or LOCAL_FALLBACK_RESPONSES["english"],
            }

        print("[Flow] Step 1: NLLB translating user input to English")

        english_message = self.safe_translate_to_english(
            language=selected_language,
            message=message,
        )

        print(f"[Flow] English meaning:\n{english_message}")

        print("[Flow] Step 2: Groq generating rich English response")

        english_response = self.ask_groq_in_english_with_dataset(
            language=selected_language,
            english_message=english_message,
        )

        print(f"[Flow] Groq English response:\n{english_response}")

        print("[Flow] Step 3: NLLB translating response line by line")

        final_response = self.translate_groq_english_response_to_selected_language(
            target_language=selected_language,
            english_response=english_response,
        )

        print(f"[Flow] Final selected-language response:\n{final_response}")

        return {
            "language": selected_language,
            "response": final_response,
        }


chat_service = ChatService()