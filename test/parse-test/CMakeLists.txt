SET (BinName parse_test)
FILE (GLOB_RECURSE BinSources RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ParseTest.vala)
SET (BinPackages gee-0.8)
SET (BinCustomVapis ${CMAKE_BINARY_DIR}/src/latex-struct/${PROJECT_LOWERCASE_NAME}-${MAJOR}.vapi)
SET (BinLinkLibs ${PROJECT_LOWERCASE_NAME})
INCLUDE_DIRECTORIES ("${CMAKE_BINARY_DIR}/src/latex-struct")
INCLUDE (ValaBinCommonRules)

# Parse tests
MACRO (do_parse_test testname table_path etalon_path regexp)
  IF ("${etalon_path}" STREQUAL "")
    SET (extra_args "")
  ELSE ()
    SET (extra_args --etalon ${etalon_path})
  ENDIF ()
  ADD_TEST (ParseTest-${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/parse_test --table ${table_path} ${extra_args})
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
SET_TESTS_PROPERTIES(ParseTest-throttleList PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-includegraphicsWalk PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleCmp ${PROJECT_SOURCE_DIR}/test/tex/throttle.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-throttleCmp PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr1 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err1.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:15: : Unexpected end tag sequence '..end{longtable}' without begin tag pair.
.end{longtable}
              .")
SET_TESTS_PROPERTIES(ParseTest-throttleErr1 PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr2 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err2.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:1: Begin tag sequence '..begin{longtable}' without end tag pair.
.begin{longtable}
.
")
SET_TESTS_PROPERTIES(ParseTest-throttleErr2 PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr3 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err3.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:34:1: Error parsing subdoc.
.begin{longtable}
.
LAviewParsersLongtableParser:55:46: Stop external tag sequence '..end{longtable}' without begin tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{longtable} &  &  &  & .tabularnewline
                                             .
")
SET_TESTS_PROPERTIES(ParseTest-throttleErr3 PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr4 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err4.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:13: : Unexpected end tag sequence '..end{tabular}' without begin tag pair.
.end{tabular}
            .")
SET_TESTS_PROPERTIES(ParseTest-throttleErr4 PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr5 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err5.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:33:1: Begin tag sequence '..begin{tabular}' without end tag pair.
.begin{tabular}
.
")
SET_TESTS_PROPERTIES(ParseTest-throttleErr5 PROPERTIES ENVIRONMENT "LANG=en")

# test throttle.tex
do_parse_test (throttleErr6 ${PROJECT_SOURCE_DIR}/test/tex/throttle_err6.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:34:1: Error parsing subdoc.
.begin{tabular}
.
LAviewParsersTabularParser:55:46: Stop external tag sequence '..end{tabular}' without begin tag pair.
.multicolumn{2}{|l|}{ЗМГ} &  & .end{tabular} &  &  &  & .tabularnewline
                                           .
")
SET_TESTS_PROPERTIES(ParseTest-throttleErr6 PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-formularList PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-formularWalk PROPERTIES ENVIRONMENT "LANG=en")

# test formular.tex
do_parse_test (formularCmp ${PROJECT_SOURCE_DIR}/test/tex/formular.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-formularCmp PROPERTIES ENVIRONMENT "LANG=en")

# test formular.tex
do_parse_test (formularErr1 ${PROJECT_SOURCE_DIR}/test/tex/formular_err1.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:192:15: : Unexpected end tag sequence '..end{longtable}' without begin tag pair.
.end{longtable}
              .")
SET_TESTS_PROPERTIES(ParseTest-formularErr1 PROPERTIES ENVIRONMENT "LANG=en")

# test formular.tex
do_parse_test (formularErr2 ${PROJECT_SOURCE_DIR}/test/tex/formular_err2.tex ""
"Error parsing TeX document: LAviewParsersGlobParser:44:1: Begin tag sequence '..begin{longtable}' without end tag pair.
.begin{longtable}
.
")
SET_TESTS_PROPERTIES(ParseTest-formularErr2 PROPERTIES ENVIRONMENT "LANG=en")

# test for caption in all_subtables.tex
do_parse_test (captionTest ${PROJECT_SOURCE_DIR}/test/tex/all_subtables.tex ""
".begin{document}
.begin{longtable}{.c.c.}
.caption{Caption of the table}
")
SET_TESTS_PROPERTIES(ParseTest-captionTest PROPERTIES ENVIRONMENT "LANG=en")

# test all_subtables.tex
do_parse_test (all_subtablesCmp ${PROJECT_SOURCE_DIR}/test/tex/all_subtables.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-all_subtablesCmp PROPERTIES ENVIRONMENT "LANG=en")

# test all_subtables.tex
do_parse_test (linesCmp ${PROJECT_SOURCE_DIR}/test/tex/lines.tex ${PROJECT_SOURCE_DIR}/test/tex/lines.etalon.tex
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-linesCmp PROPERTIES ENVIRONMENT "LANG=en")

# test ltable_embedded.tex
do_parse_test (ltable_embedded ${PROJECT_SOURCE_DIR}/test/tex/ltable_embedded.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-ltable_embedded PROPERTIES ENVIRONMENT "LANG=en")

# test ltable_double_embedded.tex
do_parse_test (ltable_double_embedded ${PROJECT_SOURCE_DIR}/test/tex/ltable_double_embedded.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-ltable_double_embedded PROPERTIES ENVIRONMENT "LANG=en")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500Cmp ${PROJECT_SOURCE_DIR}/test/tex/throttle_VK2500.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-throttle_VK2500Cmp PROPERTIES ENVIRONMENT "LANG=en")

# test throttle_VK2500.tex
do_parse_test (throttle_VK2500PSCmp ${PROJECT_SOURCE_DIR}/test/tex/throttle_VK2500PS.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-throttle_VK2500PSCmp PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-throttle_VK2500PS_dos_newlines_ListWalk PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-graph_in_ltable PROPERTIES ENVIRONMENT "LANG=en")

# test ltable_square_arg.tex
do_parse_test (ltable_square_arg ${PROJECT_SOURCE_DIR}/test/tex/ltable_square_arg.tex ""
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-ltable_square_arg PROPERTIES ENVIRONMENT "LANG=en")

# test table_in_table.tex
do_parse_test (table_in_table ${PROJECT_SOURCE_DIR}/test/tex/table_in_table.tex ""
"
list all objects
")
SET_TESTS_PROPERTIES(ParseTest-table_in_table PROPERTIES ENVIRONMENT "LANG=en")

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
SET_TESTS_PROPERTIES(ParseTest-unary_quotes PROPERTIES ENVIRONMENT "LANG=en")

# test back_slashes_in_a_table.tex
do_parse_test (back_slashes_in_a_table ${PROJECT_SOURCE_DIR}/test/tex/back_slashes_in_a_table.tex ${PROJECT_SOURCE_DIR}/test/tex/back_slashes_in_a_table.etalon.tex
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-back_slashes_in_a_table PROPERTIES ENVIRONMENT "LANG=en")

# test multiply_defined_columns.tex
do_parse_test (multiply_defined_columns
    ${PROJECT_SOURCE_DIR}/test/tex/multiply_defined_columns.tex
    ${PROJECT_SOURCE_DIR}/test/tex/multiply_defined_columns.etalon.tex
"Original and generated text are EQUAL .-.")
SET_TESTS_PROPERTIES(ParseTest-multiply_defined_columns PROPERTIES ENVIRONMENT "LANG=en")

# enable testing
ENABLE_TESTING ()
