# Configuration registers 

Bellow is an exhaustive list of all configuration registers accessible over the 
digital interface used to drive the behavior of the SerDes ASIC. 

All configuration registers are expected to be outlined in this document once in the 
[register list table](#register-list) and with there mapping detailed and usage outlined 
in the section afterwards. 

The template for the mapping details is as follows : 

### Register name

Description of this control register. 

Encoding : 

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| MSB:8            | Reserved (aka unused)                                                                      | -                        | 'X    |
| 7:4              | **ctrl_bit2_name**: Description of what this control bit is is use, who uses it and it works. Include encoding if relevant, eg: `4'd0` disable, `4'dF` enable, default: undefined behavior. | RW | 4'd0  |
| 3:2              | **ctrl_bit1_name**: Description of what this control bit is is use, who uses it and it works.  | RO            | 2'dX  |
| 1:0              | **ctrl_bit0_name**: Description of what this control bit is is use, who uses it and it works.  | WO           | 2'd0  |

#### Type

- RO = Read only
- WO = Write only
- R/W = Read/Write
- SC = Self-clearing
- NR = Non Roll-over

`SC`: When written it is automatically cleared to the reset value in the next cycle, use to sent pulses.

`NR`: In the absence of a non roll-over the counter will overflow. 

## Register list 

| Name                           | Size in bits | Consumer (Digital/Analog) | Address  |
| ------------------------------ | ------------ | ------------------------- | -------- |
| PCS control                    | 8            | Digital                   | 0        |
| TX test mode                   | 2            | Digital                   | 1        |
| RX test mode                   | TBD          | Digital                   | 2        |
| SPI smoke test                 | 16           | Digital                   | 3        |
| RX TAP0                        | TBD          | Analog                    | 4        |
| RX TAP1                        | TBD          | Analog                    | 5        |
| RX TAP2                        | TBD          | Analog                    | 6        |
| RX TAP3                        | TBD          | Analog                    | 7        |
| RX TAP4                        | TBD          | Analog                    | 8        |
| RX TAP5                        | TBD          | Analog                    | 9        |
| RX TAP6                        | TBD          | Analog                    | 10       |
| RX TAP7                        | TBD          | Analog                    | 11       |
| RX BER status                  | 16           | Digital                   | 12       |
| RX split count                 | 32           | Digital                   | 13       |
| RX valid blocks seen count     | 32           | Digital                   | 14       |
| RX invalid blocks seen count   | 32           | Digital                   | 15       |

## Register description

### PCS control

PCS control, only impacts digital side. 
 
| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
|   MSB:1          | Reserved    | -                   | 'X  |
|   0              | **pcs_reset**: Reset PCS and all PCS digital counters, has no effect on analog configs.    | WO, SC                   | 1'b0  |


### TX test mode

TX test pattern generator config to enable sending RPBS7 and PRBS31 patterns over TX. When enabled this takes precedance over the default TX output packet 
path. 

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| MSB:2            | Reserved (aka unused)                                                                      | -                        | 'X    |
|   1              | **tx_test_pattern_pbrs7**: Select the PBRS7 test pattern. `1'b0` - PBRS31, `1'b1` - PBRS7  | RW                       | 1'b0  |
|   0              | **tx_test_mode**: Enable TX test pattern overwriting tx output data. `1'b0` - disable, `1'b1` - enable. | RW           | 1'b0  |

 
### RX test mode

TBD

### SPI smoke test

Hard coded predicatable value to validate that the SPI configuration interface is working as intended, used for bringup. 

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 15:0             | **spi_smoke_test**: Test register reset to a predicable value and writable to validate spi bring-up infra. | RW       | 16'hCAFE |


### RX PCS status

These counters can be cleared by writting `pcs_reset`.

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 15               | **rx_pcs_block_lock**": `1'b1` : has block lock, `1'b0`: doesn't have lock                 | RO                       | 'X    |
| 14               | **rx_pcs_hi_ber**": `1'b1` : has hi\_ber, `1'b0`: doesn't have hi\_ber                     | RO                       | 'X    |
| 13:8             | **rx_pcs_ber**: BER counter                                                                | RO/NR                      | 1'b0  |
| 7:0              | **rx_pcs_err_block**: Error block counter                                                  | RO/NR                      | 1'b0  |

Note: Uses the same encoding and definitions as MDIO 3.33.

### RX PCS status

These counters can be cleared by writing `pcs_reset`.

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 15               | **rx_pcs_block_lock**": `1'b1` : has block lock, `1'b0`: doesn't have lock                 | RO                       | 'X    |
| 14               | **rx_pcs_hi_ber**": `1'b1` : has hi\_ber, `1'b0`: doesn't have hi\_ber                     | RO                       | 'X    |
| 13:8             | **rx_pcs_ber_cnt**: BER counter                                                                | RO/NR                      | 8'b0  |
| 7:0              | **rx_pcs_err_block_cnt**: Error block counter                                                  | RO/NR                      | 8'b0  |

Note: Uses the same encoding and definitions as MDIO 3.33.
 
### RX split counter

These counters can be cleared by writing `pcs_reset`.

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 31:0             | **rx_sync_splip_cnt**: Bit split count                                                     | RO                       | 32'b0  |


### RX valid block seen counter

These counters can be cleared by writting `pcs_reset`.

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 31:0             | **rx_sync_valid_blocks_seen**: Valid block seen count, increments only when lock has been aquired. | RO               | 32'b0  |

### RX invalid block seen counter

These counters can be cleared by writing `pcs_reset`.

| Bits slice index | Description                                                                                | Type                     | Reset |
| ---------------- | ------------------------------------------------------------------------------------------ | ------------------------ | ----- |
| 31:0             | **rx_sync_invalid_blocks_seen**: Invalid block seen count, increments for every block where lock has not been aquired. | RO               | 32'b0  |

