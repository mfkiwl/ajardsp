// This file is part of AjarDSP
//
// Copyright (c) 2011 Markus Lavin
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// 3. Neither the name of the <ORGANIZATION> nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module soc_top(
               CLK_50_MHZ,
               RST,

               SD_A,
               SD_DQ,
               SD_BA,
               SD_CAS,
               SD_CK_N,
               SD_CK_P,
               SD_CKE,
               SD_CS,
               SD_LDM,
               SD_LDQS,
               SD_RAS,
               SD_UDM,
               SD_UDQS,
               SD_WE,
               SD_CK_FB,

               SW,
               BTN_NORTH,
               BTN_EAST,
               BTN_SOUTH,
               LED,

               RS232_DTE_RXD, RS232_DTE_TXD,
               LCD_E, LCD_RS, LCD_RW, LCD_D,
               IRQ,
               ROT_A, ROT_B, ROT_CENTER,
               VGA_RED,
               VGA_GREEN,
               VGA_BLUE,
               VGA_HSYNC,
               VGA_VSYNC,

               ADC_SS,
               ADC_SCK,
               ADC_MISO

               );

   input CLK_50_MHZ;
   input RST;

   input [3:0] SW;
   input       BTN_NORTH;
   input       BTN_EAST;
   input       BTN_SOUTH;
/*   input       BTN_WEST; */
   output [7:0] LED;

   input            RS232_DTE_RXD;
   output           RS232_DTE_TXD;

   output           LCD_E, LCD_RS, LCD_RW;
   output [3:0]     LCD_D;

   output           VGA_RED,
                    VGA_GREEN,
                    VGA_BLUE,
                    VGA_HSYNC,
                    VGA_VSYNC;

   output           ADC_SS,
                    ADC_SCK;
   input            ADC_MISO;


   input            IRQ;

   input        ROT_A, ROT_B, ROT_CENTER;


   output [12:0] SD_A;
   inout [15:0]  SD_DQ;
   output [1:0]  SD_BA;
   output        SD_CAS;
   output        SD_CK_N;
   output        SD_CK_P;
   output        SD_CKE;
   output        SD_CS;
   output        SD_LDM;

   output        SD_LDQS;
   output        SD_RAS;
   output        SD_UDM;
   output        SD_UDQS;
   output        SD_WE;
   input         SD_CK_FB;

   reg [3:0]     rst_cnt_0, rst_cnt_1, rst_cnt_2;

   wire          clk_fb, clk_fb_, clk_fb_2, clk_fb_2_;

   wire          locked_0, locked_1, locked_2;

   wire          CLK_40_MHZ;
   wire [31:0]   read_data;
   wire          ack;

   wire          ddr_clk, ddr_clk_n, ddr_clk_fb;

   wire          rst;

   wire          clk_p, clk_n;

   reg           sd_wb_cyc_o_w,
                 sd_wb_stb_o_w,
                 vga_wb_cyc_o_w,
                 vga_wb_stb_o_w,
                 adc_wb_cyc_o_w,
                 adc_wb_stb_o_w;

   wire [31:0]   sd_wb_dat_i_w,
                 vga_wb_dat_i_w,
                 adc_wb_dat_i_w;

   wire          sd_wb_ack_i_w,
                 vga_wb_ack_i_w,
                 adc_wb_ack_i_w;

   reg         wb_ack_i_w;
   wire [31:0] wb_dat_o_w;
   reg  [31:0] wb_dat_i_w;
   wire [31:0] wb_adr_o_w;
   wire        wb_cyc_o_w;
   wire [3:0]  wb_sel_o_w;
   wire        wb_stb_o_w;
   wire        wb_we_o_w;


   assign SD_CS = 0;

   assign SD_CK_P = ddr_clk;
   assign SD_CK_N = ddr_clk_n;

//   assign  ddr_clk_fb = SD_CK_FB;

   assign rst = RST || !locked_0 || !locked_1 || !locked_2;

   assign LED = rst ? 8'haa : {5'h0, locked_1, locked_0, locked_2};

   assign LCD_E  = 0;
   assign LCD_RS = 0;
   assign LCD_RW = 0;
   assign LCD_D  = 0;


   DCM_SP #(.CLKFX_DIVIDE(5),
            .CLKFX_MULTIPLY(4))
   dcm_2(.CLK0(clk_fb_2_),
         .CLK90(),
         .CLK180(),
         .CLK270(),
         .CLK2X(),

         .CLK2X180(),
	 .CLKDV(),
         .CLKFX(CLK_40_MHZ),
         .CLKFX180(),
         .LOCKED(locked_2),
         .PSDONE(),
         .STATUS(),
	 .CLKFB(clk_fb_2),
         .CLKIN(CLK_50_MHZ),
         .DSSEN(),
         .PSCLK(),
         .PSEN(),
         .PSINCDEC(),
         .RST(RST));


   BUFG bufg2(.I(clk_fb_2_), .O(clk_fb_2));

   always @(posedge CLK_40_MHZ)
     begin
        if (RST | !locked_2)
          rst_cnt_0 <= 0;
        else if (rst_cnt_0[3] == 0)
          rst_cnt_0 <= rst_cnt_0 + 1;
     end

   DCM_SP dcm_0(.CLK0(clk_fb_),
                .CLK90(),
                .CLK180(),
                .CLK270(),
                .CLK2X(clk),

                .CLK2X180(),
	        .CLKDV(),
                .CLKFX(),
                .CLKFX180(),
                .LOCKED(locked_0),
                .PSDONE(),
                .STATUS(),
	        .CLKFB(clk_fb),
                .CLKIN(CLK_40_MHZ),
                .DSSEN(),
                .PSCLK(),
                .PSEN(),
                .PSINCDEC(),
                .RST(RST | !locked_2 | !rst_cnt_0[3]));

   BUFG bufg0(.I(clk_fb_), .O(clk_fb));


`ifdef STUPID_CLOCKS
   DCM_SP dcm_1(.CLK0(ddr_clk),
                .CLK90(clk_n),
                .CLK180(ddr_clk_n),
                .CLK270(clk_p),
                .CLK2X(),
                .CLK2X180(),
	        .CLKDV(),
                .CLKFX(),
                .CLKFX180(),
                .LOCKED(locked_1),
                .PSDONE(),
                .STATUS(),
	        .CLKFB(ddr_clk_fb),
                .CLKIN(clk),
                .DSSEN(),
                .PSCLK(),
                .PSEN(),
                .PSINCDEC(),
                .RST(RST | !locked_0));

   BUFG bufg1(.I(ddr_clk), .O(ddr_clk_fb));
`else
   DCM_SP dcm_1(.CLK0(clk_p),
                .CLK90(ddr_clk),
                .CLK180(clk_n),
                .CLK270(ddr_clk_n),
                .CLK2X(),
                .CLK2X180(),
	        .CLKDV(),
                .CLKFX(),
                .CLKFX180(),
                .LOCKED(locked_1),
                .PSDONE(),
                .STATUS(),
	        .CLKFB(ddr_clk_fb),
                .CLKIN(clk),
                .DSSEN(),
                .PSCLK(),
                .PSEN(),
                .PSINCDEC(),
                .RST(RST | !locked_0));

   BUFG bufg1(.I(clk_p), .O(ddr_clk_fb));
`endif


   always @(wb_adr_o_w or vga_wb_dat_i_w or vga_wb_ack_i_w or
            sd_wb_dat_i_w or sd_wb_ack_i_w or adc_wb_dat_i_w or adc_wb_ack_i_w)
     begin
        wb_dat_i_w     = 0;
        wb_ack_i_w     = 0;

        case (wb_adr_o_w[31:28])
          4'hf: begin
             wb_dat_i_w     = vga_wb_dat_i_w;
             wb_ack_i_w     = vga_wb_ack_i_w;
          end
          4'he: begin
             wb_dat_i_w     = adc_wb_dat_i_w;
             wb_ack_i_w     = adc_wb_ack_i_w;
          end
          default: begin
             wb_dat_i_w    = sd_wb_dat_i_w;
             wb_ack_i_w    = sd_wb_ack_i_w;
          end
        endcase
     end

   always @(wb_adr_o_w or wb_cyc_o_w or wb_stb_o_w)
     begin
        vga_wb_cyc_o_w = 0;
        vga_wb_stb_o_w = 0;
        adc_wb_cyc_o_w = 0;
        adc_wb_stb_o_w = 0;
        sd_wb_cyc_o_w = 0;
        sd_wb_stb_o_w = 0;

        case (wb_adr_o_w[31:28])
          4'hf: begin
             vga_wb_cyc_o_w = wb_cyc_o_w;
             vga_wb_stb_o_w = wb_stb_o_w;
          end
          4'he: begin
             adc_wb_cyc_o_w = wb_cyc_o_w;
             adc_wb_stb_o_w = wb_stb_o_w;
          end
          default: begin
             sd_wb_cyc_o_w = wb_cyc_o_w;
             sd_wb_stb_o_w = wb_stb_o_w;
          end
        endcase
     end


   wb_ajardsp wb_ajardsp_0(.clk(CLK_40_MHZ),
                           .rst(rst),

                           /* Wishbone interface */
                           .wb_clk_i(CLK_40_MHZ),
                           .wb_rst_i(rst),

                           .wb_ack_i(wb_ack_i_w),
                           .wb_dat_o(wb_dat_o_w),
                           .wb_dat_i(wb_dat_i_w),
                           .wb_adr_o(wb_adr_o_w),

                           .wb_cyc_o(wb_cyc_o_w),
                           .wb_stb_o(wb_stb_o_w),
                           .wb_sel_o(wb_sel_o_w),
                           .wb_we_o(wb_we_o_w),

                           .RS232_DTE_RXD(RS232_DTE_RXD),
                           .RS232_DTE_TXD(RS232_DTE_TXD)

                           );

   wb_sdram_ctrl wb_sdram_ctrl_0(.wb_clk_i(CLK_40_MHZ),
                                 .wb_rst_i(rst),

                                 .wb_adr_i(wb_adr_o_w),
                                 .wb_dat_i(wb_dat_o_w),
                                 .wb_dat_o(sd_wb_dat_i_w),

                                 .wb_cyc_i(sd_wb_cyc_o_w),
                                 .wb_stb_i(sd_wb_stb_o_w),
                                 .wb_we_i(wb_we_o_w),
                                 .wb_sel_i(wb_sel_o_w),
                                 .wb_ack_o(sd_wb_ack_i_w),

                                 .clk(clk_p),
                                 .clk_n(clk_n),

                                 .ddr_clk(ddr_clk),
                                 .ddr_clk_n(ddr_clk_n),

                                 .ddr_cke(SD_CKE),
                                 .ddr_cmd({SD_RAS, SD_CAS, SD_WE}),
                                 .ddr_data(SD_DQ),
                                 .ddr_dm({SD_UDM, SD_LDM}),
                                 .ddr_dqs({SD_UDQS, SD_LDQS}),
                                 .ddr_addr(SD_A),
                                 .ddr_ba(SD_BA)
                                 );


   wb_vga_ctrl wb_vga_ctrl_0(.wb_clk_i(CLK_40_MHZ),
                             .wb_rst_i(rst),

                             .wb_adr_i(wb_adr_o_w),
                             .wb_dat_i(wb_dat_o_w),
                             .wb_dat_o(vga_wb_dat_i_w),

                             .wb_cyc_i(vga_wb_cyc_o_w),
                             .wb_stb_i(vga_wb_stb_o_w),
                             .wb_we_i(wb_we_o_w),
                             .wb_sel_i(wb_sel_o_w),
                             .wb_ack_o(vga_wb_ack_i_w),


                             .VGA_RED(VGA_RED),
                             .VGA_GREEN(VGA_GREEN),
                             .VGA_BLUE(VGA_BLUE),
                             .VGA_HSYNC(VGA_HSYNC),
                             .VGA_VSYNC(VGA_VSYNC)

                             );

   wb_adc_ctrl wb_adc_ctrl_0(.wb_clk_i(CLK_40_MHZ),
                             .wb_rst_i(rst),

                             .wb_adr_i(wb_adr_o_w),
                             .wb_dat_i(wb_dat_o_w),
                             .wb_dat_o(adc_wb_dat_i_w),

                             .wb_cyc_i(adc_wb_cyc_o_w),
                             .wb_stb_i(adc_wb_stb_o_w),
                             .wb_we_i(wb_we_o_w),
                             .wb_sel_i(wb_sel_o_w),
                             .wb_ack_o(adc_wb_ack_i_w),

                             /* ADC interface */
                             .ADC_SS_o(ADC_SS),
                             .ADC_MISO_i(ADC_MISO),
                             .ADC_SCK_o(ADC_SCK)

                             );



endmodule
