import pytest

from src.bank_account import BankAccount


def test_new_account_has_zero_balance():
    account = BankAccount()
    assert account.get_balance() == 0


def test_account_with_initial_balance():
    account = BankAccount(250)
    assert account.get_balance() == 250


def test_negative_initial_balance_raises_error():
    with pytest.raises(ValueError, match="Initial balance cannot be negative"):
        BankAccount(-1)


def test_deposit_adds_money():
    account = BankAccount()
    account.deposit(100)
    assert account.get_balance() == 100


@pytest.mark.parametrize("amount", [0, -10])
def test_deposit_non_positive_amount_raises_error(amount):
    account = BankAccount()
    with pytest.raises(ValueError, match="Amount must be positive"):
        account.deposit(amount)


def test_withdraw_reduces_balance():
    account = BankAccount(300)
    account.withdraw(120)
    assert account.get_balance() == 180


@pytest.mark.parametrize("amount", [0, -5])
def test_withdraw_non_positive_amount_raises_error(amount):
    account = BankAccount(100)
    with pytest.raises(ValueError, match="Amount must be positive"):
        account.withdraw(amount)


def test_withdraw_more_than_balance_raises_error():
    account = BankAccount(50)
    with pytest.raises(ValueError, match="Insufficient funds"):
        account.withdraw(100)
    assert account.get_balance() == 50
