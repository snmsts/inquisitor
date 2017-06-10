(in-package :cl-user)
(defpackage inquisitor-test
  (:use :cl
        :inquisitor
        :prove)
  (:import-from :inquisitor-test.util
                :get-test-data)
  (:import-from :babel
                :string-to-octets))
(in-package :inquisitor-test)

;; NOTE: To run this test file, execute `(asdf:test-system :inquisitor)' in your Lisp.

(plan 5)


(subtest "detect-encoding"
  (subtest "for stream"
    (with-open-file (in (get-test-data "data/ascii/ascii-lf.txt")
                        :direction :input)
      (is-error (detect-encoding in :jp) 'error))

    (with-open-file (in (get-test-data "data/ascii/ascii-lf.txt")
                        :direction :input
                        :element-type '(unsigned-byte 8))
      (is (detect-encoding in :jp) :utf-8)))

  (subtest "for pathname"
    (is (detect-encoding (get-test-data "data/ascii/ascii-lf.txt") :jp) :utf-8)))

(subtest "detect-end-of-line"
  (subtest "for stream"
    (with-open-file (in (get-test-data "data/ascii/ascii-lf.txt")
                        :direction :input)
      (is-error (detect-end-of-line in) 'error))

    (with-open-file (in (get-test-data "data/ascii/ascii-lf.txt")
                        :direction :input
                        :element-type '(unsigned-byte 8))
      (is (detect-end-of-line in) :lf)))

  (subtest "for pathname"
    (is (detect-end-of-line (get-test-data "data/ascii/ascii-lf.txt"))
        :lf)))

(subtest "detect external-format --- from vector"
  (diag "when not byte-array")
  (is-error (detect-external-format "string" :jp) 'error)
  (diag "when cannot treat the encodings (how do I cause it...?)")
  (is-error (detect-external-format "" :jp) 'error)
  (let ((str (string-to-octets "string")))
    (is (detect-external-format str :jp)
        (make-external-format :utf-8 :lf))))

(subtest "detect external-format --- from stream"
  (with-output-to-string (out)
    (is-error (detect-external-format out :jp) 'error))
  (with-input-from-string (in "string")
    (is-error (detect-external-format in :jp) 'error))
  (with-open-file (in (get-test-data "data/ascii/ascii-lf.txt")
                      :direction :input
                      :element-type '(unsigned-byte 8))
    (is (detect-external-format in :jp)
        (make-external-format :utf-8 :lf))))

(subtest "detect external-format --- from pathname"
  (is-error (detect-external-format "data/ascii/ascii-lf.txt" :jp) 'error)
  (is (detect-external-format (get-test-data "data/ascii/ascii-lf.txt") :jp)
      (make-external-format :utf-8 :lf)))


(finalize)
