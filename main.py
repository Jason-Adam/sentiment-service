from fastapi import FastAPI
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

from src.models.payload import Payload
from src.models.sentiment import Sentiment


app = FastAPI()
analyzer = SentimentIntensityAnalyzer()


@app.post("/sentiment/social")
async def get_social_sentiment(payload: Payload):
    return [
        Sentiment(
            post_url=content.post_url,
            sentiment=analyzer.polarity_scores(content.content)["compound"],
        )
        for content in payload.data
    ]
