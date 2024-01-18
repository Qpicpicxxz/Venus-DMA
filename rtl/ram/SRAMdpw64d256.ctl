/* ctl_memcomp Version: 4.0.5-EAC3 */
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
//      CTL model for Synchronous Dual-Port Ram
//
//       Instance Name:              SRAMdpw64d256
//       Words:                      256
//       Bits:                       64
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Redundant Columns:          0
//       Test Muxes                  On
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Tue Jan 16 15:30:53 2024
//       Version: 	r1p1
STIL 1.0 {
   CTL P2001.10;
   Design P2001.01;
}
Header {
   Title "CTL model for `SRAMdpw64d256";
}
Signals {
   "CENYA" Out;
   "WENYA" Out;
   "AYA[7]" Out;
   "AYA[6]" Out;
   "AYA[5]" Out;
   "AYA[4]" Out;
   "AYA[3]" Out;
   "AYA[2]" Out;
   "AYA[1]" Out;
   "AYA[0]" Out;
   "CENYB" Out;
   "WENYB" Out;
   "AYB[7]" Out;
   "AYB[6]" Out;
   "AYB[5]" Out;
   "AYB[4]" Out;
   "AYB[3]" Out;
   "AYB[2]" Out;
   "AYB[1]" Out;
   "AYB[0]" Out;
   "QA[63]" Out;
   "QA[62]" Out;
   "QA[61]" Out;
   "QA[60]" Out;
   "QA[59]" Out;
   "QA[58]" Out;
   "QA[57]" Out;
   "QA[56]" Out;
   "QA[55]" Out;
   "QA[54]" Out;
   "QA[53]" Out;
   "QA[52]" Out;
   "QA[51]" Out;
   "QA[50]" Out;
   "QA[49]" Out;
   "QA[48]" Out;
   "QA[47]" Out;
   "QA[46]" Out;
   "QA[45]" Out;
   "QA[44]" Out;
   "QA[43]" Out;
   "QA[42]" Out;
   "QA[41]" Out;
   "QA[40]" Out;
   "QA[39]" Out;
   "QA[38]" Out;
   "QA[37]" Out;
   "QA[36]" Out;
   "QA[35]" Out;
   "QA[34]" Out;
   "QA[33]" Out;
   "QA[32]" Out;
   "QA[31]" Out;
   "QA[30]" Out;
   "QA[29]" Out;
   "QA[28]" Out;
   "QA[27]" Out;
   "QA[26]" Out;
   "QA[25]" Out;
   "QA[24]" Out;
   "QA[23]" Out;
   "QA[22]" Out;
   "QA[21]" Out;
   "QA[20]" Out;
   "QA[19]" Out;
   "QA[18]" Out;
   "QA[17]" Out;
   "QA[16]" Out;
   "QA[15]" Out;
   "QA[14]" Out;
   "QA[13]" Out;
   "QA[12]" Out;
   "QA[11]" Out;
   "QA[10]" Out;
   "QA[9]" Out;
   "QA[8]" Out;
   "QA[7]" Out;
   "QA[6]" Out;
   "QA[5]" Out;
   "QA[4]" Out;
   "QA[3]" Out;
   "QA[2]" Out;
   "QA[1]" Out;
   "QA[0]" Out;
   "QB[63]" Out;
   "QB[62]" Out;
   "QB[61]" Out;
   "QB[60]" Out;
   "QB[59]" Out;
   "QB[58]" Out;
   "QB[57]" Out;
   "QB[56]" Out;
   "QB[55]" Out;
   "QB[54]" Out;
   "QB[53]" Out;
   "QB[52]" Out;
   "QB[51]" Out;
   "QB[50]" Out;
   "QB[49]" Out;
   "QB[48]" Out;
   "QB[47]" Out;
   "QB[46]" Out;
   "QB[45]" Out;
   "QB[44]" Out;
   "QB[43]" Out;
   "QB[42]" Out;
   "QB[41]" Out;
   "QB[40]" Out;
   "QB[39]" Out;
   "QB[38]" Out;
   "QB[37]" Out;
   "QB[36]" Out;
   "QB[35]" Out;
   "QB[34]" Out;
   "QB[33]" Out;
   "QB[32]" Out;
   "QB[31]" Out;
   "QB[30]" Out;
   "QB[29]" Out;
   "QB[28]" Out;
   "QB[27]" Out;
   "QB[26]" Out;
   "QB[25]" Out;
   "QB[24]" Out;
   "QB[23]" Out;
   "QB[22]" Out;
   "QB[21]" Out;
   "QB[20]" Out;
   "QB[19]" Out;
   "QB[18]" Out;
   "QB[17]" Out;
   "QB[16]" Out;
   "QB[15]" Out;
   "QB[14]" Out;
   "QB[13]" Out;
   "QB[12]" Out;
   "QB[11]" Out;
   "QB[10]" Out;
   "QB[9]" Out;
   "QB[8]" Out;
   "QB[7]" Out;
   "QB[6]" Out;
   "QB[5]" Out;
   "QB[4]" Out;
   "QB[3]" Out;
   "QB[2]" Out;
   "QB[1]" Out;
   "QB[0]" Out;
   "SOA[1]" Out;
   "SOA[0]" Out;
   "SOB[1]" Out;
   "SOB[0]" Out;
   "CLKA" In;
   "CENA" In;
   "WENA" In;
   "AA[7]" In;
   "AA[6]" In;
   "AA[5]" In;
   "AA[4]" In;
   "AA[3]" In;
   "AA[2]" In;
   "AA[1]" In;
   "AA[0]" In;
   "DA[63]" In;
   "DA[62]" In;
   "DA[61]" In;
   "DA[60]" In;
   "DA[59]" In;
   "DA[58]" In;
   "DA[57]" In;
   "DA[56]" In;
   "DA[55]" In;
   "DA[54]" In;
   "DA[53]" In;
   "DA[52]" In;
   "DA[51]" In;
   "DA[50]" In;
   "DA[49]" In;
   "DA[48]" In;
   "DA[47]" In;
   "DA[46]" In;
   "DA[45]" In;
   "DA[44]" In;
   "DA[43]" In;
   "DA[42]" In;
   "DA[41]" In;
   "DA[40]" In;
   "DA[39]" In;
   "DA[38]" In;
   "DA[37]" In;
   "DA[36]" In;
   "DA[35]" In;
   "DA[34]" In;
   "DA[33]" In;
   "DA[32]" In;
   "DA[31]" In;
   "DA[30]" In;
   "DA[29]" In;
   "DA[28]" In;
   "DA[27]" In;
   "DA[26]" In;
   "DA[25]" In;
   "DA[24]" In;
   "DA[23]" In;
   "DA[22]" In;
   "DA[21]" In;
   "DA[20]" In;
   "DA[19]" In;
   "DA[18]" In;
   "DA[17]" In;
   "DA[16]" In;
   "DA[15]" In;
   "DA[14]" In;
   "DA[13]" In;
   "DA[12]" In;
   "DA[11]" In;
   "DA[10]" In;
   "DA[9]" In;
   "DA[8]" In;
   "DA[7]" In;
   "DA[6]" In;
   "DA[5]" In;
   "DA[4]" In;
   "DA[3]" In;
   "DA[2]" In;
   "DA[1]" In;
   "DA[0]" In;
   "CLKB" In;
   "CENB" In;
   "WENB" In;
   "AB[7]" In;
   "AB[6]" In;
   "AB[5]" In;
   "AB[4]" In;
   "AB[3]" In;
   "AB[2]" In;
   "AB[1]" In;
   "AB[0]" In;
   "DB[63]" In;
   "DB[62]" In;
   "DB[61]" In;
   "DB[60]" In;
   "DB[59]" In;
   "DB[58]" In;
   "DB[57]" In;
   "DB[56]" In;
   "DB[55]" In;
   "DB[54]" In;
   "DB[53]" In;
   "DB[52]" In;
   "DB[51]" In;
   "DB[50]" In;
   "DB[49]" In;
   "DB[48]" In;
   "DB[47]" In;
   "DB[46]" In;
   "DB[45]" In;
   "DB[44]" In;
   "DB[43]" In;
   "DB[42]" In;
   "DB[41]" In;
   "DB[40]" In;
   "DB[39]" In;
   "DB[38]" In;
   "DB[37]" In;
   "DB[36]" In;
   "DB[35]" In;
   "DB[34]" In;
   "DB[33]" In;
   "DB[32]" In;
   "DB[31]" In;
   "DB[30]" In;
   "DB[29]" In;
   "DB[28]" In;
   "DB[27]" In;
   "DB[26]" In;
   "DB[25]" In;
   "DB[24]" In;
   "DB[23]" In;
   "DB[22]" In;
   "DB[21]" In;
   "DB[20]" In;
   "DB[19]" In;
   "DB[18]" In;
   "DB[17]" In;
   "DB[16]" In;
   "DB[15]" In;
   "DB[14]" In;
   "DB[13]" In;
   "DB[12]" In;
   "DB[11]" In;
   "DB[10]" In;
   "DB[9]" In;
   "DB[8]" In;
   "DB[7]" In;
   "DB[6]" In;
   "DB[5]" In;
   "DB[4]" In;
   "DB[3]" In;
   "DB[2]" In;
   "DB[1]" In;
   "DB[0]" In;
   "EMAA[2]" In;
   "EMAA[1]" In;
   "EMAA[0]" In;
   "EMAWA[1]" In;
   "EMAWA[0]" In;
   "EMAB[2]" In;
   "EMAB[1]" In;
   "EMAB[0]" In;
   "EMAWB[1]" In;
   "EMAWB[0]" In;
   "TENA" In;
   "TCENA" In;
   "TWENA" In;
   "TAA[7]" In;
   "TAA[6]" In;
   "TAA[5]" In;
   "TAA[4]" In;
   "TAA[3]" In;
   "TAA[2]" In;
   "TAA[1]" In;
   "TAA[0]" In;
   "TDA[63]" In;
   "TDA[62]" In;
   "TDA[61]" In;
   "TDA[60]" In;
   "TDA[59]" In;
   "TDA[58]" In;
   "TDA[57]" In;
   "TDA[56]" In;
   "TDA[55]" In;
   "TDA[54]" In;
   "TDA[53]" In;
   "TDA[52]" In;
   "TDA[51]" In;
   "TDA[50]" In;
   "TDA[49]" In;
   "TDA[48]" In;
   "TDA[47]" In;
   "TDA[46]" In;
   "TDA[45]" In;
   "TDA[44]" In;
   "TDA[43]" In;
   "TDA[42]" In;
   "TDA[41]" In;
   "TDA[40]" In;
   "TDA[39]" In;
   "TDA[38]" In;
   "TDA[37]" In;
   "TDA[36]" In;
   "TDA[35]" In;
   "TDA[34]" In;
   "TDA[33]" In;
   "TDA[32]" In;
   "TDA[31]" In;
   "TDA[30]" In;
   "TDA[29]" In;
   "TDA[28]" In;
   "TDA[27]" In;
   "TDA[26]" In;
   "TDA[25]" In;
   "TDA[24]" In;
   "TDA[23]" In;
   "TDA[22]" In;
   "TDA[21]" In;
   "TDA[20]" In;
   "TDA[19]" In;
   "TDA[18]" In;
   "TDA[17]" In;
   "TDA[16]" In;
   "TDA[15]" In;
   "TDA[14]" In;
   "TDA[13]" In;
   "TDA[12]" In;
   "TDA[11]" In;
   "TDA[10]" In;
   "TDA[9]" In;
   "TDA[8]" In;
   "TDA[7]" In;
   "TDA[6]" In;
   "TDA[5]" In;
   "TDA[4]" In;
   "TDA[3]" In;
   "TDA[2]" In;
   "TDA[1]" In;
   "TDA[0]" In;
   "TENB" In;
   "TCENB" In;
   "TWENB" In;
   "TAB[7]" In;
   "TAB[6]" In;
   "TAB[5]" In;
   "TAB[4]" In;
   "TAB[3]" In;
   "TAB[2]" In;
   "TAB[1]" In;
   "TAB[0]" In;
   "TDB[63]" In;
   "TDB[62]" In;
   "TDB[61]" In;
   "TDB[60]" In;
   "TDB[59]" In;
   "TDB[58]" In;
   "TDB[57]" In;
   "TDB[56]" In;
   "TDB[55]" In;
   "TDB[54]" In;
   "TDB[53]" In;
   "TDB[52]" In;
   "TDB[51]" In;
   "TDB[50]" In;
   "TDB[49]" In;
   "TDB[48]" In;
   "TDB[47]" In;
   "TDB[46]" In;
   "TDB[45]" In;
   "TDB[44]" In;
   "TDB[43]" In;
   "TDB[42]" In;
   "TDB[41]" In;
   "TDB[40]" In;
   "TDB[39]" In;
   "TDB[38]" In;
   "TDB[37]" In;
   "TDB[36]" In;
   "TDB[35]" In;
   "TDB[34]" In;
   "TDB[33]" In;
   "TDB[32]" In;
   "TDB[31]" In;
   "TDB[30]" In;
   "TDB[29]" In;
   "TDB[28]" In;
   "TDB[27]" In;
   "TDB[26]" In;
   "TDB[25]" In;
   "TDB[24]" In;
   "TDB[23]" In;
   "TDB[22]" In;
   "TDB[21]" In;
   "TDB[20]" In;
   "TDB[19]" In;
   "TDB[18]" In;
   "TDB[17]" In;
   "TDB[16]" In;
   "TDB[15]" In;
   "TDB[14]" In;
   "TDB[13]" In;
   "TDB[12]" In;
   "TDB[11]" In;
   "TDB[10]" In;
   "TDB[9]" In;
   "TDB[8]" In;
   "TDB[7]" In;
   "TDB[6]" In;
   "TDB[5]" In;
   "TDB[4]" In;
   "TDB[3]" In;
   "TDB[2]" In;
   "TDB[1]" In;
   "TDB[0]" In;
   "RET1N" In;
   "SIA[1]" In;
   "SIA[0]" In;
   "SEA" In;
   "DFTRAMBYP" In;
   "SIB[1]" In;
   "SIB[0]" In;
   "SEB" In;
   "COLLDISN" In;
}
SignalGroups {
   "all_inputs" = '"CLKA" + "CENA" + "WENA" + "AA[7]" + "AA[6]" + "AA[5]" + "AA[4]" + 
   "AA[3]" + "AA[2]" + "AA[1]" + "AA[0]" + "DA[63]" + "DA[62]" + "DA[61]" + "DA[60]" + 
   "DA[59]" + "DA[58]" + "DA[57]" + "DA[56]" + "DA[55]" + "DA[54]" + "DA[53]" + "DA[52]" + 
   "DA[51]" + "DA[50]" + "DA[49]" + "DA[48]" + "DA[47]" + "DA[46]" + "DA[45]" + "DA[44]" + 
   "DA[43]" + "DA[42]" + "DA[41]" + "DA[40]" + "DA[39]" + "DA[38]" + "DA[37]" + "DA[36]" + 
   "DA[35]" + "DA[34]" + "DA[33]" + "DA[32]" + "DA[31]" + "DA[30]" + "DA[29]" + "DA[28]" + 
   "DA[27]" + "DA[26]" + "DA[25]" + "DA[24]" + "DA[23]" + "DA[22]" + "DA[21]" + "DA[20]" + 
   "DA[19]" + "DA[18]" + "DA[17]" + "DA[16]" + "DA[15]" + "DA[14]" + "DA[13]" + "DA[12]" + 
   "DA[11]" + "DA[10]" + "DA[9]" + "DA[8]" + "DA[7]" + "DA[6]" + "DA[5]" + "DA[4]" + 
   "DA[3]" + "DA[2]" + "DA[1]" + "DA[0]" + "CLKB" + "CENB" + "WENB" + "AB[7]" + "AB[6]" + 
   "AB[5]" + "AB[4]" + "AB[3]" + "AB[2]" + "AB[1]" + "AB[0]" + "DB[63]" + "DB[62]" + 
   "DB[61]" + "DB[60]" + "DB[59]" + "DB[58]" + "DB[57]" + "DB[56]" + "DB[55]" + "DB[54]" + 
   "DB[53]" + "DB[52]" + "DB[51]" + "DB[50]" + "DB[49]" + "DB[48]" + "DB[47]" + "DB[46]" + 
   "DB[45]" + "DB[44]" + "DB[43]" + "DB[42]" + "DB[41]" + "DB[40]" + "DB[39]" + "DB[38]" + 
   "DB[37]" + "DB[36]" + "DB[35]" + "DB[34]" + "DB[33]" + "DB[32]" + "DB[31]" + "DB[30]" + 
   "DB[29]" + "DB[28]" + "DB[27]" + "DB[26]" + "DB[25]" + "DB[24]" + "DB[23]" + "DB[22]" + 
   "DB[21]" + "DB[20]" + "DB[19]" + "DB[18]" + "DB[17]" + "DB[16]" + "DB[15]" + "DB[14]" + 
   "DB[13]" + "DB[12]" + "DB[11]" + "DB[10]" + "DB[9]" + "DB[8]" + "DB[7]" + "DB[6]" + 
   "DB[5]" + "DB[4]" + "DB[3]" + "DB[2]" + "DB[1]" + "DB[0]" + "EMAA[2]" + "EMAA[1]" + 
   "EMAA[0]" + "EMAWA[1]" + "EMAWA[0]" + "EMAB[2]" + "EMAB[1]" + "EMAB[0]" + "EMAWB[1]" + 
   "EMAWB[0]" + "TENA" + "TCENA" + "TWENA" + "TAA[7]" + "TAA[6]" + "TAA[5]" + "TAA[4]" + 
   "TAA[3]" + "TAA[2]" + "TAA[1]" + "TAA[0]" + "TDA[63]" + "TDA[62]" + "TDA[61]" + 
   "TDA[60]" + "TDA[59]" + "TDA[58]" + "TDA[57]" + "TDA[56]" + "TDA[55]" + "TDA[54]" + 
   "TDA[53]" + "TDA[52]" + "TDA[51]" + "TDA[50]" + "TDA[49]" + "TDA[48]" + "TDA[47]" + 
   "TDA[46]" + "TDA[45]" + "TDA[44]" + "TDA[43]" + "TDA[42]" + "TDA[41]" + "TDA[40]" + 
   "TDA[39]" + "TDA[38]" + "TDA[37]" + "TDA[36]" + "TDA[35]" + "TDA[34]" + "TDA[33]" + 
   "TDA[32]" + "TDA[31]" + "TDA[30]" + "TDA[29]" + "TDA[28]" + "TDA[27]" + "TDA[26]" + 
   "TDA[25]" + "TDA[24]" + "TDA[23]" + "TDA[22]" + "TDA[21]" + "TDA[20]" + "TDA[19]" + 
   "TDA[18]" + "TDA[17]" + "TDA[16]" + "TDA[15]" + "TDA[14]" + "TDA[13]" + "TDA[12]" + 
   "TDA[11]" + "TDA[10]" + "TDA[9]" + "TDA[8]" + "TDA[7]" + "TDA[6]" + "TDA[5]" + 
   "TDA[4]" + "TDA[3]" + "TDA[2]" + "TDA[1]" + "TDA[0]" + "TENB" + "TCENB" + "TWENB" + 
   "TAB[7]" + "TAB[6]" + "TAB[5]" + "TAB[4]" + "TAB[3]" + "TAB[2]" + "TAB[1]" + "TAB[0]" + 
   "TDB[63]" + "TDB[62]" + "TDB[61]" + "TDB[60]" + "TDB[59]" + "TDB[58]" + "TDB[57]" + 
   "TDB[56]" + "TDB[55]" + "TDB[54]" + "TDB[53]" + "TDB[52]" + "TDB[51]" + "TDB[50]" + 
   "TDB[49]" + "TDB[48]" + "TDB[47]" + "TDB[46]" + "TDB[45]" + "TDB[44]" + "TDB[43]" + 
   "TDB[42]" + "TDB[41]" + "TDB[40]" + "TDB[39]" + "TDB[38]" + "TDB[37]" + "TDB[36]" + 
   "TDB[35]" + "TDB[34]" + "TDB[33]" + "TDB[32]" + "TDB[31]" + "TDB[30]" + "TDB[29]" + 
   "TDB[28]" + "TDB[27]" + "TDB[26]" + "TDB[25]" + "TDB[24]" + "TDB[23]" + "TDB[22]" + 
   "TDB[21]" + "TDB[20]" + "TDB[19]" + "TDB[18]" + "TDB[17]" + "TDB[16]" + "TDB[15]" + 
   "TDB[14]" + "TDB[13]" + "TDB[12]" + "TDB[11]" + "TDB[10]" + "TDB[9]" + "TDB[8]" + 
   "TDB[7]" + "TDB[6]" + "TDB[5]" + "TDB[4]" + "TDB[3]" + "TDB[2]" + "TDB[1]" + "TDB[0]" + 
   "RET1N" + "SIA[1]" + "SIA[0]" + "SEA" + "DFTRAMBYP" + "SIB[1]" + "SIB[0]" + "SEB" + 
   "COLLDISN"';
   "all_outputs" = '"CENYA" + "WENYA" + "AYA[7]" + "AYA[6]" + "AYA[5]" + "AYA[4]" + 
   "AYA[3]" + "AYA[2]" + "AYA[1]" + "AYA[0]" + "CENYB" + "WENYB" + "AYB[7]" + "AYB[6]" + 
   "AYB[5]" + "AYB[4]" + "AYB[3]" + "AYB[2]" + "AYB[1]" + "AYB[0]" + "QA[63]" + "QA[62]" + 
   "QA[61]" + "QA[60]" + "QA[59]" + "QA[58]" + "QA[57]" + "QA[56]" + "QA[55]" + "QA[54]" + 
   "QA[53]" + "QA[52]" + "QA[51]" + "QA[50]" + "QA[49]" + "QA[48]" + "QA[47]" + "QA[46]" + 
   "QA[45]" + "QA[44]" + "QA[43]" + "QA[42]" + "QA[41]" + "QA[40]" + "QA[39]" + "QA[38]" + 
   "QA[37]" + "QA[36]" + "QA[35]" + "QA[34]" + "QA[33]" + "QA[32]" + "QA[31]" + "QA[30]" + 
   "QA[29]" + "QA[28]" + "QA[27]" + "QA[26]" + "QA[25]" + "QA[24]" + "QA[23]" + "QA[22]" + 
   "QA[21]" + "QA[20]" + "QA[19]" + "QA[18]" + "QA[17]" + "QA[16]" + "QA[15]" + "QA[14]" + 
   "QA[13]" + "QA[12]" + "QA[11]" + "QA[10]" + "QA[9]" + "QA[8]" + "QA[7]" + "QA[6]" + 
   "QA[5]" + "QA[4]" + "QA[3]" + "QA[2]" + "QA[1]" + "QA[0]" + "QB[63]" + "QB[62]" + 
   "QB[61]" + "QB[60]" + "QB[59]" + "QB[58]" + "QB[57]" + "QB[56]" + "QB[55]" + "QB[54]" + 
   "QB[53]" + "QB[52]" + "QB[51]" + "QB[50]" + "QB[49]" + "QB[48]" + "QB[47]" + "QB[46]" + 
   "QB[45]" + "QB[44]" + "QB[43]" + "QB[42]" + "QB[41]" + "QB[40]" + "QB[39]" + "QB[38]" + 
   "QB[37]" + "QB[36]" + "QB[35]" + "QB[34]" + "QB[33]" + "QB[32]" + "QB[31]" + "QB[30]" + 
   "QB[29]" + "QB[28]" + "QB[27]" + "QB[26]" + "QB[25]" + "QB[24]" + "QB[23]" + "QB[22]" + 
   "QB[21]" + "QB[20]" + "QB[19]" + "QB[18]" + "QB[17]" + "QB[16]" + "QB[15]" + "QB[14]" + 
   "QB[13]" + "QB[12]" + "QB[11]" + "QB[10]" + "QB[9]" + "QB[8]" + "QB[7]" + "QB[6]" + 
   "QB[5]" + "QB[4]" + "QB[3]" + "QB[2]" + "QB[1]" + "QB[0]" + "SOA[1]" + "SOA[0]" + 
   "SOB[1]" + "SOB[0]"';
   "all_ports" = '"all_inputs" + "all_outputs"';
   "_pi" = '"CLKA" + "CENA" + "WENA" + "AA[7]" + "AA[6]" + "AA[5]" + "AA[4]" + "AA[3]" + 
   "AA[2]" + "AA[1]" + "AA[0]" + "DA[63]" + "DA[62]" + "DA[61]" + "DA[60]" + "DA[59]" + 
   "DA[58]" + "DA[57]" + "DA[56]" + "DA[55]" + "DA[54]" + "DA[53]" + "DA[52]" + "DA[51]" + 
   "DA[50]" + "DA[49]" + "DA[48]" + "DA[47]" + "DA[46]" + "DA[45]" + "DA[44]" + "DA[43]" + 
   "DA[42]" + "DA[41]" + "DA[40]" + "DA[39]" + "DA[38]" + "DA[37]" + "DA[36]" + "DA[35]" + 
   "DA[34]" + "DA[33]" + "DA[32]" + "DA[31]" + "DA[30]" + "DA[29]" + "DA[28]" + "DA[27]" + 
   "DA[26]" + "DA[25]" + "DA[24]" + "DA[23]" + "DA[22]" + "DA[21]" + "DA[20]" + "DA[19]" + 
   "DA[18]" + "DA[17]" + "DA[16]" + "DA[15]" + "DA[14]" + "DA[13]" + "DA[12]" + "DA[11]" + 
   "DA[10]" + "DA[9]" + "DA[8]" + "DA[7]" + "DA[6]" + "DA[5]" + "DA[4]" + "DA[3]" + 
   "DA[2]" + "DA[1]" + "DA[0]" + "CLKB" + "CENB" + "WENB" + "AB[7]" + "AB[6]" + "AB[5]" + 
   "AB[4]" + "AB[3]" + "AB[2]" + "AB[1]" + "AB[0]" + "DB[63]" + "DB[62]" + "DB[61]" + 
   "DB[60]" + "DB[59]" + "DB[58]" + "DB[57]" + "DB[56]" + "DB[55]" + "DB[54]" + "DB[53]" + 
   "DB[52]" + "DB[51]" + "DB[50]" + "DB[49]" + "DB[48]" + "DB[47]" + "DB[46]" + "DB[45]" + 
   "DB[44]" + "DB[43]" + "DB[42]" + "DB[41]" + "DB[40]" + "DB[39]" + "DB[38]" + "DB[37]" + 
   "DB[36]" + "DB[35]" + "DB[34]" + "DB[33]" + "DB[32]" + "DB[31]" + "DB[30]" + "DB[29]" + 
   "DB[28]" + "DB[27]" + "DB[26]" + "DB[25]" + "DB[24]" + "DB[23]" + "DB[22]" + "DB[21]" + 
   "DB[20]" + "DB[19]" + "DB[18]" + "DB[17]" + "DB[16]" + "DB[15]" + "DB[14]" + "DB[13]" + 
   "DB[12]" + "DB[11]" + "DB[10]" + "DB[9]" + "DB[8]" + "DB[7]" + "DB[6]" + "DB[5]" + 
   "DB[4]" + "DB[3]" + "DB[2]" + "DB[1]" + "DB[0]" + "EMAA[2]" + "EMAA[1]" + "EMAA[0]" + 
   "EMAWA[1]" + "EMAWA[0]" + "EMAB[2]" + "EMAB[1]" + "EMAB[0]" + "EMAWB[1]" + "EMAWB[0]" + 
   "TENA" + "TCENA" + "TWENA" + "TAA[7]" + "TAA[6]" + "TAA[5]" + "TAA[4]" + "TAA[3]" + 
   "TAA[2]" + "TAA[1]" + "TAA[0]" + "TDA[63]" + "TDA[62]" + "TDA[61]" + "TDA[60]" + 
   "TDA[59]" + "TDA[58]" + "TDA[57]" + "TDA[56]" + "TDA[55]" + "TDA[54]" + "TDA[53]" + 
   "TDA[52]" + "TDA[51]" + "TDA[50]" + "TDA[49]" + "TDA[48]" + "TDA[47]" + "TDA[46]" + 
   "TDA[45]" + "TDA[44]" + "TDA[43]" + "TDA[42]" + "TDA[41]" + "TDA[40]" + "TDA[39]" + 
   "TDA[38]" + "TDA[37]" + "TDA[36]" + "TDA[35]" + "TDA[34]" + "TDA[33]" + "TDA[32]" + 
   "TDA[31]" + "TDA[30]" + "TDA[29]" + "TDA[28]" + "TDA[27]" + "TDA[26]" + "TDA[25]" + 
   "TDA[24]" + "TDA[23]" + "TDA[22]" + "TDA[21]" + "TDA[20]" + "TDA[19]" + "TDA[18]" + 
   "TDA[17]" + "TDA[16]" + "TDA[15]" + "TDA[14]" + "TDA[13]" + "TDA[12]" + "TDA[11]" + 
   "TDA[10]" + "TDA[9]" + "TDA[8]" + "TDA[7]" + "TDA[6]" + "TDA[5]" + "TDA[4]" + 
   "TDA[3]" + "TDA[2]" + "TDA[1]" + "TDA[0]" + "TENB" + "TCENB" + "TWENB" + "TAB[7]" + 
   "TAB[6]" + "TAB[5]" + "TAB[4]" + "TAB[3]" + "TAB[2]" + "TAB[1]" + "TAB[0]" + "TDB[63]" + 
   "TDB[62]" + "TDB[61]" + "TDB[60]" + "TDB[59]" + "TDB[58]" + "TDB[57]" + "TDB[56]" + 
   "TDB[55]" + "TDB[54]" + "TDB[53]" + "TDB[52]" + "TDB[51]" + "TDB[50]" + "TDB[49]" + 
   "TDB[48]" + "TDB[47]" + "TDB[46]" + "TDB[45]" + "TDB[44]" + "TDB[43]" + "TDB[42]" + 
   "TDB[41]" + "TDB[40]" + "TDB[39]" + "TDB[38]" + "TDB[37]" + "TDB[36]" + "TDB[35]" + 
   "TDB[34]" + "TDB[33]" + "TDB[32]" + "TDB[31]" + "TDB[30]" + "TDB[29]" + "TDB[28]" + 
   "TDB[27]" + "TDB[26]" + "TDB[25]" + "TDB[24]" + "TDB[23]" + "TDB[22]" + "TDB[21]" + 
   "TDB[20]" + "TDB[19]" + "TDB[18]" + "TDB[17]" + "TDB[16]" + "TDB[15]" + "TDB[14]" + 
   "TDB[13]" + "TDB[12]" + "TDB[11]" + "TDB[10]" + "TDB[9]" + "TDB[8]" + "TDB[7]" + 
   "TDB[6]" + "TDB[5]" + "TDB[4]" + "TDB[3]" + "TDB[2]" + "TDB[1]" + "TDB[0]" + "RET1N" + 
   "SIA[1]" + "SIA[0]" + "SEA" + "DFTRAMBYP" + "SIB[1]" + "SIB[0]" + "SEB" + "COLLDISN"';
   "_po" = '"CENYA" + "WENYA" + "AYA[7]" + "AYA[6]" + "AYA[5]" + "AYA[4]" + "AYA[3]" + 
   "AYA[2]" + "AYA[1]" + "AYA[0]" + "CENYB" + "WENYB" + "AYB[7]" + "AYB[6]" + "AYB[5]" + 
   "AYB[4]" + "AYB[3]" + "AYB[2]" + "AYB[1]" + "AYB[0]" + "QA[63]" + "QA[62]" + "QA[61]" + 
   "QA[60]" + "QA[59]" + "QA[58]" + "QA[57]" + "QA[56]" + "QA[55]" + "QA[54]" + "QA[53]" + 
   "QA[52]" + "QA[51]" + "QA[50]" + "QA[49]" + "QA[48]" + "QA[47]" + "QA[46]" + "QA[45]" + 
   "QA[44]" + "QA[43]" + "QA[42]" + "QA[41]" + "QA[40]" + "QA[39]" + "QA[38]" + "QA[37]" + 
   "QA[36]" + "QA[35]" + "QA[34]" + "QA[33]" + "QA[32]" + "QA[31]" + "QA[30]" + "QA[29]" + 
   "QA[28]" + "QA[27]" + "QA[26]" + "QA[25]" + "QA[24]" + "QA[23]" + "QA[22]" + "QA[21]" + 
   "QA[20]" + "QA[19]" + "QA[18]" + "QA[17]" + "QA[16]" + "QA[15]" + "QA[14]" + "QA[13]" + 
   "QA[12]" + "QA[11]" + "QA[10]" + "QA[9]" + "QA[8]" + "QA[7]" + "QA[6]" + "QA[5]" + 
   "QA[4]" + "QA[3]" + "QA[2]" + "QA[1]" + "QA[0]" + "QB[63]" + "QB[62]" + "QB[61]" + 
   "QB[60]" + "QB[59]" + "QB[58]" + "QB[57]" + "QB[56]" + "QB[55]" + "QB[54]" + "QB[53]" + 
   "QB[52]" + "QB[51]" + "QB[50]" + "QB[49]" + "QB[48]" + "QB[47]" + "QB[46]" + "QB[45]" + 
   "QB[44]" + "QB[43]" + "QB[42]" + "QB[41]" + "QB[40]" + "QB[39]" + "QB[38]" + "QB[37]" + 
   "QB[36]" + "QB[35]" + "QB[34]" + "QB[33]" + "QB[32]" + "QB[31]" + "QB[30]" + "QB[29]" + 
   "QB[28]" + "QB[27]" + "QB[26]" + "QB[25]" + "QB[24]" + "QB[23]" + "QB[22]" + "QB[21]" + 
   "QB[20]" + "QB[19]" + "QB[18]" + "QB[17]" + "QB[16]" + "QB[15]" + "QB[14]" + "QB[13]" + 
   "QB[12]" + "QB[11]" + "QB[10]" + "QB[9]" + "QB[8]" + "QB[7]" + "QB[6]" + "QB[5]" + 
   "QB[4]" + "QB[3]" + "QB[2]" + "QB[1]" + "QB[0]" + "SOA[1]" + "SOA[0]" + "SOB[1]" + 
   "SOB[0]"';
   "_si" = '"SIA[0]" + "SIA[1]" + "SIB[0]" + "SIB[1]"' {ScanIn; }
   "_so" = '"SOA[0]" + "SOA[1]" + "SOB[0]" + "SOB[1]"' {ScanOut; }
}
ScanStructures {
   ScanChain "chain_SRAMdpw64d256_1" {
      ScanLength  32;
      ScanCells   "uDQA0" "uDQA1" "uDQA2" "uDQA3" "uDQA4" "uDQA5" "uDQA6" "uDQA7" "uDQA8" "uDQA9" "uDQA10" "uDQA11" "uDQA12" "uDQA13" "uDQA14" "uDQA15" "uDQA16" "uDQA17" "uDQA18" "uDQA19" "uDQA20" "uDQA21" "uDQA22" "uDQA23" "uDQA24" "uDQA25" "uDQA26" "uDQA27" "uDQA28" "uDQA29" "uDQA30" "uDQA31" ;
      ScanIn  "SIA[0]";
      ScanOut  "SOA[0]";
      ScanEnable  "SEA";
      ScanMasterClock  "CLKA";
   }
   ScanChain "chain_SRAMdpw64d256_2" {
      ScanLength  32;
      ScanCells  "uDQA63" "uDQA62" "uDQA61" "uDQA60" "uDQA59" "uDQA58" "uDQA57" "uDQA56" "uDQA55" "uDQA54" "uDQA53" "uDQA52" "uDQA51" "uDQA50" "uDQA49" "uDQA48" "uDQA47" "uDQA46" "uDQA45" "uDQA44" "uDQA43" "uDQA42" "uDQA41" "uDQA40" "uDQA39" "uDQA38" "uDQA37" "uDQA36" "uDQA35" "uDQA34" "uDQA33" "uDQA32"  ;
      ScanIn  "SIA[1]";
      ScanOut  "SOA[1]";
      ScanEnable  "SEA";
      ScanMasterClock  "CLKA";
   }
   ScanChain "chain_SRAMdpw64d256_3" {
      ScanLength  32;
      ScanCells   "uDQB0" "uDQB1" "uDQB2" "uDQB3" "uDQB4" "uDQB5" "uDQB6" "uDQB7" "uDQB8" "uDQB9" "uDQB10" "uDQB11" "uDQB12" "uDQB13" "uDQB14" "uDQB15" "uDQB16" "uDQB17" "uDQB18" "uDQB19" "uDQB20" "uDQB21" "uDQB22" "uDQB23" "uDQB24" "uDQB25" "uDQB26" "uDQB27" "uDQB28" "uDQB29" "uDQB30" "uDQB31" ;
      ScanIn  "SIB[0]";
      ScanOut  "SOB[0]";
      ScanEnable  "SEB";
      ScanMasterClock  "CLKB";
   }
   ScanChain "chain_SRAMdpw64d256_4" {
      ScanLength  32;
      ScanCells  "uDQB63" "uDQB62" "uDQB61" "uDQB60" "uDQB59" "uDQB58" "uDQB57" "uDQB56" "uDQB55" "uDQB54" "uDQB53" "uDQB52" "uDQB51" "uDQB50" "uDQB49" "uDQB48" "uDQB47" "uDQB46" "uDQB45" "uDQB44" "uDQB43" "uDQB42" "uDQB41" "uDQB40" "uDQB39" "uDQB38" "uDQB37" "uDQB36" "uDQB35" "uDQB34" "uDQB33" "uDQB32"  ;
      ScanIn  "SIB[1]";
      ScanOut  "SOB[1]";
      ScanEnable  "SEB";
      ScanMasterClock  "CLKB";
   }
}
Timing {
   WaveformTable "_default_WFT_" {
      Period '100ns';
      Waveforms {
         "all_inputs" {
            01ZN { '0ns' D/U/Z/N; }
         }
         "all_outputs" {
            XHTL { '40ns' X/H/T/L; }
         }
         "CLKA" {
            P { '0ns' D; '45ns' U; '55ns' D; }
         }
         "CLKB" {
            P { '0ns' D; '45ns' U; '55ns' D; }
         }
      }
   }
}
Procedures {
   "capture" {
      W "_default_WFT_";
      V { "_pi" = #; "_po" = #; }
   }
   "capture_CLK" {
      W "_default_WFT_";
      V {"_pi" = #; "_po" = #;"CLKA" = P;"CLKB" = P; }
   }
   "load_unload" {
      W "_default_WFT_";
      V { "CLKA" = 0; "CLKB" = 0; "_si" = \r2 N; "_so" =\r2 X; "SEA" = 1; "SEB" = 1; "DFTRAMBYP" = 1; }
      Shift {
         V { "CLKA" = P; "CLKB" = P; "_si" = \r2 #; "_so" = \r2 #; }
      }
   }
}
MacroDefs {
   "test_setup" {
      W "_default_WFT_";
      C {"all_inputs" = \r60 N; "all_outputs" = \r34 X; }
      V { "CLKA" = P; "CLKB" = P; }
   }
}
Environment "SRAMdpw64d256" {
   CTL {
   }
   CTL Internal_scan {
      TestMode InternalTest;
      Focus Top {
      }
      Internal {
         "SIA[0]" {
            CaptureClock "CLKA" {
               LeadingEdge;
            }
            DataType ScanDataIn {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SIA[1]" {
            CaptureClock "CLKA" {
               LeadingEdge;
            }
            DataType ScanDataIn {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SOA[0]" {
            LaunchClock "CLKA" {
               LeadingEdge;
            }
            DataType ScanDataOut {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SOA[1]" {
            LaunchClock "CLKA" {
               LeadingEdge;
            }
            DataType ScanDataOut {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SEA" {
            DataType ScanEnable {
               ActiveState ForceUp;
            }
         }
         "CLKA" {
            DataType ScanMasterClock MasterClock;
         }
         "SIB[0]" {
            CaptureClock "CLKB" {
               LeadingEdge;
            }
            DataType ScanDataIn {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SIB[1]" {
            CaptureClock "CLKB" {
               LeadingEdge;
            }
            DataType ScanDataIn {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SOB[0]" {
            LaunchClock "CLKB" {
               LeadingEdge;
            }
            DataType ScanDataOut {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SOB[1]" {
            LaunchClock "CLKB" {
               LeadingEdge;
            }
            DataType ScanDataOut {
               ScanDataType Internal;
            }
            ScanStyle MultiplexedData;
         }
         "SEB" {
            DataType ScanEnable {
               ActiveState ForceUp;
            }
         }
         "CLKB" {
            DataType ScanMasterClock MasterClock;
         }
      }
   }
}
Environment dftSpec {
   CTL {
   }
   CTL all_dft {
      TestMode ForInheritOnly;
   }
}
