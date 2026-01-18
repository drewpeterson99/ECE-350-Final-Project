.text

# $r1 = 1 if startSignal, 0 otherwise

# $r29 = 1
# $r28 = "timer"

# $r2 = 1 if round1Win
# $r3 = round1Score
# $r4 = 1 if round2Win
# $r5 = round2Score
# ...

idle:
    bne     $r0, $r1, loop
    j       idle

loop:
    add     $r28, $r28, $r29

    add     $r3, $r3, $r2
    add     $r5, $r5, $r4
    add     $r7, $r7, $r6
    add     $r9, $r9, $r8
    add     $r11, $r11, $r10
    add     $r13, $r13, $r12

    bne     $r0, $r1, loop
    j       idle