from pydantic import BaseModel


class Sentiment(BaseModel):
    post_url: str
    sentiment: float
