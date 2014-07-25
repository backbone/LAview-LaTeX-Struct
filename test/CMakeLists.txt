INCLUDE (FindVala)
INCLUDE (UseVala)

FIND_PACKAGE (PkgConfig REQUIRED)

PKG_CHECK_MODULES (GEE REQUIRED gee-0.8)
INCLUDE_DIRECTORIES (${GEE_INCLUDE_DIRS})

INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}")
INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}/src")

# add parse_test executable
FILE (GLOB_RECURSE ParseTestSources RELATIVE ${CMAKE_SOURCE_DIR}/test ParseTest.vala)
VALA_PRECOMPILE (ParseTest_C ${ParseTestSources}
                 PACKAGES gee-0.8 posix
                 OPTIONS --thread ${VALA_DEBUG}
                 CUSTOM_VAPIS ${PROJECT_BINARY_DIR}/src/${PROJ_LCASE}-${MAJOR}.vapi
                 GENERATE_VAPI
                 GENERATE_HEADER
                )
ADD_EXECUTABLE (ParseTest ${ParseTest_C})
TARGET_LINK_LIBRARIES (ParseTest ${PROJ_LCASE} ${GEE_LIBRARIES})

# add ltable_test executable
FILE (GLOB_RECURSE LTableTestSources RELATIVE ${CMAKE_SOURCE_DIR}/test LTableTest.vala)
VALA_PRECOMPILE (LTableTest_C ${LTableTestSources}
                 PACKAGES gee-0.8 posix
                 OPTIONS --thread ${VALA_DEBUG}
                 CUSTOM_VAPIS ${PROJECT_BINARY_DIR}/src/${PROJ_LCASE}-${MAJOR}.vapi
                 GENERATE_VAPI
                 GENERATE_HEADER
                )
ADD_EXECUTABLE (LTableTest ${LTableTest_C})
TARGET_LINK_LIBRARIES (LTableTest ${PROJ_LCASE} ${GEE_LIBRARIES})

# add split_test executable
FILE (GLOB_RECURSE LTableTestSources RELATIVE ${CMAKE_SOURCE_DIR}/test SplitTest.vala)
VALA_PRECOMPILE (SplitTest_C ${LTableTestSources}
                 PACKAGES gee-0.8 posix
                 OPTIONS --thread ${VALA_DEBUG}
                 CUSTOM_VAPIS ${PROJECT_BINARY_DIR}/src/${PROJ_LCASE}-${MAJOR}.vapi
                 GENERATE_VAPI
                 GENERATE_HEADER
                )
ADD_EXECUTABLE (SplitTest ${SplitTest_C})
TARGET_LINK_LIBRARIES (SplitTest ${PROJ_LCASE} ${GEE_LIBRARIES})

# parsing test macro
MACRO (do_parse_test testname table_path etalon_path regexp)
  IF ("${etalon_path}" STREQUAL "")
    SET (extra_args "")
  ELSE ()
    SET (extra_args --etalon ${etalon_path})
  ENDIF ()
  ADD_TEST (ParseTest-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ParseTest --table ${table_path} ${extra_args})
  SET_TESTS_PROPERTIES (ParseTest-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
ENDMACRO (do_parse_test)

# test throttle.tex
do_parse_test (throttleList ${PROJECT_SOURCE_DIR}/test/tex/throttle.tex ""
"list all objects
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableTabular
LAviewText
end of objects

")

# test throttle.tex
do_parse_test (includegraphicsWalk ${PROJECT_SOURCE_DIR}/test/tex/includegraphics.tex ""
"Walk through all objects
LAviewText
LAviewGraphics
  width=0.000000. height=3.000000pt. path=174.
  gen..=.includegraphics.height=3.000000pt.angle=25.scale=3.{174}
resized gen.. = .includegraphics.width=0.500000pt.height=6.000000dd.angle=25.scale=3.{174}
LAviewText
LAviewGraphics
  width=12.000000cm. height=25.000000cm. path=151.
  gen..=.includegraphics.width=12.000000cm.height=25.000000cm.{151}
resized gen.. = .includegraphics.width=0.500000pt.height=50.000000dd.{151}
LAviewText
end of objects

")

# test throttle.tex
do_parse_test (throttleCmp ${PROJECT_SOURCE_DIR}/test/tex/throttle.tex ""
"Original and generated text are EQUAL .-.")

# test throttle.tex
do_parse_test (throttleErr1 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err1.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:15: : Unexpected end tag sequence '..end{longtable}' without begin tag pair.
.end{longtable}
              .")

# test throttle.tex
do_parse_test (throttleErr2 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err2.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:1: Begin tag sequence '..begin{longtable}' without end tag pair.
.begin{longtable}
.
")

# test throttle.tex
do_parse_test (throttleErr3 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err3.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:34:1: Error parsing subdoc.
.begin{longtable}
.
LAviewParsersLongtableParser:55:46: Stop external tag sequence '..end{longtable}' without begin tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{longtable} &  &  &  & .tabularnewline
                                             .
")

# test throttle.tex
do_parse_test (throttleErr4 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err4.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:13: : Unexpected end tag sequence '..end{tabular}' without begin tag pair.
.end{tabular}
            .")

# test throttle.tex
do_parse_test (throttleErr5 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err5.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:1: Begin tag sequence '..begin{tabular}' without end tag pair.
.begin{tabular}
.
")

# test throttle.tex
do_parse_test (throttleErr6 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err6.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:34:1: Error parsing subdoc.
.begin{tabular}
.
LAviewParsersTabularParser:55:46: Stop external tag sequence '..end{tabular}' without begin tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{tabular} &  &  &  & .tabularnewline
                                           .
")

# test formular.tex
do_parse_test (formularList ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ""
"list all objects
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
end of objects

")

# test formular.tex
do_parse_test (formularWalk ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ""
"Walk through all objects
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
end of objects

")

# test formular.tex
do_parse_test (formularCmp ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ""
"Original and generated text are EQUAL .-.")

# test formular.tex
do_parse_test (formularErr1 ${PROJECT_SOURCE_DIR}/test/tex/formular_err1.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:192:15: : Unexpected end tag sequence '..end{longtable}' without begin tag pair.
.end{longtable}
              .")

# test formular.tex
do_parse_test (formularErr2 ${PROJECT_SOURCE_DIR}/test/tex/formular_err2.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:44:1: Begin tag sequence '..begin{longtable}' without end tag pair.
.begin{longtable}
.
")

# test for caption in all_subtables.tex
do_parse_test (captionTest ${PROJECT_SOURCE_DIR}/test/tex/all_subtables.tex ""
".begin{document}
.begin{longtable}{.c.c.}
.caption{Caption of the table}
")

# test all_subtables.tex
do_parse_test (all_subtablesCmp ${PROJECT_SOURCE_DIR}/test/tex/all_subtables.tex ""
"Original and generated text are EQUAL .-.")

# test all_subtables.tex
do_parse_test (linesCmp ${PROJECT_SOURCE_DIR}/test/tex/lines.tex ${PROJECT_SOURCE_DIR}/test/tex/lines.etalon.tex
"Original and generated text are EQUAL .-.")

# test ltable_embedded.tex
do_parse_test (ltable_embedded ${PROJECT_SOURCE_DIR}/test/tex/ltable_embedded.tex ""
"Original and generated text are EQUAL .-.")

# test ltable_double_embedded.tex
do_parse_test (ltable_double_embedded ${PROJECT_SOURCE_DIR}/test/tex/ltable_double_embedded.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500Cmp ${PROJECT_SOURCE_DIR}/test/tex/throttle_VK2500.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500PSCmp ${PROJECT_SOURCE_DIR}/test/tex/throttle_VK2500PS.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500_dos_newlines_.tex
do_parse_test (throttle_VK2500PS_dos_newlines_ListWalk ${PROJECT_SOURCE_DIR}/test/tex/throttle_VK2500PS_dos_newlines.tex ""
"list all objects
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
end of objects

Walk through all objects
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
end of objects
")

# test graph_in_ltable.tex
do_parse_test (graph_in_ltable ${PROJECT_SOURCE_DIR}/test/tex/graph_in_ltable.tex ""
"
list all objects
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableLongtable
  LAviewTableLongtable
LAviewText
LAviewTableLongtable
  LAviewGraphics
  LAviewTableLongtable
LAviewText
end of objects

Walk through all objects
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableLongtable
LAviewText
LAviewTableLongtable
LAviewText
end of objects
")

# test ltable_square_arg.tex
do_parse_test (ltable_square_arg ${PROJECT_SOURCE_DIR}/test/tex/ltable_square_arg.tex ""
"Original and generated text are EQUAL .-.")

# test table_in_table.tex
do_parse_test (table_in_table ${PROJECT_SOURCE_DIR}/test/tex/table_in_table.tex ""
"
list all objects
")

# test unary_quotes.tex
do_parse_test (unary_quotes ${PROJECT_SOURCE_DIR}/test/tex/unary_quotes.tex ""
"
list all objects
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
end of objects

Walk through all objects
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
LAviewTableTabular
LAviewText
end of objects
")

# test back_slashes_in_a_table.tex
do_parse_test (back_slashes_in_a_table ${PROJECT_SOURCE_DIR}/test/tex/back_slashes_in_a_table.tex ${PROJECT_SOURCE_DIR}/test/tex/back_slashes_in_a_table.etalon.tex
"Original and generated text are EQUAL .-.")

# ltable_test macro
macro (ltable_test testname tex_path1 tex_path2 operation regexp)
    add_test (ltable_test-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/LTableTest ${tex_path1} ${tex_path2} ${operation})
set_tests_properties (ltable_test-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
endmacro (ltable_test)

# ltable_test rm0row
ltable_test (rm0row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm0row.tex rm0row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm1row
ltable_test (rm1row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm1row.tex rm1row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm1000row
ltable_test (rm1000row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm1000row.tex rm1000row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm_last_row
ltable_test (rm_last_row ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_rm_last_row.tex rm_last_row
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_0
ltable_test (clone_0_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_0.tex clone_0_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_1
ltable_test (clone_0_1 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_1.tex clone_0_1
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_1_0
ltable_test (clone_1_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_1_0.tex clone_1_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_last
ltable_test (clone_0_last ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_last.tex clone_0_last
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_last_0
ltable_test (clone_last_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_last_0.tex clone_last_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_lastp1
ltable_test (clone_0_lastp1 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_lastp1.tex clone_0_lastp1
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_lastp1_0
ltable_test (clone_lastp1_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_lastp1_0.tex clone_lastp1_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_1000
ltable_test (clone_0_1000 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_0_1000.tex clone_0_1000
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_1000_0
ltable_test (clone_1000_0 ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ${PROJECT_SOURCE_DIR}/test/tex/ltable_clone_1000_0.tex clone_1000_0
"Etalon and generated text are EQUAL .-.")

# ltable_test append_row0
ltable_test (append_row0 ${PROJECT_SOURCE_DIR}/test/tex/table_rows.tex ${PROJECT_SOURCE_DIR}/test/tex/table_rows.etalon.tex append_row0
"Etalon and generated text are EQUAL .-.")

MACRO (do_split_test testname limits table etalon regexp)
  ADD_TEST (split_test-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/SplitTest
            --limits ${limits} --table ${table} --etalon ${etalon})
SET_TESTS_PROPERTIES (split_test-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
ENDMACRO (do_split_test)

# test TeXReport_splitLongtable () function
do_split_test (split_test ${PROJECT_SOURCE_DIR}/test/tex/limits1.in
                          ${PROJECT_SOURCE_DIR}/test/tex/limits_table1.tex
                          ${PROJECT_SOURCE_DIR}/test/tex/limits_table1.etalon.tex
"Etalon and generated text are EQUAL ...\n")

# enable testing
ENABLE_TESTING ()
