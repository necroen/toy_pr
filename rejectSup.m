function g2 = rejectSup(g,sup)

g2 = 2.*projectSup(g,sup) - g;