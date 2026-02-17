
#define EEPROM_ADDR      0x50    // 7-bit Address
#define EEPROM_PAGE_SIZE 252


typedef struct QspiData {
    u32 header;
    s32 dac_setpt_offset;
    s32 dac_setpt_gain;
    u32 dcct1_offset;
    u32 dcct1_gain;
    u32 dcct2_offset;
    u32 dcct2_gain;
    s32 dacmon_offset;
    s32 dacmon_gain;
    s32 volt_offset;
    s32 volt_gain;
    s32 gnd_offset;
    s32 gnd_gain;
    s32 spare_offset;
    s32 spare_gain;
    s32 reg_offset;
    s32 reg_gain;
    s32 error_offset;
    s32 error_gain;
    u32 ovc1_thresh;
    u32 ovc2_thresh;
    u32 ovv_thresh;
    u32 err1_thresh;
    u32 err2_thresh;
    u32 ignd_thresh;
    u32 ovc1_cntlim;
    u32 ovc2_cntlim;
    u32 ovv_cntlim;
    u32 err1_cntlim;
    u32 err2_cntlim;
    u32 ignd_cntlim;
    u32 dcct_cntlim;
    u32 flt1_cntlim;
    u32 flt2_cntlim;
    u32 flt3_cntlim;
    u32 on_cntlim;
    u32 heartbeat_cntlim;
    u32 fault_mask;
    float sf_ampspersec;
    float sf_dac_dccts;
    float sf_vout;
    float sf_ignd;
    float sf_spare;
    float sf_regulator;
    float sf_error;
} QspiData_t;



int QspiFlashInit();
//void QspiFlashEraseSect(u32);
//void QspiFlashWrite(u32, u32, u8 *);
//void QspiFlashRead(u32, u32, u8 *);
void QspiGatherData(u32, u8 *);
void QspiDisperseData(u32, u8 *);
void QspiPrintData(QspiData_t *, u32 );
void GetEepromSettings(u32 chan);



