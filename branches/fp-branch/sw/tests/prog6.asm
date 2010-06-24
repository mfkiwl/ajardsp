.data
input:
        .word 0
        .word 1
        .word 2
        .word 3
        .word 4
        .word -5
        .word -0x6
        .word 7
        .word 8
        .word 9
        .word 10
        .word 11
        .word 12
        .word 13
        .word 14
        .word 15

output:
        .skip 32
.code

        ldimm16 $ptr3, 10
        nop
        nop
        ldoff16 $acc3h, -1, $ptr3
        ldoff16 $acc3h, 0, $ptr3
        ldoff16 $acc3h, 1, $ptr3
        ldoff32 $acc7, -2, $ptr3
        nop
        nop
        stoff32 $acc7, -4, $ptr3
        stoff32 $acc7, 2, $ptr3 | stoff16 $acc7h, -5, $ptr3


        ldimm16 $acc0l, 0xffff
      | ldimm16 $acc0h, 0x0000
        ldimm16 $acc1l, 0xff00
      | ldimm16 $acc1h, 0x0808

        ldimm16 $acc4h, 32
	nop
	nop
	mvts16 $acc4h, $sp
        nop
        nop

        mvts16 $acc0l, $satctrl
        mvts16 $acc0h, $satctrl
        mvts16 $acc1l, $satctrl
        mvts16 $acc1h, $satctrl
        mvts16 $acc0l, $mulsign
        push16 $satctrl
        push16 $mulsign

        ldimm16 $acc2l, 0x1234
      | ldimm16 $acc2h, 0x7fff

        nop
        nop
        add32 $acc2, $acc2, $acc3
        nop

        ldimm16 $acc2l, 0xffff
        ldimm16 $acc2h, -3
        nop
        nop
        mpy16 $acc2l, $acc2h, $acc5
        nop
        nop
        push32 $acc5

        halt
