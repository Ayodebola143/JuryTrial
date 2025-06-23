(define-data-var case-counter uint u0)

;; Case data map keyed by case-id
(define-map cases
  {case-id: uint}
  {
    description: (string-ascii 280),
    creator: principal,
    jurors: (list 7 principal),
    settled: bool
  }
)

;; Verdicts map keyed by (case-id, juror)
(define-map verdicts
  {case-id: uint, juror: principal}
  bool
)

;; Registered jurors map keyed by juror principal
(define-map verified-jurors
  {juror: principal}
  {
    active: bool
  }
)

;; Error codes
(define-constant ERR_CASE_NOT_FOUND (err u100))
(define-constant ERR_CASE_SETTLED (err u101))
(define-constant ERR_NOT_JUROR (err u102))
(define-constant ERR_ALREADY_VOTED (err u103))
(define-constant ERR_NO_JURORS (err u104))
(define-constant ERR_VOTE_TALLY_REQUIRED (err u200))

;; Register a juror
(define-public (register-juror (juror principal))
  (begin
    (map-set verified-jurors {juror: juror} {active: true})
    (ok true)
  )
)

;; Open a new case with description
(define-public (open-case (description (string-ascii 280)))
  (let ((new-id (var-get case-counter)))
    (begin
      (map-set cases {case-id: new-id}
        {
          description: description,
          creator: tx-sender,
          jurors: (list), ;; Initialize with empty list
          settled: false
        }
      )
      (var-set case-counter (+ new-id u1))
      (ok new-id)
    )
  )
)

;; Helper: Check if a single juror is active
(define-private (is-juror-active (j principal))
  (match (map-get? verified-jurors {juror: j})
    juror-data (get active juror-data)
    false
  )
)

;; Assign jurors to a case (max 7 jurors)
(define-public (assign-jurors (case-id uint) (jurors (list 7 principal)))
  (begin
    (asserts! (is-some (map-get? cases {case-id: case-id})) ERR_CASE_NOT_FOUND)
    (let ((case-data (unwrap-panic (map-get? cases {case-id: case-id}))))
      (asserts! (not (get settled case-data)) ERR_CASE_SETTLED)
      ;; Check that all jurors are active
      (asserts!
        (is-eq
          (len jurors)
          (len (filter is-juror-active jurors))
        )
        ERR_NO_JURORS
      )
      ;; Replace the case with updated jurors
      (map-set cases {case-id: case-id}
        {
          description: (get description case-data),
          creator: (get creator case-data),
          jurors: jurors,
          settled: (get settled case-data)
        }
      )
      (ok true)
    )
  )
)

;; Submit verdict by juror
(define-public (submit-verdict (case-id uint) (vote bool))
  (let ((case-data (map-get? cases {case-id: case-id})))
    (match case-data
      data
      (begin
        (asserts! (not (get settled data)) ERR_CASE_SETTLED)
        (asserts! (is-some (index-of (get jurors data) tx-sender)) ERR_NOT_JUROR)
        (asserts! (is-none (map-get? verdicts {case-id: case-id, juror: tx-sender})) ERR_ALREADY_VOTED)
        (map-set verdicts {case-id: case-id, juror: tx-sender} vote)
        (ok true)
      )
      (err u100)
    )
  )
)

;; Read-only: get case data
(define-read-only (get-case (case-id uint))
  (map-get? cases {case-id: case-id})
)

;; Read-only: check if juror is assigned to case
(define-read-only (is-juror-assigned (case-id uint) (juror principal))
  (match (map-get? cases {case-id: case-id})
    case-data
    (ok (is-some (index-of (get jurors case-data) juror)))
    (err u100)
  )
)
