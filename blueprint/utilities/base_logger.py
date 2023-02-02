import logging
import os
import sys

# Get logging level from environment
level = os.getenv("LOGGING_LEVEL", default="INFO")

# Define the format
FORMAT = '%(asctime)s.%(msecs)dZ:APP:%(name)s:%(levelname)s:%(message)s'
FORMAT="[%(asctime)s] %(levelname)s [%(name)s.%(funcName)s:%(lineno)d] %(message)s"
formatter = logging.Formatter(FORMAT, datefmt="%Y-%m-%dT%H:%M:%S")

# Create a handler that sends the logs to stdout
handler = logging.StreamHandler(stream=sys.stdout)
handler.setFormatter(formatter)


# Configure logger
base_logger = logging.getLogger()
base_logger.setLevel(getattr(logging, level))
base_logger.addHandler(handler)
