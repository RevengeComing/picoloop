import asyncio
from asyncio.events import BaseDefaultEventLoopPolicy

from .loop import PicoLoop  # NOQA


__version__ = '0.0.1'
__all__ = ('new_event_loop', 'EventLoopPolicy')


class Loop(PicoLoop, asyncio.AbstractEventLoop):
    pass
    

def new_event_loop():
    """Return a new event loop."""
    return Loop()


class EventLoopPolicy(BaseDefaultEventLoopPolicy):
    """Event loop policy.

    The preferred way to make your application use picoloop:

    >>> import asyncio
    >>> import picoloop
    >>> asyncio.set_event_loop_policy(picoloop.EventLoopPolicy())
    >>> asyncio.get_event_loop()
    <picoloop.Loop running=False closed=False debug=False>
    """

    def _loop_factory(self):
        return new_event_loop()
