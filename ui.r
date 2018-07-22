library(shinydashboard)
shinyUI(dashboardPage(
  dashboardHeader(title = "Medicare Data"), 
  dashboardSidebar(sidebarUserPanel("Yulia Norenko"),
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("info")),
      menuItem("Payments/Discharges by State", tabName = "data", icon = icon("globe")),
      menuItem("Data by Diagnosis Code", tabName = "charts", icon = icon("user-md")),
      menuItem('Price Variations', tabName = 'code', icon = icon('usd')),
      menuItem('Correlations', tabName = 'corr', icon = icon("line-chart")),
      menuItem('Further Exploration', tabName = 'further', icon = icon("hourglass-half")),
      selectInput('select', 'Select Item to Display', choice)
    )
  ),
  dashboardBody(
    tabItems(
    tabItem(tabName = 'intro',
            fluidPage(
              h1("Variation in Hospital Charges for Inpatient Procedures in the United States."),
              column(1,imageOutput("Pic", height = 100, width = 100)),
              column(width = 4, offset = 7, h3('Background:') ,
                     h4('A number of observers have voiced concerns over significant variation in hospital charges and payments for 
                        the same services in the U.S.  In 2013, The Centers for Medicare & Medicaid Services (CMS) began providing 
                        Medicare claims and payment data in an effort to increase price transparency. We have analyzed the CMS data 
                        for FY 2015. Our analysis has shown that wide variations in hospital charges for the same services persist.'),
                     h3('The Dataset:'),
                     h4('National Summary of Inpatient Charge Data by Medicare Severity Diagnosis Related Group (MS-DRG), FY 2015.'),
              h4("The Dataset is owned by the CMS."),
              h4('The dataset includes hospital-specific charges for over 3,000 U.S. hospitals that receive Medicare Inpatient 
                 Prospective Payment System (IPPS) payments, paid under Medicare 
                 based on a rate per discharge using the Medicare Severity Diagnosis Related Group (MS-DRG) for Fiscal Year (FY) 2015.'),
              h4('The dataset includes 201K rows and 12 columns.')),
              HTML(
                paste('<br/>', '<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>',
                      '<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>','<br/>',
                      '<br/>','<br/>','<br/>','<br/>', '<br/>', '<br/>', '<br/>', '<br/>', '<br/>',
                      '<br/>',
                  h5("Author: Yulia Norenko \n\n"),
                  h5("Email: yn485@nyu.edu \n\n")
              )
            )
            )
    ),
    tabItem(tabName = "data",
            fluidPage(
              tabBox(
                id = 'box1',
                tabPanel("Tab1", plotlyOutput('plotMapGeo', height = 450)), 
                tabPanel("Tab2", plotlyOutput('plotPopGeo', height = 450)), width = 10  
              ),
              box(
                DT::dataTableOutput("table"), width = 12
              )
            )
    ),
    tabItem(tabName = 'charts',
            fluidRow(
              box(
                id = 'box2', 
                tabPanel("Tab2", plotlyOutput('plot2', height = 350)), width = 12
              ),
              box(
                sliderInput("slider", "Number of observations:", 1, 100, 50)
              ),
              box(
                width = 12, solidHeader = F,
                DT::dataTableOutput("table3")
              )
            )
    ),
    tabItem(tabName = 'code',
            fluidRow(
              tags$head(tags$style(HTML("
                                 .multicol { 
                                        height: auto;
                                        -webkit-column-count: 2; /* Chrome, Safari, Opera */ 
                                        -moz-column-count: 2;    /* Firefox */ 
                                        column-count: 2; 
                                        -webkit-column-fill: balance;
                                        -moz-column-fill: balance;
                                        -column-fill: balance;
                                        margin-top: 0px;
                                        margin-left: 0px;
                                        } 
                                        ")) 
              ),
              tabBox(
                tabPanel("Tab1", plotOutput('plot3', height = 550)), 
                tabPanel("Tab2", plotOutput('plot4', height = 550)),
                tabPanel("Tab3", plotOutput('plot5', height = 550)), width = 10  
              ),
             box(
               tags$div(align = 'left', 
                        class = 'multicol',
               checkboxGroupInput('checkbox', 'States',
               choices = c(choices), selected = c('CA', 'NY', 'TX', 'FL', 'IL', 'VA'), inline = T)
              ), width = 2),
             box(
               selectInput('select1', 'Select Item to Display', Diagnosis)
             )
            )
    ),
    tabItem(tabName = 'corr',
      fluidRow(
        box(
          plotOutput('correl', height = 600), width = 10)
          )
        ),
    tabItem(tabName = 'further',
            fluidPage(
              tags$pre(h2("\t Further Exploration.")),
      column(1,imageOutput("Pic2", height = 100, width = 100)),
      column(width = 4, offset = 7, h4('1. Assess trends in hospital price variation over time.'),
             h4('2. Measure inpatient hospital charge variability within the same area or city.'),
             h4('3. Evaluate characteristics of hospitals that charge higher rates compared to 
                actual Medicare reimbursement as well as characteristics of hospitals that charge less.'),
             h4('4. Try to explain the variability in hospital charges and examine its relationship to 
                population health measures.'))
    )
    )
      )
    )
   )
  )

