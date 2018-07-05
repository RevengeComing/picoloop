import asyncio
import subprocess
import socket
import cython

from . cimport picoev


cdef class PicoLoop:
    cdef picoev.picoev_loop* picoev_loop

    def __cinit__(self):
        self.picoev_loop = picoev.picoev_create_loop(60)

        self._stopping = 0
        self._closed = 0


    cdef inline _check_closed(self):
        if self._closed == 1:
            raise RuntimeError("Event loop is closed.")

    def run_forever(self):
        """Run the event loop until stop() is called."""
        self._check_closed()
        while not self._stopping:
            pass

    def run_until_complete(self, future):
        """Run the event loop until a Future is done.
        Return the Future's result, or raise its exception.
        """
        raise NotImplementedError

    def stop(self):
        """Stop the event loop as soon as reasonable.
        Exactly how soon that is may depend on the implementation, but
        no more I/O callbacks should be scheduled.
        """
        raise NotImplementedError

    def is_running(self):
        """Return whether the event loop is currently running."""
        return bool(self._running)

    def is_closed(self):
        """Returns True if the event loop was closed."""
        raise NotImplementedError

    def close(self):
        """Close the loop.
        The loop should not be running.
        This is idempotent and irreversible.
        No other methods should be called after this one.
        """
        raise NotImplementedError

    async def shutdown_asyncgens(self):
        """Shutdown all active asynchronous generators."""
        raise NotImplementedError

    # Methods scheduling callbacks.  All these return Handles.

    def _timer_handle_cancelled(self, handle):
        """Notification that a TimerHandle has been cancelled."""
        raise NotImplementedError

    def call_later(self, delay, callback, *args):
        raise NotImplementedError

    def call_at(self, when, callback, *args):
        raise NotImplementedError

    def time(self):
        raise NotImplementedError

    def create_future(self):
        raise NotImplementedError

    # Method scheduling a coroutine object: create a task.

    def create_task(self, coro):
        raise NotImplementedError

    # Methods for interacting with threads.

    def call_soon_threadsafe(self, callback, *args):
        raise NotImplementedError

    async def run_in_executor(self, executor, func, *args):
        raise NotImplementedError

    def set_default_executor(self, executor):
        raise NotImplementedError

    # Network I/O methods returning Futures.

    async def getaddrinfo(self, host, port, *,
                          family=0, type=0, proto=0, flags=0):
        raise NotImplementedError

    async def getnameinfo(self, sockaddr, flags=0):
        raise NotImplementedError

    async def create_connection(
            self, protocol_factory, host=None, port=None,
            *, ssl=None, family=0, proto=0,
            flags=0, sock=None, local_addr=None,
            server_hostname=None,
            ssl_handshake_timeout=None):
        raise NotImplementedError

    async def create_server(
            self, protocol_factory, host=None, port=None,
            *, family=socket.AF_UNSPEC,
            flags=socket.AI_PASSIVE, sock=None, backlog=100,
            ssl=None, reuse_address=None, reuse_port=None,
            ssl_handshake_timeout=None,
            start_serving=True):
        """A coroutine which creates a TCP server bound to host and port.
        The return value is a Server object which can be used to stop
        the service.
        If host is an empty string or None all interfaces are assumed
        and a list of multiple sockets will be returned (most likely
        one for IPv4 and another one for IPv6). The host parameter can also be
        a sequence (e.g. list) of hosts to bind to.
        family can be set to either AF_INET or AF_INET6 to force the
        socket to use IPv4 or IPv6. If not set it will be determined
        from host (defaults to AF_UNSPEC).
        flags is a bitmask for getaddrinfo().
        sock can optionally be specified in order to use a preexisting
        socket object.
        backlog is the maximum number of queued connections passed to
        listen() (defaults to 100).
        ssl can be set to an SSLContext to enable SSL over the
        accepted connections.
        reuse_address tells the kernel to reuse a local socket in
        TIME_WAIT state, without waiting for its natural timeout to
        expire. If not specified will automatically be set to True on
        UNIX.
        reuse_port tells the kernel to allow this endpoint to be bound to
        the same port as other existing endpoints are bound to, so long as
        they all set this flag when being created. This option is not
        supported on Windows.
        ssl_handshake_timeout is the time in seconds that an SSL server
        will wait for completion of the SSL handshake before aborting the
        connection. Default is 60s.
        start_serving set to True (default) causes the created server
        to start accepting connections immediately.  When set to False,
        the user should await Server.start_serving() or Server.serve_forever()
        to make the server to start accepting connections.
        """
        raise NotImplementedError

    async def sendfile(self, transport, file, offset=0, count=None,
                       *, fallback=True):
        """Send a file through a transport.
        Return an amount of sent bytes.
        """
        raise NotImplementedError

    async def start_tls(self, transport, protocol, sslcontext, *,
                        server_side=False,
                        server_hostname=None,
                        ssl_handshake_timeout=None):
        """Upgrade a transport to TLS.
        Return a new transport that *protocol* should start using
        immediately.
        """
        raise NotImplementedError

    async def create_unix_connection(
            self, protocol_factory, path=None, *,
            ssl=None, sock=None,
            server_hostname=None,
            ssl_handshake_timeout=None):
        raise NotImplementedError

    async def create_unix_server(
            self, protocol_factory, path=None, *,
            sock=None, backlog=100, ssl=None,
            ssl_handshake_timeout=None,
            start_serving=True):
        """A coroutine which creates a UNIX Domain Socket server.
        The return value is a Server object, which can be used to stop
        the service.
        path is a str, representing a file systsem path to bind the
        server socket to.
        sock can optionally be specified in order to use a preexisting
        socket object.
        backlog is the maximum number of queued connections passed to
        listen() (defaults to 100).
        ssl can be set to an SSLContext to enable SSL over the
        accepted connections.
        ssl_handshake_timeout is the time in seconds that an SSL server
        will wait for the SSL handshake to complete (defaults to 60s).
        start_serving set to True (default) causes the created server
        to start accepting connections immediately.  When set to False,
        the user should await Server.start_serving() or Server.serve_forever()
        to make the server to start accepting connections.
        """
        raise NotImplementedError

    async def create_datagram_endpoint(self, protocol_factory,
                                       local_addr=None, remote_addr=None, *,
                                       family=0, proto=0, flags=0,
                                       reuse_address=None, reuse_port=None,
                                       allow_broadcast=None, sock=None):
        """A coroutine which creates a datagram endpoint.
        This method will try to establish the endpoint in the background.
        When successful, the coroutine returns a (transport, protocol) pair.
        protocol_factory must be a callable returning a protocol instance.
        socket family AF_INET, socket.AF_INET6 or socket.AF_UNIX depending on
        host (or family if specified), socket type SOCK_DGRAM.
        reuse_address tells the kernel to reuse a local socket in
        TIME_WAIT state, without waiting for its natural timeout to
        expire. If not specified it will automatically be set to True on
        UNIX.
        reuse_port tells the kernel to allow this endpoint to be bound to
        the same port as other existing endpoints are bound to, so long as
        they all set this flag when being created. This option is not
        supported on Windows and some UNIX's. If the
        :py:data:`~socket.SO_REUSEPORT` constant is not defined then this
        capability is unsupported.
        allow_broadcast tells the kernel to allow this endpoint to send
        messages to the broadcast address.
        sock can optionally be specified in order to use a preexisting
        socket object.
        """
        raise NotImplementedError

    # Pipes and subprocesses.

    async def connect_read_pipe(self, protocol_factory, pipe):
        """Register read pipe in event loop. Set the pipe to non-blocking mode.
        protocol_factory should instantiate object with Protocol interface.
        pipe is a file-like object.
        Return pair (transport, protocol), where transport supports the
        ReadTransport interface."""
        # The reason to accept file-like object instead of just file descriptor
        # is: we need to own pipe and close it at transport finishing
        # Can got complicated errors if pass f.fileno(),
        # close fd in pipe transport then close f and vise versa.
        raise NotImplementedError

    async def connect_write_pipe(self, protocol_factory, pipe):
        """Register write pipe in event loop.
        protocol_factory should instantiate object with BaseProtocol interface.
        Pipe is file-like object already switched to nonblocking.
        Return pair (transport, protocol), where transport support
        WriteTransport interface."""
        # The reason to accept file-like object instead of just file descriptor
        # is: we need to own pipe and close it at transport finishing
        # Can got complicated errors if pass f.fileno(),
        # close fd in pipe transport then close f and vise versa.
        raise NotImplementedError

    async def subprocess_shell(self, protocol_factory, cmd, *,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               **kwargs):
        raise NotImplementedError

    async def subprocess_exec(self, protocol_factory, *args,
                              stdin=subprocess.PIPE,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              **kwargs):
        raise NotImplementedError

    # Ready-based callback registration methods.
    # The add_*() methods return None.
    # The remove_*() methods return True if something was removed,
    # False if there was nothing to delete.

    def add_reader(self, fd, callback, *args):
        raise NotImplementedError

    def remove_reader(self, fd):
        raise NotImplementedError

    def add_writer(self, fd, callback, *args):
        raise NotImplementedError

    def remove_writer(self, fd):
        raise NotImplementedError

    # Completion based I/O methods returning Futures.

    async def sock_recv(self, sock, nbytes):
        raise NotImplementedError

    async def sock_recv_into(self, sock, buf):
        raise NotImplementedError

    async def sock_sendall(self, sock, data):
        raise NotImplementedError

    async def sock_connect(self, sock, address):
        raise NotImplementedError

    async def sock_accept(self, sock):
        raise NotImplementedError

    async def sock_sendfile(self, sock, file, offset=0, count=None,
                            *, fallback=None):
        raise NotImplementedError

    # Signal handling.

    def add_signal_handler(self, sig, callback, *args):
        raise NotImplementedError

    def remove_signal_handler(self, sig):
        raise NotImplementedError

    # Task factory.

    def set_task_factory(self, factory):
        raise NotImplementedError

    def get_task_factory(self):
        raise NotImplementedError

    # Error handlers.

    def get_exception_handler(self):
        raise NotImplementedError

    def set_exception_handler(self, handler):
        raise NotImplementedError

    def default_exception_handler(self, context):
        raise NotImplementedError

    def call_exception_handler(self, context):
        raise NotImplementedError

    # Debug flag management.

    def get_debug(self):
        raise NotImplementedError

    def set_debug(self, enabled):
        raise NotImplementedError