import numpy as np
import pandas as pd
import yfinance as yf
from sklearn.preprocessing import MinMaxScaler, RobustScaler
from sklearn.metrics import mean_squared_error
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout, Input
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau

def get_stock_prediction(ticker: str, forecasting_period: int):
    data = yf.download(ticker, start='2010-01-01')

    if data.empty:
        raise ValueError(f"No data found for ticker {ticker}")

    data = data[['Close']]
    data = data.fillna(method='ffill')

    if data.isnull().values.any():
        raise ValueError("Data contains NaN values even after forward fill")

    training_data_len = int(np.ceil(len(data) * 0.8))
    train_data = data[:training_data_len]
    test_data = data[training_data_len:]

    scaler = RobustScaler()
    scaled_train_data = scaler.fit_transform(train_data)
    scaled_test_data = scaler.transform(test_data)

    def create_sequences(data, seq_length):
        xs, ys = [], []
        for i in range(len(data) - seq_length):
            x = data[i:i + seq_length]
            y = data[i + seq_length]
            xs.append(x)
            ys.append(y)
        return np.array(xs), np.array(ys)

    SEQ_LENGTH = 60
    X_train, y_train = create_sequences(scaled_train_data, SEQ_LENGTH)
    X_test, y_test = create_sequences(scaled_test_data, SEQ_LENGTH)

    model = Sequential([
        Input(shape=(SEQ_LENGTH, 1)),
        LSTM(50, return_sequences=True),
        Dropout(0.2),
        LSTM(50),
        Dropout(0.2),
        Dense(1)
    ])

    model.compile(optimizer='adam', loss='mean_squared_error')

    early_stopping = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)
    reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=0.0001)

    model.fit(X_train, y_train, epochs=50, batch_size=32, validation_split=0.1, verbose=1,
              callbacks=[early_stopping, reduce_lr])

    predictions = []
    last_sequence = X_test[-1]

    for _ in range(forecasting_period):
        prediction = model.predict(last_sequence.reshape(1, SEQ_LENGTH, 1))
        predictions.append(prediction[0][0])
        last_sequence = np.append(last_sequence[1:], prediction, axis=0)

    predictions = np.array(predictions).reshape(-1, 1)
    predictions = scaler.inverse_transform(predictions)
    current_price = scaler.inverse_transform(y_test[-1].reshape(-1, 1))[0][0]

    mse = mean_squared_error(y_test, model.predict(X_test))
    rmse = np.sqrt(mse)

    predictions = predictions.flatten().tolist()
    mse = float(mse)
    rmse = float(rmse)

    return {
        'current_price': current_price,
        'predicted_prices': predictions,
        'mse': mse,
        'rmse': rmse,
        'historical_prices': data['Close'].values[-SEQ_LENGTH:].tolist(),
        'prediction': 'CALL' if predictions[-1] > current_price else 'SELL'
    }
