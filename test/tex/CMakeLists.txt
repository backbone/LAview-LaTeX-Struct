FIND_PACKAGE (PkgConfig REQUIRED)
PKG_CHECK_MODULES (GLIB2 REQUIRED glib-2.0)
PKG_CHECK_MODULES (GOBJECT2 REQUIRED gobject-2.0)

INCLUDE_DIRECTORIES (${GLIB2_INCLUDE_DIRS} ${GOBJECT2_INCLUDE_DIRS})
LINK_DIRECTORIES (${GLIB2_LIBRARY_DIRS} ${GOBJECT2_LIBRARY_DIRS})

IF (CMAKE_COMPILER_IS_GNUCC)
  ADD_DEFINITIONS (${GLIB2_CFLAGS_OTHER} ${GOBJECT2_CFLAGS_OTHER})
ENDIF ()

# add the executable
ADD_EXECUTABLE (txr_parse_test txr_parse_test.c)
TARGET_LINK_LIBRARIES (txr_parse_test txr-texparser ${GLIB2_LIBRARIES} ${GOBJECT2_LIBRARIES})

# add ltable_test executable
ADD_EXECUTABLE (ltable_test ltable_test.c)
TARGET_LINK_LIBRARIES (ltable_test txr-texparser ${GLIB2_LIBRARIES} ${GOBJECT2_LIBRARIES})

# add the install targets and files
# INSTALL (TARGETS txr_parse_test ltable_test DESTINATION bin)

# parsing test macro
MACRO (do_parse_test testname table_path etalon_path regexp)
  IF ("${etalon_path}" STREQUAL "")
    SET (extra_args "")
  ELSE ()
    SET (extra_args --etalon ${etalon_path})
  ENDIF ()
  ADD_TEST (txr_parse_test-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/txr_parse_test --table ${table_path} ${extra_args})
  SET_TESTS_PROPERTIES (txr_parse_test-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
ENDMACRO (do_parse_test)

# test throttle.tex
do_parse_test (throttleList ${PROJECT_SOURCE_DIR}/test/throttle.tex ""
"list all objects
TXRText
TXRLongtable
TXRText
TXRTabular
TXRText
TXRGraphics
TXRText
end of objects

")

# test throttle.tex
do_parse_test (throttleWalk ${PROJECT_SOURCE_DIR}/test/throttle.tex ""
"Walk through all objects
TXRText
TXRLongtable
TXRText
TXRTabular
TXRText
TXRGraphics
  width=0.000000.null., height=0.000000.null., path=174,
  gen..=.includegraphics., angle=25, scale=3,angle=70 ,  ,  .{174}
resized gen.. = .includegraphics.angle=25,scale=3.{174}
TXRText
end of objects

")

# test throttle.tex
do_parse_test (throttleCmp ${PROJECT_SOURCE_DIR}/test/throttle.tex ""
"Original and generated text are EQUAL .-.")

# test throttle.tex
do_parse_test (throttleErr1 ${PROJECT_SOURCE_DIR}/test/throttle_err1.tex ""
"Error parsing TeX document: TXRGlobScanner:33:15: : Unexpected stop tag sequence '..end{longtable}' without start tag pair.
.end{longtable}
              .")

# test throttle.tex
do_parse_test (throttleErr2 ${PROJECT_SOURCE_DIR}/test/throttle_err2.tex ""
"Error parsing TeX document: TXRGlobScanner:33:1: Start tag sequence '..begin{longtable}' without stop tag pair.
.begin{longtable}
.
")

# test throttle.tex
do_parse_test (throttleErr3 ${PROJECT_SOURCE_DIR}/test/throttle_err3.tex ""
"Error parsing TeX document: TXRGlobScanner:34:1: Error parsing subdoc.
.begin{longtable}
.
TXRLongtableScanner:55:46: Stop external tag sequence '..end{longtable}' without start tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{longtable} &  &  &  & .tabularnewline
                                             .
")

# test throttle.tex
do_parse_test (throttleErr4 ${PROJECT_SOURCE_DIR}/test/throttle_err4.tex ""
"Error parsing TeX document: TXRGlobScanner:33:13: : Unexpected stop tag sequence '..end{tabular}' without start tag pair.
.end{tabular}
            .")

# test throttle.tex
do_parse_test (throttleErr5 ${PROJECT_SOURCE_DIR}/test/throttle_err5.tex ""
"Error parsing TeX document: TXRGlobScanner:33:1: Start tag sequence '..begin{tabular}' without stop tag pair.
.begin{tabular}
.
")

# test throttle.tex
do_parse_test (throttleErr6 ${PROJECT_SOURCE_DIR}/test/throttle_err6.tex ""
"Error parsing TeX document: TXRGlobScanner:34:1: Error parsing subdoc.
.begin{tabular}
.
TXRTabularScanner:55:46: Stop external tag sequence '..end{tabular}' without start tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{tabular} &  &  &  & .tabularnewline
                                           .
")

# test formular.tex
do_parse_test (formularList ${PROJECT_SOURCE_DIR}/test/formular.tex ""
"list all objects
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRGraphics
TXRText
end of objects

")

# test formular.tex
do_parse_test (formularWalk ${PROJECT_SOURCE_DIR}/test/formular.tex ""
"Walk through all objects
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRGraphics
  width=12.000000cm, height=25.000000cm, path=151,
  gen..=.includegraphics.width=12cm,height=25cm.{151}
resized gen.. = .includegraphics.width=6.000000pt,height=50.000000dd.{151}
TXRText
end of objects

")

# test formular.tex
do_parse_test (formularCmp ${PROJECT_SOURCE_DIR}/test/formular.tex ""
"Original and generated text are EQUAL .-.")

# test formular.tex
do_parse_test (formularErr1 ${PROJECT_SOURCE_DIR}/test/formular_err1.tex ""
"Error parsing TeX document: TXRGlobScanner:192:15: : Unexpected stop tag sequence '..end{longtable}' without start tag pair.
.end{longtable}
              .")

# test formular.tex
do_parse_test (formularErr2 ${PROJECT_SOURCE_DIR}/test/formular_err2.tex ""
"Error parsing TeX document: TXRGlobScanner:44:1: Start tag sequence '..begin{longtable}' without stop tag pair.
.begin{longtable}
.
")

# test for caption in all_subtables.tex
do_parse_test (captionTest ${PROJECT_SOURCE_DIR}/test/all_subtables.tex ""
".begin{document}
.begin{longtable}{.c.c.}
.caption{Caption of the table}
")

# test all_subtables.tex
do_parse_test (all_subtablesCmp ${PROJECT_SOURCE_DIR}/test/all_subtables.tex ""
"Original and generated text are EQUAL .-.")

# test all_subtables.tex
do_parse_test (linesCmp ${PROJECT_SOURCE_DIR}/test/lines.tex ${PROJECT_SOURCE_DIR}/test/lines.etalon.tex
"Original and generated text are EQUAL .-.")

# test ltable_embedded.tex
do_parse_test (ltable_embedded ${PROJECT_SOURCE_DIR}/test/ltable_embedded.tex ""
"Original and generated text are EQUAL .-.")

# test ltable_double_embedded.tex
do_parse_test (ltable_double_embedded ${PROJECT_SOURCE_DIR}/test/ltable_double_embedded.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500Cmp ${PROJECT_SOURCE_DIR}/test/throttle_VK2500.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500PSCmp ${PROJECT_SOURCE_DIR}/test/throttle_VK2500PS.tex ""
"Original and generated text are EQUAL .-.")

# test throttle_VK2500_dos_newlines_.tex
do_parse_test (throttle_VK2500PS_dos_newlines_ListWalk ${PROJECT_SOURCE_DIR}/test/throttle_VK2500PS_dos_newlines.tex ""
"list all objects
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
end of objects

Walk through all objects
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
end of objects
")

# test graph_in_ltable.tex
do_parse_test (graph_in_ltable ${PROJECT_SOURCE_DIR}/test/graph_in_ltable.tex ""
"
list all objects
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRLongtable
  TXRLongtable
TXRText
TXRLongtable
  TXRGraphics
  TXRLongtable
TXRText
end of objects

Walk through all objects
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRLongtable
TXRText
TXRLongtable
TXRText
end of objects
")

# test ltable_square_arg.tex
do_parse_test (ltable_square_arg ${PROJECT_SOURCE_DIR}/test/ltable_square_arg.tex ""
"Original and generated text are EQUAL .-.")

# test table_in_table.tex
do_parse_test (table_in_table ${PROJECT_SOURCE_DIR}/test/table_in_table.tex ""
"
list all objects
")

# test unary_quotes.tex
do_parse_test (unary_quotes ${PROJECT_SOURCE_DIR}/test/unary_quotes.tex ""
"
list all objects
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
end of objects

Walk through all objects
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
TXRTabular
TXRText
end of objects
")

# test back_slashes_in_a_table.tex
do_parse_test (back_slashes_in_a_table ${PROJECT_SOURCE_DIR}/test/back_slashes_in_a_table.tex ${PROJECT_SOURCE_DIR}/test/back_slashes_in_a_table.etalon.tex
"Original and generated text are EQUAL .-.")


# ltable_test macro
macro (ltable_test testname tex_path1 tex_path2 operation regexp)
  add_test (ltable_test-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/ltable_test ${tex_path1} ${tex_path2} ${operation})
set_tests_properties (ltable_test-${testname}
  PROPERTIES PASS_REGULAR_EXPRESSION ${regexp}
             FAIL_REGULAR_EXPRESSION "CRITICAL;WARNING")
endmacro (ltable_test)

# ltable_test rm0row
ltable_test (rm0row ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_rm0row.tex rm0row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm1row
ltable_test (rm1row ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_rm1row.tex rm1row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm1000row
ltable_test (rm1000row ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_rm1000row.tex rm1000row
"Etalon and generated text are EQUAL .-.")

# ltable_test rm_last_row
ltable_test (rm_last_row ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_rm_last_row.tex rm_last_row
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_0
ltable_test (clone_0_0 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_0_0.tex clone_0_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_1
ltable_test (clone_0_1 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_0_1.tex clone_0_1
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_1_0
ltable_test (clone_1_0 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_1_0.tex clone_1_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_last
ltable_test (clone_0_last ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_0_last.tex clone_0_last
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_last_0
ltable_test (clone_last_0 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_last_0.tex clone_last_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_lastp1
ltable_test (clone_0_lastp1 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_0_lastp1.tex clone_0_lastp1
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_lastp1_0
ltable_test (clone_lastp1_0 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_lastp1_0.tex clone_lastp1_0
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_0_1000
ltable_test (clone_0_1000 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_0_1000.tex clone_0_1000
"Etalon and generated text are EQUAL .-.")

# ltable_test clone_1000_0
ltable_test (clone_1000_0 ${PROJECT_SOURCE_DIR}/test/formular.tex ${PROJECT_SOURCE_DIR}/test/ltable_clone_1000_0.tex clone_1000_0
"Etalon and generated text are EQUAL .-.")

# ltable_test append_row0
ltable_test (append_row0 ${PROJECT_SOURCE_DIR}/test/table_rows.tex ${PROJECT_SOURCE_DIR}/test/table_rows.etalon.tex append_row0
"Etalon and generated text are EQUAL .-.")

# enable testing
ENABLE_TESTING ()
