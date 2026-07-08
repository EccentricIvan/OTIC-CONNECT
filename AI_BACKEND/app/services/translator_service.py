import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM


MODEL_NAME = "facebook/nllb-200-distilled-600M"

LANGUAGE_CODES = {
    "english": "eng_Latn",
    "luganda": "lug_Latn",
    "swahili": "swh_Latn",

    # Phase 1 test languages
    # Some of these may not be supported by the base Facebook NLLB tokenizer.
    # If unsupported, the API will return a clear error.
    "acholi": "ach_Latn",
    "ateso": "teo_Latn",
    "lugbara": "lgg_Latn",
    "runyankole": "nyn_Latn",
}


class TranslatorService:
    def __init__(self):
        print("Loading real NLLB translation model. First run may take time...")

        self.device = "cuda" if torch.cuda.is_available() else "cpu"

        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME)

        self.model.to(self.device)
        self.model.eval()

        print(f"NLLB model loaded successfully on {self.device}.")

    def get_language_code_and_token_id(self, language_name: str):
        language_name = language_name.lower().strip()

        if language_name not in LANGUAGE_CODES:
            supported = ", ".join(LANGUAGE_CODES.keys())
            raise ValueError(
                f"Unsupported language: {language_name}. "
                f"Supported languages are: {supported}"
            )

        language_code = LANGUAGE_CODES[language_name]
        token_id = self.tokenizer.convert_tokens_to_ids(language_code)

        if token_id is None or token_id == self.tokenizer.unk_token_id:
            raise ValueError(
                f"The language '{language_name}' maps to '{language_code}', "
                "but this base NLLB model/tokenizer does not support it. "
                "This language may need a custom fine-tuned model or custom tokens."
            )

        return language_code, token_id

    def translate(self, source_language: str, target_language: str, text: str) -> str:
        text = text.strip()

        if not text:
            raise ValueError("Text cannot be empty.")

        source_code, _ = self.get_language_code_and_token_id(source_language)
        target_code, target_token_id = self.get_language_code_and_token_id(target_language)

        self.tokenizer.src_lang = source_code

        inputs = self.tokenizer(
            text,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=256
        )

        inputs = {
            key: value.to(self.device)
            for key, value in inputs.items()
        }

        with torch.no_grad():
            translated_tokens = self.model.generate(
                **inputs,
                forced_bos_token_id=target_token_id,
                max_length=256,
                num_beams=3
            )

        translated_text = self.tokenizer.batch_decode(
            translated_tokens,
            skip_special_tokens=True
        )[0]

        return translated_text


translator_service = TranslatorService()