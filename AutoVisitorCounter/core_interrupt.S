#define __SFR_OFFSET 0
#include "avr/io.h"

#define ENTRY_FLAG  0x0200
#define EXIT_FLAG   0x0201

.global interrupt_init
.global INT0_vect
.global INT1_vect

interrupt_init:
    cbi     DDRD, 2
    cbi     DDRD, 3
    sbi     PORTD, 2        
    sbi     PORTD, 3        
 
    ldi     r16, (1<<ISC01)|(1<<ISC11)
    sts     EICRA, r16
   
    ldi     r16, (1<<INT0)|(1<<INT1)
    out     EIMSK, r16
    ret

INT0_vect:
    push    r16
    in      r16, SREG
    push    r16
    
    ldi     r16, 1
    sts     ENTRY_FLAG, r16
    
    in      r16, EIMSK
    andi    r16, ~(1<<INT0)
    out     EIMSK, r16
    
    pop     r16
    out     SREG, r16
    pop     r16
    reti

INT1_vect:
    push    r16
    in      r16, SREG
    push    r16
    
    ldi     r16, 1
    sts     EXIT_FLAG, r16
    
    in      r16, EIMSK
    andi    r16, ~(1<<INT1)
    out     EIMSK, r16
    
    pop     r16
    out     SREG, r16
    pop     r16
    reti
