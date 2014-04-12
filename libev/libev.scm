(import foreign)
(foreign-declare "#include <ev.h>")
(foreign-declare "#include <stdio.h>")

(define-foreign-variable EVFLAG-AUTO "EVFLAG_AUTO")
(define-foreign-variable EVFLAG-NO_ENV "EVFLAG_NO_ENV")
(define-foreign-variable EVFLAG-FORKCHECK "EVFLAG_FORKCHECK")
(define-foreign-variable EVFLAG-NOINOTIFY "EVFLAG_NOINOTIFY")
(define-foreign-variable EVFLAG-SIGNALFD "EVFLAG_SIGNALFD")
(define-foreign-variable EVFLAG-NOSIGMASK "EVFLAG_NOSIGMASK")

(define-foreign-variable EVBACKEND-SELECT "EVBACKEND_SELECT")
(define-foreign-variable EVBACKEND-POLL "EVBACKEND_POLL")
(define-foreign-variable EVBACKEND-EPOLL "EVBACKEND_EPOLL")
(define-foreign-variable EVBACKEND-KQUEUE "EVBACKEND_KQUEUE")
(define-foreign-variable EVBACKEND-DEVPOLL "EVBACKEND_DEVPOLL")
(define-foreign-variable EVBACKEND-PORT "EVBACKEND_PORT")
(define-foreign-variable EVBACKEND-ALL "EVBACKEND_ALL")
(define-foreign-variable EVBACKEND-MASK "EVBACKEND_MASK")

(define-foreign-variable EVBREAK-CANCEL "EVBREAK_CANCEL")
(define-foreign-variable EVBREAK-ONE "EVBREAK_ONE")
(define-foreign-variable EVBREAK-ALL "EVBREAK_ALL")

(define-foreign-type ev-tstamp double) ; ev_tstamp
(define-foreign-type ev-loop (c-pointer "struct ev_loop"))

(define-foreign-type ev-io "struct ev_io")
(define-foreign-type ev-timer "ev_timer")
(define-foreign-type *ev-timer (c-pointer ev-timer))


(define ev-version-major (foreign-lambda int "ev_version_major"))
(define ev-version-minor (foreign-lambda int "ev_version_minor"))
(define ev-supported-backends (foreign-lambda unsigned-int "ev_supported_backends"))
(define ev-recommended-backends (foreign-lambda unsigned-int "ev_recommended_backends"))
(define ev-embeddable-backends (foreign-lambda unsigned-int "ev_embeddable_backends"))
(define ev-time (foreign-lambda ev-tstamp "ev_time"))
(define ev-sleep (foreign-lambda void "ev_sleep" ev-tstamp))
(define ev-feed-signal (foreign-lambda void "ev_feed_signal" int))
(define ev-default-loop (foreign-lambda ev-loop "ev_default_loop" unsigned-int))
(define ev-loop-new (foreign-lambda ev-loop "ev_loop_new" unsigned-int))
(define ev-loop-destroy (foreign-lambda void "ev_loop_destroy" ev-loop))
(define ev-loop-fork (foreign-lambda void "ev_loop_fork" ev-loop))
(define ev-is-default-loop (foreign-lambda bool "ev_is_default_loop" ev-loop))
(define ev-iteration (foreign-lambda unsigned-int "ev_iteration" ev-loop))
(define ev-depth (foreign-lambda unsigned-int "ev_depth" ev-loop))
(define ev-backend (foreign-lambda unsigned-int "ev_backend" ev-loop))
(define ev-now (foreign-lambda ev-tstamp "ev_now" ev-loop))
(define ev-now-update (foreign-lambda void "ev_now_update" ev-loop))
(define ev-suspend (foreign-lambda void "ev_suspend" ev-loop))
(define ev-resume (foreign-lambda void "ev_resume" ev-loop))
(define ev-run (foreign-safe-lambda void "ev_run" ev-loop int))
(define ev-break (foreign-lambda void "ev_break" ev-loop int))
(define ev-ref (foreign-lambda void "ev_ref" ev-loop))
(define ev-unref (foreign-lambda void "ev_unref" ev-loop))
(define ev-unloop (foreign-lambda void "ev_unloop" ev-loop int))

(define ev-timer-init (foreign-lambda void "ev_timer_init" *ev-timer (function void (ev-loop *ev-timer int)) ev-tstamp ev-tstamp))
(define ev-timer-start (foreign-lambda void "ev_timer_start" ev-loop *ev-timer))

; TODO: use (make-blob)
(define malloc-ev-timer (foreign-lambda* *ev-timer ()
  "ev_timer *t;
   t = malloc(sizeof(ev_timer));
   C_return(t);"))

(define (new-ev-timer loop time callback)
  (let ((t (malloc-ev-timer)))
      (ev-timer-init t callback time 0)
      (ev-timer-start loop t)
      t))
  
; main
(define l (ev-default-loop 0))

(display "Default: ")(display (ev-is-default-loop l))(newline)
(display "Iteration: ")(display (ev-iteration l))(newline)
(display "Depth: ")(display (ev-depth l))(newline)
(display "Backend: ")(display (ev-backend l))(newline)


(define-external (testcb (ev-loop loop) (*ev-timer timer) (int reent)) void
    ; success?
    (ev-break loop EVBREAK_ALL)
    )

#>

static void quitloop(EV_P_ ev_timer *w, int revents){
  puts("Fuck yeah!");
  ev_break(EV_A_ EVBREAK_ALL);
}

ev_timer *newloop(
    int,
    EV_CB_DECLARE(ev_timer)
){
  ev_timer *t = malloc(sizeof(ev_timer));
  ev_timer_init(t, quitloop, 1, 0);
  return t;
}

<#

(define newloop (foreign-lambda *ev-timer "newloop" int (function void (ev-loop *ev-timer int))))
(define quitloop (foreign-lambda void "quitloop" ev-loop *ev-timer int))

(define t (newloop 1 quitloop))
;(ev-timer-init t quitloop 1 0)
(ev-timer-start l t)

;(define t (malloc-ev-timer))
;(ev-timer-init t testcb 1.0 0.0)
;(ev-timer-start l t)

(ev-run l 0)
(ev-loop-destroy l)

