import os
from flask import Flask

app = Flask(__name__)

@app.route('/health')
def health():
    return "OK", 200

@app.route('/value')
def get_value():
    value = os.getenv("WEB_API_VALUE")

    if value is None:
        return "Web api value is not set", 500

    return value, 200

if __name__ == "__main__":
    port = int(os.getenv("WEB_API_PORT", 5001))
    app.run(host="0.0.0.0", port=port, debug=True)