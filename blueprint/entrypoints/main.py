"""CLI entrypoint.
"""
from __future__ import annotations

import argparse
from typing import TYPE_CHECKING

from blueprint.entities.customer import Customer
from blueprint.utilities.base_logger import logging

if TYPE_CHECKING:
    pass

logger = logging.getLogger(__name__)


def run():
    customer = Customer(
        first_name="John",
        last_name="Doe",
    )
    logger.info("Customer data: {}".format(customer))


if __name__ == '__main__':
    run()
