from pydantic import BaseModel


class Content(BaseModel):
    post_url: str
    content: str
