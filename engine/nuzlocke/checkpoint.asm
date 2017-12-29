; A non-core rule of Nuzlocke: "As another mercy rule, each Gym Badge acts as a checkpoint. If the player gets a game over, they can start from when they got their previous Gym Badge." (courtesy of Bulbapedia)

SavePartyCheckpoint:: ; called when player defeats a Gym Leader.
	EnableSRAM
	ld a, $01
	ld [MBC1SRamBankingMode],a
	ld [MBC1SramBank],a
	ld hl, wPartyDataStart
	ld de, sNuzlockeCheckpoint
	ld bc, wPartyDataEnd-wPartyDataStart
	call CopyData
        ld hl, sPlayerName
        ld bc, sMainDataCheckSum - sPlayerName
        call SAVCheckSum
        ld [sMainDataCheckSum], a
        xor a
        ld [MBC1SRamBankingMode], a
        ld [MBC1SRamEnable], a
        ret

