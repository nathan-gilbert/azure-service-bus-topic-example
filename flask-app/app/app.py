import os
import logging

from azure.servicebus import ServiceBusClient, ServiceBusMessage

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')

logger = logging.getLogger(__name__)

SERVICE_BUS_CONNECTION_STRING = os.getenv("SERVICE_BUS_CONNECTION_STRING")
TOPIC_NAME = os.getenv("TOPIC_NAME")
SUBSCRIPTION_NAME = os.getenv("SUBSCRIPTION_NAME")

def receive_messages():
    with ServiceBusClient.from_connection_string(SERVICE_BUS_CONNECTION_STRING) as client:
        receiver = client.get_subscription_receiver(
            topic_name=TOPIC_NAME,
            subscription_name=SUBSCRIPTION_NAME
        )
        with receiver:
            for msg in receiver:
                logger.debug(f"Received: {str(msg)}")
                receiver.complete_message(msg)

if __name__ == "__main__":
    receive_messages()
