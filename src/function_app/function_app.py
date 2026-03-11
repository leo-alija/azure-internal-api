import azure.functions as func
import json
import uuid
from datetime import datetime, timezone

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

# POST /api/message
# Accepts JSON with a "message" field, returns it back with a timestamp and request ID.
# Auth level is anonymous because we're using mTLS (client certs) instead of function keys.
@app.route(route="message", methods=["POST"])
def message(req: func.HttpRequest) -> func.HttpResponse:
    try:
        body = req.get_json()
    except ValueError:
        return func.HttpResponse(
            json.dumps({"error": "Request body must be valid JSON"}),
            status_code=400,
            mimetype="application/json"
        )

    message_value = body.get("message")
    if not message_value:
        return func.HttpResponse(
            json.dumps({"error": "Missing required field: message"}),
            status_code=400,
            mimetype="application/json"
        )

    response = {
        "message": message_value,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "requestId": str(uuid.uuid4())
    }

    return func.HttpResponse(
        json.dumps(response),
        status_code=200,
        mimetype="application/json"
    )

# GET /api/health
# Simple health check — returns 200 if the function is running.
@app.route(route="health", methods=["GET"])
def health(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps({
            "status": "healthy",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }),
        status_code=200,
        mimetype="application/json"
    )