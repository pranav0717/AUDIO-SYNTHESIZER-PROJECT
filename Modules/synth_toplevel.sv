module synth_toplevel(

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 
		input		 MAX10_CLK2_50,
		input	 	 ADC_CLK_10,
      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,

      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 
	);



//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic Reset_h, vssig, blank, sync, VGA_Clk;
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;
	
			//SGTL5000:
			logic SDA_IN,SCL_IN,SDA_OE,SCL_OE;
			logic [1:0] sgtl_clk;
			logic SCLK, LRCLK, I2SDOUT;
			logic [31:0] I2SDIN;
			
			//Gaming Parameters:
			logic [1:0] WavetableSelect;		//wavetable select. Controlled by A/B keys on Shield.
			logic [12:0] deltatime;				//time elapsed since the game begins
			
//			//ADC keys, omitted:
//			logic [11:0] ResponseData,ADCData;
//			logic [4:0] ADCResponseChannel,ADCCommandChannel, curADCCh;
//			logic ADCValid;
			
			//PhaseOSC temp Outputs:
			wire [31:0] WTOUT0,WTOUT1,WTOUT2,WTOUT3;
			
			//MIDI keys:
			logic [15:0] MIDIKey0, MIDIKey1, MIDIKey2, MIDIKey3;
			wire [4:0] KeyOffset0, KeyOffset1, KeyOffset2, KeyOffset3;
			wire [23:0] FreqReg0, FreqReg1, FreqReg2, FreqReg3;
//=======================================================
//  Structural coding
//=======================================================

			//final exclusive: assigning arduino SCL, SDA, sgtl exclusive 12.5MHz clk
			//I2C:
			assign SCL_IN = ARDUINO_IO[15];
			assign ARDUINO_IO[15] = SCL_OE? 1'b0 : 1'bz;
			assign SDA_IN = ARDUINO_IO[14];
			assign ARDUINO_IO[14] = SDA_OE? 1'b0 : 1'bz;
			
			//I2S:
			assign SCLK = ARDUINO_IO[5];
			assign LRCLK = ARDUINO_IO[4];
			assign ARDUINO_IO[3] = sgtl_clk[1];
			assign ARDUINO_IO[2] = I2SDOUT;
			assign ARDUINO_IO[1] = 1'bz;
		
	//from 6.2:
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	
	HexDriver hex_driver0 (debughex, HEX0[6:0]);
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5[6:0] = { ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2[6:0] = { ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	assign HEX5[7] = I2SDOUT;	
	assign HEX4[7] = WTOUT0[15];
	assign HEX3[7] = WTOUT0[14];
	assign HEX2[7] = WTOUT0[13];
	assign HEX1[7] = WTOUT0[4];	
	assign HEX0[7] = WTOUT0[3];	
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	
	
	
			//CLOCK making:
			always_ff @(posedge MAX10_CLK2_50) begin
				sgtl_clk <= sgtl_clk + 1;
			end
	
	
finalsoc rhythm_game_synthesizer (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
		//I2C
		.i2c_export_sda_in(SDA_IN),
		.i2c_export_scl_in(SCL_IN),
		.i2c_export_sda_oe(SDA_OE),
		.i2c_export_scl_oe(SCL_OE),
		
		//ADC block. Discarded due to stagnant Fitter error
//		.adc_0_command_valid(1'b1),            //           adc_0_command.valid
//		.adc_0_command_channel(ADCCommandChannel),          //                        .channel
//		.adc_0_command_startofpacket(1'b1),    //                        .startofpacket
//		.adc_0_command_endofpacket(1'b1),      //                        .endofpacket
//		.adc_0_command_ready(),            //                        .ready
//		.adc_0_response_valid(ADCValid),           //          adc_0_response.valid
//		.adc_0_response_channel(ADCResponseChannel),         //                        .channel
//		.adc_0_response_data(ResponseData),            //                        .data
//		.adc_0_response_startofpacket(),   //                        .startofpacket
//		.adc_0_response_endofpacket(),
//
////		.adc_clk_10_clk(ADC_CLK_10)

		//MIDI keys
		.keyvol_0_export(MIDIKey0),
		.keyvol_1_export(MIDIKey1),
		.keyvol_2_export(MIDIKey2),
		.keyvol_3_export(MIDIKey3)
);


vga_controller vga_controller_final ( .Clk(MAX10_CLK1_50), .Reset(Reset_h), .DrawX(drawxsig), .DrawY(drawysig), .sync(sync), .pixel_clk(VGA_Clk), .hs(VGA_HS), .vs(VGA_VS), .blank(blank));

I2S I2S_final (.Din(I2SDIN), .Dout(I2SDOUT), .SCLK(SCLK), .LRCLK(LRCLK));
//Calculate the root of pythagorean of these four samples:
assign I2SDIN = WTOUT0 + WTOUT1 + WTOUT2 + WTOUT3;
//RootSquareSumCalculator I2SDINCalc(.sample0(WTOUT0), .sample1(WTOUT1), .sample2(WTOUT2), .sample3(WTOUT3), .pythagorean(I2SDIN));

Phase_OSC OSC_0 (.MasterCLK(MAX10_CLK1_50), .FSCLK(LRCLK), .WTOUT(WTOUT0), .WTSelect(SW[1:0]),
							.FreqRegInputVal(FreqReg0), .Velocity(MIDIKey0[6:0]));
Phase_OSC OSC_1 (.MasterCLK(MAX10_CLK1_50), .FSCLK(LRCLK), .WTOUT(WTOUT1), .WTSelect(SW[3:2]),
							.FreqRegInputVal(FreqReg1), .Velocity(MIDIKey1[6:0]));
Phase_OSC OSC_2 (.MasterCLK(MAX10_CLK1_50), .FSCLK(LRCLK), .WTOUT(WTOUT2), .WTSelect(SW[5:4]),
							.FreqRegInputVal(FreqReg2), .Velocity(MIDIKey2[6:0]));
Phase_OSC OSC_3 (.MasterCLK(MAX10_CLK1_50), .FSCLK(LRCLK), .WTOUT(WTOUT3), .WTSelect(SW[7:6]),
							.FreqRegInputVal(FreqReg3), .Velocity(MIDIKey3[6:0]));

color_mapper color_mapper_final (.Clk(VGA_Clk), .blank(blank), .AnchorX(160), .AnchorY(360), .score_q(score_q), .deltatime(deltatime),
											.DrawX(drawxsig), .DrawY(drawysig), .Red(Red), .Green(Green), .Blue(Blue), .KeyOffset(FreqReg0));


//need MIDIKeyConverter modules to interpret MIDI messages and send them out as offsets/volume multipliers
MIDIKeyConverter converter0(.Pitch(MIDIKey0[15:8]), .Offset(KeyOffset0));
MIDIKeyConverter converter1(.Pitch(MIDIKey1[15:8]), .Offset(KeyOffset1));
MIDIKeyConverter converter2(.Pitch(MIDIKey2[15:8]), .Offset(KeyOffset2));
MIDIKeyConverter converter3(.Pitch(MIDIKey3[15:8]), .Offset(KeyOffset3));
											
FrequencyMapper freqregtable0(.Offset(KeyOffset0), .FreqRegValue(FreqReg0));
FrequencyMapper freqregtable1(.Offset(KeyOffset1), .FreqRegValue(FreqReg1));
FrequencyMapper freqregtable2(.Offset(KeyOffset2), .FreqRegValue(FreqReg2));
FrequencyMapper freqregtable3(.Offset(KeyOffset3), .FreqRegValue(FreqReg3));

score_rom loader(.clock(VGA_Clk), .address(score_address), .q(score_q));

rhythm_game Space_Jam(.Master_Clk(MAX10_CLK1_50), .Frame_Clk(VGA_VS), .Game_Reset(Reset_h), .deltatime(deltatime),
							 .Press_Start(~KEY[1]), 
							/*.KeyOffsets(FreqReg0), .WavetableSelect(WavetableSelect), .JS_keytype(curADCCh), .JS_data(ADCData)*/);

	//initialization logic
initial begin
//	WavetableSelect = 2'b00;
//	CurrentKeyOffset = 0;
//	CurrentKeyVelocity = 127;
end

//Globalized score_rom color mapping logic, need to be used elsewhere
logic [17:0] score_address;
wire score_q;

assign score_address = ((drawxsig-160)/20 + (90 - drawysig[9:2]) *24   + deltatime * 24);

////ADC signals update logic, no longer used
//always_ff @ (posedge ADC_CLK_10) begin
//	ADCCommandChannel = MAX10_CLK1_50 ? 4'b0100 : 4'b0011;
//	if(ADCValid) begin
//		ADCData <= ResponseData;
//		curADCCh <= ADCResponseChannel;
//	end
//end

////LED/HEX debugging logics
//logic [12:0] debugvol;
//logic [3:0] debughex;
//
//always_ff @ (posedge ADC_CLK_10) begin
//	debugvol = ResponseData * 2 * 2500 / 4095;
//////	LEDR[9:0] = debugvol[12:3]; 	//debug value
//	debughex <= 4'h5;
//end


endmodule
