from copy import deepcopy

import pytest


@pytest.fixture
def dummy_data() -> dict[str, str]:
    """Return Dummy data."""
    data = {
        "first_name": "John",
        "last_name": "Doe",
    }
    return deepcopy(data)
