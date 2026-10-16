# tex() output is stable

    Code
      tex(c("Sample size ($n$)", "$\\hat{f}(y)$", "$P(Y > y \\, | \\, \\textbf{x})$",
        "$\\bar{y} \\pm 2s$", "$\\sigma^2 = 1$", "$\\log(\\hat{f}(y_i))$",
        "$\\textbf{x}_{ij}$"), output = "character")
    Output
      [1] "\"Sample size (\" * italic(\"n\") * \")\""                                                                                                                                                                                  
      [2] "{     hat(italic(\"f\")) * bold(\"(\") * {         italic(\"y\")     } * bold(\")\") }"                                                                                                                                     
      [3] "{     italic(\"P\") * bold(\"(\") * {         italic(\"Y\") * {             phantom() > phantom()         } * italic(\"y\") * phantom(.) * group(\"|\", phantom(), \"\") * phantom(.) * bolditalic(x)     } * bold(\")\") }"
      [4] "bar(italic(\"y\")) %+-% bold(\"2\") * italic(\"s\")"                                                                                                                                                                        
      [5] "italic(\"σ\")^{     bold(\"2\") } * {     phantom() == phantom() } * bold(\"1\")"                                                                                                                                           
      [6] "{     italic(\"log\") * bold(\"(\") * {         {             hat(italic(\"f\")) * bold(\"(\") * {                 italic(\"y\")[italic(\"i\")]             } * bold(\")\")         }     } * bold(\")\") }"                
      [7] "bolditalic(x)[italic(\"ij\")]"                                                                                                                                                                                              

# tex() rejects an unknown output

    Code
      tex("$x$", output = "plotmath")
    Condition
      Error in `tex()`:
      ! `output` must be one of "expression" or "character", not "plotmath".

