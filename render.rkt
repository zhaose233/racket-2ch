#lang racket

(define (render-post post)
  `(div ((class "card"))
        (div ((class "card-body"))
             (h5 ((class "card-title")) (a ((href ,(format "/?n=~A" (vector-ref post 0))))  ,(vector-ref post 1)))
             (p ((class "card-text")) ,(vector-ref post 2))
             (p ((class "card-text")) (small ,(vector-ref post 3))))))

(provide render-post)
