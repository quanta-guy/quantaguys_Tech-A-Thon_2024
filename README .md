
# Real-Time Stock Market Data Prediction API and Flutter App

## Overview
This project combines a real-time stock market data prediction API built using FastAPI and an accompanying Flutter frontend application. The API processes stock ticker data to predict future stock prices using an LSTM (Long Short-Term Memory) neural network, and the Flutter app provides an interface for users to interact with the API.

## Prerequisites

### Backend (FastAPI)
- Python 3.7 or higher
- Conda or virtualenv for environment management
- FastAPI
- Uvicorn
- TensorFlow
- Scikit-learn
- yfinance

### Frontend (Flutter)
- Flutter SDK
- A text editor or IDE (e.g., Visual Studio Code, Android Studio)

## Setup Instructions

### Backend Setup

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd <repository_name>
   ```

2. **Create a virtual environment:**
   - Using Conda:
     ```bash
     conda create --name stock-prediction python=3.8
     conda activate stock-prediction
     ```
   - Or using virtualenv:
     ```bash
     python3 -m venv env
     source env/bin/activate  # On Windows use `env\Scriptsctivate`
     ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the API server:**
   ```bash
   uvicorn main:app --reload
   ```

   The API will be available at `http://127.0.0.1:8000/`.

### Frontend Setup

1. **Install Flutter SDK:**
   Follow the instructions on the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) to set up Flutter on your system.

2. **Create a new Flutter project:**
   ```bash
   flutter create stock_prediction_app
   cd stock_prediction_app
   ```

3. **Replace the `main.dart` and `pubspec.yaml`:**
   Replace the `lib/main.dart` file in your Flutter project with the `main.dart` provided in this repository. Similarly, replace the `pubspec.yaml` file with the one provided.

4. **Install Flutter dependencies:**
   In the root of your Flutter project directory, run:
   ```bash
   flutter pub get
   ```

5. **Run the Flutter app:**
   Connect a device or start an emulator, then run:
   ```bash
   flutter run
   ```

   The Flutter app will connect to the FastAPI backend to display real-time stock predictions.

## Project Structure

### Backend
- **`main.py`**: The FastAPI application that handles incoming requests and routes them to the stock prediction function.
- **`predictor.py`**: Contains the logic for data preprocessing, model training, and stock price prediction.
- **`requirements.txt`**: Lists the dependencies required for the backend.

### Frontend
- **`lib/main.dart`**: The main Dart file for the Flutter app, responsible for the UI and API integration.
- **`pubspec.yaml`**: Specifies the dependencies required for the Flutter app.

## Detailed Functionality

### API Endpoint
- **POST `/stock/{ticker}`**: Predicts future stock prices for a given ticker symbol over a specified period. The prediction includes:
  - Current stock price
  - Predicted prices for the forecasting period
  - Historical prices
  - Mean Squared Error (MSE) and Root Mean Squared Error (RMSE)
  - A prediction label (`CALL` or `SELL`)

### Prediction Methodology
- The `predictor.py` script fetches historical stock data using the `yfinance` library.
- Data is preprocessed using scaling techniques to normalize the stock prices.
- The LSTM model is trained on the historical data to learn patterns.
- The model predicts future prices based on the last known data.
- Predictions are scaled back to the original price range, and the results are evaluated for accuracy.

### Model Architecture
- The LSTM network is designed with two LSTM layers followed by dropout layers to prevent overfitting.
- The final Dense layer outputs the predicted stock price.

## Example Usage

Once both the API server and the Flutter app are running, you can interact with the app to select a stock ticker and view the predicted prices.

## Future Scope

- **Attention Mechanism**: Implementing an attention mechanism to improve the accuracy of predictions by focusing on more critical time steps.
- **Extended UI**: Enhancing the Flutter frontend to provide more interactive features and better visualizations.
- **Additional Models**: Experimenting with other machine learning models to compare performance and accuracy.

## Conclusion

This project demonstrates the application of LSTM neural networks in stock market prediction, providing users with valuable insights into potential future stock prices through an intuitive Flutter frontend. The API is built to be scalable and easy to use, with future improvements planned to enhance prediction accuracy and user experience.
