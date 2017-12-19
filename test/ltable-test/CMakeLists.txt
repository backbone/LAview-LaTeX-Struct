SET (BinName ltable_test)
FILE (GLOB_RECURSE BinSources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} LTableTest.vala)
SET (BinPackages gee-0.8)
SET (BinPkgModules gee-0.8)
SET (BinCustomVapis ${CMAKE_BINARY_DIR}/src/latex-struct/${PROJECT_LOWERCASE_NAME}-${MAJOR}.vapi)
SET (BinLinkLibs ${PROJECT_LOWERCASE_NAME})
INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}/src/latex-struct")
INCLUDE (ValaBinCommonRules)

# Longtable tests
MACRO (ltable_test testname tex_path1 tex_path2 operation regexp)
    ADD_TEST (ltable_test-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ltable_test ${tex_path1} ${tex_path2} ${operation})
    SET_TESTS_PROPERTIES (ltable_test-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
ENDMACRO (ltable_test)

# ltable_test rm0row
ltable_test (rm0row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm0row.tex rm0row
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-rm0row PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test rm1row
ltable_test (rm1row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm1row.tex rm1row
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-rm1row PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test rm1000row
ltable_test (rm1000row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm1000row.tex rm1000row
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-rm1000row PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test rm_last_row
ltable_test (rm_last_row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm_last_row.tex rm_last_row
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-rm_last_row PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_0_0
ltable_test (clone_0_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_0.tex clone_0_0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_0_0 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_0_1
ltable_test (clone_0_1 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_1.tex clone_0_1
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_0_1 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_1_0
ltable_test (clone_1_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_1_0.tex clone_1_0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_1_0 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_0_last
ltable_test (clone_0_last ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_last.tex clone_0_last
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_0_last PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_last_0
ltable_test (clone_last_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_last_0.tex clone_last_0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_last_0 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_0_lastp1
ltable_test (clone_0_lastp1 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_lastp1.tex clone_0_lastp1
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_0_lastp1 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_lastp1_0
ltable_test (clone_lastp1_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_lastp1_0.tex clone_lastp1_0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_lastp1_0 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_0_1000
ltable_test (clone_0_1000 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_1000.tex clone_0_1000
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_0_1000 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test clone_1000_0
ltable_test (clone_1000_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_1000_0.tex clone_1000_0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-clone_1000_0 PROPERTIES ENVIRONMENT "LANG=en")

# ltable_test append_row0
ltable_test (append_row0 ${PROJECT_SOURCE_DIR}/test/tex/table_rows.tex ${PROJECT_SOURCE_DIR}/test/tex/table_rows.etalon.tex append_row0
"Etalon and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ltable_test-append_row0 PROPERTIES ENVIRONMENT "LANG=en")

# enable testing
ENABLE_TESTING ()
