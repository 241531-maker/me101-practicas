#------scrpit 1 ------------------------------------------------------------------

# Completa: reconstruye el degradado con matrix()
gris <- matrix(rep(seq(0, 255, length.out = 5), times = 5),
               nrow = 5, ncol = 5, byrow = TRUE)

# Completa: dim() y mean()
dim(gris)    # 5 5
mean(gris)   # 127.5

#------scrpit 2 ------------------------------------------------------------------
rgb <- array(0, dim = c(4, 4, 3))
rgb[, 1:2, ] <- rep(c(200, 50, 50), each = 8)   
rgb[, 3:4, ] <- rep(c(50, 100, 200), each = 8)  


#-------scrpit 3 -----------------------------------------------------------
# Completa: gris_luminosa en R
R <- rgb[, , 1]
G <- rgb[, , 2]
B <- rgb[, , 3]

gris_luminosa <- 0.299 * R + 0.587 * G + 0.114 * B
gris_luminosa
