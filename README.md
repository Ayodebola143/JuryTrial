```markdown
# JuryTrial Smart Contract

## Overview

**JuryTrial** is a decentralized jury-based dispute resolution smart contract built in Clarity for the Stacks blockchain. It enables transparent case creation, juror registration and assignment, and secure verdict submission, all governed by on-chain logic and strict access controls.

---

## Features

- **Juror Registration:**  
  Principals can register as jurors and are tracked for active status.

- **Case Lifecycle:**  
  - **Open Cases:** Any user can open a new case with a description.
  - **Assign Jurors:** Only active jurors can be assigned to a case (up to 7 per case).
  - **Verdict Submission:** Assigned jurors can submit a single verdict per case; double voting and unauthorized voting are prevented.
  - **Case Settlement:** Cases can be settled based on verdicts (future extension).

- **Strict Access Control:**  
  - Only registered, active jurors can be assigned.
  - Only assigned jurors can vote.
  - No double voting or voting on settled cases.

- **Comprehensive Error Handling:**  
  All public functions return clear error codes for invalid actions (e.g., not a juror, already voted, case not found).

- **Read-Only Queries:**  
  - Retrieve case data.
  - Check if a juror is assigned to a case.

---

## Contract Functions

### Public Functions

- `register-juror (juror principal)`  
  Registers a juror and marks them as active.

- `open-case (description (string-ascii 280))`  
  Opens a new case with the given description.

- `assign-jurors (case-id uint) (jurors (list 7 principal))`  
  Assigns a list of active jurors to a case.

- `submit-verdict (case-id uint) (vote bool)`  
  Allows an assigned juror to submit their verdict for a case.

### Read-Only Functions

- `get-case (case-id uint)`  
  Returns the case data for the given case ID.

- `is-juror-assigned (case-id uint) (juror principal)`  
  Checks if a juror is assigned to a specific case.

---

## Error Codes

| Code         | Meaning                    |
|--------------|---------------------------|
| `u100`       | Case not found            |
| `u101`       | Case already settled      |
| `u102`       | Not an assigned juror     |
| `u103`       | Juror already voted       |
| `u104`       | No valid jurors assigned  |
| `u200`       | Vote tally required       |

---

## Usage Example

```clarity
;; Register a juror
(register-juror tx-sender)

;; Open a new case
(open-case "Dispute over contract terms")

;; Assign jurors to the case
(assign-jurors u0 (list tx-sender 'SP2C2... 'SP3D3...))

;; Submit a verdict as an assigned juror
(submit-verdict u0 true)
```

---


### Testing

Run tests with Clarinet:

```sh
clarinet test
```

### Deployment

Deploy using Clarinet or your preferred Stacks deployment tool.

---

## File Structure

- `contracts/JuryTrial.clar` – Main smart contract
- `.gitignore` – Standard ignores for Stacks/Node/Clarinet projects

---

## Security & Best Practices

- All state-changing functions use strict assertions and error codes.
- Only active, assigned jurors can vote.
- Double voting and unauthorized actions are prevented at the contract level.
- All logic is transparent and auditable on-chain.

---
