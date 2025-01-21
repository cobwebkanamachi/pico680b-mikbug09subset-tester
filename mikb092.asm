* fragments of MIKBUG 0.9
* cf. https://tms9918.hatenablog.com/entry/2023/03/27/212510
ACIACS  EQU $f000
ACIADA  EQU $f001
STRAPS  EQU $f003
VAR EQU $0000
;
;   OPT MEMORY
    ORG $0300
    JMP START

;   L COMMAND
LOAD    EQU *
    LDAA    #$0D
    BSR OUTCH
    NOP
    LDAA    #$0A
    BSR OUTCH
;
;   CHECK TYPE
LOAD3   BSR INCH
    CMPA    #'S'
    BNE LOAD3   ;1ST CHAR NOT (S)
    BSR INCH    ;READ CHAR
    CMPA    #'9'
    BEQ LOAD21  ;START ADDRESS
    CMPA    #'1'
    BNE LOAD3   ;2ND CHAR NOT (1)
    CLR CKSM    ;ZERO CHECKSUM
    BSR BYTE    ;READ BYTE
    SUBA    #2
    STAA    BYTECT  ;BYTE COUNT
;
;   BUILD ADDRESS
    BSR BADDR
;
;   STORE DATA
LOAD11  BSR BYTE
    DEC BYTECT
    BEQ LOAD15  ;ZERO BYTE COUNT
    STAA    X   ;STORE DATA
    INX
    BRA LOAD11
;
;   ZERO BYTE COUNT
LOAD15  INC CKSM
    BEQ LOAD3
LOAD19  LDAA    #'?'    ;PRINT QUESTION MARK
    BSR OUTCH
LOAD21  EQU *
C1  JMP CONTRL

* BUILD ADDRESS
;   CHANGE MENORY (M AAAA DD NN)
BADDR  BSR    BYTE     ;READ 2 FRAMES
       STA A  XHI
       BSR    BYTE
       STA A  XLOW
       LDX    XHI      ;(X) ADDRESS WE BUILT
       RTS

* INPUT BYTE (TWO FRAMES)
BYTE   BSR    INHEX    ;GET HEX CHAR
       ASL A
       ASL A
       ASL A
       ASL A
       TAB
       BSR    INHEX
       AND A  #$0F     ;MASK TO 4 BITS
       ABA
       TAB
       ADD B  CKSM
       STA B  CKSM
       RTS

OUTHL   LSRA    ;OUT HEX LEFT BCD DIGIT
    LSRA
    LSRA
    LSRA
OUTHR   ANDA    #$F ;OUT HEX RIGHT BCD DIGIT
    ADDA    #$30
    CMPA    #$39
    BLS OUTCH
    ADDA    #$7
;
;   OUTPUT ONE CHAR
OUTCH   JMP OUTEEE
INCH    JMP INEEE
;
;   PRINT DATA POINTED AT BY X-REG
PDATA2  BSR OUTCH
    INX
PDATA1  LDAA    X
    CMPA    #4
    BNE PDATA2
    RTS     ;STOP ON EOT

* CHANGE MEMORY (M AAAA DD NN)
CHANGE  BSR BADDR   ;BUILD ADDRESS
CHA51   LDX #MCL
    BSR PDATA1  ;C/R L/F
    LDX #XHI
    BSR OUT4HS  ;PRINT ADDRESS
    LDX XHI
    BSR OUT2HS  ;PRINT DATA (OLD)
    STX XHI ;SAVE DATA ADDRESS
    ;BSR INCH    ;INPUT ONE CHAR
    ;CMPA    #$20
    ;BNE CHA51   ;NOT SPACE
    BSR BYTE    ;INPUT NEW DATA
    DEX
    STAA    X   ;CHANGE MEMORY
    CMPA    X
    BEQ CHA51   ;DID CHANGE
    BRA LOAD19  ;NOT CHANGED
;CHANGE BSR    BADDR    ;BUILD ADDRESS
;CHA52  BSR    OUTS     ;PRINT SPACE
;       BSR    OUT2HS
;       BSR    BYTE
;       DEX
;       ;JSR    SAV
;       STA A  X
;       CMP A  X
;       BEQ    CHK   ;MEMORY DID NOT CHANGE
;ADR    ;JSR    BAK 
;       ;INC    1,X
;       BSR    OUT4HS
;       BRA    CHA52
;CHK    BSR INCH    ;INPUT ONE CHAR
;       CMPA   #$1b
;       BEQ    EXT   ;EXIT
;       BRA    ADR
;EXT    JMP    CONTRL

INHEX   BSR INCH
    SUBA    #$30
    BMI C1  ;NOT HEX
    CMPA    #$09
    BLE IN1HG
    CMPA    #$11
    BMI C1  ;NOT HEX
    CMPA    #$16
    BGT C1  ;NOT HEX
    SUBA    #7
IN1HG   RTS
;
;   OUTPUT 2 HEX CHAR
OUT2H   LDAA    0,X ;OUTPUT 2 HEX CHAR
OUT2HA  BSR OUTHL   ;OUT LEFT HEX CHAR
    LDAA    0,X
    INX
    BRA OUTHR   ;OUTPUT RIGHT HEX CHAR AND R
;
;   OUTPUT 2-4 HEX CHAR + SPACE
OUT4HS  BSR OUT2H   ;OUTPUT 4 HEX CHAR + SPACE
OUT2HS  BSR OUT2H   ;OUTPUT 2 HEX CHAR + SPACE
;
;   OUTPUT SPACE
OUTS    LDAA    #$20    ;SPACE
    BRA OUTCH   ;(BSR & RTS)
;
;   ENTER POWER  ON SEQUENCE
START   EQU *
    LDS $00F3
    ;STS $00F3;SP  ;INZ TARGET'S STACK PNTR
;
;   ACIA INITIALIZE
    LDAA    #$03    ;RESET CODE
    STAA    ACIACS
    NOP
    NOP
    NOP
    LDAA    #$15    ;8N1 NON-INTERRUPT
        STAA    ACIACS
;
;   COMMAND CONTROL
;   COMMAND CONTROL
CONTRL  LDS #STACK  ;SET CONTRL STACK POINTER
    LDX #MCL
    BSR PDATA1  ;PRINT DATA STRING
    BSR INCH    ;READ CHARACTER
    TAB
    BSR OUTS    ;PRINT SPACE
    CMPB    #'L'
    BNE *+5
    JMP LOAD
    CMPB    #'M'
    BEQ CHANGE
    CMPB    #'R'
    BEQ PRINT   ;STACK
    CMPB    #'P'
    BNE *+5
    JMP PUNCH
    ;BEQ PUNCH   ;PRINT/PUNCH
    CMPB    #'J'
    BNE CONTRL
    JSR BADDR
    JMP X
    ;LDS SP  ;RESTORE PGM'S STACK PTR
    JMP CONTRL
    ;SWI ; GO
    ;swi
    
;   PRINT CONTENTS OF STACK
PRINT   LDX SP
    INX
    BSR OUT2HS  ;CONDITION CODES
    BSR OUT2HS  ;ACC-B
    BSR OUT2HS  ;ACC-A
    BSR OUT4HS  ;X-REG
    BSR OUT4HS  ;P-COUNTER
    LDX #SP
    BSR OUT4HS  ;STACK POINTER
C2  JMP CONTRL
;
MCL FCB $D,$A,'*',4
;
;   SAVE X REGISTER
SAV STX XTEMP
    RTS
BAK LDX #XTEMP
    RTS
;
;   INPUT ONE CHAR INTO A-REGISTER
INEEE
    BSR SAV
IN1 LDAA    ACIACS
    ASRA
    BCC IN1 ;RECEIVE NOT READY
    LDAA    STRAPS  ;INPUT CHARACTER
    ANDA    #$7F    ;RESET PARITY BIT
    CMPA    #$7F
    BEQ IN1 ;IF RUBOUT, GET NEXT CHAR
    BSR OUTEEE
    RTS
;
;   OUTPUT ONE CHAR 
OUTEEE  PSH A
OUTEEE1 LDA A   ACIACS
    ASR A
    ASR A
    BCC OUTEEE1
    PUL A
    STA A   ACIADA
    RTS

;
;   PUNCH DUMP
;   PUNCH FROM BEGINING ADDRESS (BEGA) THRU ENDI
;   ADDRESS (ENDA)
MTAPE1  FCB $D,$A,'S','1',4 ;PUNCH FORMAT
    FCB 1,1,1,1 ;GRUE
PUNCH   EQU *
    LDX BEGA
    STX TW  ;TEMP BEGINING ADDRESS
PUN11   LDAA    ENDA+1
    SUBA    TW+1
    LDAB    ENDA
    SBCB    TW
    BNE PUN22
    CMPA    #16
    BCS PUN23
PUN22   LDAA    #15
PUN23   ADDA    #4
    STAA    MCONT   ;FRAME COUNT THIS RECORD
    SUBA    #3
    STAA    TEMP    ;BYTE COUNT THIS RECORD
;
;   PUNCH C/R,L/F,NULL,S,1
    LDX #MTAPE1
    JSR PDATA1
    CLRB        ;ZERO CHECKSUM
;
;   PUNCH FRAME COUNT
    LDX #MCONT
    BSR PUNT2   ;PUNCH 2 HEX CHAR
;
;   PUNCH ADDRESS
    LDX #TW
    BSR PUNT2
    BSR PUNT2
;
;   PUNCH DATA
    LDX TW
PUN32   BSR PUNT2   ;PUNCH ONE BYTE (2 FRAMES)
    DEC TEMP    ;DEC BYTE COUNT
    BNE PUN32
    STX TW
    COMB
    PSHB
    TSX
    BSR PUNT2   ;PUNCH CHECKSUM
    PULB        ;RESTORE STACK
    LDX TW
    DEX
    CPX ENDA
    BNE PUN11
    JMP CONTRL  ;JMP TO CONTRL
;
;   PUNCH 2 HEX CHAR UPDATE CHECKSUM
PUNT2   ADDB    0,X ;UPDATE CHECKSUM
    JMP OUT2H   ;OUTPUT TWO HEX CHAR AND RTS

;
;   VECTOR
    ORG $FFFE
;    FDB IO
;    FDB SFE
;    FDB POWDWN
    FDB START

        ORG    VAR
IOV     RMB    2         ;IO INTERRUPT POINTER
BEGA    RMB    2         ;BEGINING ADDR PRINT/PUNCH
ENDA    RMB    2         ;ENDING ADDR PRINT/PUNCH
NIO     RMB    2         ;NMI INTERRUPT POINTER
SP      RMB    1         ;S-HIGH
        RMB    1         ;S-LOW
CKSM    RMB    1         ;CHECKSUM

BYTECT  RMB    1         ;BYTE COUNT
XHI     RMB    1         ;XREG HIGH
XLOW    RMB    1         ;XREG LOW
TEMP    RMB    1         ;CHAR COUNT (INADD)
TW      RMB    2         ;TEMP
MCONT   RMB    1         ;TEMP
XTEMP   RMB    2         ;X-REG TEMP STORAGE
        RMB    46
STACK   RMB    1         ;STACK POINTER

        END
