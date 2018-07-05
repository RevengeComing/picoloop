from posix.types cimport time_t


cdef extern from "picoev_w32.h":
    ctypedef unsigned short picoev_loop_id_t

    ctypedef picoev_loop_st picoev_loop

    ctypedef void picoev_handler(
        picoev_loop* loop,int fd,
        int revents,
        void* cb_arg
    );

    ctypedef struct timeout_st:
      short* vec
      short* vec_of_vec
      size_t base_idx
      time_t base_time
      int resolution
      void* _free_addr

    ctypedef struct picoev_loop_st:
        picoev_loop_id_t loop_id
        timeout_st timeout
        time_t now

    ctypedef struct picoev_fd_st:
        picoev_handler* callback;
        void* cb_arg;
        picoev_loop_id_t loop_id;
        char events;
        unsigned char timeout_idx; 
        int _backend;
    ctypedef picoev_fd_st picoev_fd
  
    ctypedef struct picoev_globals_st:
        picoev_fd* fds
        void* _fds_free_addr
        int max_fd
        int num_loops
        size_t timeout_vec_size
        size_t timeout_vec_of_vec_size
    ctypedef picoev_globals_st picoev_globals

    picoev_loop* picoev_create_loop(int max_timeout)

    int picoev_destroy_loop(picoev_loop* loop)
    int picoev_update_events_internal(picoev_loop* loop, int fd, int events)
    int picoev_poll_once_internal(picoev_loop* loop, int max_wait)

    int picoev_loop_once(picoev_loop* loop, int max_wait)