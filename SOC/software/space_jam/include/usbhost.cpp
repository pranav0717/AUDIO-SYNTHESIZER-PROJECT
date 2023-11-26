#include "../include/usbhost.h"

uint8_t usb_task_state;
MAX3421e::MAX3421e() {
	printf("MAX3421e Constructor\n");
	vbusState = 0;
};

uint8_t MAX3421e::vbusState = 0;

uint8_t MAX3421e::getVbusState(void) {
	return vbusState;
};

/* write single byte into MAX3421 register */
void MAX3421e::regWr(uint8_t reg, uint8_t val) {
	//printf("MAX3421e regWr\n");
	//    Select_MAX3421E;
	alt_u8 spi_command_string_tx[2] = "";
	alt_u8 spi_command_string_rx[1] = "";
	alt_u8 return_code;
	spi_command_string_tx[0] = reg + 2;
	spi_command_string_tx[1] = val;
	//SPI_wr ( reg + 2 ); //set WR bit and send register number
	//SPI_wr ( val );
	return_code = alt_avalon_spi_command(SPI_0_BASE, 0, 2,
		spi_command_string_tx, 0, spi_command_string_rx, 0);
	if (return_code < 0)
		printf("ERROR SPI MAXreg_wr RET = %x \n", return_code);
	//    Deselect_MAX3421E;
};
/* multiple-byte write                            */

/* returns a pointer to memory position after last written */
uint8_t* MAX3421e::bytesWr(uint8_t reg, uint8_t nbytes, uint8_t* data) {
	//printf("MAX3421e bytesWr\n");
	alt_u8 spi_command_string_tx[nbytes + 1];
	alt_u8 spi_command_string_rx[1];
	alt_u8 return_code;
	spi_command_string_tx[0] = reg + 2;
	memcpy(&spi_command_string_tx[1], data, nbytes);

	return_code = alt_avalon_spi_command(SPI_0_BASE, 0, nbytes + 1,
			spi_command_string_tx, 0, spi_command_string_rx, 0);
	if (return_code < 0)
		printf("ERROR SPI MAXbytes_wr RET = %x \n", return_code);

//    Select_MAX3421E;    //assert SS
//    SPI_wr ( reg + 2 ); //set W/R bit and select register
//    while( nbytes ) {
//        SPI_wr( *data );    // send the next data byte
//        data++;             // advance the pointer
//        nbytes--;
//    }
//    Deselect_MAX3421E;  //deassert SS
//    return( data );

	return (data + nbytes);
}
/* GPIO write                                           */
/*GPIO byte is split between 2 registers, so two writes are needed to write one byte */

/* GPOUT bits are in the low nibble. 0-3 in IOPINS1, 4-7 in IOPINS2 */
void MAX3421e::gpioWr(uint8_t data) {
	printf("MAX3421e gpioWr\n");
	regWr(rIOPINS1, data);
	data >>= 4;
	regWr(rIOPINS2, data);
	return;
}

/* single host register read    */
uint8_t MAX3421e::regRd(uint8_t reg) {
	//printf("MAX3421e regRd\n");
	alt_u8 spi_command_string_tx[1] = "";
	alt_u8 spi_command_string_rx[1] = "";
	alt_u8 return_code;
	spi_command_string_tx[0] = reg;
	return_code = alt_avalon_spi_command(SPI_0_BASE, 0, 1,
		spi_command_string_tx, 1, spi_command_string_rx, 0);
	if (return_code < 0)
		printf("ERROR SPI MAXreg_rd RET = %x \n", return_code);

	return spi_command_string_rx[0];
}
/* multiple-byte register read  */

/* returns a pointer to a memory position after last read   */
uint8_t* MAX3421e::bytesRd(uint8_t reg, uint8_t nbytes, uint8_t* data) {
	//printf("MAX3421e bytesRd\n");
	alt_u8 spi_command_string_tx[1] = "";
	alt_u8 return_code;
	spi_command_string_tx[0] = reg;

	return_code = alt_avalon_spi_command(SPI_0_BASE, 0, 1,
		spi_command_string_tx, nbytes, data, 0);

	if (return_code < 0)
		printf("ERROR SPI MAXreg_rd RET = %x \n", return_code);

	return (data + nbytes);
}
/* GPIO read. See gpioWr for explanation */

/** @brief  Reads the current GPI input values
*   @retval uint8_t Bitwise value of all 8 GPI inputs
*/
/* GPIN pins are in high nibbles of IOPINS1, IOPINS2    */
uint8_t MAX3421e::gpioRd() {
	printf("MAX3421e gpioRd\n");
	uint8_t gpin = 0;
	gpin = regRd(rIOPINS2); //pins 4-7
	gpin &= 0xf0; //clean lower nibble
	gpin |= (regRd(rIOPINS1) >> 4); //shift low bits and OR with upper from previous operation.
	return ( gpin);
}

/** @brief  Reads the current GPI output values
*   @retval uint8_t Bitwise value of all 8 GPI outputs
*/
/* GPOUT pins are in low nibbles of IOPINS1, IOPINS2    */
uint8_t MAX3421e::gpioRdOutput() {
	printf("MAX3421e gpioRdOutput\n");
	uint8_t gpout = 0;
	gpout = regRd(rIOPINS1); //pins 0-3
		gpout &= 0x0f; //clean upper nibble
		gpout |= (regRd(rIOPINS2) << 4); //shift high bits and OR with lower from previous operation.
		return ( gpout);
}

/* reset MAX3421E. Returns number of cycles it took for PLL to stabilize after reset
  or zero if PLL haven't stabilized in 65535 cycles */
uint16_t MAX3421e::reset() {
	printf("MAX3421e reset\n");
	//hardware reset, then software reset
	IOWR_ALTERA_AVALON_PIO_DATA(USB_RST_BASE, 0);
	usleep(1000000);
	IOWR_ALTERA_AVALON_PIO_DATA(USB_RST_BASE, 1);
	uint16_t i = 0;
	regWr(rUSBCTL, bmCHIPRES);
	regWr(rUSBCTL, 0x00);
	while(++i) {
		if((regRd(rUSBIRQ) & bmOSCOKIRQ)) {
			break;
		}
	}
	return ( i);
}

/* turn USB power on/off                                                */
/* ON pin of VBUS switch (MAX4793 or similar) is connected to GPOUT7    */
/* OVERLOAD pin of Vbus switch is connected to GPIN7                    */
/* OVERLOAD state low. NO OVERLOAD or VBUS OFF state high.              */
bool Vbus_power(bool action) {
	// power on/off successful
	return (1);
}

/* initialize MAX3421E. Set Host mode, pullups, and stuff. Returns 0 if success, -1 if not */
int8_t MAX3421e::Init() {
	printf("MAX3421e Init\n");
	/* Configure full-duplex SPI, interrupt pulse   */
	/* MAX3421E - full-duplex SPI, level interrupt */
	// GPX pin on. Moved here, otherwise we flicker the vbus.
	regWr(rPINCTL, (bmFDUPSPI | bmINTLEVEL));

	if(reset() == 0) { //OSCOKIRQ hasn't asserted in time
		return ( -1);
	}

	regWr(rMODE, bmDPPULLDN | bmDMPULLDN | bmHOST); // set pull-downs, Host

	regWr(rHIEN, bmCONDETIE | bmFRAMEIE); //connection detection

	/* check if device is connected */
	regWr(rHCTL, bmSAMPLEBUS); // sample USB bus
	while(!(regRd(rHCTL) & bmSAMPLEBUS)); //wait for sample operation to finish

	busprobe(); //check if anything is connected

	regWr(rHIRQ, bmCONDETIRQ); //clear connection detect interrupt
	regWr(rCPUCTL, 0x01); //enable interrupt pin

	return ( 0);                           //enable interrupt pin
}

/* initialize MAX3421E. Set Host mode, pullups, and stuff. Returns 0 if success, -1 if not */
int8_t MAX3421e::Init(int mseconds) {
	printf("MAX3421e Init mseconds\n");
	/* MAX3421E - full-duplex SPI, level interrupt, vbus off */
	regWr(rPINCTL, (bmFDUPSPI | bmINTLEVEL | GPX_VBDET));

	if(reset() == 0) { //OSCOKIRQ hasn't asserted in time
		return ( -1);
	}

	// Delay a minimum of 1 second to ensure any capacitors are drained.
	// 1 second is required to make sure we do not smoke a Microdrive!
	if(mseconds < 1000) mseconds = 1000;
	delay(mseconds);

	regWr(rMODE, bmDPPULLDN | bmDMPULLDN | bmHOST); // set pull-downs, Host

	regWr(rHIEN, bmCONDETIE | bmFRAMEIE); //connection detection

	/* check if device is connected */
	regWr(rHCTL, bmSAMPLEBUS); // sample USB bus
	while(!(regRd(rHCTL) & bmSAMPLEBUS)); //wait for sample operation to finish

	busprobe(); //check if anything is connected

	regWr(rHIRQ, bmCONDETIRQ); //clear connection detect interrupt
	regWr(rCPUCTL, 0x01); //enable interrupt pin

	// GPX pin on. This is done here so that busprobe will fail if we have a switch connected.
	regWr(rPINCTL, (bmFDUPSPI | bmINTLEVEL));

	return ( 0);
}

/* probe bus to determine device presence and speed and switch host to this speed */
void MAX3421e::busprobe() {
	printf("MAX3421e busprobe\n");
	uint8_t bus_sample;
	bus_sample = regRd(rHRSL); //Get J,K status
	bus_sample &= (bmJSTATUS | bmKSTATUS); //zero the rest of the byte
	switch(bus_sample) { //start full-speed or low-speed host
		case( bmJSTATUS):
			if((regRd(rMODE) & bmLOWSPEED) == 0) {
				printf("Starting full-speed host\n");
				regWr(rMODE, MODE_FS_HOST); //start full-speed host
				vbusState = FSHOST;
			} else {
				printf("Starting low-speed host\n");
				regWr(rMODE, MODE_LS_HOST); //start low-speed host
				vbusState = LSHOST;
			}
			break;
		case( bmKSTATUS):
			if((regRd(rMODE) & bmLOWSPEED) == 0) {
				regWr(rMODE, MODE_LS_HOST); //start low-speed host
				vbusState = LSHOST;
			} else {
				regWr(rMODE, MODE_FS_HOST); //start full-speed host
				vbusState = FSHOST;
			}
			break;
		case( bmSE1): //illegal state
			vbusState = SE1;
			break;
		case( bmSE0): //disconnected state
			regWr(rMODE, bmDPPULLDN | bmDMPULLDN | bmHOST | bmSEPIRQ);
			vbusState = SE0;
			break;
	}//end switch( bus_sample )
}

/* MAX3421 state change task and interrupt handler */
uint8_t MAX3421e::Task(void) {
//	printf("MAX3421e Task\n");

	uint8_t rcode = 0;
	uint8_t pinvalue;
	//USB_HOST_SERIAL.print("Vbus state: ");
	//USB_HOST_SERIAL.println( vbusState, HEX );
	pinvalue = *((uint8_t*) USB_IRQ_BASE); //Read();
	//pinvalue = digitalRead( MAX_INT );
	if(IORD_ALTERA_AVALON_PIO_DATA(USB_IRQ_BASE) == 0) {
		rcode = IntHandler();
	}
	//    pinvalue = digitalRead( MAX_GPX );
	//    if( pinvalue == LOW ) {
	//        GpxHandler();
	//    }
	//    usbSM();                                //USB state machine
	return ( rcode);
}

uint8_t MAX3421e::IntHandler() {
	uint8_t HIRQ;
	uint8_t HIRQ_sendback = 0x00;
	HIRQ = regRd(rHIRQ); //determine interrupt source

	//if( HIRQ & bmFRAMEIRQ ) {               //->1ms SOF interrupt handler
	//    HIRQ_sendback |= bmFRAMEIRQ;
	//}//end FRAMEIRQ handling
	if(HIRQ & bmCONDETIRQ) {
		busprobe();
		HIRQ_sendback |= bmCONDETIRQ;
	}
	/* End HIRQ interrupts handling, clear serviced IRQs    */
	regWr(rHIRQ, HIRQ_sendback);
	return ( HIRQ_sendback);
}

uint8_t MAX3421e::GpxHandler()
{
	//BYTE GPINIRQ;
	//GPINIRQ = regRd( rGPINIRQ);            //read both IRQ registers
	return 0;
}
