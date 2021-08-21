#lang racket

(require db)
(require racket/date)

(define sql (sqlite3-connect #:database "posts.db" #:mode 'create))

;;判断是否是新建的数据库
(let ((result (query sql "SELECT count(*) FROM sqlite_master WHERE type=\"table\" AND name = \"POSTS\"")))
  (let ((exist (vector-ref (car (rows-result-rows result)) 0)))
    (when (= exist 0)
      (query-exec sql "CREATE TABLE POSTS(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   WORDS          TEXT    NOT NULL,
   TIME           TEXT    NOT NULL
);")
      (query-exec sql "INSERT INTO POSTS VALUES (0, '朝色', '到底了哟', 'THE END')"))))

;;获得最后一个帖子的ID
(define (get-latest-id)
  (define latest (query sql "SELECT ID FROM POSTS ORDER BY 1 desc"))
  (vector-ref (car (rows-result-rows latest)) 0))

;;获得一页，10个帖子
(define (get-page-posts page)
  (define latest-id (get-latest-id))
  ;;(displayln latest-id)
  (if (< latest-id (* 10 page)) (reverse (for/list ((i (range 0 (+ (- latest-id (* 10 (- page 1))) 1))))
                                           (car (rows-result-rows (query sql "SELECT * FROM POSTS WHERE ID=$1" i)))))
      (reverse (for/list ((i (range (+ (- latest-id (* 10 page)) 1) (+ (- latest-id (* 10 (- page 1))) 1))))
                 (car (rows-result-rows (query sql "SELECT * FROM POSTS WHERE ID=$1" i)))))))

;;单个帖子
(define (get-post n)
  (list (car (rows-result-rows (query sql "SELECT * FROM POSTS WHERE ID=$1" n)))))

;;新增帖子
(define (add-post name words)
  (define id (+ 1 (get-latest-id)))
  (define date-now (current-date))

  (define time-now (string-append (number->string (date-year date-now)) "年" (number->string (date-month date-now)) "月" (number->string (date-day date-now)) "日" (number->string (date-hour date-now)) "时" (number->string (date-minute date-now)) "分"))

  (query-exec sql "INSERT INTO POSTS VALUES ($1, $2, $3, $4)" id name words time-now))

(provide get-latest-id
         get-page-posts
         get-post
         add-post)
