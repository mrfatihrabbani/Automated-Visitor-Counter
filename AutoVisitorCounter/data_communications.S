#define __SFR_OFFSET 0
#include "avr/io.h"

#define ENTRY_FLAG      0x0200
#define EXIT_FLAG       0x0201
#define OCCUPANCY_COUNT 0x0202
#define ALARM_ACTIVE    0x0203
#define EEP_PTR         0x0100
#define RTC_SEC         0x0110
#define RTC_MIN         0x0111
#define RTC_HOUR        0x0112

#define EEP_COUNT_ADDR_H  0x03
#define EEP_COUNT_ADDR_L  0xFF

#define LIMIT           5
#define DS3231_W        0xD0
#define DS3231_R        0xD1

.extern lcd_refresh

.global I2C_start
.global I2C_stop
.global I2C_write
.global data_init
.global process_flags
.global EEPROM_restore

data_init:
    clr     r16
    sts     UCSR0A, r16
    sts     UBRR0H, r16
    ldi     r16, 103
    sts     UBRR0L, r16
    ldi     r16, (1<<TXEN0)|(1<<RXEN0)
    sts     UCSR0B, r16
    ldi     r16, (1<<UCSZ01)|(1<<UCSZ00)
    sts     UCSR0C, r16

    clr     r21
    sts     TWSR, r21
    ldi     r21, 12             
    sts     TWBR, r21
    ldi     r21, (1<<TWEN)
    sts     TWCR, r21
    ret

EEPROM_restore:
    ldi     r16, EEP_COUNT_ADDR_H
    ldi     r20, EEP_COUNT_ADDR_L
    rcall   EEPROM_read
    sts     OCCUPANCY_COUNT, r18

    mov     r19, r18
    rcall   check_limit

    clr     r20
    clr     r16
scan_log:
    cpi     r16, EEP_COUNT_ADDR_H
    brne    execute_read           
    cpi     r20, EEP_COUNT_ADDR_L
    breq    scan_done              

execute_read:
    rcall   EEPROM_read            
    cpi     r18, 0xFF             
    breq    scan_done             

scan_next:
    inc     r20                    
    brne    scan_log               
    inc     r16                   
    rjmp    scan_log

scan_done:
    sts     EEP_PTR,   r20
    sts     EEP_PTR+1, r16
    ret

process_flags:
    lds     r17, ENTRY_FLAG
    cpi     r17, 1
    brne    check_exit

    lds     r19, OCCUPANCY_COUNT
    inc     r19
    sts     OCCUPANCY_COUNT, r19

    rcall   check_limit
    rcall   EEPROM_save_count
    rcall   get_RTC
    ldi     r18, 1
    rcall   log_event
    rcall   lcd_refresh      
    rcall   send_entry

wait_entry_release:
    sbis    PIND, 2        
    rjmp    wait_entry_release  

    ldi     r24, 255
d_rel1:
    ldi     r25, 255
d_rel2:
    dec     r25
    brne    d_rel2
    dec     r24
    brne    d_rel1

    clr     r17
    sts     ENTRY_FLAG, r17     
    ldi     r17, (1<<INTF0)
    out     EIFR, r17          
    
    in      r17, EIMSK
    ori     r17, (1<<INT0)
    out     EIMSK, r17
    
    rjmp    process_flags_done  

check_exit:
    lds     r17, EXIT_FLAG
    cpi     r17, 1
    brne    process_flags_done

    lds     r19, OCCUPANCY_COUNT
    tst     r19
    breq    clear_exit_lock
    dec     r19
    sts     OCCUPANCY_COUNT, r19

    rcall   check_limit
    rcall   EEPROM_save_count
    rcall   get_RTC
    ldi     r18, 2
    rcall   log_event
    rcall   lcd_refresh       
    rcall   send_exit

wait_exit_release:
    sbis    PIND, 3             
    rjmp    wait_exit_release  

    ldi     r24, 255
d_rel3:
    ldi     r25, 255
d_rel4:
    dec     r25
    brne    d_rel4
    dec     r24
    brne    d_rel3

clear_exit_lock:
    clr     r17
    sts     EXIT_FLAG, r17      
    ldi     r17, (1<<INTF1)
    out     EIFR, r17         
    
    in      r17, EIMSK
    ori     r17, (1<<INT1)
    out     EIMSK, r17

process_flags_done:
    ret

check_limit:
    ldi     r16, LIMIT
    cp      r19, r16
    brlo    below_limit
    ldi     r16, 1
    sts     ALARM_ACTIVE, r16
    ret
below_limit:
    clr     r16
    sts     ALARM_ACTIVE, r16
    ret

EEPROM_save_count:
    lds     r18, OCCUPANCY_COUNT
    ldi     r16, EEP_COUNT_ADDR_H
    ldi     r20, EEP_COUNT_ADDR_L
    rcall   EEPROM_write
    ret

get_RTC:
    rcall   I2C_start
    ldi     r27, DS3231_W
    rcall   I2C_write
    ldi     r27, 0
    rcall   I2C_write
    rcall   I2C_start
    ldi     r27, DS3231_R
    rcall   I2C_write
    rcall   I2C_read_ack
    sts     RTC_SEC, r27
    rcall   I2C_read_ack
    sts     RTC_MIN, r27
    rcall   I2C_read_nack
    sts     RTC_HOUR, r27
    rcall   I2C_stop
    ret

I2C_start:
    ldi     r21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
    sts     TWCR, r21
s1: lds     r21, TWCR
    sbrs    r21, TWINT
    rjmp    s1
    ret

I2C_stop:
    ldi     r21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
    sts     TWCR, r21
    ret

I2C_write:
    sts     TWDR, r27
    ldi     r21, (1<<TWINT)|(1<<TWEN)
    sts     TWCR, r21
s2: lds     r21, TWCR
    sbrs    r21, TWINT
    rjmp    s2
    ret

I2C_read_ack:
    ldi     r21, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
    sts     TWCR, r21
s3: lds     r21, TWCR
    sbrs    r21, TWINT
    rjmp    s3
    lds     r27, TWDR
    ret

I2C_read_nack:
    ldi     r21, (1<<TWINT)|(1<<TWEN)
    sts     TWCR, r21
s4: lds     r21, TWCR
    sbrs    r21, TWINT
    rjmp    s4
    lds     r27, TWDR
    ret

EEPROM_write:
w1: sbic    EECR, 1
    rjmp    w1
    out     EEARH, r16
    out     EEARL, r20
    out     EEDR,  r18
    sbi     EECR, 2
    sbi     EECR, 1
    ret

EEPROM_read:
r1: sbic    EECR, 1
    rjmp    r1
    out     EEARH, r16
    out     EEARL, r20
    sbi     EECR, 0
    in      r18, EEDR
    ret

log_event:
    lds     r20, EEP_PTR
    lds     r16, EEP_PTR+1
    rcall   EEPROM_write

    lds     r20, EEP_PTR
    lds     r16, EEP_PTR+1
    inc     r20
    sts     EEP_PTR, r20
    lds     r18, RTC_HOUR
    rcall   EEPROM_write

    lds     r20, EEP_PTR
    inc     r20
    sts     EEP_PTR, r20
    lds     r18, RTC_MIN
    rcall   EEPROM_write

    lds     r20, EEP_PTR
    inc     r20
    sts     EEP_PTR, r20
    lds     r18, RTC_SEC
    rcall   EEPROM_write

    lds     r20, EEP_PTR
    inc     r20
    sts     EEP_PTR, r20
    ret

send_entry:
    rcall   print_time
    ldi     r30, lo8(msg_entry)
    ldi     r31, hi8(msg_entry)
    rjmp    print_msg

send_exit:
    rcall   print_time
    ldi     r30, lo8(msg_exit)
    ldi     r31, hi8(msg_exit)

print_msg:
    lpm     r18, Z+
    tst     r18
    breq    done_str
    rcall   uart_print
    rjmp    print_msg
done_str:
    ret

print_time:
    ldi     r18, '['
    rcall   uart_print
    lds     r18, RTC_HOUR
    rcall   print_RTC
    ldi     r18, ':'
    rcall   uart_print
    lds     r18, RTC_MIN
    rcall   print_RTC
    ldi     r18, ':'
    rcall   uart_print
    lds     r18, RTC_SEC
    rcall   print_RTC
    ldi     r18, ']'
    rcall   uart_print
    ldi     r18, ' '
    rcall   uart_print
    ret

print_RTC:
    push    r18
    swap    r18
    andi    r18, 0x0F
    subi    r18, -'0'
    rcall   uart_print
    pop     r18
    andi    r18, 0x0F
    subi    r18, -'0'
    rcall   uart_print
    ret

uart_print:
    lds     r17, UCSR0A
    sbrs    r17, UDRE0
    rjmp    uart_print
    sts     UDR0, r18
    ret

.p2align 1  
msg_entry:
    .ascii "ENTRY\r\n\0"
msg_exit:
    .ascii "EXIT\r\n\0"
