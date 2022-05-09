; ------------------------------------------------------------------------------------------------------
; MSXBAS2ROM Z80 routines (for tokenized mode)
; by: Amaury Carvalho, 2020
; Compile with:
;   pasmo routines.asm routines.bin
;   xxd -i routines.bin routines.h
; ------------------------------------------------------------------------------------------------------

  org 0x8010

; ------------------------------------------------------------------------------------------------------
; PLETTER AND PT3TOOLS
; ------------------------------------------------------------------------------------------------------

PT3.LOAD:         equ 0x0100 ;0x4010
PT3.LOAD_FROM_HL: equ PT3.LOAD + 3
PT3.PLAY:         equ PT3.LOAD + 5
PT3.MUTE:         equ PT3.LOAD + 8
PT3.DATA.STATUS:  equ PT3.LOAD + 10    ; setup and status flags
PT3.DATA.INDEX:   equ PT3.LOAD + 11    ; pointer to current position value in PT3 module;
PT3.DATA.ADDR:    equ PT3.LOAD + 0x0900
PT3.DATA.TEMP:    equ PT3.DATA.ADDR + 0x1800

; ------------------------------------------------------------------------------------------------------
; BIOS AND BASIC FUNCTIONS
; ------------------------------------------------------------------------------------------------------

CALBAS:       equ 0x0159
CALSLT:       equ 0x001C
EXTROM:       equ 0x015F
BASINIT:      equ 0x629A   ; initialize interpreter, basic pointer at start of program
RDSLT:        equ 0x000C   ; Read a byte in a Slot
RSLREG:       equ 0x0138   ; Read primary Slot REGister
WRSLT:        equ 0x0014   ; Write a byte in a Slot
WSLREG:       equ 0x013B   ; Write primary Slot REGister
ENASLT:       equ 0x0024   ; enable slot (a=slot indicator, hl=address to enable)
RDHDR:        equ 0x7E1A   ; read header data
XFER:         equ 0xF36E   ; LDIR of RAM page 1 from/to RAM page 3 (BC=512 bytes, HL=source address, DE=dest address)
IOALLOC:      equ 0x7E6B   ; IO allocation (CLEAR stmt)

CRUNCH:       equ 0x42B2
NEWSTT:       equ 0x4601   ; execute a text (hl=text pointer; text must start with a ":")
CHRGTR:       equ 0x4666   ; extract one character from command line text (hl=text pointer; hl=char address, a=char, Z=end of line)
FRMEVL:       equ 0x4C64   ; evaluate an expression in text (hl=expression pointer; hl=after expression, VALTYP/DAC)
FRMQNT:       equ 0x542F   ; evaluate an expression and return as integer (hl=expression; hl=after, DE=result)
GETBYT:       equ 0x521C   ; evaluate an expression and return as byte (hl=expression; hl=after, A=result)
FRESTR:       equ 0x67D0   ; register a string (VALTYP=3, DAC=string descriptor; HL=string descriptor)
PTRGET:       equ 0x5EA4   ; obtain the address for the storage of a variable (HL=variable name address, SUBFLG; HL=after name, DE=content address)
BEEP:         equ 0x00C0
CHGET:        equ 0x009F
CHPUT:        equ 0x00A2
CHSNS:        equ 0x009C
GICINI:       equ 0x0090   ; initialize PSG voices
GTTRIG:       equ 0x00D8   ; joy trigger status

PLAY:         equ 0x39AE
DRAW:         equ 0x39A8
ERRORHANDLER: equ 0x406F
RUN:          equ 0x3940

HCMD:         equ 0xFE0D   ; cmd hook
HPRGE:        equ 0xFEF8   ; end of program hook
HTIMI:        equ 0xFD9F   ; timer interrupt hook
HREAD:        equ 0xFF07   ; ready prompt hook
HSTKE:        equ 0xFEDA   ; stack hook (for after msx initialization)
HCHPU:        equ 0xFDA4   ; char put hook
HKEYI:        equ 0xFD9A

WRTVDP:       equ 0x0047
RDVRM:        equ 0x004A
WRTVRM:       equ 0x004D
LDIRVM:       equ 0x005C
LDIRMV:       equ 0x0059
FILVRM:       equ 0x0056 ; fill VRAM with value
CALPAT:       equ 0x0084
CALATR:       equ 0x0087
GSPSIZ:       equ 0x008A
GRPPRT:       equ 0x008D
CLRSPR:       equ 0x0069

DISSCR:       equ 0x0041
ENASCR:       equ 0x0044

BIGFIL:       equ 0x016B ; msx 2
NRDVRM:       equ 0x0174 ; msx 2
NWRVRM:       equ 0x0177 ; msx 2
NRDVDP:       equ 0x013E ; msx 2
VDPSTA:       equ 0x0131 ; msx 2
NWRVDP:       equ 0x012D ; msx 2 (0x0647)
CALPAT2:      equ 0x00F9 ; msx 2
CALATR2:      equ 0x00FD ; msx 2
GSPSIZ2:      equ 0x0101 ; msx 2
CLRSPR2:      equ 0x00F5 ; msx 2

INIFNK:       equ 0x003E
INITIO:       equ 0x003B
INIT32:       equ 0x006F
INITXT:       equ 0x006C
KILBUF:       equ 0x0156


; ------------------------------------------------------------------------------------------------------
; BIOS AND BASIC WORK AREA
; ------------------------------------------------------------------------------------------------------

USRTAB:       equ 0xF39A   ; 20
VALTYP:       equ 0xF663   ; 1
VALDAT:       equ 0xF7F8   ; 2
DAC:          equ 0xF7F6   ; 16
ARG:          equ 0xF847   ; 16
SUBFLG:       equ 0xF6A5   ; 1 (0=simple variable, not 0 = array)
STMTKTAB:     equ 0x392E   ; addresses of BASIC statement token service routines (start from 081H to 0D8H)
FNCTKTAB:     equ 0x39DE   ; addresses of BASIC function token service routines

TEMP:         equ 0xF6A7   ; 2
TEMP2:        equ 0xF6BC   ; 2
TEMP3:        equ 0xF69D   ; 2
TEMP8:        equ 0xF69F   ; 2
TEMP9:        equ 0xF7B8   ; 2
RAWPRT:       equ 0xF41F   ; 1
PARM1:        equ 0xF6E8   ; 100
PARM2:        equ 0xF750   ; 100
CMDP0:        equ PARM1    ; 1
CMDP1:        equ CMDP0+1  ; 2
CMDP2:        equ CMDP1+2  ; 2
CMDP3:        equ CMDP2+2  ; 2
BUF:          equ 0xF55E   ; 259
KBUF:         equ 0xF41F   ; 318
SWPTMP:       equ 0xF7BC   ; 8
STRBUF:       equ 0xF7C5   ; 43
JIFFY:        equ 0xFC9E   ; timer counter
VARWRK:       equ 0xF380   ; BASIC variables workspace start
TRCFLG:       equ 0xF7C4   ; BASIC line number trace on/off (0=off)
CLKFLG:       equ 0xF338   ; ask for clock flag (0=yes, 1=no)
WRMBOOT:      equ 0xF340   ; warm boot? (1=yes)
DSKDIS:       equ 0xFD99   ; disable disks (DEVICE, 0xFF=yes)

ROMSLT:       equ 0xFFF7   ; Main-ROM slot
EXPTBL:       equ 0xFCC1   ; Expanded Slot Table
SLTTBL:       equ 0xFCC5   ; Slot Table
RAMAD0:       equ 0xF341   ; slotid ram page 0
RAMAD1:       equ 0xF342   ; slotid ram page 1
RAMAD2:       equ 0xF343   ; slotid ram page 2
RAMAD3:       equ 0xF344   ; slotid ram page 3
RAMSLT:       equ KBUF+3   ; temporary searched ram slot
SLTWRK:       equ 0xFD09   ; 128 - variable array used to reserve a RAM work area in Main-RAM for ROM applications
SLTATR:       equ 0xFCC9   ; 64 - slots attributes (bit 5 = statement, bit 7 = basic code at page)

SCRMOD:       equ 0xFCAF   ; 0=40x24 Text Mode, 1=32x24 Text Mode, 2=Graphics Mode, 3=Multicolour Mode.
RG0SAV:       equ 0xF3DF
RG1SAV:       equ 0xF3E0
RG8SAV:       equ 0xFFE7
STATFL:       equ 0xF3E7  ; VDP status register

TRGFLG:       equ 0xF3E8  ; joysticks trigger ports flag (b0-space, b4-1A, b5-1B, b6-2A, b7-2B)
SCNCNT:       equ 0xF3F6  ; joystick test counter (1 time for each 3 cycles)
QUETAB:       equ 0xF959  ; play queue tab (6 bytes per channel: index in, index out, flag, size, address)

FORCLR:       equ 0xF3E9  ; foreground color
BAKCLR:       equ 0xF3EA  ; background color
BDRCLR:       equ 0xF3EB  ; border color
ATRBYT:       equ 0xF3F2  ; char color

NAMBAS:       equ 0xF922  ; pattern name table - basic
CGPBAS:       equ 0xF924  ; pattern generator table - basic
LINLEN:       equ 0xF3B0  ; line text length (default=39)
CRTCNT:       equ 0xF3B1  ; line text count (default=24)

GRPNAM:       equ 0xF3C7  ; pattern name table
GRPCOL:       equ 0xF3C9  ; colour table
GRPCGP:       equ 0xF3CB  ; pattern generator table (screen 2)
GRPATR:       equ 0xF3CD  ; sprite attribute table
GRPPAT:       equ 0xF3CF  ; sprite generator table
CGPNT:        equ 0xF920  ; 2 - current MSX Font location (0x1BBF)
ATRBAS:       equ 0xF928  ; sprite attribute table

TXTCGP:       equ 0xF3B7  ; pattern generator table (screen 0)
T32CGP:       equ 0xF3C1  ; pattern generator table (screen 1)

MLTNAM:       equ 0xF3D1  ; pattern name table (screen 3, multicolor)
MLTCOL:       equ 0xF3D3  ; colour table (screen 3, multicolor)
MLTCGP:       equ 0xF3D5  ; pattern generator table (screen 3, multicolor)
MLTATR:       equ 0xF3D7  ; sprite attribute table (screen 3, multicolor)
MLTPAT:       equ 0xF3D9  ; sprite generator table (screen 3, multicolor)

MUSICF:       equ 0xFB3F  ; contains 3 bit flags set by the STRTMS. Bits 0, 1 and 2 correspond to VOICAQ, VOICBQ and VOICCQ.
CLIKSW:       equ 0xF3DB  ; 0=keyboard click off, 1=keyboard click on
CSRY:         equ 0xF3DC  ; cursor Y pos
CSRX:         equ 0xF3DD  ; cursor X pos
TTYPOS:       equ 0xF661  ; teletype position

TXTTAB:       equ 0xF676     ; start of basic program
VARTAB:       equ 0xF6C2     ; start of variables area (end of basic program)
ARYTAB:       equ 0xF6C4     ; start of array area
STREND:       equ 0xF6C6     ; end of variables area
BASROM:       equ 0xFBB1     ; user basic code on rom? (0=RAM, not 0 = ROM)
NLONLY:       equ 0xF87C     ; loading basic program flags (bit 0=not close i/o buffer 0, bit 7=not close user i/o buffer)
LPTPOS:       equ 0xF415     ; printer head horizontal position
ONELIN:       equ 0xF6B9
ONEFLG:       equ 0xF6BB
PRTFLG:       equ 0xF416     ; output to screen (0=true)
PTRFLG:       equ 0xF6A9     ; line number converted to pointer (0=false)

BOTTOM: equ 0xFC48
HIMEM:  equ 0xFC4A
ENDBUF: equ 0xF660
AUTFLG: equ 0xF6AA
BUFMIN: equ 0xF55D
KBFMIN: equ 0xF41E
CGTABL: equ 0x0004
PRMSTK: equ 0xF6E4
PRMPRV: equ 0xF74C
STKTOP: equ 0xF674
SAVSTK: equ 0xF6B1
MEMSIZ: equ 0xF672
ENDPRG: equ 0xF40F

WRKARE:       equ 0xC000     ; homebrew rom internal workarea start in RAM (alternatives: SLTWRK or PARM2)

SLTSTR:       equ WRKARE     ; startup slotid
PT3STS:       equ SLTSTR+1   ; PT3 status flag (0=idle, 1=load, 2=play, 3=mute) - RAWPRT
PT3HKSAV:     equ PT3STS+1   ; HTIMI hook saved

SLTAD0:       equ PT3HKSAV+5 ; default slotid from page 0
SLTAD1:       equ SLTAD0+1   ; default slotid from page 1
SLTAD2:       equ SLTAD1+1   ; default slotid from page 2
SLTAD3:       equ SLTAD2+1   ; default slotid from page 3

BASTEXT:      equ 0x800E     ; 0x8008 - address of user basic code
BASMEM:       equ SLTAD3+1

; ------------------------------------------------------------------------------------------------------
; MACROS
; ------------------------------------------------------------------------------------------------------

MACRO call_basic,CALL_PARM
    ld ix, CALL_PARM
    call CALBAS
ENDM

MACRO call_debug,CHAR
  push af
  push hl
  push de
  push bc
  ld a, CHAR
  call CHPUT
  call BEEP
  call CHGET
  pop bc
  pop de
  pop hl
  pop af
ENDM

; ------------------------------------------------------------------------------------------------------
; INITIALIZE
; ------------------------------------------------------------------------------------------------------

initialize:
  jp start
  jp cmd_parse.xbasic

pre_start:
  ;ld h, 0xC0
  ;call page.getslt
  ;cp (SLTSTR)
  ;jr z, start         ; verify if ROM was loaded into RAM by a loader

    ld a, (SLTSTR)

    ld hl, pre_start.hook_data
    ld de, HSTKE
    ld bc, 5
    ldir

    ld (HSTKE+1), a     ; program rom slot

    ret

pre_start.hook_data:
  db 0xF7, 0x00, 0x10, 0x80, 0xC9

start:
  call verify.slots
  call initialize.cmd
  call initialize.chput
  call initialize.pt3
  call initialize.usr

adjust_call_statement:
  ld a, (SLTSTR)     ; get startup slot
  bit 7, a
  jr nz, clr_stmt_flag
    and 3              ; slot only
    ld hl, EXPTBL
    add a, l
    ld l, a
    ld a, 0x80         ; slot expanded (xbasic)
    ld (hl), a         ; set as expanded into EXPTBL
    ld a, (SLTSTR)     ; get startup slot again
    or 0x80            ; assure expanded

clr_stmt_flag:
  ld hl, SLTATR
  ld b, 64
clr_stmt_flag.loop:
    res 5, (hl)     ; reset bit 5 from all slots (hotbit bug fix)
    inc hl
  djnz clr_stmt_flag.loop

set_stmt_flag:
  bit 7, a
  jp nz, set_stmt_flag.subslt  ; jump if SlotID has SubSlot information (bit 7 is on)
    and 3    ; remove subslot (slot is not expanded, remember?)

set_stmt_flag.subslt:
  ; 4 * 4 * slot_number + 4 * subslot_number + page = slot attribute location
  ld d, a    ; d = slot ID
  and 12     ; extract subslot
  ld e, a    ; e = subslot*4

  ld a, d
  and 3      ; extract slot
  sla a
  sla a
  sla a
  sla a      ; x16
  or e       ; a = slot*16 + subslot*4

  ld d, 0
  ld e, a
  ld hl, SLTATR+1 ; +1 for page 1
  add hl, de
  set 5, (hl)     ; Set bit 5 to enable CALL handler on page 1

clear_basic_environment:
  ld a, 0xC9
  ld (HSTKE), a
  ld (HSTKE+1), a
  ld (HSTKE+2), a
  ld (HSTKE+3), a
  ld (HSTKE+4), a

  xor a
  ld (BUF), a                ; clear BUF (keyboard)
  ld (ENDBUF), a             ; endmarker for BUF
  ld (KBUF), a               ; clear KBUF (interpreter command line)
  ld (AUTFLG), a             ; quit auto linenumber mode
  ld (LPTPOS), a             ; printer position
  ld (TRCFLG), a             ; disable trace
  ld (PRTFLG), a             ; output to screen
  ld (ENDPRG+1),a            ; fake line
  ld (ENDPRG+2),a            ; fake line
  ld (ENDPRG+3),a            ; fake line
  ld (ENDPRG+4),a            ; fake line
  ld (TRGFLG), a             ; joysticks ports

  ld A,','
  ld (BUFMIN),A              ; dummy prefix for BUF

  ld A,":"
  ld (KBFMIN),A              ; dummy prefix for KBUF
  ld (ENDPRG),a              ; fake line

  ld a, 0x81                 ; 10000001b
  ld (NLONLY), a             ; dont close i/o buffers

  ld a, 0xFF
  ld (PTRFLG), a             ; line number converted to pointer (0=false)
  ld (DSKDIS), a             ; disable disks

  ;ld a, 0x32                 ; sets H.TIMI hook
  ;ld (HTIMI), a
  ;ld a, 0xE7
  ;ld (HTIMI+1), a
  ;ld a, 0xF3                 ; ld (STATFL), a
  ;ld (HTIMI+2), a
  ;ld a, 0xC9
  ;ld (HTIMI+3), a            ; ret
  ;ld (HTIMI+4), a

  call KILBUF
  call INIT32                  ; screen 1
  call CLRSPR                  ; clear sprites

select_basic_on_page_1:
  ld a, (EXPTBL)
  ld hl,04000h
  call ENASLT    ; Select main ROM on page 1 (4000h~7FFFh)

run_user_basic_code_on_rom:
  ld hl, BASMEM              ; variable starts at page 3 (0xC000...)
  ld (VARTAB), hl
  ld (BOTTOM), hl

  ld hl, (BASTEXT)           ; start of user basic code
  inc hl
  ld (TXTTAB), hl
  ld a, h
  ld (BASROM), a             ; basic code location (0=RAM, not 0 = ROM)

  ld HL,VARWRK
  ld (HIMEM),HL              ; highest BASIC RAM address
  ;ld hl,VARWRK-267-1
  ld (MEMSIZ),hl
  xor a                      ; user i/o channels (FILES number=0)
  ld bc, 200                 ; string buffer size
  sbc hl, bc
  ld (STKTOP), hl

  call IOALLOC               ; clear statement

  call BASINIT               ; initialize interpreter, basic pointer at start of program

  ld a, 0xC9                 ; ret
  ld (0xF397), a             ; CALSLT bug fix to some MSX 1 BIOS (ex: Expert XP-800 and GPC-1)

  jp NEWSTT                  ; execute next line

; ------------------------------------------------------------------------------------------------------
; CMD IMPLEMENTATION
; https://github.com/Konamiman/MSX2-Technical-Handbook/blob/master/md/Chapter2.md#44-expansion-of-cmd-command
; ------------------------------------------------------------------------------------------------------

initialize.cmd:
  ld hl, cmd_hook
  ld de, HCMD
  ld bc, 5
  ldir
  ret

; cmd hook
cmd_hook:
  jp cmd_parse.basic
  nop
  nop

; cmd instruction parser from xbasic
;   HL point to: <TOKEN> [<@> <address>|<#> <value>] [<@> <address>|<#> <value>] [<@> <address>|<#> <value>] <0>
cmd_parse.xbasic:
  pop hl              ; caller return address = stream of cmd data

  ld a, (hl)
  ld (VALTYP), a
  ld de, 0
  ld (DAC), de         ; first parm
  ld (ARG), de         ; second parm
  ld (ARG+2), de       ; third parm

  ; get first parameter, or run
  call cmd_parse.xbasic.get
  jr z, cmd_parse.xbasic.run
  ld (DAC), bc

  ; get next parameter, or run
  call cmd_parse.xbasic.get
  jr z, cmd_parse.xbasic.run
  ld (ARG), bc

  ; get next parameter, or run
  call cmd_parse.xbasic.get
  jr z, cmd_parse.xbasic.run
  ld (ARG+2), bc

  jr cmd_parse.xbasic.run

cmd_parse.xbasic.get:
  inc hl
  ld a, (hl)
  or 0
  ret z

  inc hl
  cp '@'
  jr nz, cmd_parse.xbasic.get.2
    ld e, (hl)
    inc hl
    ld d, (hl)
    ex de, hl
    ld c, (hl)
    inc hl
    ld b, (hl)
    ex de, hl
    inc a
    ret
cmd_parse.xbasic.get.2:
  ld c, (hl)
  inc hl
  ld b, (hl)
  ret

cmd_parse.xbasic.run:
  push hl              ; return to xbasic code
  call cmd_run
  ret z

basic.error:
  ld e, 5    ; illegal function call
  ld ix, ERRORHANDLER
  jp CALBAS


; cmd instruction parser from basic
;   default error handler loaded into call stack
;   (drop it with POP AF to register success)
;   HL point to: <TOKEN> <parm1>[, <parm2>] <0|:>
cmd_parse.basic:
  ; get main token
  dec hl
  call CHRGTR          ; next token in A
  ret z                ; eol = error

  ld (CMDP0), a        ; register token
  ld de, 0
  ld (CMDP1), de       ; first parm
  ld (CMDP2), de       ; second parm
  ld (CMDP3), de       ; third parm

  ; get first parameter, or run
  call CHRGTR                 ; next token in A
  jr z, cmd_parse.basic.run   ; eol = run command
  call FRMQNT                 ; evaluate an expression and return as integer (hl=expression; hl=after, DE=result)
  ld (CMDP1), de

  ; get next parameter, or run
  call cmd_parse.basic.get
  jr z, cmd_parse.basic.run   ; eol = run command
  ld (CMDP2), de

  ; get next parameter, or run
  call cmd_parse.basic.get
  jr z, cmd_parse.basic.run   ; eol = run command
  ld (CMDP3), de

  ; try one more parameter (and dispatch error if found)
  dec hl
  call CHRGTR                 ; next token in A
  ret nz                      ; not eol = error

cmd_parse.basic.run:
  push hl
    ld a, (CMDP0)
    ld (VALTYP), a
    ld bc, (CMDP1)
    ld (DAC), bc
    ld bc, (CMDP2)
    ld (ARG), bc
    ld bc, (CMDP3)
    ld (ARG+2), bc
    call cmd_run
  pop hl
  ret nz               ; parse error

  pop af               ; discards default CMD error handler
  ret

cmd_parse.basic.get:
  dec hl
  call CHRGTR                 ; next token in A
  ret z                       ; eol = run command

  cp ','
  jr nz, cmd_parse.basic.err  ; not ',' = error

  call CHRGTR                 ; next token in A
  jr z, cmd_parse.basic.err   ; eol = error

  jp FRMQNT                   ; evaluate an expression and return as integer (hl=expression; hl=after, DE=result)

cmd_parse.basic.err:
  pop af ; drop last call
  xor a
  inc a
  ret    ; ret with error


; cmd instruction execute
; VALTYP = TOKEN
; DAC = PARM1
; ARG = PARM2
cmd_run:
  ld a, (VALTYP)
  ld hl, 0

  cp 0xC1
  jp z, cmd_play

  cp 0xBE
  jp z, cmd_draw

  sub 'a'
  jr c, cmd_run.error

  cp cmd.list.length
  jr nc, cmd_run.error

  add a, a
  ld c, a
  ld b, 0
  ld hl, cmd.list
  add hl, bc

  ld e, (hl)
  inc hl
  ld d, (hl)

  ld bc, cmd_run.ok
  push bc
  push de
  ret      ; indirect jump

cmd_run.ok:
  xor a
  ret

cmd_run.error:
  xor a
  inc a
  ret

cmd.list.length: equ 0x25

cmd.list:
  dw cmd_runasm, cmd_runbas, cmd_wrtvram, cmd_wrtfnt, cmd_wrtchr, cmd_wrtclr, cmd_wrtscr, cmd_wrtsprpat
  dw cmd_wrtsprclr, cmd_wrtspratr, cmd_ramtovram, cmd_vramtoram
  dw cmd_disscr, cmd_enascr, cmd_keyclkoff, cmd_mute
  dw cmd_pt3load, cmd_pt3play, cmd_pt3mute, cmd_setfnt, cmd_clrscr, cmd_ramtoram
  dw cmd_pt3loop, cmd_pt3replay, cmd_clrkey

; play resource with Basic standard statement
; CMD PLAY <resource number> [, <channel C: 0=off|1=on>]
cmd_play:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c
  ld a, (ARG)
  and 1
  sla a
  sla a
  ld c, a
  push bc
    ld ix, (PLAY)
    call CALBAS
  pop bc
  di
    ld a, (MUSICF)
    and 3                  ; disable channel C
    or c                   ; enable/disable channel C
    ld (MUSICF), a
    ld a, 0xFF
    ld (QUETAB + 12), a
    ld (QUETAB + 13), a    ; clear channel C buffer index (in and out)
  ei
  xor a
  ret

; mute PSG
; CMD MUTE
cmd_mute:
  call GICINI
  jp GICINI

; draw resource with Basic standard statement
; CMD DRAW <resource number>
cmd_draw:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c
  ld ix, (DRAW)
  call CALBAS
  xor a
  ret

; exec as assembly code
; CMD RUNASM <resource number>
cmd_runasm:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c
  push hl
  ret                      ; indirect call

; exec as plain text basic code
; CMD RUNBAS <resource number>
cmd_runbas:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c
  call savehook
  call execbas   ; hl has the line code in plain text, null terminated
  call resthook
  xor a
  ret

; write resource to vram address
; CMD WRTVRAM <resource number>, <vram address>
cmd_wrtvram:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c

  ;ld de, (ARG)
  ;jp vpletter.unpack    ; hl = pletter data, de = vram address
  di
    ld de, PT3.DATA.TEMP
    ld ix, resource.ram.unpack
    call jp_with_ram_in_0

    ld hl, PT3.DATA.TEMP
    ld de, (ARG)
    ld ix, gfxLDIRVM
    call jp_with_ram_in_0
  ei
  ret

; write resource to vram tile pattern table
; CMD WRTCHR <resource number>
cmd_wrtchr:
  ld bc, (GRPCGP)
  ld (ARG), bc
  call cmd_wrtvram
  jp cmd_setfnt.default_colors

cmd_wrtfnt:
  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c

  di
    ld de, PT3.DATA.TEMP
    ld ix, resource.ram.unpack
    call jp_with_ram_in_0

    call cmd_setfnt.get_vram_address
    ex de, hl
    ld hl, PT3.DATA.TEMP + 7
    dec bc
    dec bc
    dec bc
    dec bc
    dec bc
    dec bc
    dec bc
    ld ix, gfxLDIRVM
    call jp_with_ram_in_0
  ei

  ;di
  ;  call page.1.save

  ;  call page.1.ram
  ;  ld de, 0x6900
  ;  call resource.ram.unpack

  ;  ld hl, 0x6907
  ;  ld de, (GRPCGP)
  ;  dec bc
  ;  dec bc
  ;  dec bc
  ;  dec bc
  ;  dec bc
  ;  dec bc
  ;  dec bc
  ;  call LDIRVM

  ;  call page.1.restore
  ;ei

  ret

; write resource to vram tile color table
; CMD WRTCLR <resource number>
cmd_wrtclr:
  ld bc, (GRPCOL)
  ld (ARG), bc
  jp cmd_wrtvram

; write resource to vram screen table
; CMD WRTSCR <resource number>
cmd_wrtscr:
  ld bc, (GRPNAM)
  ld (ARG), bc
  jp cmd_wrtvram

; write resource to vram sprite pattern table
; CMD WRTSPRPAT <resource number>
cmd_wrtsprpat:
  xor a
  call gfxCALPAT
  ld (ARG), hl
  jp cmd_wrtvram

; write resource to vram sprite color table
; CMD WRTSPRCLR <resource number>
cmd_wrtsprclr:
  xor a
  call gfxCALCOL
  ld (ARG), hl
  jp cmd_wrtvram

; write resource to vram sprite attribute table
; CMD WRTSPRATR <resource number>
cmd_wrtspratr:
  xor a
  call gfxCALATR
  ld (ARG), hl
  jp cmd_wrtvram

; write ram to vram address
; CMD RAMTOVRAM <ram address>, <vram address>, <size>
cmd_ramtovram:
  ld hl, (DAC)
  ld de, (ARG)
  ld bc, (ARG+2)
  jp LDIRVM      ; hl = ram data address, de = vram data address, bc = length

; write vram to ram address
; CMD VRAMTORAM <vram address>, <ram address>, <size>
cmd_vramtoram:
  ld hl, (DAC)
  ld de, (ARG)
  ld bc, (ARG+2)
  jp LDIRMV      ; de = ram data address, hl = vram data address, bc = length

; copy ram to ram address
; CMD RAMTORAM <ram source address>, <ram dest address>, <size>
cmd_ramtoram:
  ld hl, (DAC)
  ld de, (ARG)
  ld bc, (ARG+2)
  ldir      ; hl = source ram address, de = dest ram address, bc = length
  ret

; disable screen
cmd_disscr:
  jp DISSCR

; enable screen
cmd_enascr:
  jp ENASCR

cmd_keyclkoff:
  xor a
  ld (CLIKSW), a
  ret

; load PT3 resource in memory
; CMD PT3LOAD <resource number>
cmd_pt3load:
  di
    ld a, 0                ; idle
    ld (PT3STS), a
  ei

  ld bc, (DAC)             ; bc = resource number
  call resource.address    ; hl = resource start address
  ret c

  di
    ld de, PT3.DATA.ADDR
    ld ix, pletter.unpack
    call jp_with_ram_in_0

    call cmd_pt3replay.do

    ld a, 1                ; load
    ld (PT3STS), a
  ei

cmd_pt3load.wait:
  ld a, (PT3STS)
  or a
  jr nz, cmd_pt3load.wait  ; wait to load complete

  xor a
  ret

; replay PT3 in memory
; CMD PT3REPLAY
cmd_pt3replay:
  di
    call cmd_pt3replay.do
    ld a, 1                ; load
    ld (PT3STS), a
  ei
cmd_pt3replay.wait:
  ld a, (PT3STS)
  or a
  jr nz, cmd_pt3replay.wait  ; wait to load complete

  jp cmd_pt3play

cmd_pt3replay.do:
    push de
      ld a, (RAMAD0)
      ld hl, PT3.DATA.STATUS
      call RDSLT
    pop de
    and %00000001          ; clear all flags (except loop flag)
    ld e, a
    ld a, (RAMAD0)
    ld hl, PT3.DATA.STATUS
    call WRSLT
    ret

; play PT3 in memory
; CMD PT3PLAY
cmd_pt3play:
  di
    ld a, 2                ; play
    ld (PT3STS), a
  ei
  xor a
  ret

; mute PT3 in memory
; CMD PT3MUTE
cmd_pt3mute:
  di
    ld a, 3         ; mute
    ld (PT3STS), a
  ei
  xor a
  ret

; set PT3 loop status
; CMD PT3LOOP <0=off|1=on>
cmd_pt3loop:
  ld a, (DAC)             ; a = loop status
  ld e, 1
  and e
  xor e
  ld e, a
  di
    push de
      ld a, (RAMAD0)
      ld hl, PT3.DATA.STATUS
      call RDSLT
    pop de
    and %11111110
    or e
    ld e, a
    ld a, (RAMAD0)
    ld hl, PT3.DATA.STATUS
    call WRSLT
  ei
  xor a
  ret

; enable built in fonts
; CMD SETFNT
cmd_setfnt:
  ld bc, (DAC)             ; bc = resource number

  ld a, c
  or b
  jp z, cmd_setfnt.bios

  call resource.count      ; de = resource count

  ld h, d
  ld l, e
  xor a
  sbc hl, bc
  ld b, h
  ld c, l                  ; font resource

  call resource.address    ; hl = resource start address
  ret c

  ld de, PT3.DATA.TEMP
  ld ix, resource.ram.unpack
  di
    call jp_with_ram_in_0
  ei

  ld hl, PT3.DATA.TEMP   ; ram font source
  ld a, (ARG)            ; bank number in vram
  ld ix, cmd_setfnt.cpy_to_bank
  di
    call jp_with_ram_in_0
  ei

    ;call page.1.save

    ;call page.1.ram
    ;ld de, 0x6900
    ;call resource.ram.unpack

    ;ld hl, 0x6900    ; ram font source
    ;ld a, (ARG)      ; bank number in vram
    ;call cmd_setfnt.cpy_to_bank

    ;call page.1.restore

  jp cmd_setfnt.default_colors

cmd_setfnt.bios:
  ld bc, 95 * 8    ; bytes to be copied (chars * 8)
  ld hl, 32 * 8    ; pattern generator in bios start position * 8
  ld de, (CGPNT)
  add hl, de       ; ram font source in bios
  ld a, (ARG)      ; bank number in vram
  jp cmd_setfnt.cpy_to_bank

; a = bank number
; hl = ram address
cmd_setfnt.cpy_to_bank:
  push hl
    call cmd_setfnt.get_vram_address
    ld de, 32 * 8    ; pattern generator in vram start position * 8
    add hl, de
    or a
    jr z, cmd_setfnt.cpy_to_bank.cont
      ld de, 0x0800
      add hl, de         ; next bank
      cp 1
      jr z, cmd_setfnt.cpy_to_bank.cont
        add hl, de       ; next bank
cmd_setfnt.cpy_to_bank.cont:
    ex de, hl
  pop hl
  ld bc, 95 * 8    ; bytes to be copied (chars * 8)
  jp gfxLDIRVM

; out hl = pattern generator vram address
cmd_setfnt.get_vram_address:
  push af
    ld hl, (GRPCGP)
    ld a, (SCRMOD)
    cp 2
    jr nc, cmd_setfnt.get_address.exit
    ld hl, (T32CGP)
    cp 1
    jr z, cmd_setfnt.get_address.exit
    ld hl, (TXTCGP)
cmd_setfnt.get_address.exit:
  pop af
  ret

cmd_setfnt.default_colors:
  ld a, (SCRMOD)
  cp 2
  ret nz
    push hl
    push de
    push bc
      ld bc, (GRPATR)
      ld (ATRBAS), bc
      ld bc, (GRPNAM)
      ld (NAMBAS), bc
      ld bc, (GRPCGP)
      ld (CGPBAS), bc
      ld a, 32  ;31
      ld (LINLEN), a
      ld a, 24
      ld (CRTCNT), a
      ld hl, (GRPCOL)
      ld de, 32*8
      add hl, de
      ld a, (ARG)      ; bank number in vram
      or a
      jr z, cmd_setfnt.default_colors.1
        ld de, 0x0800
        add hl, de
        cp 1
        jr z, cmd_setfnt.default_colors.1
          add hl, de
cmd_setfnt.default_colors.1:
      ld a, (FORCLR)
      sla a ; x2
      sla a ; x4
      sla a ; x8
      sla a ; x16
      ex de, hl
        ld hl, BAKCLR
        or (hl)
      ex de, hl
      ld bc, 95*8
      call FILVRM
    pop bc
    pop de
    pop hl
    ret

cmd_clrkey:
  di
    push hl
      call KILBUF
    pop hl
    xor a
    ld (TRGFLG), a   ; clear joysticks
  ei
  ret

cmd_clrscr:
  ld hl, (GRPNAM)
  ld bc, 28*32
  ld a, 32
  jp FILVRM

initialize.chput:
  ld hl, cmd_chput_hook
  ld de, HCHPU
  ld bc, 5
  ldir
  ret

cmd_chput_hook:
  jp cmd_chput_exec
  nop
  nop

cmd_chput_exec:
  ld a, (SCRMOD)
  cp 2
  ret nz
cmd_chput_exec.1:
    ex (sp), hl
    ld a, 5
    add a, l
    ld l, a
    ex (sp), hl
    ret


; ------------------------------------------------------------------------------------------------------
; USR() IMPLEMENTATION
; https://github.com/Konamiman/MSX2-Technical-Handbook/blob/master/md/Chapter2.md#41-usr-function
; ------------------------------------------------------------------------------------------------------

initialize.usr:
  ld hl, newusrtab
  ld de, USRTAB
  ld bc, 20
  ldir
  ret

newusrtab: dw usr0, usr1, usr2, usr3, usr_def, usr_def, usr_def, usr_def, usr_def, usr_def

; get resource data address
usr0:
  call usr.parm  ; bc = parameter
  jp nz, basic.error
  call resource.address
  jp c, usr_def
  jp usr_def.exit

; get resource data size
usr1:
  call usr.parm  ; bc = parameter
  jp nz, basic.error
  call resource.size
  jp c, usr_def
  jp usr_def.exit

; multi function root
usr2:
  call usr.parm  ; bc = parameter
  ld a, c
  or a
  jr z, usr2_play
  cp 1
  jp z, usr2_inkey
  cp 2
  jp z, usr2_input
  cp 3
  jp z, usr2_pt3status
  jp usr_def


; PLAY() function alternative
usr2_play:
  call usr.parm  ; bc = parameter
  ld e, b
  ld a, (MUSICF)
  dec e
  jp m, usr2.3

usr2.0:
  rrca
  dec e
  jp p, usr2.0
  ld a, 0
  jr nc, usr2.2

usr2.1:
  dec a

usr2.2:
  ld c, a
  rla
  sbc a, a
  ld b, a
  jp usr_def.exit

usr2.3:
  and 7
  jr z, usr2.2
  ld a, 0xff
  jr usr2.2

; INKEY() function alternative
usr2_inkey:
  call CHSNS
  jp z, usr_def

; INPUT() function alternative
usr2_input:
  call CHGET
  ld b, 0
  ld c, a
  jp usr_def.exit

usr2_pt3status:
  di
    ld a, (RAMAD0)
    ld hl, PT3.DATA.STATUS
    call RDSLT                          ; return a = PT3 status
  ei
  xor 1                               ; invert loop flag
  ld b, 0
  ld c, a
  jp usr_def.exit

; sprite collision detection algorithm
; reference:
; https://www.msx.org/forum/development/msx-development/sprite-collision-detection-or-manually-calculation-sprite-coordina
usr3:
  call usr.parm  ; bc = parameter
  ld (DAC), bc
  ;;in a, (0x99)       ; VDP status flag
  ;;ld (STATFL), a
  halt
  ld a, (STATFL)
  bit 5, a           ; collision test
  jr nz, usr3.init
    ld bc, 0xFFFF    ; return false
    jp usr_def.exit

usr3.init:
    ; copy sprite attribute table to ram
    ld hl, (ATRBAS)        ; source: attribute table
    ;ld hl, (GRPATR)        ; source: graphical attribute table
    ;ld hl, (MLTATR)        ; source: msx2 graphical attribute table
    ld de, BUF             ; dest: ram
    ld bc, 128             ; 32*4 = size of attribute table
    call LDIRMV

    ; pre-calculate each sprite width
    call usr3.GetSpriteSize
	ld c, a                     ; sprite size
    ld b, 32                    ; sprite count
	ld d, 208                   ; Y no-display flag
    ld hl, BUF                  ; start of sprites attributes

    ; test screen mode
    ld a, (SCRMOD)
    cp 3           ; above screen 3?
    jp c, usr3.init.next
      ld d, 216    ; Y no-display flag

usr3.init.next:
    ; test IC flag (no collision) in color table
    ; test EC flag (early clock, shift 32 dots to the left) in color table
    ; set x1 = x0 + size, y1 = y0 + size
    ld a, (hl)   ; y0
    cp d         ; test if sprite will not be displayed
    jr z, usr3.init.clear_all_sprite_data
      inc l
      ld e, (hl)   ; x0
      inc l

      ex af, af'
      ld a, (hl)   ; sprite pattern
      cp 32        ; test if pattern = 32
      jr z, usr3.init.clear_sprite_data

      ex af, af'
      add a, c     ; y0 + sprite_size
      ld (hl), a   ; y1
      inc l

      ld a, e      ; x0
      add a, c     ; x0 + sprite_size
      ld (hl), a   ; x1
      inc l

      djnz usr3.init.next
      jp usr3.check.collision

usr3.init.clear_sprite_data:
    dec l
    dec l
    ld (hl), 0xff  ; clear sprite data
    inc l
    inc l
    inc l
    inc l
    djnz usr3.init.next
    jp usr3.check.collision

usr3.init.clear_all_sprite_data:
    ld (hl), 0xff  ; clear sprite data
    inc l
    inc l
    inc l
    inc l
    djnz usr3.init.clear_all_sprite_data

usr3.check.collision:      ; DAC = sprite number
    ld hl, (DAC)

    xor a
    or h                 ; check if direct test of two sprite numbers
    jp z, usr3.check.collision.loop_one      ; test all sprites against this sprite number
      bit 7, h               ; check if sprite number is negative (loop all sprites if so)
      jr nz, usr3.check.collision.loop_all
        jr usr3.check.collision.couple

usr3.check.collision.loop_one:
      call usr3.check.collision.target
      jp usr_def.exit

usr3.check.collision.loop_all:
      ld hl, 0
      ld (DAC), hl

usr3.check.collision.loop.1:
      call usr3.check.collision.target
      ld a, c
      cp 0xFF
      jp nz, usr_def.exit
        ;ld a, (DAC)
        ;inc a
        ;ld (DAC), a
        ld hl, DAC
        inc (hl)
        ld a, (hl)
        cp 32
        jp nz, usr3.check.collision.loop.1   ; check next if current sprite < max sprite number
          jp usr_def.exit

usr3.check.collision.couple:
    call usr3.check.collision.couple.1
    jp usr_def.exit

usr3.check.collision.couple.1:
    ; calculate first sprite address (iy = hl)
    ld a, (DAC)
    ld l, a
    ld h, 0
    ld de, BUF
    add hl, hl            ; x4
    add hl, hl
    add hl, de
    push hl
    pop iy

    ; calculate second sprite address (iy = hl)
    ld a, (DAC+1)
    ld l, a
    ld h, 0
    ld de, BUF
    add hl, hl            ; x4
    add hl, hl
    add hl, de
    push hl
    pop ix

    ; test if x1 > nx and x < nx1 and y1 > ny and y < ny1
    ld a, (ix)   ; ny
    cp 0xFF      ; test if sprite will not be displayed
    jp z, usr3.false

    cp (iy+2)    ; y1
    jp nc, usr3.false

    ld a, (ix+1) ; nx
    cp (iy+3)    ; x1
    jp nc, usr3.false

    ld a, (iy+1) ; x
    cp (ix+3)    ; nx1
    jp nc, usr3.false

    ld a, (iy)   ; y
    cp (ix+2)    ; ny1
    jp nc, usr3.false

    ; if so, return collider sprite (bc)
    ld a, (DAC)
    jp usr3.true     ; return true

usr3.check.collision.target:      ; DAC = sprite number
    ; calculate target sprite address (iy = hl)
    ld hl, (DAC)
    ld de, BUF
    add hl, hl            ; sprite number * 4 + BUF
    add hl, hl
    add hl, de

    ld a, (hl)            ; y0
    cp 0xff               ; check if y0 = 0xFF
    jp z, usr3.false      ; if so, its a no visible sprite

    ld b, a               ; y0
    inc l
    ld c, (hl)            ; x0
    inc l
    ld d, (hl)            ; y1
    inc l
    ld e, (hl)            ; x1

    ; start test against others sprites
    ld hl, BUF
    xor a                 ; initialize sprite counter
    ex af, af'            ; save sprite counter

usr3.check.next:
    ; load next nx0, ny0, nx1, ny1
    ; skip if ny0 = 0xFF
    ; or test if x1 > nx0 and x0 < nx1 and y1 > ny0 and y0 < ny1
    ld a, (hl)            ; ny0
    cp 0xff
    jr z, usr3.check.skip.4

    cp d                  ; jump if ny0 >= y1
    jr nc, usr3.check.skip.4

    inc l

    ; skip if ny0 = y0 and nx0 = x0
    cp b                  ; jump if ny0 <> y0
    ld a, (hl)            ; nx0
    jr nz, usr3.check.next.cont
      cp c                ; jump if nx0 = x0
      jr z, usr3.check.skip.3

usr3.check.next.cont:
    cp e                  ; jump if nx0 >= x1?
    jr nc, usr3.check.skip.3

    inc l
    ld a, b               ; y0
    cp (hl)               ; jump if y0 >= ny
    jr nc, usr3.check.skip.2

    inc l
    ld a, c               ; x0
    cp (hl)               ; jump if  x0 >= nx1
    jr nc, usr3.check.skip.1

    ex af,af'             ; restore sprite counter
    jp usr3.true          ; return true

usr3.check.skip.4:
  inc l
usr3.check.skip.3:
  inc l
usr3.check.skip.2:
  inc l
usr3.check.skip.1:
  inc l
  ex af, af'            ; restore sprite counter
    inc a
    cp 32               ; jump if end of sprite list
    jr z, usr3.false
  ex af, af'            ; save sprite counter
  jp usr3.check.next

  ; else return false
usr3.false:
  ld bc, 0xFFFF    ; return false
  ret

usr3.true:
  ld b, 0
  ld c, a
  ret

usr3.GetSpriteSize:
  push bc
    ld bc, 0x0808
    ld a, (RG1SAV)  		; bit 0 = double size, bit 1 = sprite size (0=8 pixels, 1=16 pixels)
    bit 1, a
    jr z, usr3.GetSpriteSize.1
      ld bc, 0x1010

usr3.GetSpriteSize.1:
    bit 0, a
    jr z, usr3.GetSpriteSize.2
      sll b

usr3.GetSpriteSize.2:
    ld (ARG), bc
    ld a, c
  pop bc
  ret

; default
usr_def:
  ld bc, 0
usr_def.exit:
  ld a, 2
  ld (VALTYP), a
  ld (VALDAT), bc
  ld hl, DAC
  ld de, DAC
  ret

;---------------------------------------------------------------------------------------------------------
; PT3TOOLS support routines
;---------------------------------------------------------------------------------------------------------

initialize.pt3:
  ld hl, resource.data
  ld e, (hl)
  inc hl
  ld d, (hl)   ; de = pt3tools address
  ex de, hl

  ld a, l
  or h
  ret z

  ld de, PT3.LOAD         ; 0x0100
  ld ix, pletter.unpack   ; hl = packed data, de = ram destination
  di
    call jp_with_ram_in_0

    ld ix, PT3.PLAY
    call jp_with_ram_in_0_save
  ei

  ;call page.1.save

  ;call page.1.ram

  ;ld de, 0x4010
  ;call pletter.unpack    ; hl = packed data, de = ram destination

  ;call page.1.restore

  ; now, set hook for pt3

hook.pt3:
    di
      xor a
      ld (PT3STS), a

      ; save old hook
      ld hl, HTIMI       ;OLD HOOK SAVE
	  ld de, PT3HKSAV
	  ld bc, 5
	  ldir

	  ; set new hook
	  ld a, 0xF7          ; rst 0x30 - CALLF
      ld (HTIMI), a
	  ld a, (SLTAD2)      ;ld h, 0x80   ;call page.getslt   ; a = program rom slot
      ld (HTIMI+1), a
      ld hl, int.pt3
	  ld (HTIMI+2), hl
	  ld a, 0xC9          ; ret
	  ld (HTIMI+4), a
    ei
    ret

unhook.pt3:
    di
      ld hl, PT3HKSAV
      ld de, HTIMI
      ld bc, 5
      ldir
    ei
	call GICINI
	ret

int.pt3:
    ;ld (STATFL), a
    push af
      ld a, (PT3STS)
      cp 2             ; play
      jr z, int.pt3.play

      cp 0             ; idle
      jp z, int.pt3.exit

      cp 3             ; mute
      jr z, int.pt3.mute

      cp 1             ; load
      jr z, int.pt3.load

int.pt3.exit:
    pop af
    ;ret
    jp PT3HKSAV

int.pt3.load:
      ld ix, PT3.LOAD_FROM_HL
      ld hl, PT3.DATA.ADDR
      call jp_with_ram_in_0
      xor a          ; idle
      ld (PT3STS), a
    jp int.pt3.exit

int.pt3.play:
      call jp_with_ram_in_0_exec
    pop af
    ;ret
    jp PT3HKSAV

int.pt3.mute:
      xor a          ; idle
      ld (PT3STS), a
      ld ix, PT3.MUTE
      call jp_with_ram_in_0
    jp int.pt3.exit

;---------------------------------------------------------------------------------------------------------
; Support routines
;---------------------------------------------------------------------------------------------------------

; in  a  = vartype
; out bc = parameter as integer
usr.parm:
  ld a,  (VALTYP)
  cp 2             ; integer type
  ld bc, (VALDAT)  ; input integer
  ret

; out: de = resource count
resource.count:
  ld hl, resource.data

  inc hl
  inc hl       ; skip pt3tools address

  ld e, (hl)   ; resource count
  inc hl
  ld d, (hl)
  inc hl

  ret

; in:  bc = resource number
; out: hl = resource address
resource.address:
  call resource.count

  dec de

  ld a, d
  cp b
  ret c       ; return if resource number > resource count
  jr nz, resource.address.next

  ld a, e
  cp c
  ret c       ; return if resource number > resource count

resource.address.next:
  ex de, hl
  ld l, c
  ld h, b
  add hl, hl  ; x2
  add hl, hl  ; x4
  ex de, hl

  add hl, de

  ld e, (hl)  ; get resource address
  inc hl
  ld d, (hl)
  inc hl

  ex de, hl
  xor a
  ret

; in:  bc = resource number
; out: bc = resource size
resource.size:
  call resource.address
  ret c
  ex de, hl
  ld b, (hl)
  inc hl
  ld c, (hl)
  xor a
  ret

; in:  hl = pletter data
;      de = ram address
; out: hl = ram address
;      bc = size
resource.ram.unpack:
  push de
    call pletter.unpack
    exx       ; calculate decoded length (de' point to end of decoded data)
    ex de, hl
  pop de
  push de
    xor a
    sbc hl, de
    ld b, h
    ld c, l                 ; bc = decoded length
  pop hl                    ; hl = decoded data
  ret

savehook:
  push hl
    ld hl,HPRGE
    ld de,PARM2+90
    ld bc,5
    ldir
  pop hl
  ret

resthook:
  push hl
    ld hl,PARM2+90
    ld de,HPRGE
    ld bc,5
    ldir
  pop hl
  ret

; hl = basic code in plain text
; https://www.msx.org/forum/msx-talk/development/invoking-the-basic-interpreter-from-a-ml-program
execbas:
  pop hl
  ld a, 0xC3      ; jp (hl) = ret
  ld (HPRGE), a
  ld (HPRGE+1), hl
  call_basic CRUNCH
  ld hl,RAWPRT
  call_basic NEWSTT
  ret

;---------------------------------------------------------------------------------------------------------
; SLOT / PAGES routines
;---------------------------------------------------------------------------------------------------------

; IX = call address
; A, HL, DE = parms
; needs DI/EI
jp_with_ram_in_0:
  push af
  push hl
  push de
  push bc

    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-3
    ld e, 0xC3    ; jp xx xx
    call WRSLT

    push ix
    pop de
    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-2
    call WRSLT

    push ix
    pop de
    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-1
    ld e, d
    call WRSLT

  pop bc
  pop de
  pop hl
  pop af

  ld iy, (RAMAD0-1)
  ld ix, PT3.DATA.ADDR-3
  jp CALSLT

; IX = call address
jp_with_ram_in_0_save:
  push af
  push hl
  push de
  push bc

    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-6
    ld e, 0xC3    ; jp xx xx
    call WRSLT

    push ix
    pop de
    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-5
    call WRSLT

    push ix
    pop de
    ld a, (RAMAD0)
    ld hl, PT3.DATA.ADDR-4
    ld e, d
    call WRSLT

  pop bc
  pop de
  pop hl
  pop af
  ret

; PT3.DATA.ADDR-6 = saved address to call
jp_with_ram_in_0_exec:
  ld iy, (RAMAD0-1)
  ld ix, PT3.DATA.ADDR-6
  jp CALSLT

if defined PAGE_TOOLS

page.0.save:
  push hl
    ld h, 0x00
    call page.getslt
    ld (SLTAD0), a
  pop hl
  ret

page.0.restore:
  ld a, (SLTAD0)
  ld hl, 0x0000
  call ENASLT              ; restore page 1 slot
  ret

page.0.ram:
  push hl
    ld a, (RAMAD0)
    ld hl, 0x0000
    call ENASLT            ; Select RAM on page 1
  pop hl
  ret

page.1.save:
  push hl
    ld h, 0x40
    call page.getslt
    ld (SLTAD1), a
  pop hl
  ret

page.1.restore:
  ld a, (SLTAD1)
  ld hl, 0x4000
  call ENASLT              ; restore page 1 slot
  ret

page.1.ram:
  push hl
    ld a, (RAMAD1)
    ld hl, 0x4000
    call ENASLT            ; Select RAM on page 1
  pop hl
  ret

endif

; h = memory page
; a <- slot ID formatted FxxxSSPP
; Modifies: af, bc, de, hl
; ref: https://www.msx.org/forum/msx-talk/development/fusion-c-and-htimi#comment-366469
page.getslt:
	call RSLREG
	bit 7,h
	jr z,PrimaryShiftContinue
	rrca
	rrca
	rrca
	rrca
PrimaryShiftContinue:
	bit 6,h
	jr z,PrimaryShiftDone
	rrca
	rrca
PrimaryShiftDone:
	and 00000011B
	ld c,a
	ld b,0
	ex de,hl
	ld hl,EXPTBL
	add hl,bc
	ld c,a
	ld a,(hl)
	and 80H
	or c
	ld c,a
	inc hl  ; move to SLTTBL
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	ex de,hl
	bit 7,h
	jr z,SecondaryShiftContinue
	rrca
	rrca
	rrca
	rrca
SecondaryShiftContinue:
	bit 6,h
	jr nz,SecondaryShiftDone
	rlca
	rlca
SecondaryShiftDone:
	and 00001100B
	or c
	ret

; verify default slots and memory ram
verify.slots:
    ld h, 0x00
    call page.getslt
    ld (SLTAD0), a

    ld h, 0x40
    call page.getslt
    ld (SLTAD1), a

    ld h, 0x80
    call page.getslt
    ld (SLTAD2), a

    ld h, 0xC0
    call page.getslt
    ld (SLTAD3), a

if not defined SEARCH_RAM

    ld (RAMAD0), a      ; presume same slot/subslot of page 3 as RAM of all pages
    ld (RAMAD1), a
    ld (RAMAD2), a
    ld (RAMAD3), a
    ret

else

    jp search.ram

; Routine of search for RAM on each page from MSX cartridge
; Output: RAMAD0-RAMAD3 = Slot number of Main-RAM for corresponding page
; https://www.msx.org/wiki/Develop_a_program_in_cartridge_ROM#Search_for_RAM
search.ram:
def_RAMAD3:
	call RSLREG
	and	0xC0
	rlca
	rlca			; A = Primary slot
	ld c,a
	ld b,0
	ld hl,EXPTBL
	add hl,bc
	ld a,(hl)
	and 0x80
	jr z,No_SS3	; Jump if slot is not secondary (page 3)
	ld hl,SLTTBL
	add hl,bc
	ld a,(hl)		; A = Value of current decondary slots register
	and 0xC0		; Keep the bits for page 3
	rrca
	rrca
	rrca
	rrca			; Bits 2-3 of A = Current secondary slot (page 2)
	or c
	or 0x80		; Set the bit 7
No_SS3:
	ld (RAMAD3),a	; Bit7=1 if extended Slot
def_RAMAD2:
	ld hl,0x8000
	call ram_srch
	ld (RAMAD2),a
def_RAMAD1:
	ld hl,0x4000
	call ram_srch
	ld (RAMAD1),a
def_RAMAD0:
	ld hl,0x0000
	call ram_srch
	ld (RAMAD0),a
    ret

; Search RAM on a page
; Input: HL=0000h, 4000h or 8000h
; output: A=slot number and Carry = 0, Carry = 1 if Ram not found
ram_srch:
	ld b,4       ;Slot primaire
ram_srch_loop:
	ld a,b
	dec a
	xor 3
	ld (RAMSLT),a
	ld e,a
	push hl
	ld hl,EXPTBL
	ld d,0
	add hl,de
	ld a,(hl)
	ld (KBUF),a	 ; Save secondary slot flag
	pop	hl
	ld a,h
	exx
	ld h,a
	ld l,0		; Restore HL address
	ld a,(KBUF)	; Restore secondary slot flag
	rlca
	ld b,1
	ld a,(RAMSLT)
	jr nc,PrimSLT
	ld b,4      ;Slot secondaire
ram_srch_loop2:
	ld	a,b
	dec	a
	xor	3
	rlca
	rlca
	ld	c,a
	ld	a,(RAMSLT)
	or	c
	or	0x80	; Set bit 7
PrimSLT:
	ld	(KBUF+1),a
	push	bc
	call	RDSLT
	ld	(KBUF+2),a
	pop	bc
	cp	0x41
	jr	nz,no_header	; Jump if first byte = "A" (Rom?)
	inc	hl
	ld	a,(KBUF+1)
	push	bc
	call	RDSLT
	pop	bc
	dec	hl
	cp	0x42
	jr	z,no_ram	; Jump if second byte <> "B"
no_header:
	ld	a,(KBUF+1)
	push bc
	call RDSLT		; Read first byte
	pop	bc
	ld	e,0x41
	ld	a,(KBUF+1)
	push bc
	call WRSLT		; Write "A" at first byte
	pop	bc
	ld	a,(KBUF+1)
	push bc
	call RDSLT		; Read first byte
	pop	bc
	cp	0x41
	jr	z,ram_found	; Jump if first byte = "A"
no_ram:
	djnz ram_srch_loop2	; Go to next Slot if No RAM
	exx
	djnz ram_srch_loop	; Go to next Slot if No RAM
	scf			; Set Carry
	ret
ram_found:
	ld	a,(KBUF+2)
	ld	e,a
	ld	a,(KBUF+1)
	push	af
	or 0x80
	call WRSLT		; Restore first byte value of RAM
	pop	af		; A=Slot of Ram found (without Bit7)
	or	a		; Reset Carry
	ret

endif

;---------------------------------------------------------------------------------------------------------
; VDP / VRAM support routines
;---------------------------------------------------------------------------------------------------------

if defined VDP_ROUTINES

; WRITE TO VDP
; in b = data
;    c = register number
;    a = register number
gfxWRTVDP:
  bit 7, a
  ret nz                ; is negative? read only
  cp 8
  ret z                 ; is register 8? then status register 0 (read only)
  jr nc, gfxWRTVDP.1    ; is > 8? then control registers numbers added 1
  jr gfxWRTVDP.3
gfxWRTVDP.1:
  ld ix, SCRMOD
  bit 3, (ix)
  jr nz, gfxWRTVDP.2
  bit 2, (ix)
  jr nz, gfxWRTVDP.2
  ret
gfxWRTVDP.2:
  dec a
  ld c, a
gfxWRTVDP.3:
  jp WRTVDP        ; msx 1

; READ FROM VDP
; in  a = register number
; out a = data
gfxRDVDP:
  bit 7, a
  jr nz, gfxRDVDP.1     ; is negative? then status register 1 to 9
  cp 8
  jr z,  gfxRDVDP.2     ; is register 8? then status register 0
  cp 9
  jr nc, gfxRDVDP.3     ; is >= 9? then control registers numbers added 1
    ld hl, RG0SAV       ; else is correct control registers numbers
    jr gfxRDVDP.4
gfxRDVDP.1:
  ld ix, SCRMOD
  bit 3, (ix)
  jr nz, gfxRDVDP.1.a
  bit 2, (ix)
  jr nz, gfxRDVDP.1.a
  xor a
  ret
gfxRDVDP.1.a:
  neg
  jp NRDVDP   ;BIOS_VDPSTA
gfxRDVDP.2:
  ld a, (STATFL)
  ret
  ;xor a
  ;jp BIOS_VDPSTA
gfxRDVDP.3:
  ld hl, RG8SAV-9
gfxRDVDP.4:
  ld d, 0
  ld e, a
  add hl,de
  ld a, (hl)
  ret

endif

; in: A=Sprite pattern number
; out: HL=Sprite pattern address
gfxCALPAT:
  ld iy, SCRMOD
  ld ix, CALPAT2
  bit 3, (iy)
  jp nz, EXTROM
  bit 2, (iy)
  jp nz, EXTROM
  jp CALPAT

; in: A=Sprite number
; out: HL=Sprite attribute address
gfxCALATR:
  ld iy, SCRMOD
  ld ix, CALATR2
  bit 3, (iy)
  jp nz, EXTROM
  bit 2, (iy)
  jp nz, EXTROM
  jp CALATR

; in:  A = sprite number
; out: HL = address to color table
gfxCALCOL:
  push af
  push de
    ld h, 0
    ld l, a         ; recover sprite number
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl      ; multiply by 16 (shift left 4)
    push hl
      xor a
      call gfxCALATR    ; get sprite attribute table address
    pop de
    add hl, de
    xor a
    ld de, 512
    sbc hl, de      ; address of color table from sprite multicolor
  pop de
  pop af
  ret

if defined SPRITES_ROUTINES

; out: A=Bytes in sprite pattern (8 or 32)
gfxGSPSIZ:
  ld iy, SCRMOD
  ld ix, GSPSIZ2
  bit 3, (iy)
  jp nz, EXTROM
  bit 2, (iy)
  jp nz, EXTROM
  jp GSPSIZ

gfxCLRSPR:
  ld iy, SCRMOD
  ld ix, CLRSPR2
  bit 3, (iy)
  jp nz, EXTROM
  bit 2, (iy)
  jp nz, EXTROM
  jp CLRSPR

endif

; RAM to VRAM (needs DI/EI)
; in: BC=Length, dest DE=VRAM address, source HL=RAM address
gfxLDIRVM:
  ex      de,hl
  ;xor a           ; initialize (msx2)
  ;out (99H),A
  ;ld A,8EH
  ;out (99H),A
  ;ld A,L
  ;out (99H),A
  ;ld A,H
  ;and 3FH         ; "?"
  ;or 40H          ; "@"
  ;out (99H),A
  ld a,l           ; initialize (msx1)
  out     (099H),a
  ld      a,h
  and     03FH
  or      040H
  out     (099H),a
gfxLDIRVM.loop:
  ld      a,(de)
  out     (098H),a
  inc     de
  dec     bc
  ld      a,c
  or      b
  jr      nz, gfxLDIRVM.loop
  ret

if defined VRAM_ROUTINES

; RAM to VRAM
; in: BC=Length, dest DE=VRAM address, source HL=RAM address
;gfxLDIRVM:
;  jp LDIRVM

; VRAM to RAM
; in: BC=Length, dest DE=RAM address, source HL=VRAM address
gfxLDIRMV:
  jp LDIRMV

; in: A=Data byte, BC=Length, HL=VRAM address
gfxFILVRM:
  ld ix, SCRMOD
  bit 3, (ix)
  jp nz, BIGFIL
  bit 2, (ix)
  jp nz, BIGFIL
  jp FILVRM

; WRITE TO VRAM
; in hl = address
;     a = data
gfxWRTVRM:
  ld ix, SCRMOD
  bit 3, (ix)
  jp nz, NWRVRM
  bit 2, (ix)
  jp nz, NWRVRM
  jp WRTVRM

; READ FROM VRAM
; in hl = address
; out a = data
gfxRDVRM:
  ld ix, SCRMOD
  bit 3, (ix)
  jp nz, NRDVRM
  bit 2, (ix)
  jp nz, NRDVRM
  jp RDVRM

endif

;---------------------------------------------------------------------------------------------------------
; Pletter v0.5b VRAM Depacker v1.1 - 16Kb version (by metalion@orange.fr)
; https://www.msx.org/forum/development/msx-development/bitbuster-depack-vram?page=0
; HL = RAM/ROM source ; DE = VRAM destination
; note: it is limited to 0000h - 3FFFh VRAM addresses
;---------------------------------------------------------------------------------------------------------

if defined VPLETTER

vpletter.unpack:
  di

; VRAM address setup
  ld a,e
  out (099h),a
  ld a,d
  or 040h
  out (099h),a

; Initialization
  ld a,(hl)
  inc hl
  exx
  ld de,0
  add a,a
  inc a
  rl e
  add a,a
  rl e
  add a,a
  rl e
  rl e
  ld hl, vpletter.modes
  add hl,de
  ld e,(hl)
  ld ixl,e
  inc hl
  ld e,(hl)
  ld ixh,e
  ld e,1
  exx
  ld iy, vpletter.loop

; Main depack loop
vpletter.literal:
  ld c,098h
  outi
  inc de
vpletter.loop:
  add a,a
  call z, vpletter.getbit
  jr nc, vpletter.literal

; Compressed data
  exx
  ld h,d
  ld l,e
vpletter.getlen:
  add a,a
  call z, vpletter.getbitexx
  jr nc, vpletter.lenok
vpletter.lus:
  add a,a
  call z, vpletter.getbitexx
  adc hl,hl
  ret c
  add a,a
  call z, vpletter.getbitexx
  jr nc, vpletter.lenok
  add a,a
  call z, vpletter.getbitexx
  adc hl,hl
  jp c, vpletter.Depack_out
  add a,a
  call z, vpletter.getbitexx
  jp c, vpletter.lus
vpletter.lenok:
  inc hl
  exx
  ld c,(hl)
  inc hl
  ld b,0
  bit 7,c
  jp z, vpletter.offsok
  push ix
  ret      ;  jp ix

vpletter.mode7:
  add a,a
  call z, vpletter.getbit
  rl b
vpletter.mode6:
  add a,a
  call z, vpletter.getbit
  rl b
vpletter.mode5:
  add a,a
  call z, vpletter.getbit
  rl b
vpletter.mode4:
  add a,a
  call z, vpletter.getbit
  rl b
vpletter.mode3:
  add a,a
  call z, vpletter.getbit
  rl b
vpletter.mode2:
  add a,a
  call z, vpletter.getbit
  rl b
  add a,a
  call z, vpletter.getbit
  jr nc, vpletter.offsok
  or a
  inc b
  res 7,c
vpletter.offsok:
  inc bc
  push hl
  exx
  push hl
  exx
  ld l,e
  ld h,d
  sbc hl,bc
  pop bc
  push af
vpletter.loop2:
  ld a,l
  out (099h),a
  ld a,h
  nop                     ; VDP timing
  out (099h),a
  nop                     ; VDP timing
  in a,(098h)
  ex af,af'
  ld a,e
  nop                     ; VDP timing
  out (099h),a
  ld a,d
  or 040h
  out (099h),a
  ex af,af'
  nop                     ; VDP timing
  out (098h),a
  inc de
  cpi
  jp pe, vpletter.loop2
  pop af
  pop hl
  push iy
  ret      ; jp iy

vpletter.getbit:
  ld a,(hl)
  inc hl
  rla
  ret

vpletter.getbitexx:
  exx
  ld a,(hl)
  inc hl
  exx
  rla
  ret

; Depacker exit
vpletter.Depack_out:
  ei
  ret

vpletter.modes:
  dw vpletter.offsok
  dw vpletter.mode2
  dw vpletter.mode3
  dw vpletter.mode4
  dw vpletter.mode5
  dw vpletter.mode6
  dw vpletter.mode7

endif

;---------------------------------------------------------------------------------------------------------
; Pletter v0.5c1 adapted from XL2S Entertainment 2008
; https://github.com/nanochess/Pletter
; PLETTER UNPACKED RAM TO RAM
; HL = packed data in RAM, DE = destination in RAM
; define lengthindata when the original size is written in the pletter data
; define LENGTHINDATA
;---------------------------------------------------------------------------------------------------------

  macro PLETTER.GETBIT
    add a,a
    call z,pletter.getbit
  endm

  macro PLETTER.GETBITEXX
    add a,a
    call z,pletter.getbitexx
  endm

pletter.modes
  dw pletter.offsok
  dw pletter.mode2
  dw pletter.mode3
  dw pletter.mode4
  dw pletter.mode5
  dw pletter.mode6

pletter.unpack:

  if defined LENGTHINDATA
    inc hl
    inc hl
  endif

  ld a,(hl)
  inc hl
  exx
  ld de,0
  add a,a
  inc a
  rl e
  add a,a
  rl e
  add a,a
  rl e
  rl e
  ld hl,pletter.modes
  add hl,de
  ld e,(hl)
  ld ixl,e
  inc hl
  ld e,(hl)
  ld ixh,e
  ld e,1
  exx
  ld iy,pletter.loop
pletter.literal:
  ldi
pletter.loop:
  PLETTER.GETBIT
  jr nc,pletter.literal
  exx
  ld h,d
  ld l,e
pletter.getlen:
  PLETTER.GETBITEXX
  jr nc,pletter.lenok
pletter.lus:
  PLETTER.GETBITEXX
  adc hl,hl
  ret c
  PLETTER.GETBITEXX
  jr nc,pletter.lenok
  PLETTER.GETBITEXX
  adc hl,hl
  ret c
  PLETTER.GETBITEXX
  jp c,pletter.lus
pletter.lenok
  inc hl
  exx
  ld c,(hl)
  inc hl
  ld b,0
  bit 7,c
  jp z,pletter.offsok
  push ix
  ret       ;jp ix

pletter.mode6
  PLETTER.GETBIT
  rl b
pletter.mode5
  PLETTER.GETBIT
  rl b
pletter.mode4
  PLETTER.GETBIT
  rl b
pletter.mode3
  PLETTER.GETBIT
  rl b
pletter.mode2
  PLETTER.GETBIT
  rl b
  PLETTER.GETBIT
  jr nc,pletter.offsok
  or a
  inc b
  res 7,c
pletter.offsok
  inc bc
  push hl
  exx
  push hl
  exx
  ld l,e
  ld h,d
  sbc hl,bc
  pop bc
  ldir
  pop hl
  ;jp iy
  push iy
  ret

pletter.getbit
  ld a,(hl)
  inc hl
  rla
  ret

pletter.getbitexx
  exx
  ld a,(hl)
  inc hl
  exx
  rla
  ret

if defined FUNCT_TOOLS

;--- Obtain slot work area (8 bytes) on SLTWRK
; Input: A = Slot number
; Output: HL = Work area address
; Modifies: AF, BC
getwrk:
  ld b,a
  rrca
  rrca
  rrca
  and %01100000
  ld c,a ;C = Slot * 32
  ld a,b
  rlca
  and %00011000 ;A = Subslot * 8
  or c
  ld c,a
  ld b,0
  ld hl,SLTWRK
  add hl,bc
  ret

endif

;---------------------------------------------------------------------------------------------------------

resource.data:
