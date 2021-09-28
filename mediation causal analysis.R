file_path <- "F:/tax/¤¤¤¶¤ÀªR/analysis.csv"
analysis<- read.table(file_path, header = TRUE, stringsAsFactors = FALSE, sep = ",")
View(analysis)

install.packages("mediation")
library("mediation")

analysis$quit <- factor(analysis$quit)
analysis$tax2 <- factor(analysis$tax2)
analysis$caseage <- factor(analysis$caseage)
analysis$edu <- factor(analysis$edu)
analysis$casefirstsdn <- factor(analysis$casefirstsdn)
analysis$caseSmokeScore <- factor(analysis$caseftnd)
analysis$famsmoker <- factor(analysis$famsmoker)
analysis$usedrug <- factor(analysis$usedrug)

med.fit <- glm(adh ~ tax2 + caseage + edu + sex + casefirstsdn + caseftnd + famsmoker + usedrug, data=analysis, family=poisson(link="log"))
out.fit <- glm(quit ~ adh*tax2 + caseage + edu + sex + casefirstsdn + caseftnd + famsmoker + usedrug + addweek, data=analysis, family=binomial)
med.out <- mediate(med.fit, out.fit, treat="tax2", mediator="adh", robustSE=TRUE, sims=1000)
summary(med.out)

test.TMint(med.out,conf.level= .95)
plot(med.out)



test.modmed(med.out, covariates.1 = list(tax2 = 0), covariates.2 = list(tax2 = 1), sims = 1000)



