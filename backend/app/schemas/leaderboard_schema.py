
from pydantic import BaseModel


class LeaderboardEntry(BaseModel):
    rank: int
    username: str
    score_percentage: float
