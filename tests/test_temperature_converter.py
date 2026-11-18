import pytest

from src.temperature_converter import TemperatureConverter


def test_zero_celsius_is_32_fahrenheit():
    result = TemperatureConverter.celsius_to_fahrenheit(0)
    assert result == pytest.approx(32.0)


def test_100_celsius_is_212_fahrenheit():
    assert TemperatureConverter.celsius_to_fahrenheit(100) == pytest.approx(212.0)


def test_32_fahrenheit_is_zero_celsius():
    assert TemperatureConverter.fahrenheit_to_celsius(32) == pytest.approx(0.0)


def test_212_fahrenheit_is_100_celsius():
    assert TemperatureConverter.fahrenheit_to_celsius(212) == pytest.approx(100.0)


def test_celsius_string_raises_type_error():
    with pytest.raises(TypeError, match="Temperature must be a number"):
        TemperatureConverter.celsius_to_fahrenheit("hot")


def test_fahrenheit_string_raises_type_error():
    with pytest.raises(TypeError, match="Temperature must be a number"):
        TemperatureConverter.fahrenheit_to_celsius("cold")


def test_celsius_below_absolute_zero_raises_error():
    with pytest.raises(ValueError, match="below absolute zero"):
        TemperatureConverter.celsius_to_fahrenheit(-300)


def test_fahrenheit_below_absolute_zero_raises_error():
    with pytest.raises(ValueError, match="below absolute zero"):
        TemperatureConverter.fahrenheit_to_celsius(-500)


def test_absolute_zero_celsius_is_accepted():
    assert TemperatureConverter.celsius_to_fahrenheit(-273.15) == pytest.approx(-459.67)
