/*******************************************************************************
*                           TEMPLATE MASTER DO-FILE                            *
********************************************************************************
*                                                                              *
*   PURPOSE:     Reproduce all data work, map inputs and outputs,              *
*                facilitate collaboration                                      *
*                                                                              *
*   OUTLINE:     PART 1:  Set standard settings and install packages           *
*                PART 2:  Prepare folder paths and define programs             *
*                PART 3:  Run do-files                                         *
*                                                                              *
********************************************************************************
    PART 1:  Install user-written packages and harmonize settings
********************************************************************************/

*NEED TO BE REVISED BEFORE USE

//
// local user_commands ietoolkit iefieldkit //Add required user-written commands
//     foreach command of local user_commands {
//         cap which `command'
//         if _rc == 111 ssc install `command'
//     }
//
//     *Harmonize settings across users as much as possible
//     ieboilstart, v(13.1)
//     `r(version)'


/*******************************************************************************
    PART 2:  Prepare folder paths and define programs
*******************************************************************************/

*NEED TO BE REVISED BEFORE USE


//   if "`c(username)'" == "ResearchAssistant" {
//         global github      "C:/Users/RA/Documents/GitHub/d4di/DataWork"
//         global dropbox     "C:/Users/RA/Dropbox/d4di/DataWork"
//         global encrypted   "M:/DataWork/EncryptedData"
//     }
//
//     * Baseline folder globals
//     global bl_encrypt       "${encrypted}/Round Baseline Encrypted"
//     global bl_dt            "${dropbox}/Baseline/DataSets"
//     global bl_doc           "${dropbox}/Baseline/Documentation"
//     global bl_do            "${github}/Baseline/Dofiles"
//     global bl_out           "${github}/Baseline/Output"

	

/*------------------------------------------------------------------------------
    PART 3.1:  Clean data
    REQUIRES:   ${bl_dt}/xxxxxxxxx.dta
    CREATES:    ${bl_dt}/xxxxxxxxx.dta
    IDS VAR:    hhid
----------------------------------------------------------------------------- */

  *Change the 0 to 1 to run the baseline cleaning do-file
    if (0) do "${bl_do}/s1_data_cleaning.do"
	

/*-----------------------------------------------------------------------------
    PART 3.2:  Analyse data 
    REQUIRES:   ${bl_dt}/xxxxxxxxx.dta
    CREATES:    ${bl_out}/xxxxxxxx.png
                ${bl_dt}/xxxxxxxxxx.dta
    IDS VAR:    hhid
----------------------------------------------------------------------------- */
    *Change the 0 to 1 to run the baseline variable construction do-file
    if (0) do "${bl_do}/Construct/construct_income.do"

