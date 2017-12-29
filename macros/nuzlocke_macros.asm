EnableSRAM: MACRO
	ld a, SRAM_ENABLE
        ld [MBC1SRamEnable], a
        ld a, $1
        ld [MBC1SRamBankingMode], a
        ld [MBC1SRamBank], a
ENDM

DisableSRAM: MACRO
	ld a, SRAM_DISABLE
        ld [MBC1SRamBankingMode], a
        ld [MBC1SRamEnable], a
ENDM

; GetBitmask and CheckTableByte are by nitro2k01 and not me. The comments in GetBitmask are by them and not me.

GetBitmask: MACRO
	; Check a bit mask table. A contains an index where the top 5 bits
	; reference a byte address in the table, and the lower 3 bits
	; reference a bit in that table. Ie, the whole index references
	; a continuous table of bits.
	; Input: A=index
	ld	B,A		; Store for the carry calculation later.
	rrca			; /2 (Rotate right.)
	rrca			; /4
	rrca			; /8
	and	$1f		; Mask unused bits.
	ld	HL,\1		; Table base.
	add	A,L		; Add the index.
	ld	L,A		; Move back to HL for pointer dereferencing.
	; HL should now contain the pointer to the relevant byte.
	ld	A,B		; Retrieve the saved value for the remainder calculation.
	and	A,$07		; Calculate remainder.
	ld	B,A		;
	inc	B		; Make the bit index base 1. Needed for the dec loop or index 0 would become "index 256".
	xor	A,A		; Set A to 0. 
	scf			; Set carry flag, which will be shifted in on the first rla of the loop.
.bitloop
	rla			; Shift A to the right.
	dec	B		; Decrement the loop counter. (This is safe because dec doesn't affect carry.)
	jr	nz,.bitloop	; Loop
	; A should now contain a bit mask with 1 bit set.
	; (minerobber note: HL is the bit you need to check and A is the bitmask for the bit you need to check)
ENDM

CheckTableBit: MACRO
	GetBitmask \1
	and A,[HL] ; if z flag set, bit was set
ENDM

CheckFought: MACRO
	EnableSRAM
	ld a,[wCurMap]
	CheckTableBit sNuzlockeBattleFlags
	jr z,.finishCheck	; If bit isn't set, then the check is over. This is the first battle the player has had in this area.
	ld hl, \1
	call PrintText
	scf			; after this, do what you want (if carry flag is set, player has seen a Pokemon in this area before.)
.finishCheck
	DisableSRAM
ENDM
