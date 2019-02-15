# ## get summary for plotting
# plotSummary=summarySEwithin(data=exp.tidy, measurevar="RT", withinvars=c("conditionName","category"), idvar="subject")
# 
# 
# ## Make plot
# library(ggthemes)
# library(ggplot2)
# plotLimits=c(1000,2500)
# dodge <- position_dodge(width = 0.9)
# ggplot(plotSummary, aes(x=category,y=RT, fill=conditionName)) +
#   geom_bar(stat="identity", position=dodge) +  # plot the point
#   geom_errorbar(aes(ymin=RT-se, ymax=RT+se), width=.1, position=dodge) + # make some error bars
#   coord_cartesian(ylim=plotLimits) + # ugh, need this for some reason with bar plots - sorry
#   theme_hc(base_size=14)  + ## change ggplot theme, number here modulates size of text
#   theme(axis.ticks.x=element_blank(),    axis.ticks.y=element_blank()) + 
#   theme(text=element_text(family="Helvetica Light")) + # I just think this is agood font
#   labs(x="", y="Search speed (ms)") + # kill redudant x label +
#   scale_fill_grey() +
#   ggtitle("Mean RT by Condition & Category")
# 
# ggplot(avgByCondAndCat, aes(x=category,y=RT, fill=conditionName)) +
#   geom_bar(stat="mean", position=dodge) +  # plot the point
#   geom_point() + 
#   geom_errorbar(aes(ymin=RT-se, ymax=RT+se), width=.1, position=dodge) + # make some error bars
#   coord_cartesian(ylim=plotLimits) + # ugh, need this for some reason with bar plots - sorry
#   theme_hc(base_size=14)  + ## change ggplot theme, number here modulates size of text
#   theme(axis.ticks.x=element_blank(),    axis.ticks.y=element_blank()) + 
#   theme(text=element_text(family="Helvetica Light")) + # I just think this is agood font
#   labs(x="", y="Search speed (ms)") + # kill redudant x label +
#   scale_fill_grey() +
#   ggtitle("Mean RT by Condition & Category")
# 
# 
# plotSummaryMin=summarySEwithin(data=exp.tidy, measurevar="RT", withinvars=c("conditionName"), idvar="sub")
# tiff('RTbyCond.tiff', units="in", width=5, height=5, res=300)
# ggplot(plotSummaryMin, aes(x=conditionName,y=RT, fill=conditionName)) +
#   geom_bar(stat="identity", position = position_dodge(width = 0.9)) +  # plot the point
#   geom_errorbar(aes(ymin=RT-se, ymax=RT+se), width=.1) + # make some error bars
#   coord_cartesian(ylim=plotLimits) + # ugh, need this for some reason with bar plots - sorry
#   theme_hc(base_size=14)  + ## change ggplot theme, number here modulates size of text
#   theme(axis.ticks.x=element_blank(),    axis.ticks.y=element_blank()) + 
#   theme(text=element_text(family="Helvetica Light")) + # I just think this is agood font
#   labs(x="", y="Search speed (ms)") + # kill redudant x label +
#   scale_fill_grey() +
#   theme(aspect.ratio=1.5) 
# dev.off()
#   # + ggtitle("Mean RT by Condition")