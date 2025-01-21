## pico680b-mikbug09subset-tester<BR>

picobug is bellow.
https://github.com/simple-circuit/picobug
(I love this Altair 680b simulator with prom monitor clone)<BR>

I try several times to make mikbug and minibug work on picobug. But I did not complete because picobug's ino's Stack frame was not same with swtpc or mikbug 's one.<BR>
I have no time to complete these work all in short period.
So this made for testing mikbug's routines on picobug memory.
<BR>
How to use this repo's asm and s19
1. L on picobug
2. send mikb09.s19 via teraterm of your terminal.
3. J 0300
4. Then * prompts.
5. Implemented Commands: L(G has not yet, so not well tested), M, R
6. Assemble command
    a68 mikb09.asm -l mikb09.lst -s mikb09.s19
<BR>
[Update 20250119 19:28]<BR>
mikb091 is P command available.<BR>
if you use this, please set BEGA and ENDA on STack. BEGA is on 0002 and ENDA is on 0004.<BR>
Unfortunately if you set these with M command, if protected area, it cloud not do.<BR>
So, I moved Vars on EQU 0000. I test M command could change memory value.<BR>
If vars on rom area(ex: FFFE) it cloud not be change, because picobug wipe and paste it.<BR>
G command not yet...
[Update 20250121 18:06]<BR>
mikb092 is J command available.<BR>
implementation (brief): <BR>
<PRE>
BSR BADDR
JMP X
</PRE>
tested with https://github.com/cobwebkanamachi/pico680b-echoback's s19 file (L then J 0100).<BR>
inspired with https://deramp.com/downloads/mfe_archive/010-S100%20Computers%20and%20Boards/00-MITS/99-Non-S100%20Systems/Altair%20680%20family/11-Altair%20680b/680b%20Manual/Altair%20680b%2099-%20System%20Monitor%20Manual.pdf<BR>
TEST seq.<BR><PRE>
>L
upload this s19
>J 0300
*L
upload echoback's s19
*J 0100
echoback works.</PRE>
No Warranty, esp. SWI, Hardware interrupt would be tainted(because picobug's stack structure is not same with mikbug).<BR>
Enjoy!<BR>


