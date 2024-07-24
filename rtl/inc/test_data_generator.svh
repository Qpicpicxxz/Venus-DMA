`ifndef TEST_DATA_GENERATER_SVH
`define TEST_DATA_GENERATER_SVH

logic [7:0] response8;
logic [15:0] response16;
logic [31:0] response;
logic [63:0] response64;
logic [127:0] response128;
logic [255:0] response256;
logic [511:0] response512;
logic [1023:0] response1024;
logic [2047:0] response2048;
logic [4095:0] response4096;
logic [8191:0] response8192;
logic [16383:0] response16384;
logic [32767:0] response32768;
logic [65535:0] response65536;
logic [131071:0] response131072;

parameter TESTDATA512bits_block_0 = {256'h0000_ffff_0000_eeee_0000_dddd_0000_cccc_0000_bbbb_0000_aaaa_0000_9999_0000_8888,
                                     256'h0000_7777_0000_6666_0000_5555_0000_4444_0000_3333_0000_2222_0000_1111_0000_0000};

parameter TESTDATA512bits_block_1 = {256'h0001_ffff_0001_eeee_0001_dddd_0001_cccc_0001_bbbb_0001_aaaa_0001_9999_0001_8888,
                                     256'h0001_7777_0001_6666_0001_5555_0001_4444_0001_3333_0001_2222_0001_1111_0001_0000};

parameter TESTDATA512bits_block_2 = {256'h0002_ffff_0002_eeee_0002_dddd_0002_cccc_0002_bbbb_0002_aaaa_0002_9999_0002_8888,
                                     256'h0002_7777_0002_6666_0002_5555_0002_4444_0002_3333_0002_2222_0002_1111_0002_0000};

parameter TESTDATA512bits_block_3 = {256'h0003_ffff_0003_eeee_0003_dddd_0003_cccc_0003_bbbb_0003_aaaa_0003_9999_0003_8888,
                                     256'h0003_7777_0003_6666_0003_5555_0003_4444_0003_3333_0003_2222_0003_1111_0003_0000};

parameter TESTDATA512bits_block =  {256'hffff_ffff_eeee_eeee_dddd_dddd_cccc_cccc_bbbb_bbbb_aaaa_aaaa_9999_9999_8888_8888,
                                    256'h7777_7777_6666_6666_5555_5555_4444_4444_3333_3333_2222_2222_1111_1111_0000_0000};

parameter TESTDATA512bits_1  =     {256'h2a88_020e_2e81_3a46_ae02_a3db_78cc_9a95_cffd_3df6_d202_7833_a37f_e1dd_3ead_1274,
                                    256'h39e0_6c1b_ce55_cc13_3143_c0c9_9144_cb22_4045_32d0_a9f8_77e5_7759_0929_a681_0742};

parameter TESTDATA8192bits_1 =     {256'h6941_868c_b0b7_ca07_455f_9a05_8972_2226_c029_c922_e4f6_e0fb_98cd_e670_6020_a376,
                                    256'ha1d0_cae3_abf2_7dfc_5dff_ef2e_45e2_425d_1130_0df3_540c_3da8_fdff_ad82_a15f_f84a,
                                    256'he2fe_598d_d536_1ff3_7aa8_5224_4b85_085f_f55a_b112_7bfb_27cd_96db_945c_f527_9c24,
                                    256'h323b_df29_9e87_f090_b494_30d3_0075_3bb9_de2f_cb2f_9f51_4c40_3d8e_760a_14a9_0e2f,
                                    256'h9b1a_8014_2f10_b53f_e168_b4e0_c551_ad23_4fb6_9b76_c135_abd6_52ed_9f5d_9840_ec57,
                                    256'h2a88_020e_2e81_3a46_ae02_a3db_78cc_9a95_cffd_3df6_d202_7833_a37f_e1dd_3ead_1274,
                                    256'h39e0_6c1b_ce55_cc13_3143_c0c9_9144_cb22_4045_32d0_a9f8_77e5_7759_0929_a681_0742,
                                    256'hf36f_465b_dce2_fe42_71d1_d6cc_167f_4f8d_3194_6ba8_5f55_d4db_85df_098d_e2a3_b7de,
                                    256'hc637_3b38_8c76_d9d4_e8f2_849a_3f3e_3af5_76fd_78dc_00cc_cd9f_536f_b298_2151_da92,
                                    256'h57a4_c868_0860_7156_5779_49d0_dddd_389e_b54c_2ead_4c80_79eb_eac2_a41c_a541_914a,
                                    256'ha539_3b4a_f747_c59e_8d63_6508_afdf_d5b6_8d4d_26f7_ba53_b353_0656_be9c_0c65_14e0,
                                    256'ha882_13da_ee49_203c_c0f7_1418_d2a1_af5a_c965_7720_79fc_f6e3_bb76_1442_1eec_c553,
                                    256'hd2bb_c275_736d_cc8d_b073_034b_ee05_d76f_2877_e32f_4f91_fa49_2912_9c40_ccf6_4cdb,
                                    256'h65e6_024e_d784_21bd_e2a9_5d2d_59e3_4cf2_bb47_80c5_fe13_6dc9_95b7_f0b9_9cee_186d,
                                    256'hfc17_3bb4_a5d8_0704_a00e_f86c_ef27_8d67_a4b5_373c_a79e_9e5b_fba8_c155_b355_33ce,
                                    256'hade9_f910_889e_8a61_4abd_bf0e_8ec8_920d_172c_d7dc_d7f4_dd6e_4096_0570_0545_b373,
                                    256'h88d0_29f4_13e3_a462_df7d_8647_bb57_4a8b_ec9e_3f36_b874_4002_8ffc_f7c0_fa70_9ccd,
                                    256'h97dd_6023_a2c0_6450_b9ab_d22c_a43b_7e10_7e5a_940f_714c_29c5_93c2_9ca1_809a_8bc5,
                                    256'hc92f_abab_2985_542e_ec54_1b07_d872_aea6_030b_068f_c82b_1022_5d2e_560f_17d4_d93b,
                                    256'hdc68_333a_5051_7312_a5c8_a425_2630_2517_193d_7056_a1fb_a464_71af_e388_7523_ab80,
                                    256'h98da_fd9a_634b_821a_17c0_d162_e62a_443b_052a_830c_39c8_fd4b_75d7_72ec_b8bc_ff5c,
                                    256'h1b16_d057_bf12_b913_aec6_d23e_c434_f200_5843_acbb_ede4_4da2_5d35_09cd_da86_5c0a,
                                    256'hc8b0_ab8d_e20e_4680_fdf2_fcb2_4d6a_37e0_39ab_fefe_8c85_f1df_333b_d126_5988_89a0,
                                    256'hbc74_f2bb_4f7c_8da2_ae91_6584_bf05_2844_8666_3fc7_6135_8bd5_d083_99c0_f971_6077,
                                    256'h3e79_1f27_1e32_4be4_8bc4_c229_800f_0b59_799f_08ce_e906_3bbe_d949_7607_a4e7_3f12,
                                    256'hf742_b1b1_c022_25d2_452e_cde2_fde9_6f6a_cc4e_d5db_6e6b_3512_0307_2cd1_579c_e7d1,
                                    256'ha2fb_ca1e_5d97_1060_2038_c4fd_57ba_72de_c95c_188f_18f8_55d1_3f4a_c565_b50a_ae2c,
                                    256'h6cd3_ff98_991d_e391_c247_8f4e_3605_6c74_0c49_c4a2_31b9_621d_a36e_423e_b666_d381,
                                    256'hd402_fc57_0ae8_4c75_11e3_d0dc_f099_62b1_d7d5_f42f_8fec_f672_d88c_cf94_225a_29de,
                                    256'h42ac_267c_c57b_d959_98a6_6c9b_d158_8c9c_f8bb_7eb9_34b4_4522_fd71_48c5_7b49_8a63,
                                    256'h2af7_cf7d_fec4_fca9_2ce4_5ebf_9046_5f83_10dd_52f8_6d5a_2007_cb3d_2d40_dfae_481e,
                                    256'h5283_579e_872b_aa47_b2b7_aafa_e402_9d84_0972_cae1_3aae_934d_e623_81fd_daee_63e1};

parameter TESTDATA16384bits_1 =    {256'hc27f_e629_2e95_ee0b_e685_cefb_b1e8_3e01_59a3_e33c_0124_03d8_d0ec_c30a_e9e0_9483,
                                    256'h6941_868c_b0b7_ca07_455f_9a05_8972_2226_c029_c922_e4f6_e0fb_98cd_e670_6020_a376,
                                    256'ha1d0_cae3_abf2_7dfc_5dff_ef2e_45e2_425d_1130_0df3_540c_3da8_fdff_ad82_a15f_f84a,
                                    256'he2fe_598d_d536_1ff3_7aa8_5224_4b85_085f_f55a_b112_7bfb_27cd_96db_945c_f527_9c24,
                                    256'h323b_df29_9e87_f090_b494_30d3_0075_3bb9_de2f_cb2f_9f51_4c40_3d8e_760a_14a9_0e2f,
                                    256'h9b1a_8014_2f10_b53f_e168_b4e0_c551_ad23_4fb6_9b76_c135_abd6_52ed_9f5d_9840_ec57,
                                    256'h2a88_020e_2e81_3a46_ae02_a3db_78cc_9a95_cffd_3df6_d202_7833_a37f_e1dd_3ead_1274,
                                    256'h39e0_6c1b_ce55_cc13_3143_c0c9_9144_cb22_4045_32d0_a9f8_77e5_7759_0929_a681_0742,
                                    256'hf36f_465b_dce2_fe42_71d1_d6cc_167f_4f8d_3194_6ba8_5f55_d4db_85df_098d_e2a3_b7de,
                                    256'hc637_3b38_8c76_d9d4_e8f2_849a_3f3e_3af5_76fd_78dc_00cc_cd9f_536f_b298_2151_da92,
                                    256'h57a4_c868_0860_7156_5779_49d0_dddd_389e_b54c_2ead_4c80_79eb_eac2_a41c_a541_914a,
                                    256'ha539_3b4a_f747_c59e_8d63_6508_afdf_d5b6_8d4d_26f7_ba53_b353_0656_be9c_0c65_14e0,
                                    256'ha882_13da_ee49_203c_c0f7_1418_d2a1_af5a_c965_7720_79fc_f6e3_bb76_1442_1eec_c553,
                                    256'hd2bb_c275_736d_cc8d_b073_034b_ee05_d76f_2877_e32f_4f91_fa49_2912_9c40_ccf6_4cdb,
                                    256'h65e6_024e_d784_21bd_e2a9_5d2d_59e3_4cf2_bb47_80c5_fe13_6dc9_95b7_f0b9_9cee_186d,
                                    256'hfc17_3bb4_a5d8_0704_a00e_f86c_ef27_8d67_a4b5_373c_a79e_9e5b_fba8_c155_b355_33ce,
                                    256'hade9_f910_889e_8a61_4abd_bf0e_8ec8_920d_172c_d7dc_d7f4_dd6e_4096_0570_0545_b373,
                                    256'h88d0_29f4_13e3_a462_df7d_8647_bb57_4a8b_ec9e_3f36_b874_4002_8ffc_f7c0_fa70_9ccd,
                                    256'h97dd_6023_a2c0_6450_b9ab_d22c_a43b_7e10_7e5a_940f_714c_29c5_93c2_9ca1_809a_8bc5,
                                    256'hc92f_abab_2985_542e_ec54_1b07_d872_aea6_030b_068f_c82b_1022_5d2e_560f_17d4_d93b,
                                    256'hdc68_333a_5051_7312_a5c8_a425_2630_2517_193d_7056_a1fb_a464_71af_e388_7523_ab80,
                                    256'h98da_fd9a_634b_821a_17c0_d162_e62a_443b_052a_830c_39c8_fd4b_75d7_72ec_b8bc_ff5c,
                                    256'h1b16_d057_bf12_b913_aec6_d23e_c434_f200_5843_acbb_ede4_4da2_5d35_09cd_da86_5c0a,
                                    256'hc8b0_ab8d_e20e_4680_fdf2_fcb2_4d6a_37e0_39ab_fefe_8c85_f1df_333b_d126_5988_89a0,
                                    256'hbc74_f2bb_4f7c_8da2_ae91_6584_bf05_2844_8666_3fc7_6135_8bd5_d083_99c0_f971_6077,
                                    256'h3e79_1f27_1e32_4be4_8bc4_c229_800f_0b59_799f_08ce_e906_3bbe_d949_7607_a4e7_3f12,
                                    256'hf742_b1b1_c022_25d2_452e_cde2_fde9_6f6a_cc4e_d5db_6e6b_3512_0307_2cd1_579c_e7d1,
                                    256'ha2fb_ca1e_5d97_1060_2038_c4fd_57ba_72de_c95c_188f_18f8_55d1_3f4a_c565_b50a_ae2c,
                                    256'h6cd3_ff98_991d_e391_c247_8f4e_3605_6c74_0c49_c4a2_31b9_621d_a36e_423e_b666_d381,
                                    256'hd402_fc57_0ae8_4c75_11e3_d0dc_f099_62b1_d7d5_f42f_8fec_f672_d88c_cf94_225a_29de,
                                    256'h42ac_267c_c57b_d959_98a6_6c9b_d158_8c9c_f8bb_7eb9_34b4_4522_fd71_48c5_7b49_8a63,
                                    256'h2af7_cf7d_fec4_fca9_2ce4_5ebf_9046_5f83_10dd_52f8_6d5a_2007_cb3d_2d40_dfae_481e,
                                    256'h5283_579e_872b_aa47_b2b7_aafa_e402_9d84_0972_cae1_3aae_934d_e623_81fd_daee_63e1,
                                    256'hf6c1_5c45_56b2_668d_545a_5d41_7579_4ed6_6e13_0b42_dab9_8a19_9bed_1a12_dd80_5248,
                                    256'h7051_c7bc_884b_b4ae_d115_fd67_f6b8_76bb_8ace_ce5e_f96c_6b32_9468_3907_b6c2_604e,
                                    256'h923d_d191_e9cf_e0cd_896b_b8ca_01c4_589d_e926_3586_3611_5a25_d794_c206_38ec_61be,
                                    256'h3239_eae6_1021_0ca0_ba05_21ea_a806_aff9_acf3_a852_7733_07d2_146b_565d_86f0_3819,
                                    256'hdb12_6476_14d9_fc5a_7167_873f_67b8_aae0_8805_66aa_fd74_0eff_287e_26c4_0694_ed6b,
                                    256'h77d1_4bad_4e5f_e5eb_cc76_30fe_f777_b831_391d_b68e_e5d5_e4b6_bdb1_f8b2_ef1e_2547,
                                    256'hbee9_9272_59c3_cb81_9dd8_ca6a_fe81_5f35_2a5e_3e97_c683_4163_409b_1e6d_bc73_7f02,
                                    256'h42d8_e444_0db0_ef7c_c1e9_32dd_ec61_2b5e_5dae_1e87_5639_b082_a1ee_d7ba_ac1f_a881,
                                    256'h3f89_5794_42ec_6eaa_6fae_b02d_db4e_bb05_1ffa_7b4d_5c2b_75ff_d3d9_27b5_3a6f_85e4,
                                    256'h5ad3_ffd9_b550_5bf1_33c9_d95b_f87f_d4e1_82a6_85a6_2ce5_2552_5f61_4729_7bf4_77de,
                                    256'he36d_5017_5a59_483a_4876_760a_3f5a_ab14_390f_17a2_d4ed_3e10_4a7c_d847_d7b6_95dc,
                                    256'h3b3f_c7ca_7bea_cf8e_1dc7_eaf7_ca94_8df8_55e2_ed83_cf46_8c70_05e3_e9a4_92f5_c311,
                                    256'h9098_bebf_9c1a_89d2_d37e_15b3_e208_d232_db3a_5a34_6236_0eb0_1138_5401_cdde_aab0,
                                    256'h8e8b_b3ee_451e_d2af_19df_09c8_6543_6d72_05b6_6660_2851_fa7a_bd2e_7541_79d9_05b9,
                                    256'ha71a_870d_959e_ebd3_e504_03f7_957a_a1f2_724e_31bc_f457_83fb_6fea_d1f5_7bfc_9c3c,
                                    256'h0478_1cdb_a976_04a4_c55d_98fb_0b17_f0b3_07f7_f520_8b63_8063_a5f8_8300_edd5_f25f,
                                    256'hb02b_010b_4af8_d0d5_e15e_4163_8f80_c680_487e_aacd_ef6d_af85_1d2a_cbc9_aa28_8712,
                                    256'h6d52_7aa7_2690_05f6_2bd1_4dfa_4ca9_a59c_f3b7_c633_f43c_f8d3_e275_390f_8713_0c1f,
                                    256'h5363_68aa_1514_2fc2_7976_6d70_35cb_7056_9f17_91e1_b9c1_43dc_15ea_2908_7383_ada0,
                                    256'h1073_78a1_c84b_038a_df3e_7f6d_9778_d911_4dc5_963a_3f0f_d72a_e591_4cdb_58ed_e2e8,
                                    256'h5397_becf_f7c4_8c07_8d88_abee_d3d4_2448_dd0e_4360_762d_5dad_c774_67ff_94df_7a3c,
                                    256'h70c6_d14b_83f3_7081_f6f3_6fbf_e9cd_c0fb_5810_09b0_0945_fda5_4dbd_725c_913d_0bdd,
                                    256'hd32a_fa6f_88af_7aaa_f20b_7efe_934a_26e6_d8bb_97fe_4ae9_500d_02f0_ab81_16d0_6bfa,
                                    256'h58b6_c92d_f37f_e402_6c8a_b1b1_b2dd_4813_a086_4db0_35d1_461d_780e_844a_0460_98cf,
                                    256'h5a8f_be7e_063b_f2fb_1efa_335b_a7d5_e85c_8664_c0e6_1ff0_fcba_17eb_a0b5_f935_6e89,
                                    256'h691f_b0b5_ca8b_47b4_95d7_7678_3e11_76fb_a613_1283_da5a_8fe9_4422_5750_b498_544d,
                                    256'h2ef5_9c99_9de5_e451_2989_143f_28d4_5d13_a2c3_a26c_f95e_4eee_74a0_dda6_c951_5ce8,
                                    256'h2ecf_c378_ec25_c0fd_7bd1_ef95_9c03_d570_32b8_d05f_ef13_6698_658c_913e_0079_1a51,
                                    256'hcae6_e286_43c9_3f4e_c9a3_1219_8aa6_cfa4_efa0_52ea_06c6_8b82_3a77_146a_61f3_d7b0,
                                    256'ha569_a120_bec4_746c_7463_1435_fb2c_8fa7_7a62_ecd1_9e73_2f90_92c5_ca21_5f0c_8194,
                                    256'hebe2_a872_86a4_f7fe_8af4_1460_8a60_8c4a_bb08_e5ed_1415_4623_8e35_8015_7e4c_496e};

parameter TESTDATA16384bits_2 =    {256'hbdaf_6870_7fdd_f388_9f37_d5a3_4f27_1c55_9713_1e89_3abe_e053_260f_36cd_b15f_90d0,
                                    256'h52a8_bbd0_1e20_a487_24c9_f08e_052e_61d9_4479_be28_dc18_20b2_09d2_cf97_3383_93e8,
                                    256'he1df_d7df_9539_53fc_a6d7_4efd_de07_5cc5_a1f0_fa2c_8f25_348f_9130_f791_98a7_2554,
                                    256'hf1b9_7f09_b536_25ea_41ed_a227_e483_49e2_89ae_e976_cadf_84b7_bbb8_ed4f_4ba0_b9f1,
                                    256'h98a1_91b8_22c4_d950_c286_3585_39b8_61d8_7931_3629_5ad7_136d_693f_2fb0_c8cc_3149,
                                    256'h77b1_6f15_a153_8a33_6bbd_5281_fdcd_ca4f_642e_a8c2_76c0_378e_13c2_49d2_fe0e_adbf,
                                    256'h2a8f_2685_f266_3db2_806e_788f_4067_f476_da75_3e24_5709_a6fe_b0b0_4472_48b9_5075,
                                    256'hd2fc_1bc3_8c27_9aa3_0c87_30c9_2379_7e7c_c19c_10e0_7056_de1a_6115_70c8_1891_3d0a,
                                    256'hf5ef_775a_dd45_044b_1c8d_92d2_d491_334d_f706_fe4d_b82c_d7c1_1557_0d2b_bdc6_e68c,
                                    256'hbc14_6d9e_7d8b_1c23_4932_bd9d_4777_e681_19e0_b7f6_53eb_d8df_1652_1f6f_a278_83ec,
                                    256'h20e1_d0d9_bb66_f401_7e70_1dda_9d69_590f_fc04_e5a0_488e_d023_ff6d_4620_0cb7_0a07,
                                    256'h2902_db81_85d0_0781_a277_a807_0cea_094d_84c0_6fc6_d53e_c107_2546_fe0a_f02a_0c97,
                                    256'h49ec_e92e_0319_cf22_4ba4_79ac_264c_acad_c623_4187_8e4f_f449_c211_6aa7_ef48_7fd2,
                                    256'hecae_b27e_2c49_47b9_d2f9_90ae_319b_d8f1_5b9e_23a2_16f8_9e16_3857_40d5_7ba2_1f18,
                                    256'hdffb_173c_ed1b_7a81_a7ae_5c30_550c_289f_9a56_2202_8b3e_8291_8092_e6e1_a2fd_6e9b,
                                    256'h46c8_88cf_2b50_8b52_d35a_783e_af1f_14ce_7662_2781_a0eb_8b36_e682_2190_002a_f70d,
                                    256'h5915_7320_d869_c3b3_786f_bb8b_08f5_12a7_38dd_5bb2_9546_9441_5182_eed9_55c8_135a,
                                    256'h5deb_539a_334c_a7a9_78fb_24bc_ba57_e0b3_4a1e_a001_ba12_1b1f_59cd_e2e2_7599_f963,
                                    256'hae09_cb03_3646_dd3e_69de_e585_dfce_9808_27ec_f255_ce26_9a3a_733b_837e_9eb2_2398,
                                    256'h8db8_6d65_3cbc_8de4_edf4_cabb_df8f_d0d1_8101_aeed_4896_cda6_1839_3535_c100_da72,
                                    256'hbfa3_40e4_594f_cc08_9220_fc61_c2bb_e3a3_5e8f_1fe8_38c6_9837_e888_6e86_ea72_7865,
                                    256'heb83_fa5f_de7f_f2d6_201a_2fa4_63c6_071d_af20_2548_d42f_215f_4495_ee90_d2cd_5c4e,
                                    256'hc2df_adb6_409c_ae38_ea5b_9983_7f7e_0068_45ed_986b_2a1b_a070_1b7a_007a_fa05_a309,
                                    256'h8c7f_5e74_629c_5614_2c15_458d_a741_e571_837a_b8be_1bcf_ba27_9f6d_58d6_3ffd_ab64,
                                    256'h86ca_2123_0976_7997_6f6a_6955_7a06_d8d3_c97b_44fc_19fa_fe00_c66e_1fe1_2a51_7520,
                                    256'h2118_85b2_d7eb_05ba_ad8c_1787_921c_45d2_bc1f_2aab_53b8_1804_af7b_2bd2_f4d0_fcd3,
                                    256'h2ae7_62dd_40a5_53fc_fe20_7188_eaea_e998_06bd_0828_236b_c2ef_753e_05d7_5b31_b834,
                                    256'h3530_16e0_52f7_62db_6f91_64a8_7cf8_2221_7937_d81b_84ed_3459_e529_febf_5d68_05b7,
                                    256'had27_e73f_97a9_ae73_7968_5780_54c1_c977_b983_7428_1693_2aaf_ff5d_8faf_e12d_1b0c,
                                    256'h19a8_3a0a_1803_1573_448f_5726_d7bc_16ce_326a_0c6a_d541_eda9_bb58_a9e7_bd4a_3812,
                                    256'hc7ad_23af_dbc2_6e43_0809_6d0c_51e4_6e10_77fc_a5bd_da9c_1165_e4bf_91c5_6f9a_ce87,
                                    256'h2106_e235_41d5_7373_5c3d_b152_d9cd_5610_16ca_fb93_d243_fa63_bad2_cf14_416d_248a,
                                    256'hf209_235f_acbb_11a4_9734_2111_a99f_cf9d_4379_13ef_06b4_4049_b9a8_ee0c_8054_75c5,
                                    256'hd7ab_37c6_02b5_b07c_0220_ccbe_d57e_6355_3ca3_80fa_7c61_bc5a_fe84_5388_3b31_0195,
                                    256'h968e_976f_fdd4_5835_b013_b419_cb03_307c_188a_bfd4_35db_eddf_5150_ee85_b7e1_7d3d,
                                    256'h56a5_79d6_ca46_2045_c2cd_d39d_9b0d_ea1d_32a9_e909_45b0_cd7d_4a26_2f44_5347_9d75,
                                    256'hb442_03ba_4b11_d0b4_0a74_32ca_ac01_e9df_c5f7_c25a_436c_598b_7271_e21e_43a6_42b6,
                                    256'h7975_0de3_9005_cc38_619b_ea4f_09c1_bf80_c2f2_45e1_f4d8_1f24_9ffb_1f50_8ad3_5c01,
                                    256'hf3bb_8d93_7192_5021_b5a8_7231_f7dd_bb34_1c67_031e_7570_3eb5_de24_5a21_610e_7ecc,
                                    256'he069_7296_176e_1f0a_696a_cb39_cc28_e452_6615_48e4_b4bc_4b85_dccf_0457_572d_bfeb,
                                    256'hbef7_9d8a_44db_819e_1bd6_74a7_a711_f1fa_2a8f_7a00_b819_25fc_84e6_8567_a4ca_4d1d,
                                    256'he873_ae85_9733_b3a3_20a6_0f4a_f5c2_a836_f512_2ce9_0c3f_4e00_be58_937f_9007_ff68,
                                    256'he66c_7f11_5ec1_057e_3e97_6620_7110_13b3_3b79_daf1_a014_1efa_701d_8be9_db8e_e021,
                                    256'hdbfd_8f7e_d819_d48f_ec0d_ae2f_0e2d_8676_6399_143e_ce81_7991_8605_b9b4_2322_d3e1,
                                    256'hb2bb_124e_8597_9bf8_f2a6_4e91_410e_f7de_035c_3deb_87f0_5277_cae7_a974_820a_0c08,
                                    256'hbaa2_7dbc_ca0d_6b71_77d5_55c4_884f_aa63_a574_c9c7_5463_067a_83fa_e052_bc21_ca55,
                                    256'hf884_367e_bc2a_a14f_715d_0bb4_4d72_db7b_b9a8_c8eb_b780_26d2_288f_ac56_3fb7_78bf,
                                    256'h8d78_74ff_fba6_f9b9_5818_c04d_371f_021b_c852_e324_e06d_9dce_eb7b_9b63_1f0e_d386,
                                    256'he3eb_8ba9_e8a6_de7e_02a1_7280_bdcf_08ff_26d0_6ad6_1b3a_61ac_6640_2da3_14a7_8d99,
                                    256'h0553_3160_f672_9f8e_7c50_f0e0_1310_a87d_af30_e049_c476_ec24_1abe_1fb3_1cb8_9fcb,
                                    256'h42d8_ef7d_4d97_a3dd_58fd_64c5_6909_3aa5_2a94_3443_f9bd_e79b_5e61_f9d5_2879_2397,
                                    256'hec04_bac8_244b_646b_e831_6102_e2a4_86dd_d4a9_41be_c137_f623_48a5_d086_4b9e_64dc,
                                    256'h275d_d147_5268_7e4a_424b_1652_f04f_4bcc_6969_3c3a_8e2b_2c67_8f18_0ee0_9f92_4b88,
                                    256'h0297_95a2_bbdc_1f33_642c_4df4_6b2a_cfe3_06e2_bcbd_48e2_a220_57a9_91ae_5440_96eb,
                                    256'h526e_b2a4_f261_640f_cac8_6290_9a75_af11_bdd6_a1f0_30c0_7a9c_3b86_5db9_f73e_d049,
                                    256'h6508_bd85_5435_b86d_d9ff_c3ea_68f9_ff39_5c89_5225_bb76_82b2_09d7_42ee_c117_4b19,
                                    256'h6e04_4767_bf50_537f_6526_5205_9046_4801_62e7_3827_83c4_9122_e48f_8656_66f3_46e8,
                                    256'h3a75_0204_f09a_5d3d_9a4a_9c34_bea1_5547_4733_d966_1656_2112_b5ce_8729_548f_6663,
                                    256'h8979_5b75_450a_1b11_97c5_7cd8_6c0c_27e3_6415_2f45_ebd8_0bc7_1b42_996a_aa3b_3514,
                                    256'h21cd_aa75_adfc_3385_86b9_cc05_6de3_4fb3_b345_037a_c18a_6de6_61b4_4676_f9b9_f35a,
                                    256'h3c5b_edb9_c529_59f9_08d9_e0d4_4061_6174_2735_9c65_0a7a_ff1d_9036_20db_5c65_0066,
                                    256'h55ff_5680_e5d7_effb_5637_5137_c816_4e75_b878_0f9e_9b6a_f64b_a9a4_bc2b_d6fc_1aa4,
                                    256'h3a9f_64e7_399a_6a04_8bcb_9852_af03_6a77_ff3a_92a5_e600_4c64_dcaa_fed1_7311_0be8,
                                    256'hb8cf_2714_9a4b_eb47_cbd0_6eb9_b88d_60a6_9598_9cf3_2c54_81da_f45c_550d_def8_e837};

parameter TESTDATA16384bits_3 =    {256'h6197_dd32_7fb1_076d_e6c4_ca54_4a2b_9341_2d11_96c3_e3d8_0765_9d20_379c_7af8_f856,
                                    256'hd0f3_5a43_074f_681b_8eda_6c41_4a56_9c54_1219_69dd_106e_cf8a_7583_070e_8b99_35cb,
                                    256'h0ffa_e652_8452_4ad7_1fb1_3646_993b_3a6e_7f51_5554_8950_e665_96b9_d367_dafd_1a70,
                                    256'he536_88df_441a_d9ac_4215_bdfb_9ad1_c777_2233_6b21_f7cf_023d_30a5_30a9_91d5_0104,
                                    256'hd070_79cb_2517_193b_0543_cc35_4dab_ee4f_9043_6dc3_a5c4_dd2f_3f18_379c_2751_3817,
                                    256'had7d_3a2f_c5ac_bbee_9c8e_2429_9afc_4aa9_3722_a4c6_42f4_9b79_a929_5501_9588_9a87,
                                    256'h6fad_d079_9d87_3524_e1c9_40e1_4372_a737_57ef_80db_5e56_8815_74b7_e6fb_45ad_99cf,
                                    256'h06ff_e0e8_2791_f04e_de3a_a3d2_fd22_4092_d0fd_038f_4f2c_6c8d_5786_f006_1d81_213a,
                                    256'h506e_73e4_6263_67b9_97d3_4391_03e5_dbcc_f55e_99d2_6dd9_b37e_75ef_af3d_7876_d5d0,
                                    256'ha656_eeb1_1d6a_662e_82c3_209b_9b4e_d2e7_4c4c_0933_cff9_6daa_7904_1e6e_2348_aa04,
                                    256'h9a95_f20f_1af1_b93a_2bac_b1d8_2dd4_e8df_2feb_4380_f0f5_7346_4815_50c1_e919_525e,
                                    256'h5e39_5beb_65f4_c3a0_60c5_5c76_a2ca_757b_38ab_6c58_2a1f_98e1_13b8_b992_1394_49a0,
                                    256'h3fb6_f507_63d8_ecc0_61d7_7d20_29f6_7684_3cd9_b3cd_fc9f_2fca_e4a1_18a8_43b3_7949,
                                    256'h5671_ccf6_9e10_9266_aaa1_d706_6dad_ede4_e936_4c4a_4bbe_8eed_8d6e_b684_b660_f67d,
                                    256'ha650_76c2_1056_0243_a00c_7397_ee5b_2a4d_6734_d134_6df1_fdb4_4ef5_f689_df1b_4fab,
                                    256'hb78b_b162_6bf7_4a4e_0e37_0a63_131c_cf88_5683_b614_06fb_3750_7aa8_6406_735c_7cb8,
                                    256'h8365_4473_8031_37d1_5019_adb7_cd77_5039_6788_0def_100b_e273_85a6_d13d_d675_73a8,
                                    256'h4af5_2c64_a087_37f4_66d9_44d9_4ed2_b58f_5498_aeca_0a40_02cd_8715_5187_7d9d_3c40,
                                    256'h4855_a70c_dd89_58b1_b50e_5abf_355d_b273_1e36_283f_f86b_ebae_c5df_6994_51aa_85cb,
                                    256'h47fa_f1b6_16de_b202_aa6e_1e1d_9b6e_8674_85c8_2e50_68ed_3008_10a1_6904_1e60_6d60,
                                    256'h9838_677c_ebab_7d1a_f609_5374_a357_9ce6_2e5c_23f3_9842_2004_fc63_5c9a_0723_134e,
                                    256'h9147_4d59_b64f_f50f_fc70_642a_901b_c130_f95c_83dc_d748_ca0c_7e7b_7267_9cb6_5e78,
                                    256'h53a4_eab4_f7be_6984_f56d_b2bd_1137_ed27_5b9c_aca5_5628_383d_2a64_bcd3_6d83_bfad,
                                    256'ha275_85ff_5499_1e6a_e883_8b7b_b7b1_04e5_af31_5baf_a711_53c8_fd0d_b3d8_b0a8_d3f4,
                                    256'hbe3e_6862_b84a_0ffd_5bf7_f7ee_64d5_c919_826b_a66c_0780_ce77_56e7_5471_059d_6154,
                                    256'hf7b6_9a7b_d961_919d_289c_6dc6_dd2d_e3a8_48f2_dd06_a981_ed19_3757_061a_8123_3029,
                                    256'heebc_476a_a226_4ff4_c67b_7b68_d406_ab0d_0045_7846_b84b_d1ae_3a17_ce12_2b84_3d3c,
                                    256'h17c8_a708_6e58_7fb6_0a4b_413d_475f_98ae_93e2_ab08_8c02_fc58_b353_5724_b5d1_1f0b,
                                    256'h829e_172d_2f01_6640_17de_1143_adf5_ed58_f8a5_e4af_6ce0_5d13_b175_357f_ae78_ad5b,
                                    256'h10c8_72d7_8888_aacd_f58c_9a66_b773_c375_4c4e_18be_3c47_5f67_d5b6_716a_bd30_fc38,
                                    256'hc881_61f9_b86e_5ab8_4143_2726_eab1_256d_d4a0_e92c_55cf_7dd1_3e9d_0ece_94ee_fa95,
                                    256'h1d78_4fdc_c999_9dd0_0a98_51a8_46e7_46c4_4c6c_cb77_4ac2_d919_11f7_9ba3_680c_262e,
                                    256'h58e1_49e8_4323_a38b_8ff0_bc75_6315_b75e_3765_9913_e067_1d4b_a167_d5d6_4724_8768,
                                    256'h4957_0a29_b49c_02e7_1251_a088_07aa_6807_ac21_e4c4_68cc_b201_51c6_e35c_010b_c013,
                                    256'h14fa_0660_d77d_f786_66f1_ba6d_a4de_5c46_6552_22e7_01f9_85a5_48b8_9338_e978_9661,
                                    256'h8366_ffbc_ea37_21ba_5685_e911_c84e_1f17_6433_f9df_a31e_fd25_6f09_925e_93ea_ff8a,
                                    256'h99fa_194c_98ab_3607_4bdf_e87b_fe8d_f95b_af53_5030_08b4_16de_eb76_394d_3607_48f0,
                                    256'h183e_fa73_ae6d_bde4_c603_4ca6_0f65_b4d4_05a9_fe36_01c6_2fef_f1fd_c9b6_131e_50e6,
                                    256'he612_87bb_66fd_5f9a_3388_b808_d8c2_e24a_987b_e65f_a929_9937_7daf_bfc9_701d_40ed,
                                    256'h1140_7a80_122b_b5fa_3075_9562_c9ba_2a39_1466_2e69_f83c_a879_b347_6254_bb6f_eaa8,
                                    256'h50d4_2b6d_37bb_3801_32cf_81cf_a7f0_9847_bf37_4815_1e4e_35d7_707f_54b4_6c5b_a641,
                                    256'hc5c0_fda5_dd0e_8add_68a5_18e0_8aa2_0178_6725_1c91_c229_ff22_a8ff_5133_8455_04e0,
                                    256'hcdfb_ea20_cfe4_0fc6_a031_28d4_2804_56f5_d32f_52fc_e155_57d7_ded5_1d5e_c717_26d8,
                                    256'h8a88_f8f6_7ca1_9c4e_343f_395f_6f7c_7b1e_3d2d_5691_cbc0_45cd_d08e_171c_c20e_cba4,
                                    256'hf970_5a9d_099b_7fde_404b_57e0_03d4_a61d_e53c_0ae9_9ef5_76c2_89af_bdd3_f230_ec5e,
                                    256'hb498_133f_5857_a295_0785_f08b_4350_1653_1ecf_da45_9ed8_0942_6642_1e94_2ccf_6ba3,
                                    256'h8456_9c31_8e3d_3ade_32d1_6baa_42dc_0f58_f06d_6f77_d17b_46b2_81a6_a3c7_795f_9339,
                                    256'h7536_29f3_3fca_bc96_4962_2749_2d73_d351_8123_9feb_6719_0cf6_e355_d50e_a160_15f1,
                                    256'h2ff7_75b1_5ec9_27e1_1088_1118_7f6c_9242_9829_44e4_a3cc_1f4b_f087_6da3_ba0a_0130,
                                    256'hc1cb_671c_021a_c665_be28_0495_920d_c3ff_57e2_5d25_17f7_2ce2_f186_c532_aa78_ba10,
                                    256'h2bac_6232_d572_e38d_836b_9abc_14a3_a314_17ac_9a6a_932e_addb_821c_c094_bf88_0504,
                                    256'h43d4_1368_9851_1f34_ac6d_7ec2_b838_c835_e53f_3ed9_d3bd_0b53_a9f1_0d84_c1c7_aa5b,
                                    256'hb29b_fb17_613b_43d4_3921_dbce_6ea7_310d_288a_2caa_2968_0c5c_03ff_792c_a2a8_cf12,
                                    256'hd6e3_ddc8_3bfc_95df_3887_2645_5b96_2a27_f30d_189b_4291_a71c_ee3a_7e9f_2811_f33d,
                                    256'h8ad5_994f_0ec3_ea79_9bb6_1794_d191_e870_6939_e11b_58d6_b075_563e_545e_4362_5b4b,
                                    256'h6ba2_bd53_b3f3_c963_3aff_777c_2771_f411_a41c_40a4_7632_7e41_d1a3_870c_406d_b346,
                                    256'he74c_2c7c_0baa_5967_a8c2_ec35_d3b3_73fd_a3bf_a9b2_7bf4_4577_89d9_0fa5_57a7_0f90,
                                    256'h85b2_d625_952f_6c42_517e_56ae_9451_5138_8a27_7910_2522_55a0_18fc_f618_222e_b0ab,
                                    256'hcc19_bf34_c6fb_07ba_ca1e_2c68_e870_82b9_4a4d_8c55_aeef_ac54_01eb_e3e4_ea77_4400,
                                    256'h03c3_0e66_252b_2964_c169_e402_8497_5505_2a33_032e_e4be_4ed4_ec37_e791_d021_0f19,
                                    256'h3fec_fcd7_4bc8_ab37_57cc_b55f_340b_6c46_0a80_b69c_1833_b397_96a2_e6ff_bdac_7096,
                                    256'h7a04_ed7a_096f_683e_56c4_a60e_7e38_99bc_753f_4ed6_ec2c_8c5f_8172_3d97_a70e_dabb,
                                    256'h9783_f1e0_3c04_1afb_3405_2cc4_093a_363f_8e24_f8cc_458d_26b5_8e68_177c_6dc4_e17a,
                                    256'h3a02_9fce_ff82_15c4_83f9_6634_adca_ec2f_9470_0208_796e_e190_a097_0b6a_a926_00a5};

parameter TESTDATA16384bits_4 =    {256'h508b_8d36_bfb7_e753_d4be_6511_5649_8915_8184_9cb5_1b84_c082_0650_b58e_c314_0d2c,
                                    256'h6de0_e810_fb0f_269c_5ace_b616_7134_7a34_926d_c3fb_30c9_6d92_597a_ca3b_df80_1521,
                                    256'h4914_003c_5846_69c1_f999_5353_8522_ca74_c686_5230_a8d1_aae0_ed0b_c11d_a8d6_e74b,
                                    256'h90b2_34a6_a81e_1698_e39a_cb97_fe01_56f4_b84e_e232_b66f_dd2b_4122_7356_a1b7_431f,
                                    256'h5f09_a2db_80de_273b_b800_cbb9_f608_4af6_1603_adf9_39b6_334d_7fc4_1251_5425_125e,
                                    256'hff20_6d14_bf1d_f557_25b4_12ae_c0cc_ef70_62cc_bef4_13cf_ca2a_73ec_1b43_3636_7496,
                                    256'hc67e_fa17_a2d2_2b1a_a0df_9038_5037_a051_7648_3860_beb4_51c7_2556_69d3_daac_4cc7,
                                    256'hbcd3_eb7c_dffb_8ee1_3a33_349b_3cec_0c9f_e334_d4ea_0058_a92e_6262_b0e3_a93b_273f,
                                    256'hfe8f_89ee_63f0_155f_2310_5dcb_109c_3b0d_b905_3dbe_9e3e_386c_0dc1_5b3e_3642_0e2b,
                                    256'h2240_8b98_eec0_71a9_876e_0be7_dafb_a3be_aeb9_c961_d40e_792b_8f60_9a42_3d12_6346,
                                    256'h2e58_58e3_0ecf_378f_2fd4_7929_f053_265c_aa03_c637_6970_d35d_6c3a_15cf_576f_08e6,
                                    256'h85ca_94e2_c225_8dc5_5bc5_d7e5_58ad_db1f_8230_5db9_d8ca_b1fc_e46f_4c2d_1016_e743,
                                    256'h9c76_d8bb_afb5_e037_6c67_f2a5_1d83_0fc1_2ca3_0955_8278_6f31_1cc8_b13b_cb5f_c299,
                                    256'hcbf3_2fa9_b31f_a07f_907f_7683_0560_29f5_5f20_a8cf_4867_c849_f9e8_1923_55a1_5ced,
                                    256'h9c5d_e6af_30fc_d260_4bb0_bea4_ea23_3e8f_c377_4fb9_e262_8d4e_c086_4636_fc9b_ee3f,
                                    256'h5d96_b026_9ef3_6c9e_114e_9e31_4220_be66_cd46_1d8f_e6c6_a062_3f2f_42a4_5bb4_ffa0,
                                    256'hfbcd_fead_21e3_43eb_c915_0909_40d3_f38e_a92d_c504_fa6e_f8ed_fd4e_cfeb_8c54_f7ad,
                                    256'h93eb_7135_924d_9c8f_ed10_854e_e650_20b5_f881_1b65_03de_b301_7510_57cc_b44b_a601,
                                    256'h847e_20e3_67fa_820a_31b0_c2a7_924b_ba67_a451_205f_fe6a_f231_95c9_64d8_850b_cbf9,
                                    256'h6231_bd9c_8dbd_6304_fb91_1835_a33f_21a0_3858_4638_ca07_6f2e_b625_c492_d549_7146,
                                    256'h0bf8_21f9_3adf_f871_2877_59eb_f97d_e38e_b888_8e7c_fde1_d24f_08b2_b49b_2ecd_1e7f,
                                    256'h1e21_cf8e_26f1_f9fc_53a6_242c_446a_8afc_a023_3e9f_2551_0ca2_aecd_9fd5_961a_b637,
                                    256'hc577_1c6b_8d7c_1446_115c_165e_ed71_7a31_7161_1a91_48f7_f26b_d33e_96a7_b8af_3955,
                                    256'hb35c_7681_9713_6c26_ebd5_36ba_063d_fb34_3af3_0b56_ec1c_c93d_bfd0_6eea_3d99_cb7f,
                                    256'haf7a_8001_00b0_1357_5d9c_f3aa_8dfb_d0e6_d6cd_3dcd_f008_d0e1_1c5e_5fe2_f6b6_029f,
                                    256'hda4f_beb9_8acb_6541_fe13_fb51_35c4_f43c_6e87_7b3a_b20a_dfe0_6d39_799b_3745_e523,
                                    256'he821_c28a_75b4_9a4f_2eb8_ea93_6d87_c1c1_3bb7_302b_d10d_6679_801f_2140_520b_3e1d,
                                    256'h76c5_35f4_b4da_1cba_8c42_393a_c698_2a82_6f58_ee18_242a_073b_2323_414f_914e_d432,
                                    256'h993f_1dab_914b_5081_1ed3_a346_1026_6779_103a_b840_10c1_a8d9_8290_b8cd_e12c_a715,
                                    256'h235c_c9af_6e4e_2c3a_cdd6_de98_1ae7_1fd5_095a_4f14_c23b_6e0d_409b_1ee3_3758_0dd6,
                                    256'h9878_7762_8071_41e2_7c25_15d8_275d_21eb_b996_4da4_59e2_2047_4de6_95fe_ca4b_99ef,
                                    256'h7bd7_9c3a_407f_b526_f6bc_9af9_e236_4fc7_a100_bb50_ecc6_10c1_7b24_9af0_767f_e304,
                                    256'h5365_569b_5c9a_54ca_4145_bf4d_d717_08c9_c3f3_886f_0098_87fa_908d_cb1c_5405_884d,
                                    256'h09f2_52f9_1b86_3980_b3ff_276a_9c72_3c56_a78e_11ea_1576_e4d0_a054_81ae_96ef_2920,
                                    256'hdce3_e28b_3ab2_52ab_106d_310e_d5fe_56fa_f159_dbce_1b6d_56ec_09af_a1cf_0d1c_bb78,
                                    256'hdb3e_a3e0_43c6_76bd_c2b9_6f32_22ba_f589_0a1b_f2d6_b5ea_f407_083d_26b5_f4bb_275b,
                                    256'hb282_c58a_fcd8_942e_6a2a_6ab9_a26c_0d7e_8cb6_081d_f87c_56f5_8350_3189_2b76_3fca,
                                    256'h75d5_8833_2924_0b9b_3877_3f95_a68c_e632_333c_1029_0490_3ce0_1a6e_d9c0_c219_f8fe,
                                    256'h6e78_cb70_f48f_9259_8e7e_5835_6bf9_4d51_486e_6b38_045e_b08d_5648_d641_2a88_d7d1,
                                    256'he0bb_a82a_9d45_3574_552d_6e35_675b_41ab_6a88_f70a_95ee_0592_98af_7286_7a32_1bdb,
                                    256'h266e_463f_249e_e486_f1f5_3ea0_10d0_1a77_a9de_1cb8_2018_4f79_bc14_bc9f_874e_4800,
                                    256'h24b2_18ac_dc5f_8c6b_ed02_1bde_7b76_f8f5_b7f1_402d_4a62_113b_a5c2_ee17_73db_0d10,
                                    256'h1275_8fb5_bfdd_6281_e394_d0bd_4044_fd50_8db4_3caa_7acf_f168_6997_2c51_bfb6_9986,
                                    256'hecfc_177e_4a75_7f47_ee65_4bb5_f3c0_f8ea_74f3_1af2_a1c3_002a_8ed8_33b1_3f07_61d3,
                                    256'h36b5_23ce_671f_5e8f_ecae_2529_2c69_1f2a_5880_c38f_ad6a_5473_5c96_6fc4_ec30_7540,
                                    256'h378f_088e_7d51_455f_e37f_55af_109c_7aee_ff86_8a20_dd08_cb86_01ae_a0c5_f726_07d3,
                                    256'hf0a0_ca18_ac3d_fe60_765e_25e6_d763_ce35_1f9d_ec53_6f9a_d6ab_a660_2f8e_f336_b34f,
                                    256'h00b3_ea30_14ed_9ba1_ef16_d297_39a4_a0c3_d0a2_bfa5_3f49_cdd8_2203_afaa_e469_7960,
                                    256'h16b7_6361_2eb6_329c_3d9a_2112_612c_453f_e983_bd43_447b_0332_b979_8a8f_fe92_5200,
                                    256'h5bc7_b1ac_21d6_e1b5_35a3_bcc1_8918_0148_66f9_4239_4089_01b7_d20a_0b8a_09fb_f5c3,
                                    256'h20e2_9c90_3620_0ca9_ba2e_1e20_2146_355e_d495_7f06_0af8_cc95_bd85_6457_fd18_9c2c,
                                    256'h6408_fdda_fa01_1da0_68fb_42ad_f591_d3f7_d689_b859_7576_ebfe_577a_81cb_c8de_81d6,
                                    256'h9b02_889c_39c5_8ffb_2d3c_7aa7_98e0_f7cc_88ba_03de_1559_680d_61fb_7897_17a6_4c80,
                                    256'h35a4_75af_529a_b4c3_4dca_b761_da80_8794_fc7a_f4e3_a1e9_c48f_63e7_e388_26a5_6a7d,
                                    256'h35c7_9e13_4151_c665_515f_ce73_b379_45cb_0113_91d3_f403_68f6_ddd6_5545_abc4_ed32,
                                    256'h9646_f5d6_d28d_fd27_fdd8_527d_ffc5_a778_a547_8753_dc81_e2c8_91ad_7f08_d9a5_f8a8,
                                    256'h7446_8c46_107a_a623_28df_d835_bb8d_4348_f2f6_5312_abf6_2680_92d7_aaad_c922_aff8,
                                    256'h49c1_402d_a4e3_6dab_3f5e_a37c_f5fe_79a6_a8a5_a99b_18f7_77e4_365e_1492_0e2c_0f61,
                                    256'h8bbb_6eb2_d3b4_c263_58ea_1cdd_2f42_8143_fb8d_482e_bacc_6503_6906_c003_042e_ea9c,
                                    256'hd127_d370_88fa_9d77_14a2_1f54_d0ba_3b10_1820_45de_4d58_98af_577a_57d5_62af_b6f3,
                                    256'h7f8f_b5be_1762_7481_8805_e3a9_7e75_93ee_ecf2_af95_ac29_d0ff_d360_9f96_70b5_c89b,
                                    256'h919a_41e8_39c9_6b51_aeef_30a6_c4a4_e03b_7865_b82c_8849_7d05_46bc_f22e_3772_346a,
                                    256'haa75_79e8_0102_6895_04ed_4893_2c21_c36e_d09d_e50c_d847_aef5_91ab_254c_c1d0_816d,
                                    256'habe0_9eb9_30eb_9ecb_3cd2_5686_90ab_184d_e32f_788a_27cc_adbf_ad9c_c635_f001_161b};

logic[511:0] ddr_model[bit[31:0]];

class test_dma_data;
  rand  bit[511:0] data;
endclass
test_dma_data data64;

class test_dma_desc_normal;
  randc bit[31:0]  src;
  randc bit[31:0]  dst;
  rand  bit[31:0]  len;
  constraint ad {
    src >= 32'h1100_0000;
    src <= 32'h1100_3fff;
    dst >= 32'h1400_0000;
    dst <= 32'h1400_ffff;
    src + len <= 32'h1100_3fff;
    dst + len <= 32'h1400_ffff;
    src % 32 == 0;
    dst % 32 == 0;
    len <= 32'h4000;
  }
endclass
test_dma_desc_normal desc;

// logic            dma_go_i;
// s_dma_desc_t     dma_desc;
// s_dma_error_t    dma_error;
// s_dma_status_t   dma_stats;

// task automatic dma_transfer;
//   input [31:0] src;
//   input [31:0] dst;
//   input [31:0] bytes;
//   dma_desc.src_addr  = src;
//   dma_desc.dst_addr  = dst;
//   dma_desc.num_bytes = bytes;
//   dma_go_i           = 1'b1;
//   while(!dma_stats.active) @(posedge clk);
//   dma_go_i           = 1'b0;
//   while(!dma_stats.done && dma_stats.active) @(posedge clk) begin
//     if(dma_stats.error == 1) begin
//       $display("[%0t]: DMA error is %d", $time, dma_error.src);
//     end
//   end
// endtask

// task automatic ram_init;
//   for (int i = 0; i < 16384; i++)begin
//     data64.randomize();
//     ddr_model[(RAM_START_ADDR+(32'h40 * i))] = data64.data;
//     u_axi4_master_bfm.BFM_WRITE_BURST64(RAM_START_ADDR, (32'h40 * i), data64.data, `ENABLE_MESSAGE);
//   end
// endtask

// task automatic transfer_test;
//   input int repeat_num;
//   input int byte_num;
//   int num = byte_num / 64;
//     repeat(repeat_num) begin
//       desc.randomize();
//       $display("[%0t] testing %d-bytes transfer, src = %h, dst = %h", $time, byte_num, desc.src, desc.dst);
//       for (int i = 0; i < num; i++) begin
//         ddr_model[desc.dst + (32'h40 * i)]=ddr_model[desc.src + (32'h40 * i)];
//       end
//       dma_transfer(desc.src, desc.dst, (32'h40 * num));
//     end
// endtask

// task automatic dma_random_test;
// 	desc        = new();
//   data64      = new();
//   master_ctrl = 1'b0;    // change to BFM
//   ram_init();
//   master_ctrl = 1'b1;    // change to DMA
//   transfer_test(5,256);  // (repeat num, transfer bytes)
//   transfer_test(5,512);
//   transfer_test(50,1024);
//   transfer_test(5,2048);
//   transfer_test(5,4096);
//   transfer_test(5,8192);
//   master_ctrl = 1'b0;    // change to BFM
//   foreach(ddr_model[j])begin
//      u_axi4_master_bfm.BFM_READ_BURST64(j, 0, response512, `ENABLE_MESSAGE);
//      if((response512 != ddr_model[j]) || (response512 === 'dx)) begin
//          $display("DMA error at %0h, write data is:%0h, read data is:%0h.",j ,ddr_model[j], response512);
//          $stop;
//      end
//   end
//   $display("DMA test done!");
//   $stop;
// endtask

`endif
