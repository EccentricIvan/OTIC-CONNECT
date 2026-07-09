from app.routes.feedback import router as feedback_router
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.translate import router as translate_router
from app.routes.chat import router as chat_router


app = FastAPI(
    title="OTIC Local Language AI Backend",
    version="0.3.0",
    description="Translation and local language chat backend for OTIC-CONNECT"
)


# Allow Flutter app, browser, and local testing tools to access this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # okay for local testing; restrict later in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Register API routes
app.include_router(translate_router)
app.include_router(chat_router)
app.include_router(feedback_router)

@app.get("/")
def home():
    return {
        "message": "OTIC Local Language AI Backend is running",
        "docs": "Go to /docs to test the API",
        "available_endpoints": [
            "/translate/",
            "/chat/",
            "/health"
        ]
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "OTIC Local Language AI Backend"
    }
