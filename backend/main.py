from fastapi import FastAPI, Query
from stock_predictor.predictor import get_stock_prediction

app = FastAPI()

@app.post("/stock/{ticker}")
async def stock_prediction(ticker: str, forecasting_period: int = Query(30)):
    # Call the synchronous function directly
    result = get_stock_prediction(ticker, forecasting_period)
    return result

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
