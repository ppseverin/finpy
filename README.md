# NNFX Inspired Forex Trading Indicators Library
Welcome to a Python-based library of Forex trading indicators, inspired by the No Nonsense Forex (NNFX) methodology. This project aims to empower Forex traders with a comprehensive toolkit for market analysis, emphasizing technical analysis, risk management, and a disciplined approach to trading.

Why NNFX? The NNFX methodology challenges conventional Forex trading wisdom by advocating for a systematic, indicator-based approach that eschews the noise and inconsistency of traditional trading strategies. Recognizing the value in this method, we've developed this library to bring the principles of NNFX to Python, offering traders a powerful and flexible toolset to craft their strategies.

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
import pandas as pd

from finpy.indicators import DSS_AverageOfMomentum

dataset = pd.read_csv('path/to/your/data.csv')

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

## Acknowledgments
This project stands on the shoulders of the vibrant open-source community and the collective wisdom of Forex traders worldwide. While the indicators translated and implemented here are derived from publicly available sources, the effort to adapt them to Python and the No Nonsense Forex (NNFX) methodology is an original endeavor aimed at providing the trading community with more tools and resources.

Special thanks to:

- The creators and maintainers of the various technical indicators used as the foundation for this library. Their work has made it possible to access a wide range of trading tools that are instrumental in developing effective Forex trading strategies.
- The No Nonsense Forex (NNFX) community, especially VP, for the comprehensive approach to Forex trading that has inspired countless traders, including myself, to look beyond conventional strategies and seek a more disciplined and systematic way to engage with the markets.
- The open-source projects and developers behind Python, Pandas, NumPy, and TA-Lib, for providing the essential building blocks that enable the development of complex trading analysis tools with relative ease.

This project is a tribute to the spirit of collaboration and innovation that defines the open-source and trading communities. As we continue to build and improve upon these foundations, I look forward to seeing how these tools evolve through community feedback and contributions.
