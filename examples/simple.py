import picoloop
import asyncio

asyncio.set_event_loop_policy(picoloop.EventLoopPolicy())
loop = asyncio.get_event_loop()
