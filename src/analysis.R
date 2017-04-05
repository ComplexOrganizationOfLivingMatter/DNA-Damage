# -------------- DNA-Damage ------------------ #
require(ggplot2)
require(sandwich)
require(msm)

info <- readMat('D:/Pablo/DNA-Damage/results/segmentation/characteristicsOfNetworks.mat')

#ir <- lm(info$IR.MinDistancesOfFociToHeterocrhomatin)
#vp16 <- lm(info$VP16.MinDistancesOfFociToHeterocrhomatin)

boundaries <- seq(0, 3, by=.25/2)

minDis <- c(info$IR.MinDistancesOfFociToHeterocrhomatin, info$VP16.MinDistancesOfFociToHeterocrhomatin)
cond <- c(array(1, length(info$IR.MinDistancesOfFociToHeterocrhomatin)), array(2, length(info$VP16.MinDistancesOfFociToHeterocrhomatin)))

t.test(minDis ~ cond)
t.test(log(minDis) ~ cond)

ir <- hist(info$IR.MinDistancesOfFociToHeterocrhomatin, probability = TRUE, breaks = boundaries, xlim = c(0, 3), col="lightblue")
vp16<- hist(info$VP16.MinDistancesOfFociToHeterocrhomatin, probability = TRUE, breaks = boundaries, xlim = c(0, 3))

irLm <- lm(ir$mids ~ ir$density)
vp16Lm <- lm(ir$mids ~ vp16$density)

summary(lm(ir$mids ~ ir$density + vp16$density))
summary(glm(ir$mids ~ ir$density + vp16$density))

anova(irLm, vp16Lm, test="Chisq")
#summary(m1 <- glm(ir$mids ~ ir$density, family="poisson"))