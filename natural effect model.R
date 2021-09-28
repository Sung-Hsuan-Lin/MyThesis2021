file_path <- "F:/tax/¤¤¤¶¤ÀªR/analysis.csv"
analysis<- read.table(file_path, header = TRUE, stringsAsFactors = FALSE, sep = ",")
View(analysis)

install.packages("medflex")
library("medflex")

analysis$quit <- factor(analysis$quit)
analysis$tax2 <- factor(analysis$tax2)
analysis$caseage <- factor(analysis$caseage)
analysis$edu <- factor(analysis$edu)
analysis$casefirstsdn <- factor(analysis$casefirstsdn)
analysis$caseSmokeScore <- factor(analysis$caseftnd)
analysis$famsmoker <- factor(analysis$famsmoker)
analysis$usedrug <- factor(analysis$usedrug)

med.fit <- glm(adh ~ tax2 + caseage + edu + sex + casefirstsdn + caseftnd + famsmoker + usedrug, data=analysis, family=poisson(link="log"))
expData <- neWeight(med.fit)
w <- weights(expData)

View(expData)
set.seed(1234)
neMod1 <- neModel(quit ~ tax20 + tax21 + caseage + edu + sex + casefirstsdn + caseftnd + famsmoker + usedrug + addweek, data=analysis, family = binomial, expData = expData)
summary(neMod1)
exp(confint(neMod1)[c("tax201", "tax211"), ])
exp(0.020725)
exp(0.135255)
neEffdecomp(neMod1)
exp(0.15598)
exp(confint(neEffdecomp(neMod1)))

plot(neMod1, xlab = "odds ratio", transf = exp)
exp(confint(neEffdecomp(neMod1))[c("natural indirect effect"), ])


impData <- neImpute(quit ~ (tax2 + adh) * usedrug + sex + caseage + edu + caseftnd + casefirstsdn + famsmoker + addweek, family = binomial, data = analysis)
neMod4 <- neModel(quit ~ tax20 + tax21 * usedrug + sex + caseage + edu + caseftnd + casefirstsdn + famsmoker + addweek, family = binomial, expData = impData, se = "robust")
summary(neMod4)


