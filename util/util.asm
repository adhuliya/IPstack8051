; This file contains useful routiens.

; Routine names
;----------------------------------------------------------------
; wait_1sec --- makes a buzy (using loop) 1 second wait
;----------------------------------------------------------------

wait_1sec:
	mov	dcount_3,#07d
l2:	mov 	dcount_2,#0ffh
l1:	mov 	dcount_1,#0ffh
	djnz 	dcount_1,$
	djnz 	dcount_2,l1
	djnz 	dcount_3,l2
	ret
