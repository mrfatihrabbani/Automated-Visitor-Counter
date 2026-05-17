#define __SFR_OFFSET 0
#include "avr/io.h"

#define OCCUPANCY_COUNT 0x0202
#define ALARM_ACTIVE    0x0203
#define ENTRY_LOCK      0x0204  
#define EXIT_LOCK       0x0205
#define LOCK_PRESCALER  0x0206

#define GREEN_LED   4       
#define RED_LED     5       
#define BUZZER_PIN  1       

#define LCD_I2C_ADDR    0x4E    
#define LCD_RS          0x01
#define LCD_E           0x04
#define LCD_BACKLIGHT   0x08

.extern I2C_start
.extern I2C_stop
.extern I2C_write

.global display_timer_init
.global TIMER0_OVF_vect
.global lcd_init              
.global lcd_refresh           

display_timer_init:
    SBI     DDRB, RED_LED
    SBI     DDRB, GREEN_LED
    SBI     DDRC, BUZZER_PIN

    SBI     PORTB, GREEN_LED
    CBI     PORTB, RED_LED
    CBI     PORTC, BUZZER_PIN

    CLR     R16
    OUT     TCCR0A, R16
    LDI     R16, (1<<CS01)|(1<<CS00)  
    OUT     TCCR0B, R16
    LDI     R16, (1<<TOIE0)
    STS     TIMSK0, R16

    // Initialize prescaler
    LDI     R16, 10
    STS     LOCK_PRESCALER, R16
    RET

TIMER0_OVF_vect:
    PUSH    R16
    IN      R16, SREG
    PUSH    R16

    lds     R16, ALARM_ACTIVE
    cpi     R16, 1
    breq    alarm_on

alarm_off:
    SBI     PORTB, GREEN_LED
    CBI     PORTB, RED_LED
    CBI     PORTC, BUZZER_PIN
    rjmp    isr_done

alarm_on:
    CBI     PORTB, GREEN_LED
    SBI     PORTB, RED_LED
    SBI     PORTC, BUZZER_PIN
    
isr_done:
    POP     R16
    OUT     SREG, R16
    POP     R16
    RETI

lcd_init:
    rcall   delay_long
    ldi     r22, 0x30
    rcall   lcd_send_nibble_init
    rcall   delay_long
    ldi     r22, 0x30
    rcall   lcd_send_nibble_init
    rcall   delay_long
    ldi     r22, 0x30
    rcall   lcd_send_nibble_init
    
    ldi     r22, 0x20           
    rcall   lcd_send_nibble_init
    rcall   delay_long

    ldi     r24, 0x28           
    rcall   lcd_command
    ldi     r24, 0x0C           
    rcall   lcd_command
    ldi     r24, 0x01           
    rcall   lcd_command
    rcall   delay_long
    ret

lcd_refresh:
    ldi     r24, 0x80           
    rcall   lcd_command
    ldi     r30, lo8(str_line1)
    ldi     r31, hi8(str_line1)
    rcall   lcd_print_string

    lds     r24, OCCUPANCY_COUNT
    mov     r18, r24
    
    ldi     r19, 100            
    rcall   convert_digit
    ldi     r19, 10             
    rcall   convert_digit
    
    mov     r24, r18            
    subi    r24, -'0'
    rcall   lcd_data

    ldi     r24, ' '
    rcall   lcd_data

    ldi     r24, 0xC0           
    rcall   lcd_command

    lds     r16, ALARM_ACTIVE
    cpi     r16, 1
    breq    draw_limit_hit

draw_not_reached:
    ldi     r30, lo8(str_normal)
    ldi     r31, hi8(str_normal)
    rcall   lcd_print_string
    ret

draw_limit_hit:
    ldi     r30, lo8(str_alarm)
    ldi     r31, hi8(str_alarm)
    rcall   lcd_print_string
    ret

convert_digit:
    clr     r20
digit_loop:
    cp      r18, r19
    brlo    digit_done
    sub     r18, r19
    inc     r20
    rjmp    digit_loop
digit_done:
    mov     r24, r20
    subi    r24, -'0'
    rcall   lcd_data
    ret

lcd_print_string:
    lpm     r24, Z+
    tst     r24
    breq    lcd_str_exit
    rcall   lcd_data
    rjmp    lcd_print_string
lcd_str_exit:
    ret

lcd_command:
    push    r24
    mov     r22, r24
    andi    r22, 0xF0           
    rcall   lcd_send_nibble
    pop     r24
    swap    r24                 
    andi    r24, 0xF0           
    mov     r22, r24
    rcall   lcd_send_nibble
    ret

lcd_data:
    push    r24
    mov     r22, r24
    andi    r22, 0xF0
    ori     r22, LCD_RS         
    rcall   lcd_send_nibble
    pop     r24
    swap    r24
    andi    r24, 0xF0
    ori     r24, LCD_RS         
    mov     r22, r24
    rcall   lcd_send_nibble
    ret

lcd_send_nibble:
    ori     r22, LCD_BACKLIGHT
    rcall   I2C_start
    ldi     r27, LCD_I2C_ADDR
    rcall   I2C_write          

    mov     r27, r22
    rcall   I2C_write
    rcall   delay_short        
    
    ori     r27, LCD_E
    rcall   I2C_write
    rcall   delay_short        
    
    mov     r27, r22
    rcall   I2C_write
    rcall   delay_short        
    
    rcall   I2C_stop
    ret

lcd_send_nibble_init:
    ori     r22, LCD_BACKLIGHT
    rcall   I2C_start
    ldi     r27, LCD_I2C_ADDR
    rcall   I2C_write          

    mov     r27, r22
    rcall   I2C_write
    rcall   delay_short
    
    ori     r27, LCD_E
    rcall   I2C_write
    rcall   delay_short
    
    mov     r27, r22
    rcall   I2C_write
    rcall   delay_short
    
    rcall   I2C_stop
    rcall   delay_long
    ret

delay_short:
    ldi     r24, 180            
ds_l:
    dec     r24
    brne    ds_l
    ret

delay_long:
    ldi     r24, 0xFF
dl_o:
    ldi     r22, 0xFF
dl_i:
    dec     r22
    brne    dl_i
    dec     r24
    brne    dl_o
    ret

.p2align 1  
str_line1:  
    .ascii "visitors:\0"
str_normal: 
    .ascii "limit:5      \0"
str_alarm:  
    .ascii "limit:5(HIT!)\0"
