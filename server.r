shinyServer(function(input, output){
  l <- list(color = toRGB("white"), width = 2)
  
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = F,
    lakecolor = toRGB('white')
  )
  
  output$plotMapGeo = renderPlotly({plot_ly(z = data_by_state_1[[input$select]], locations = data_by_state_1$'Provider state',
                                       type = 'choropleth', locationmode = 'USA-states', colors = 'Blues') %>%
      colorbar(title = ifelse(input$select == 'Total discharges',"K", 'USD')) %>%
      layout(title = toTitleCase(paste(strsplit(input$select, split='_')[[1]],collapse =' ')),
        geo = g)
  })
  
  output$plotPopGeo = renderPlotly({
    plot_ly(z = data_merge$Percent, locations = data_merge$Provider.State,
            type = 'choropleth', locationmode = 'USA-states', colors = 'Blues') %>%
      layout(title = 'Total Discharges as Percentage of Medicare Beneficiary Population by State', geo = g) %>%
      colorbar(title = "Percent")
  })
  
  output$table = DT::renderDataTable({
    datatable(data_by_state_1, rownames=FALSE) %>%
      formatStyle(input$select,
                  background="skyblue", fontWeight='bold')
  })
  
  output$table1 = DT::renderDataTable({
    datatable(data_by_code, rownames=FALSE) %>%
      formatStyle(input$select,
                  background="skyblue", fontWeight='bold')
  }) 
  
  output$table3 = DT::renderDataTable({
    datatable(ordered_by_code(), rownames=FALSE) %>%
      formatStyle(input$select,
                  background="skyblue", fontWeight='bold')
  }) 
  
  ordered_by_code = reactive({
    data_by_code_2 %>%
      mutate(Code = sapply(strsplit(`DRG definition`, "-"), "[", 1), Definition = sapply(strsplit(`DRG definition`, "-"), "[", 2)) %>%
      arrange(desc(!!sym(input$select))) %>%
      select('DRG definition', 'Total discharges', 'Average covered charges', 'Average total payments', 'Average Medicare payments') %>%
      head(input$slider)
  })

  data_joint = reactive({
    data %>%
      select(Provider.State, DRG.Definition, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
      filter(DRG.Definition == input$select1) %>%
      group_by(Provider.State) %>%
      summarise(max_average_medicare_payments = max(Average.Medicare.Payments),
                min_average_medicare_payments = min(Average.Medicare.Payments)) %>%
      arrange(max_average_medicare_payments-min_average_medicare_payments) %>%
      filter(Provider.State %in% input$checkbox)
  })
  
  data_viol = reactive({
    data %>%
      select(Provider.State, DRG.Definition, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
      filter(DRG.Definition == input$select1) %>%
      filter(Provider.State %in% input$checkbox)
  })
  
  data_ratio = reactive({
    data_ratio = data %>%
      select(Provider.State, DRG.Definition, Average.Total.Payments, Average.Covered.Charges, Average.Medicare.Payments) %>%
      filter(DRG.Definition == input$select1) %>%
      mutate(ratio = Average.Covered.Charges/Average.Medicare.Payments) %>%
      filter(Provider.State %in% input$checkbox)
  })
  
  ordered_data_by_code = reactive({
    data_by_code_2 %>%
    mutate(Code = sapply(strsplit(`DRG definition`, "-"), "[", 1), Definition = sapply(strsplit('DRG definition', "-"), "[", 2)) %>%
    arrange(desc(!!sym(input$select))) %>%
    head(input$slider)
    })
  
  output$plot2 = renderPlotly({
    ggplotly(ggplot(ordered_data_by_code(), aes(Code, y = !!sym(input$select), text = `DRG definition`)) + 
               geom_bar(stat = 'identity', fill='blue') +
               theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+ scale_y_continuous(labels = scales::comma)+
               xlab('Diagnosis code') +
               labs(title = toTitleCase(paste(strsplit(input$select, split='_')[[1]],collapse =' '))),
             tooltip = c('y', 'text')
    )
  })
    
  output$plot3 = renderPlot({
    ggplot(data_joint(), aes(x= min_average_medicare_payments, xend=max_average_medicare_payments, y=Provider.State, group=Provider.State)) + 
      geom_dumbbell(color="blue4", size=1) + scale_x_continuous(labels = scales::comma) + 
      labs(x=NULL, 
           y=NULL, 
           title= paste("Price variation for diagnosis code", tolower(input$select1)),
           subtitle = 'Average Medicare Payments in USD') +
      theme(plot.title = element_text(hjust=0.6, face="bold", size =15),
            plot.background=element_rect(fill="white"),
            panel.background=element_rect(fill="white"),
            panel.grid.minor=element_blank(),
            panel.grid.major.y=element_blank(),
            panel.grid.major.x=element_line(),
            axis.ticks=element_blank(),
            axis.text.x=element_text(colour="black", size = 11),
            axis.text.y=element_text(colour="black", size = 11),
            legend.position="top",
            panel.border=element_blank())
  })

  output$Pic = renderImage({
    return(list(src = "www/pic.png",contentType = "image/png"))
  }, deleteFile = FALSE)
  
  output$Pic2 = renderImage({
    return(list(src = "www/pic2.png",contentType = "image/png"))
  }, deleteFile = FALSE)
  
  output$correl = renderPlot({
    ggcorrplot(cor(c_data), hc.order = TRUE, 
               type = "lower", 
               lab = TRUE, 
               lab_size = 4, 
               tl.cex = 15,
               method="circle", 
               colors = c("tomato2", "white", "springgreen3"), 
               title="Correlations", 
               ggtheme=theme_bw) + theme(plot.title = element_text(size=18)) +
               theme(plot.title = element_text(hjust = 0.5), legend.title = element_text(size=15),
                     legend.text = element_text(size=11)) +
               scale_size_continuous(range = c(12, 20))
  })
  
  output$plot4 = renderPlot({
    ggplot(data_viol(), aes(x = Provider.State, y = Average.Medicare.Payments)) + geom_violin(aes(fill = Provider.State)) +
      theme(legend.position="none") + scale_y_continuous(labels = scales::comma) + 
      labs(x=NULL, 
           y=NULL, 
           title= paste("Variation of hospital charges for diagnosis code", tolower(input$select1)),
           subtitle = 'Average Medicare Payments in USD') + 
      theme(plot.title = element_text(hjust=0.6, face="bold", size =15), axis.text.x=element_text(colour="black", size = 11),
            axis.text.y=element_text(colour="black", size = 11))
  })
  
  output$plot5 = renderPlot({
    ggplot(data_ratio(), aes(x = Provider.State, y = ratio)) + geom_boxplot(aes(fill = Provider.State)) +
      theme(legend.position="none") +
      labs(x=NULL, 
           y=NULL, 
           title= paste("Charge to Reimbursement Ratios for", tolower(input$select1))) + 
      theme(plot.title = element_text(hjust=0.6, face="bold", size =15), axis.text.x=element_text(colour="black", size = 11),
            axis.text.y=element_text(colour="black", size = 11))
  })
})
  
  
  
