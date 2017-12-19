SET (BinName split_test)
FILE (GLOB_RECURSE BinSources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} SplitTest.vala)
SET (BinPackages gee-0.8)
SET (BinPkgModules gee-0.8)
SET (BinCustomVapis ${CMAKE_BINARY_DIR}/src/latex-struct/${PROJECT_LOWERCASE_NAME}-${MAJOR}.vapi)
SET (BinLinkLibs ${PROJECT_LOWERCASE_NAME})
INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}/src/latex-struct")
INCLUDE (ValaBinCommonRules)

# Split tests
MACRO (do_split_test testname limits table etalon regexp)
  ADD_TEST (SplitTest-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/split_test
            --limits ${limits} --table ${table} --etalon ${etalon})
SET_TESTS_PROPERTIES (SplitTest-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
ENDMACRO (do_split_test)

# test TeXReport_splitLongtable () function
do_split_test (split0 ${PROJECT_SOURCE_DIR}/test/tex/limits1.in
                          ${PROJECT_SOURCE_DIR}/test/tex/limits_table1.tex
                          ${PROJECT_SOURCE_DIR}/test/tex/limits_table1.etalon.tex
"Etalon and generated text are EQUAL ...\n")
SET_TESTS_PROPERTIES(SplitTest-split0 PROPERTIES ENVIRONMENT "LANG=en")

# enable testing
ENABLE_TESTING ()
