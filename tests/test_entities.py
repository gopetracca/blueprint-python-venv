"""Test Example."""

# pytype: skip-file

from blueprint.entities.customer import Customer


class TestEntities:

    def test_customer_equality(self, dummy_data):
        """Test Dummy.

        Uses fixtures.
        """

        # Given
        customer_1 = Customer(**dummy_data)
        customer_2 = Customer(**dummy_data)

        # Then
        assert customer_1 == customer_2
