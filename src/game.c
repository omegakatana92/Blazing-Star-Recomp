/*
 * game.c — the Blazing Star (NGH-239) ROM set, shared by the player and the
 * generator so both load the program identically.
 *
 * MAME set "blazstar". The 3 MB P ROM is two files: 239-p1.p1 (1 MB) is the
 * fixed $000000 bank, and 239-p2.sp2 (2 MB) is the banked $200000 region
 * (two 1 MB banks). Both are stored byte-swapped (ROM_LOAD16_WORD_SWAP).
 */
#include "game.h"

const ng_game_t k_blazstar = {
    .name = "blazstar",
    .title = "Blazing Star",
    .prom_size = 0x300000,
    .prom = {
        {"239-p1.p1", 0x000000, 0x000000, 0x100000, 1},   /* file offset, dest, length, swap */
        {"239-p2.sp2", 0x000000, 0x100000, 0x200000, 1},
    },
    .crom_size = 0x2000000,                                /* 8 x 4 MB, four pairs */
    .crom_pairs = {
        {"239-c1.c1", "239-c2.c2"},
        {"239-c3.c3", "239-c4.c4"},
        {"239-c5.c5", "239-c6.c6"},
        {"239-c7.c7", "239-c8.c8"},
    },
    .srom = "239-s1.s1",
    .m1 = "239-m1.m1",
    .vrom = {"239-v1.v1", "239-v2.v2"},
};
