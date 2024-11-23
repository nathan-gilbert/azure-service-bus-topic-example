# Service Bus Python App

A simple python script to receive messages from an Azure's Service Bus subscription.

## Setup

- `tofu init`
- `tofu apply`
- Log into the Web Service via SSH and copy the app code and run it manually.

## App Install

Log in to Web Service via SSH.

1. Setup Python venv: `python3 -m venv venv`
2. copy paste `requirements.txt` onto VM
3. copy paste `app.py` onto VM
4. Activate venv: `source venv/bin/activate`
5. Install deps: `pip install -r requirements.txt`
6. Run app: `python app.py`
7. Send test message from Service Bus UI.
8. Look for connection in app logs.
