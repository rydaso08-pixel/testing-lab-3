#!/bin/bash
# Допоміжний скрипт: послідовно показує етапи RED -> GREEN -> REFACTOR та BDD для скриншотів.
# Запускати з кореня проєкту при активованому віртуальному середовищі: bash demo_stages.sh
set -u
FILES="src/bank_account.py tests/test_bank_account.py tests/test_user_registration.py features/user_registration.feature"
tar cf .final_backup.tar $FILES
pause() { echo; read -p ">>> Зроби скриншот ($1) і натисни Enter..." _; clear; }

echo "===== TDD: BankAccount ====="
cat > src/bank_account.py << 'PY'
class BankAccount:
    def __init__(self, initial_balance=0):
        self._balance = initial_balance

    def deposit(self, amount):
        pass

    def withdraw(self, amount):
        pass

    def get_balance(self):
        return self._balance
PY
cat > tests/test_bank_account.py << 'PY'
from src.bank_account import BankAccount


def test_deposit_adds_money():
    account = BankAccount()
    account.deposit(100)
    assert account.get_balance() == 100
PY
pytest tests/test_bank_account.py -v
pause "скриншот №1 - RED"

python3 - << 'PY'
p = "src/bank_account.py"
s = open(p).read().replace("    def deposit(self, amount):\n        pass", "    def deposit(self, amount):\n        self._balance += amount")
open(p, "w").write(s)
PY
pytest tests/test_bank_account.py -v
pause "скриншот №2 - GREEN"

# Повний набір тестів і фінальна реалізація (REFACTOR)
tar xf .final_backup.tar src/bank_account.py tests/test_bank_account.py
pytest tests/test_bank_account.py -v
pause "скриншот №3 - REFACTOR"

echo "===== BDD: UserRegistrationValidator ====="
cat > features/user_registration.feature << 'FE'
Feature: Реєстрація користувача

  Scenario: Коректні дані користувача
    Given користувач вводить email "student@example.com"
    And користувач вводить пароль "password1"
    And користувачу 20 років
    When система перевіряє реєстраційні дані
    Then реєстраційні дані повинні бути прийняті
FE
cat features/user_registration.feature
pause "скриншот №4 - перший .feature файл"

cat > tests/test_user_registration.py << 'PY'
from pytest_bdd import given, parsers, scenarios, then, when

from src.user_registration_validator import UserRegistrationValidator

scenarios("../features/user_registration.feature")


@given(parsers.parse('користувач вводить email "{email}"'), target_fixture="email")
def user_email(email):
    return email


@given(parsers.parse('користувач вводить пароль "{password}"'), target_fixture="password")
def user_password(password):
    return password


@given(parsers.parse("користувачу {age:d} років"), target_fixture="age")
def user_age(age):
    return age


@when("система перевіряє реєстраційні дані", target_fixture="validation_result")
def validate_user(email, password, age):
    validator = UserRegistrationValidator()
    return validator.validate(email, password, age)


@then("реєстраційні дані повинні бути прийняті")
def registration_is_accepted(validation_result):
    assert validation_result is True
PY
cat tests/test_user_registration.py
pause "скриншот №5 - кроки Given/When/Then"
pytest tests/test_user_registration.py -v
echo; read -p ">>> Позитивний сценарій пройшов. Enter - додати негативний сценарій..." _; clear

cat >> features/user_registration.feature << 'FE'

  Scenario: Email без частини після символу @
    Given користувач вводить email "student@"
    And користувач вводить пароль "password1"
    And користувачу 20 років
    When система перевіряє реєстраційні дані
    Then система повинна відхилити дані з помилкою "Email is invalid"
FE
pytest tests/test_user_registration.py -v
pause "скриншот №6 - BDD не проходить, ValueError"

tar xf .final_backup.tar features/user_registration.feature tests/test_user_registration.py
rm .final_backup.tar
echo "===== Фінальний запуск ====="
pytest -v
echo; echo ">>> Зроби скриншот №7 (усі тести PASSED)."
