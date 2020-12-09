from typing import List

from pydantic import BaseModel

from .content import Content


class Payload(BaseModel):
    data: List[Content]
