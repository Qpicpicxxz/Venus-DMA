/* common_memcomp Version: 4.0.5-beta20 */
/* lang compiler Version: 4.1.6-beta1 Jul 19 2012 13:55:19 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2024 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//       Repair Verilog RTL for Synchronous Dual-Port Ram
//
//       Instance Name:              SRAMdpw64d256_rtl_top
//       Words:                      256
//       User Bits:                  64
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 Off
//       Extra Margin Adjustment:    On
//       Redundancy:                 off
//       Redundant Rows:             0
//       Redundant Columns:          0
//       Test Muxes                  On
//       Ser:                        none
//       Retention:                  on
//       Power Gating:               off
//
//       Creation Date:  Tue Jan 16 16:38:44 2024
//       Version:      r1p1
//
//       Verified
//
//       Known Bugs: None.
//
//       Known Work Arounds: N/A
//
`timescale 1ns/1ps

module SRAMdpw64d256_rtl_top (
          CENYA, 
          WENYA, 
          AYA, 
          CENYB, 
          WENYB, 
          AYB, 
          QA, 
          QB, 
          SOA, 
          SOB, 
          CLKA, 
          CENA, 
          WENA, 
          AA, 
          DA, 
          CLKB, 
          CENB, 
          WENB, 
          AB, 
          DB, 
          EMAA, 
          EMAWA, 
          EMAB, 
          EMAWB, 
          TENA, 
          TCENA, 
          TWENA, 
          TAA, 
          TDA, 
          TENB, 
          TCENB, 
          TWENB, 
          TAB, 
          TDB, 
          RET1N, 
          SIA, 
          SEA, 
          DFTRAMBYP, 
          SIB, 
          SEB, 
          COLLDISN
   );

   output                   CENYA;
   output                   WENYA;
   output [7:0]             AYA;
   output                   CENYB;
   output                   WENYB;
   output [7:0]             AYB;
   output [63:0]            QA;
   output [63:0]            QB;
   output [1:0]             SOA;
   output [1:0]             SOB;
   input                    CLKA;
   input                    CENA;
   input                    WENA;
   input [7:0]              AA;
   input [63:0]             DA;
   input                    CLKB;
   input                    CENB;
   input                    WENB;
   input [7:0]              AB;
   input [63:0]             DB;
   input [2:0]              EMAA;
   input [1:0]              EMAWA;
   input [2:0]              EMAB;
   input [1:0]              EMAWB;
   input                    TENA;
   input                    TCENA;
   input                    TWENA;
   input [7:0]              TAA;
   input [63:0]             TDA;
   input                    TENB;
   input                    TCENB;
   input                    TWENB;
   input [7:0]              TAB;
   input [63:0]             TDB;
   input                    RET1N;
   input [1:0]              SIA;
   input                    SEA;
   input                    DFTRAMBYP;
   input [1:0]              SIB;
   input                    SEB;
   input                    COLLDISN;
   wire [63:0]             DIA;
   wire [63:0]             QOA;
   wire [63:0]             DIB;
   wire [63:0]             QOB;

   assign QA=QOA;
   assign DIA=DA;
   assign QB=QOB;
   assign DIB=DB;

   SRAMdpw64d256_fr_top u0 (
         .CENYA(CENYA),
         .WENYA(WENYA),
         .AYA(AYA),
         .CENYB(CENYB),
         .WENYB(WENYB),
         .AYB(AYB),
         .QOA(QOA),
         .QOB(QOB),
         .SOA(SOA),
         .SOB(SOB),
         .CLKA(CLKA),
         .CENA(CENA),
         .WENA(WENA),
         .AA(AA),
         .DIA(DIA),
         .CLKB(CLKB),
         .CENB(CENB),
         .WENB(WENB),
         .AB(AB),
         .DIB(DIB),
         .EMAA(EMAA),
         .EMAWA(EMAWA),
         .EMAB(EMAB),
         .EMAWB(EMAWB),
         .TENA(TENA),
         .TCENA(TCENA),
         .TWENA(TWENA),
         .TAA(TAA),
         .TDA(TDA),
         .TENB(TENB),
         .TCENB(TCENB),
         .TWENB(TWENB),
         .TAB(TAB),
         .TDB(TDB),
         .RET1N(RET1N),
         .SIA(SIA),
         .SEA(SEA),
         .DFTRAMBYP(DFTRAMBYP),
         .SIB(SIB),
         .SEB(SEB),
         .COLLDISN(COLLDISN)
);

endmodule

module SRAMdpw64d256_fr_top (
          CENYA, 
          WENYA, 
          AYA, 
          CENYB, 
          WENYB, 
          AYB, 
          QOA, 
          QOB, 
          SOA, 
          SOB, 
          CLKA, 
          CENA, 
          WENA, 
          AA, 
          DIA, 
          CLKB, 
          CENB, 
          WENB, 
          AB, 
          DIB, 
          EMAA, 
          EMAWA, 
          EMAB, 
          EMAWB, 
          TENA, 
          TCENA, 
          TWENA, 
          TAA, 
          TDA, 
          TENB, 
          TCENB, 
          TWENB, 
          TAB, 
          TDB, 
          RET1N, 
          SIA, 
          SEA, 
          DFTRAMBYP, 
          SIB, 
          SEB, 
          COLLDISN
   );

   output                   CENYA;
   output                   WENYA;
   output [7:0]             AYA;
   output                   CENYB;
   output                   WENYB;
   output [7:0]             AYB;
   output [63:0]            QOA;
   output [63:0]            QOB;
   output [1:0]             SOA;
   output [1:0]             SOB;
   input                    CLKA;
   input                    CENA;
   input                    WENA;
   input [7:0]              AA;
   input [63:0]             DIA;
   input                    CLKB;
   input                    CENB;
   input                    WENB;
   input [7:0]              AB;
   input [63:0]             DIB;
   input [2:0]              EMAA;
   input [1:0]              EMAWA;
   input [2:0]              EMAB;
   input [1:0]              EMAWB;
   input                    TENA;
   input                    TCENA;
   input                    TWENA;
   input [7:0]              TAA;
   input [63:0]             TDA;
   input                    TENB;
   input                    TCENB;
   input                    TWENB;
   input [7:0]              TAB;
   input [63:0]             TDB;
   input                    RET1N;
   input [1:0]              SIA;
   input                    SEA;
   input                    DFTRAMBYP;
   input [1:0]              SIB;
   input                    SEB;
   input                    COLLDISN;

   wire [63:0]             DA;
   wire [63:0]             QA;
   wire [63:0]             DB;
   wire [63:0]             QB;

   assign DA = DIA;
   assign QOA = QA;
   assign DB = DIB;
   assign QOB = QB;
   SRAMdpw64d256 u0 (
         .CENYA(CENYA),
         .WENYA(WENYA),
         .AYA(AYA),
         .CENYB(CENYB),
         .WENYB(WENYB),
         .AYB(AYB),
         .QA(QA),
         .QB(QB),
         .SOA(SOA),
         .SOB(SOB),
         .CLKA(CLKA),
         .CENA(CENA),
         .WENA(WENA),
         .AA(AA),
         .DA(DA),
         .CLKB(CLKB),
         .CENB(CENB),
         .WENB(WENB),
         .AB(AB),
         .DB(DB),
         .EMAA(EMAA),
         .EMAWA(EMAWA),
         .EMAB(EMAB),
         .EMAWB(EMAWB),
         .TENA(TENA),
         .TCENA(TCENA),
         .TWENA(TWENA),
         .TAA(TAA),
         .TDA(TDA),
         .TENB(TENB),
         .TCENB(TCENB),
         .TWENB(TWENB),
         .TAB(TAB),
         .TDB(TDB),
         .RET1N(RET1N),
         .SIA(SIA),
         .SEA(SEA),
         .DFTRAMBYP(DFTRAMBYP),
         .SIB(SIB),
         .SEB(SEB),
         .COLLDISN(COLLDISN)
   );

endmodule // SRAMdpw64d256_fr_top

