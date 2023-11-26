/*
 SPI.cpp - SPI library for esp8266
 Copyright (c) 2015 Hristo Gochkov. All rights reserved.
 This file is part of the esp8266 core for Arduino environment.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "../include/SPI.h"

#define SPI_PINS_HSPI			0 // Normal HSPI mode (MISO = GPIO12, MOSI = GPIO13, SCLK = GPIO14);
#define SPI_PINS_HSPI_OVERLAP	1 // HSPI Overllaped in spi0 pins (MISO = SD0, MOSI = SDD1, SCLK = CLK);

#define SPI_OVERLAP_SS 0

//uint8_t regRd(uint8_t a) {
//	printf("regRd");
//}
//void regWr(uint8_t a, uint8_t b) {
//	printf("regWr");
//}
//uint8_t* bytesRd(uint8_t a, int8_t b, uint8_t* c) {
//	printf("bytesRd");
//}
//void bytesWr(uint8_t a, uint16_t b, uint8_t* c) {
//	printf("bytesWr");
//}
#include <limits.h>
#include <string.h>

#include "system.h"
#include "alt_types.h"

#include "priv/alt_busy_sleep.h"

unsigned int alt_busy_sleep (unsigned int us)
{
/*
 * Only delay if ALT_SIM_OPTIMIZE is not defined; i.e., if software
 * is built targetting ModelSim RTL simulation, the delay will be
 * skipped to speed up simulation.
 */
#ifndef ALT_SIM_OPTIMIZE
  int i;
  int big_loops;
  alt_u32 cycles_per_loop;

  if (!strcmp(NIOS2_CPU_IMPLEMENTATION,"tiny"))
  {
    cycles_per_loop = 9;
  }
  else
  {
    cycles_per_loop = 3;
  }


  big_loops = us / (INT_MAX/
  (ALT_CPU_FREQ/(cycles_per_loop * 1000000)));

  if (big_loops)
  {
    for(i=0;i<big_loops;i++)
    {
      /*
      * Do NOT Try to single step the asm statement below
      * (single step will never return)
      * Step out of this function or set a breakpoint after the asm statements
      */
      __asm__ volatile (
        "\n0:"
        "\n\taddi %0,%0, -1"
        "\n\tbne %0,zero,0b"
        "\n1:"
        "\n\t.pushsection .debug_alt_sim_info"
        "\n\t.int 4, 0, 0b, 1b"
        "\n\t.popsection"
        :: "r" (INT_MAX));
      us -= (INT_MAX/(ALT_CPU_FREQ/
      (cycles_per_loop * 1000000)));
    }

    /*
    * Do NOT Try to single step the asm statement below
    * (single step will never return)
    * Step out of this function or set a breakpoint after the asm statements
    */
    __asm__ volatile (
      "\n0:"
      "\n\taddi %0,%0, -1"
      "\n\tbne %0,zero,0b"
      "\n1:"
      "\n\t.pushsection .debug_alt_sim_info"
      "\n\t.int 4, 0, 0b, 1b"
      "\n\t.popsection"
      :: "r" (us*(ALT_CPU_FREQ/(cycles_per_loop * 1000000))));
  }
  else
  {
    /*
    * Do NOT Try to single step the asm statement below
    * (single step will never return)
    * Step out of this function or set a breakpoint after the asm statements
    */
    __asm__ volatile (
      "\n0:"
      "\n\taddi %0,%0, -1"
      "\n\tbgt %0,zero,0b"
      "\n1:"
      "\n\t.pushsection .debug_alt_sim_info"
      "\n\t.int 4, 0, 0b, 1b"
      "\n\t.popsection"
      :: "r" (us*(ALT_CPU_FREQ/(cycles_per_loop * 1000000))));
  }
#endif /* #ifndef ALT_SIM_OPTIMIZE */
  return 0;
}

void delay(uint32_t a) {
//	alt_busy_sleep(1000*a);
	clock_t start = clock();
	while (clock() - start < a) {}
}
uint32_t millis() {
	return (uint32_t) clock();
}

uint8_t getVbusState();


typedef union {
        uint32_t regValue;
        struct {
                unsigned regL :6;
                unsigned regH :6;
                unsigned regN :6;
                unsigned regPre :13;
                unsigned regEQU :1;
        };
} spiClk_t;

//SPIClass::SPIClass() {
//    printf("SPIClass Constructor\n");
//}
//
//bool SPIClass::pins(int8_t sck, int8_t miso, int8_t mosi, int8_t ss)
//{
//    printf("SPI Class pins\n");
//}
//
//void SPIClass::begin() {
//	printf("SPI Class begin\n");
//}
//
//void SPIClass::end() {
//	printf("SPI Class end\n");
//}
//
//void SPIClass::setHwCs(bool use) {
//	printf("SPI Class setHwCs\n");
//}
//
//void SPIClass::beginTransaction(SPISettings settings) {
//	printf("SPI Class beginTransaction\n");
//}
//
//void SPIClass::endTransaction() {
//	printf("SPI Class endTransaction\n");
//}
//
//void SPIClass::setDataMode(uint8_t dataMode) {
//	printf("SPI Class setDataMode\n");
//}
//
//void SPIClass::setBitOrder(uint8_t bitOrder) {
//	printf("SPI Class setBitOrder\n");
//}
//
///**
// * calculate the Frequency based on the register value
// * @param reg
// * @return
// */
//static uint32_t ClkRegToFreq(spiClk_t * reg) {
//	printf("ClkRegToFreq\n");
//	return 0;
//}
//
//void SPIClass::setFrequency(uint32_t freq) {
//	printf("SPI Class setFrequency\n");
//}
//
//void SPIClass::setClockDivider(uint32_t clockDiv) {
//    printf("SPI Class setClockDivider\n");
//}
//
//inline void SPIClass::setDataBits(uint16_t bits) {
//	printf("SPI Class setDataBits\n");
//}
//
//uint8_t SPIClass::transfer(uint8_t data) {
//	printf("SPI Class transfer\n");
//}
//
//uint16_t SPIClass::transfer16(uint16_t data) {
//	printf("SPI Class transfer16\n");
//}
//
//void SPIClass::transfer(void *buf, uint16_t count) {
//	printf("SPI Class transfer count\n");
//}
//
//void SPIClass::write(uint8_t data) {
//	printf("SPI Class write\n");
//}
//
//void SPIClass::write16(uint16_t data) {
//	printf("SPI Class write16\n");
//}
//
//void SPIClass::write16(uint16_t data, bool msb) {
//	printf("SPI Class write16 msb\n");
//}
//
//void SPIClass::write32(uint32_t data) {
//	printf("SPI Class write32\n");
//}
//
//void SPIClass::write32(uint32_t data, bool msb) {
//	printf("SPI Class write32 msb\n");
//}
//
///**
// * Note:
// *  data need to be aligned to 32Bit
// *  or you get an Fatal exception (9)
// * @param data uint8_t *
// * @param size uint32_t
// */
//void SPIClass::writeBytes(const uint8_t * data, uint32_t size) {
//	printf("SPI Class writeBytes\n");
//
//}
//
//void SPIClass::writeBytes_(const uint8_t * data, uint8_t size) {
//	printf("SPI Class writeBytes_\n");
//
//}
//
///**
// * @param data uint8_t *
// * @param size uint8_t  max for size is 64Byte
// * @param repeat uint32_t
// */
//void SPIClass::writePattern(const uint8_t * data, uint8_t size, uint32_t repeat) {
//	printf("SPI Class writePattern\n");
//}
//
///**
// * @param out uint8_t *
// * @param in  uint8_t *
// * @param size uint32_t
// */
//void SPIClass::transferBytes(const uint8_t * out, uint8_t * in, uint32_t size) {
//	printf("SPI Class transferBytes\n");
//
//}
//
///**
// * Note:
// *  in and out need to be aligned to 32Bit
// *  or you get an Fatal exception (9)
// * @param out uint8_t *
// * @param in  uint8_t *
// * @param size uint8_t (max 64)
// */
//
//void SPIClass::transferBytesAligned_(const uint8_t * out, uint8_t * in, uint8_t size) {
//	printf("SPI Class transferBytesAligned\n");
//
//}
//
//
//void SPIClass::transferBytes_(const uint8_t * out, uint8_t * in, uint8_t size) {
//	printf("SPI Class transferBytes_\n");
//}
//
//
//#if !defined(NO_GLOBAL_INSTANCES) && !defined(NO_GLOBAL_SPI)
//SPIClass SPI;
//#endif

