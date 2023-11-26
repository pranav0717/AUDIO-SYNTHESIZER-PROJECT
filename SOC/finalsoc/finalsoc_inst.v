	finalsoc u0 (
		.clk_clk                        (<connected-to-clk_clk>),                        //                     clk.clk
		.hex_digits_export              (<connected-to-hex_digits_export>),              //              hex_digits.export
		.i2c_export_sda_in              (<connected-to-i2c_export_sda_in>),              //              i2c_export.sda_in
		.i2c_export_scl_in              (<connected-to-i2c_export_scl_in>),              //                        .scl_in
		.i2c_export_sda_oe              (<connected-to-i2c_export_sda_oe>),              //                        .sda_oe
		.i2c_export_scl_oe              (<connected-to-i2c_export_scl_oe>),              //                        .scl_oe
		.key_external_connection_export (<connected-to-key_external_connection_export>), // key_external_connection.export
		.keycode_export                 (<connected-to-keycode_export>),                 //                 keycode.export
		.keyvol_0_export                (<connected-to-keyvol_0_export>),                //                keyvol_0.export
		.keyvol_1_export                (<connected-to-keyvol_1_export>),                //                keyvol_1.export
		.keyvol_2_export                (<connected-to-keyvol_2_export>),                //                keyvol_2.export
		.keyvol_3_export                (<connected-to-keyvol_3_export>),                //                keyvol_3.export
		.leds_export                    (<connected-to-leds_export>),                    //                    leds.export
		.reset_reset_n                  (<connected-to-reset_reset_n>),                  //                   reset.reset_n
		.sdram_clk_clk                  (<connected-to-sdram_clk_clk>),                  //               sdram_clk.clk
		.sdram_wire_addr                (<connected-to-sdram_wire_addr>),                //              sdram_wire.addr
		.sdram_wire_ba                  (<connected-to-sdram_wire_ba>),                  //                        .ba
		.sdram_wire_cas_n               (<connected-to-sdram_wire_cas_n>),               //                        .cas_n
		.sdram_wire_cke                 (<connected-to-sdram_wire_cke>),                 //                        .cke
		.sdram_wire_cs_n                (<connected-to-sdram_wire_cs_n>),                //                        .cs_n
		.sdram_wire_dq                  (<connected-to-sdram_wire_dq>),                  //                        .dq
		.sdram_wire_dqm                 (<connected-to-sdram_wire_dqm>),                 //                        .dqm
		.sdram_wire_ras_n               (<connected-to-sdram_wire_ras_n>),               //                        .ras_n
		.sdram_wire_we_n                (<connected-to-sdram_wire_we_n>),                //                        .we_n
		.spi0_MISO                      (<connected-to-spi0_MISO>),                      //                    spi0.MISO
		.spi0_MOSI                      (<connected-to-spi0_MOSI>),                      //                        .MOSI
		.spi0_SCLK                      (<connected-to-spi0_SCLK>),                      //                        .SCLK
		.spi0_SS_n                      (<connected-to-spi0_SS_n>),                      //                        .SS_n
		.usb_gpx_export                 (<connected-to-usb_gpx_export>),                 //                 usb_gpx.export
		.usb_irq_export                 (<connected-to-usb_irq_export>),                 //                 usb_irq.export
		.usb_rst_export                 (<connected-to-usb_rst_export>)                  //                 usb_rst.export
	);

