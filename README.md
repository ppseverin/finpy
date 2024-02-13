## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See **Installation** for notes on how to deploy the project on a live system.

### Prerequisites

This project is developed with Python 3.9. Ensure you have this version or higher installed on your system to use this project. Additionally, this project depends on several Python libraries. Make sure you have them installed. Here are the requirements:

- Python 3.9
- TA-Lib 0.4.25 or higher
- NumPy 1.23.5 or higher
- Pandas 1.5.3 or higher

Python can be installed from [python.org](https://www.python.org/downloads/), and the dependencies can be installed using pip, the Python package manager.

### Installation

First, make sure you have Python 3.9 installed. You can check your Python version by running:

```
python --version
```
If you don't have Python 3.9 or higher, download it from python.org and follow the installation instructions.

Then, to install the required dependencies for this project, you can use the following command in your terminal:
```
pip install numpy>=1.23.5 pandas>=1.5.3 TA-Lib>=0.4.25
```
Note: Installing TA-Lib might require additional steps depending on your operating system. Please refer to the official TA-Lib documentation for specific instructions: [TA-Lib](https://ta-lib.org/).

## Usage

Below is an example of EURUSD M15 OHLC data:

| date     | time     | open   | high   | low    | close  | tick_volume |
|----------|--------|--------|--------|--------|--------|-------------|
| 2023.12.28 | 22:45:00 | 1.10621 | 1.10625 | 1.10612 | 1.10617 | 170         |
| 2023.12.28 | 23:00:00 | 1.10618 | 1.10648 | 1.10608 | 1.10636 | 444         |
| 2023.12.28 | 23:15:00 | 1.10637 | 1.10666 | 1.10637 | 1.10664 | 478         |
| 2023.12.28 | 23:30:00 | 1.10664 | 1.10665 | 1.10644 | 1.10663 | 659         |
| 2023.12.28 | 23:45:00 | 1.10665 | 1.10678 | 1.10653 | 1.10677 | 473         |


This data can be used to apply the NNFX methodology indicators implemented in this library.
You can call and process market data with an indicator like this:
```python
from finpy.indicators import DSS_AverageOfMomentum

dss = DSS_AverageOfMomentum()
dss, signal = dss.dss_averages_of_momentum(dataset)
```
Thats it!

Or you can call all indicators and see which indicators are available as entry, exit or baseline indicators like this:
```python
from finpy.indicator_types.indicator_types import IndicatorTypes

print("Entry Indicators:", [indicator.__name__ for indicator in IndicatorTypes.entry ])
print("Exit Indicators:", [indicator.__name__ for indicator in IndicatorTypes.exit])
```

## Contributing
Contributions are welcome, especially from traders who are using the NNFX methodology and have indicators or improvements to share.